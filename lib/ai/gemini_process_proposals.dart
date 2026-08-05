import 'dart:convert';

import 'ai_controller.dart';
import 'ai_models.dart';
import 'ai_provider_id.dart';
import 'providers/mock_ai_provider.dart';

/// Returns true only for the real Gemini path. Offline mock providers never
/// masquerade as Gemini process assistance.
bool canRequestGeminiProposals(AiController? controller) {
  final provider = controller?.activeProvider;
  return provider != null &&
      provider.id == AiProviderId.googleGemini &&
      provider is! MockAiProvider;
}

/// A document-bound proposal shown alongside the deterministic Knowledge
/// Builder analysis. It is presentation data only and is never persisted.
class GeminiKnowledgeProposal {
  const GeminiKnowledgeProposal({
    required this.summary,
    required this.keyStatements,
    required this.recommendedFaq,
    required this.categories,
    required this.missingInformation,
    required this.possibleDuplicates,
    required this.employeeQuestions,
    required this.reviewSuggestions,
  });

  final String summary;
  final List<String> keyStatements;
  final List<String> recommendedFaq;
  final List<String> categories;
  final List<String> missingInformation;
  final List<String> possibleDuplicates;
  final List<String> employeeQuestions;
  final List<String> reviewSuggestions;

  bool get isEmpty =>
      summary.isEmpty &&
      keyStatements.isEmpty &&
      recommendedFaq.isEmpty &&
      categories.isEmpty &&
      missingInformation.isEmpty &&
      possibleDuplicates.isEmpty &&
      employeeQuestions.isEmpty &&
      reviewSuggestions.isEmpty;

  static GeminiKnowledgeProposal? fromResponse(AiResponse response) {
    if (response.providerId != AiProviderId.googleGemini ||
        response.finishReason == AiFinishReason.error ||
        response.finishReason == AiFinishReason.contentFilter) {
      return null;
    }
    final object = _decodeObject(response.text);
    if (object == null) return null;
    final proposal = GeminiKnowledgeProposal(
      summary: _safeString(object['summary'], maxChars: 520),
      keyStatements: _safeList(object['keyStatements']),
      recommendedFaq: _safeList(object['recommendedFaq']),
      categories: _safeList(object['categories'], maxItems: 5),
      missingInformation: _safeList(object['missingInformation']),
      possibleDuplicates: _safeList(object['possibleDuplicates']),
      employeeQuestions: _safeList(object['employeeQuestions']),
      reviewSuggestions: _safeList(object['reviewSuggestions']),
    );
    return proposal.isEmpty ? null : proposal;
  }
}

/// Gemini may only select from these generic information types. The UI owns
/// their localized wording, so a model response cannot introduce facts.
const geminiKnowledgeGapIds = <String>{
  'price',
  'productLink',
  'validityDate',
  'contact',
  'download',
  'requirements',
  'compatibility',
  'instructions',
  'troubleshooting',
  'policy',
};

List<String> parseGeminiKnowledgeGapIds(AiResponse response) {
  if (response.providerId != AiProviderId.googleGemini ||
      response.finishReason == AiFinishReason.error ||
      response.finishReason == AiFinishReason.contentFilter) {
    return const [];
  }
  final object = _decodeObject(response.text);
  final values = object?['improvementIds'];
  if (values is! List) return const [];
  final result = <String>[];
  for (final value in values) {
    final id = value is String ? value.trim() : '';
    if (geminiKnowledgeGapIds.contains(id) && !result.contains(id)) {
      result.add(id);
    }
    if (result.length == 6) break;
  }
  return List.unmodifiable(result);
}

/// Gemini's Operations contribution is restricted to selecting and ordering
/// already-proven deterministic insight IDs. The visible statements remain
/// backed by the existing rules and demo numbers.
List<String> parseGeminiOperationsInsightIds(
  AiResponse response, {
  required Set<String> allowedIds,
}) {
  if (response.providerId != AiProviderId.googleGemini ||
      response.finishReason == AiFinishReason.error ||
      response.finishReason == AiFinishReason.contentFilter) {
    return const [];
  }
  final object = _decodeObject(response.text);
  final values = object?['insightIds'];
  if (values is! List) return const [];
  final result = <String>[];
  for (final value in values) {
    final id = value is String ? value.trim() : '';
    if (allowedIds.contains(id) && !result.contains(id)) result.add(id);
    if (result.length == 5) break;
  }
  return List.unmodifiable(result);
}

Map<String, Object?>? _decodeObject(String raw) {
  var text = raw.trim();
  if (text.startsWith('```')) {
    text = text.replaceFirst(RegExp(r'^```(?:json)?\s*'), '');
    text = text.replaceFirst(RegExp(r'\s*```$'), '');
  }
  final start = text.indexOf('{');
  final end = text.lastIndexOf('}');
  if (start < 0 || end <= start) return null;
  try {
    final decoded = jsonDecode(text.substring(start, end + 1));
    if (decoded is! Map) return null;
    return decoded.map((key, value) => MapEntry(key.toString(), value));
  } on FormatException {
    return null;
  }
}

String _safeString(Object? value, {int maxChars = 260}) {
  if (value is! String) return '';
  final clean = value
      .replaceAll(RegExp(r'[\u0000-\u001f]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  if (clean.length <= maxChars) return clean;
  return '${clean.substring(0, maxChars - 1).trimRight()}…';
}

List<String> _safeList(Object? value, {int maxItems = 6, int maxChars = 260}) {
  if (value is! List) return const [];
  final result = <String>[];
  for (final item in value) {
    final clean = _safeString(item, maxChars: maxChars);
    if (clean.isNotEmpty && !result.contains(clean)) result.add(clean);
    if (result.length == maxItems) break;
  }
  return List.unmodifiable(result);
}
