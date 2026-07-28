import 'ai_controller.dart';
import 'ai_models.dart';
import 'ai_provider_id.dart';
import 'providers/mock_ai_provider.dart';
import '../models/company_workspace.dart';
import '../models/knowledge_entry.dart';
import '../runtime/knowledge_answer_context.dart';
import '../runtime/knowledge_runtime.dart';

/// Outcome of a grounded answer attempt.
/// - [answered]: usable knowledge was found and the provider produced an answer.
/// - [noKnowledge]: nothing relevant in the workspace — no AI call was made.
/// - [blockedTopic]: the question touches a sensitive/blocked topic — handover,
///   no AI call.
enum GroundedOutcome { answered, noKnowledge, blockedTopic }

enum GroundedAnswerError { emptyQuestion }

class GroundedAnswerException implements Exception {
  const GroundedAnswerException(this.kind);
  final GroundedAnswerError kind;
  @override
  String toString() => 'GroundedAnswerException(${kind.name})';
}

/// A source shown in the UI — comes ONLY from an actually-used knowledge entry,
/// never from free-form AI text.
class GroundedSource {
  const GroundedSource({
    required this.id,
    required this.title,
    required this.category,
    required this.excerpt,
  });

  final String id;
  final String title;
  final KnowledgeCategory category;
  final String excerpt;
}

class GroundedAnswerRequest {
  const GroundedAnswerRequest({
    required this.question,
    required this.workspace,
    required this.language,
    this.maxSources = 4,
  });

  final String question;
  final CompanyWorkspace workspace;

  /// ISO 639-1 code the answer should be written in ('de'/'en').
  final String language;
  final int maxSources;
}

class GroundedAnswerResult {
  const GroundedAnswerResult({
    required this.outcome,
    required this.providerId,
    required this.providerDisplayName,
    required this.isMock,
    this.answer = '',
    this.sources = const [],
    this.model,
    this.requestId,
  });

  final GroundedOutcome outcome;

  /// Provider-generated answer text (only meaningful when [grounded]).
  final String answer;

  /// Exactly the knowledge entries used to ground the answer.
  final List<GroundedSource> sources;

  final AiProviderId providerId;
  final String providerDisplayName;

  /// True when the active provider is the offline mock adapter.
  final bool isMock;

  final String? model;
  final String? requestId;

  bool get grounded => outcome == GroundedOutcome.answered;
  bool get usedKnowledge => outcome == GroundedOutcome.answered;
}

/// Orchestrates a grounded answer: BusinessBrain controls the context, the
/// rules and the output; the provider only formulates. Knowledge retrieval
/// happens here (never in the widget) via [KnowledgeRuntime]; the provider is
/// reached only through [AiController] (mock or Gemini). Provider errors are
/// never swallowed — they propagate to the caller.
class GroundedAnswerService {
  const GroundedAnswerService({
    required this.aiController,
    this.runtime = const KnowledgeRuntime(),
    this.maxEntryChars = 600,
    this.maxContextChars = 2400,
  });

  final AiController aiController;
  final KnowledgeRuntime runtime;
  final int maxEntryChars;
  final int maxContextChars;

  Future<GroundedAnswerResult> answer(GroundedAnswerRequest request) async {
    final question = request.question.trim();
    if (question.isEmpty) {
      throw const GroundedAnswerException(GroundedAnswerError.emptyQuestion);
    }

    final provider = aiController.activeProvider;
    if (provider == null) {
      // Programming error: no provider wired at all.
      throw StateError('No active AI provider');
    }
    final isMock = provider is MockAiProvider;

    GroundedAnswerResult nonGrounded(GroundedOutcome outcome) =>
        GroundedAnswerResult(
          outcome: outcome,
          providerId: provider.id,
          providerDisplayName: provider.displayName,
          isMock: isMock,
        );

    // Only the active company's knowledge is consulted (the workspace passed
    // in), through the runtime — no cross-tenant data, no full dump.
    final context = runtime.buildContext(
      userQuestion: question,
      workspace: request.workspace,
    );

    // Sensitive/blocked topics never reach the model — hand over to a human.
    if (context.blockedTopicHits.isNotEmpty || context.requiresHumanHandover) {
      return nonGrounded(GroundedOutcome.blockedTopic);
    }

    // Only green, actually-relevant entries, capped in count.
    final usable = <ScoredKnowledgeMatch>[
      for (final m in context.topEntries)
        if (!m.restricted && m.score > 0) m,
    ].take(request.maxSources).toList();

    // No usable knowledge -> honest "not found", and crucially NO AI call.
    if (usable.isEmpty) {
      return nonGrounded(GroundedOutcome.noKnowledge);
    }

    final sources = [
      for (final m in usable)
        GroundedSource(
          id: m.entry.id,
          title: m.entry.title,
          category: m.entry.category,
          excerpt: _excerpt(m.entry.content),
        ),
    ];

    final aiRequest = _buildRequest(question, request.language, usable);
    final response = await aiController.generate(aiRequest); // errors propagate

    return GroundedAnswerResult(
      outcome: GroundedOutcome.answered,
      answer: response.text.trim(),
      sources: sources,
      providerId: provider.id,
      providerDisplayName: provider.displayName,
      isMock: isMock,
      model: response.model,
      requestId: response.raw['requestId'] is String
          ? response.raw['requestId'] as String
          : null,
    );
  }

  AiRequest _buildRequest(
    String question,
    String language,
    List<ScoredKnowledgeMatch> usable,
  ) {
    final buffer = StringBuffer();
    var used = 0;
    for (var i = 0; i < usable.length; i++) {
      final entry = usable[i].entry;
      final snippet = _excerpt(entry.content);
      final block = '[${i + 1}] ${entry.title}\n$snippet\n';
      if (used + block.length > maxContextChars) break;
      buffer.write(block);
      used += block.length;
    }

    final system =
        'You are BusinessBrain, a support assistant for a company. '
        'Answer ONLY using the provided company knowledge below. '
        'Do not invent facts and do not claim to use a source that was not '
        'provided. If the knowledge is insufficient, say clearly that the '
        'information was not found in the knowledge base. Give no medical, '
        'legal or financial guarantees. Do not claim to publish anything or '
        'take any external action. Answer in "$language". Be clear and concise.';

    final user =
        'Question: $question\n\n'
        'Company knowledge:\n${buffer.toString().trim()}';

    return AiRequest(
      messages: [AiMessage.system(system), AiMessage.user(user)],
      metadata: {'feature': 'grounded_bot_demo'},
    );
  }

  String _excerpt(String content) {
    final normalized = content.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.length <= maxEntryChars) return normalized;
    return '${normalized.substring(0, maxEntryChars).trimRight()}…';
  }
}
