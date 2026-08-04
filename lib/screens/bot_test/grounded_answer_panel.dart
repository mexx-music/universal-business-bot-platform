import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../../ai/ai_controller.dart';
import '../../ai/ai_models.dart';
import '../../ai/ai_transport.dart';
import '../../ai/gemini_process_proposals.dart';
import '../../ai/grounded_answer_service.dart';
import '../../ai/grounded_question_strategy.dart';
import '../../ai/transports/edge_function_client.dart';
import '../../data/app_state.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/label_helpers.dart';
import '../../models/knowledge_entry.dart';
import '../../platform/external_link_opener.dart';

/// Localizable demo errors (machine-readable internally, mapped to a message
/// in [build] — never a raw stack trace).
enum _DemoError {
  config,
  network,
  timeout,
  rateLimit,
  blocked,
  server,
  generic,
}

/// The visible grounded-AI demo: question -> KnowledgeRuntime -> AiController
/// -> answer with sources and provider status. Knowledge retrieval lives in
/// [GroundedAnswerService], never in this widget.
class GroundedAnswerPanel extends StatefulWidget {
  const GroundedAnswerPanel({super.key, this.serviceOverride});

  /// Test seam: inject a service (with a fake AiController). Production builds
  /// one from the ambient [AiController] via [AiScope].
  final GroundedAnswerService? serviceOverride;

  @override
  State<GroundedAnswerPanel> createState() => _GroundedAnswerPanelState();
}

class _GroundedAnswerPanelState extends State<GroundedAnswerPanel> {
  final _controller = TextEditingController();
  bool _loading = false;
  GroundedAnswerResult? _result;
  _DemoError? _error;
  List<String> _geminiGapImprovementIds = const [];
  bool _geminiGapLoading = false;
  int _gapProposalRequest = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  GroundedAnswerService _service() {
    return widget.serviceOverride ??
        GroundedAnswerService(aiController: AiController.of(context));
  }

  Future<void> _submit() async {
    if (_loading) return; // prevent double trigger
    final question = _controller.text.trim();
    if (question.isEmpty) return;

    AppState.of(context).consumeRecentKnowledgeImportForGroundedAnswer();
    _gapProposalRequest++;

    setState(() {
      _loading = true;
      _error = null;
      _result = null;
      _geminiGapImprovementIds = const [];
      _geminiGapLoading = false;
    });

    try {
      final service = _service();
      final result = await service.answer(
        GroundedAnswerRequest(
          question: question,
          workspace: AppState.of(context).groundedAnswerWorkspace,
          language: Localizations.localeOf(context).languageCode,
        ),
      );
      if (!mounted) return;
      setState(() => _result = result);
      final hasGap =
          result.outcome == GroundedOutcome.noKnowledge ||
          (result.outcome == GroundedOutcome.answered &&
              result.coverage == GroundedEvidenceCoverage.partiallyAnswerable);
      if (hasGap && canRequestGeminiProposals(service.aiController)) {
        final proposalRequest = ++_gapProposalRequest;
        setState(() => _geminiGapLoading = true);
        unawaited(
          _loadGeminiGapProposals(
            service: service,
            question: question,
            result: result,
            request: proposalRequest,
          ),
        );
      }
    } on AiConfigurationException {
      if (!mounted) return;
      setState(() => _error = _DemoError.config);
    } on AiTransportException catch (e) {
      if (!mounted) return;
      setState(() => _error = _mapTransport(e.kind));
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = _DemoError.generic);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadGeminiGapProposals({
    required GroundedAnswerService service,
    required String question,
    required GroundedAnswerResult result,
    required int request,
  }) async {
    List<String> improvementIds = const [];
    try {
      final language = service.languageResolver.resolveQuestionLanguage(
        question,
        fallbackLanguage: Localizations.localeOf(context).languageCode,
      );
      final response = await service.aiController.generate(
        AiRequest(
          temperature: 0,
          maxTokens: 250,
          metadata: const {'feature': 'knowledge-gap-assistant'},
          messages: [
            AiMessage.system(
              'You identify which generic information types are missing from '
              'confirmed company knowledge. Do not answer the customer '
              'question. Do not add facts. Return JSON only as '
              '{"improvementIds": [...]}. Select only from: '
              '${geminiKnowledgeGapIds.join(', ')}. Use at most six IDs. '
              'Return an empty array when none is justified.',
            ),
            AiMessage.user(
              jsonEncode({
                'questionLanguage': language,
                'customerQuestion': question,
                'uncoveredTerms': result.missingTerms,
                'coverage': result.coverage.name,
              }),
            ),
          ],
        ),
      );
      improvementIds = parseGeminiKnowledgeGapIds(response);
    } catch (_) {
      // Existing deterministic knowledge-gap guidance remains visible.
    }
    if (!mounted || request != _gapProposalRequest) return;
    setState(() {
      _geminiGapImprovementIds = improvementIds;
      _geminiGapLoading = false;
    });
  }

  _DemoError _mapTransport(AiTransportErrorKind kind) {
    return switch (kind) {
      AiTransportErrorKind.configuration ||
      AiTransportErrorKind.unauthorized => _DemoError.config,
      AiTransportErrorKind.network => _DemoError.network,
      AiTransportErrorKind.timeout => _DemoError.timeout,
      AiTransportErrorKind.rateLimited => _DemoError.rateLimit,
      AiTransportErrorKind.contentBlocked => _DemoError.blocked,
      AiTransportErrorKind.server => _DemoError.server,
      AiTransportErrorKind.badRequest ||
      AiTransportErrorKind.badResponse ||
      AiTransportErrorKind.unknown => _DemoError.generic,
    };
  }

  String _errorText(AppLocalizations l, _DemoError e) => switch (e) {
    _DemoError.config => l.botDemoErrorConfig,
    _DemoError.network => l.botDemoErrorNetwork,
    _DemoError.timeout => l.botDemoErrorTimeout,
    _DemoError.rateLimit => l.botDemoErrorRateLimit,
    _DemoError.blocked => l.botDemoErrorBlocked,
    _DemoError.server => l.botDemoErrorServer,
    _DemoError.generic => l.botDemoError,
  };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final state = AppState.of(context);
    final canSubmit = !_loading && _controller.text.trim().isNotEmpty;

    return Card(
      margin: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l.botDemoTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              l.botDemoIntro,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            if (state.hasRecentKnowledgeImportForGroundedAnswer) ...[
              _RecentKnowledgeImportNotice(),
              const SizedBox(height: 12),
            ],
            TextField(
              key: const Key('grounded-question-field'),
              controller: _controller,
              autofocus: state.hasRecentKnowledgeImportForGroundedAnswer,
              minLines: 1,
              maxLines: 3,
              enabled: !_loading,
              textInputAction: TextInputAction.send,
              decoration: InputDecoration(
                labelText: l.botDemoQuestionHint,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: canSubmit ? _submit : null,
                icon: _loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send, size: 18),
                label: Text(_loading ? l.botDemoLoading : l.botDemoSubmit),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              _ErrorBox(message: _errorText(l, _error!), onRetry: _submit),
            ],
            if (_result != null) ...[
              const SizedBox(height: 12),
              _ResultView(
                result: _result!,
                geminiGapImprovementIds: _geminiGapImprovementIds,
                geminiGapLoading: _geminiGapLoading,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RecentKnowledgeImportNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      key: const Key('grounded-recent-import-notice'),
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.tertiary.withAlpha(90)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            color: theme.colorScheme.onTertiaryContainer,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.botDemoRecentImportTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onTertiaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  l.botDemoRecentImportBody,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onTertiaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({
    required this.result,
    required this.geminiGapImprovementIds,
    required this.geminiGapLoading,
  });

  final GroundedAnswerResult result;
  final List<String> geminiGapImprovementIds;
  final bool geminiGapLoading;

  @override
  Widget build(BuildContext context) {
    final answered = result.outcome == GroundedOutcome.answered;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _ProviderBadge(result: result),
            _GroundedChip(grounded: result.grounded),
            _CoverageChip(coverage: result.coverage),
          ],
        ),
        const SizedBox(height: 16),
        if (answered)
          ..._answeredBody(context)
        else
          _KnowledgeGapCard(result: result),
        if (geminiGapLoading || geminiGapImprovementIds.isNotEmpty) ...[
          const SizedBox(height: 12),
          _GeminiGapImprovementCard(
            improvementIds: geminiGapImprovementIds,
            loading: geminiGapLoading,
          ),
        ],
      ],
    );
  }

  List<Widget> _answeredBody(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return [
      _AnswerCard(answer: result.answer),
      if (result.websiteLinks.isNotEmpty) ...[
        const SizedBox(height: 16),
        _WebsiteLinksSection(links: result.websiteLinks),
      ],
      if (result.sources.isNotEmpty) ...[
        const SizedBox(height: 20),
        Text(
          l.botDemoSources,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        for (final s in result.sources) _SourceCard(source: s),
      ],
      const SizedBox(height: 12),
      _HumanReviewHint(),
    ];
  }
}

class _WebsiteLinksSection extends StatelessWidget {
  const _WebsiteLinksSection({required this.links});

  final List<KnowledgeEntryLink> links;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final primaryLinks = links.length <= 5 ? links : links.take(4).toList();
    final overflowLinks = links.length <= 5
        ? const <KnowledgeEntryLink>[]
        : links.skip(4).toList();
    return Container(
      key: const Key('grounded-website-links'),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withAlpha(120),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.language_outlined, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l.botDemoFurtherInfoTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l.botDemoFurtherInfoBody,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final link in primaryLinks) _WebsiteLinkButton(link: link),
              if (overflowLinks.isNotEmpty)
                MenuAnchor(
                  menuChildren: [
                    for (final link in overflowLinks)
                      MenuItemButton(
                        leadingIcon: Icon(link.type?.icon ?? Icons.open_in_new),
                        onPressed: () => openExternalLink(link.url.trim()),
                        child: Text(_websiteLinkLabel(context, link)),
                      ),
                  ],
                  builder: (context, controller, child) => OutlinedButton.icon(
                    key: const Key('grounded-more-website-links'),
                    onPressed: () => controller.isOpen
                        ? controller.close()
                        : controller.open(),
                    icon: const Icon(Icons.more_horiz),
                    label: Text(l.botDemoMoreLinks),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WebsiteLinkButton extends StatelessWidget {
  const _WebsiteLinkButton({required this.link});

  final KnowledgeEntryLink link;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      key: ValueKey('grounded-link-${link.url}'),
      onPressed: () => openExternalLink(link.url.trim()),
      icon: Icon(link.type?.icon ?? Icons.open_in_new, size: 18),
      label: Text(_websiteLinkLabel(context, link)),
    );
  }
}

String _websiteLinkLabel(BuildContext context, KnowledgeEntryLink link) {
  final title = link.title.trim();
  if (title.isNotEmpty) return title;
  final type = link.type;
  return type == null
      ? AppLocalizations.of(context)!.knowledgeLinkWebsite
      : knowledgeLinkTypeLabel(context, type);
}

/// Presentational card for a provider-generated answer. The wording is never
/// altered here — only the presentation is elevated.
class _AnswerCard extends StatelessWidget {
  const _AnswerCard({required this.answer});

  final String answer;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                l.botDemoAnswerTitle,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SelectableText(
            answer,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
          ),
        ],
      ),
    );
  }
}

/// Honest, value-adding rendering for the [GroundedOutcome.noKnowledge] and
/// [GroundedOutcome.blockedTopic] cases. Never invents facts: recommendations
/// are generic content-type suggestions, and the term chips come verbatim from
/// [GroundedAnswerResult.missingTerms].
class _GeminiGapImprovementCard extends StatelessWidget {
  const _GeminiGapImprovementCard({
    required this.improvementIds,
    required this.loading,
  });

  final List<String> improvementIds;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      key: const Key('grounded-gemini-gap-improvements'),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withAlpha(135),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 9,
            runSpacing: 7,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(Icons.auto_awesome, color: theme.colorScheme.secondary),
              Text(
                l.botGeminiGapTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  l.botGeminiProposalBadge,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(l.botGeminiGapBody),
          if (loading) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(minHeight: 5),
          ] else ...[
            const SizedBox(height: 12),
            for (final id in improvementIds)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      size: 18,
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(width: 7),
                    Expanded(child: Text(_gapImprovementLabel(l, id))),
                  ],
                ),
              ),
          ],
          const SizedBox(height: 8),
          Text(
            l.botGeminiReviewBeforeApplying,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

String _gapImprovementLabel(AppLocalizations l, String id) => switch (id) {
  'price' => l.botGeminiGapPrice,
  'productLink' => l.botGeminiGapProductLink,
  'validityDate' => l.botGeminiGapValidityDate,
  'contact' => l.botGeminiGapContact,
  'download' => l.botGeminiGapDownload,
  'requirements' => l.botGeminiGapRequirements,
  'compatibility' => l.botGeminiGapCompatibility,
  'instructions' => l.botGeminiGapInstructions,
  'troubleshooting' => l.botGeminiGapTroubleshooting,
  'policy' => l.botGeminiGapPolicy,
  _ => id,
};

class _KnowledgeGapCard extends StatelessWidget {
  const _KnowledgeGapCard({required this.result});

  final GroundedAnswerResult result;

  @override
  Widget build(BuildContext context) {
    final blocked = result.outcome == GroundedOutcome.blockedTopic;
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: blocked
            ? theme.colorScheme.errorContainer
            : theme.colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                blocked ? Icons.shield_outlined : Icons.lightbulb_outline,
                size: 20,
                color: blocked
                    ? theme.colorScheme.onErrorContainer
                    : theme.colorScheme.onTertiaryContainer,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  blocked ? l.botDemoBlocked : l.botDemoGapTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: blocked
                        ? theme.colorScheme.onErrorContainer
                        : theme.colorScheme.onTertiaryContainer,
                  ),
                ),
              ),
            ],
          ),
          // Blocked topics show only the safe handover message — never any
          // knowledge recommendations.
          if (!blocked) ..._gapBody(context, l, theme),
        ],
      ),
    );
  }

  List<Widget> _gapBody(
    BuildContext context,
    AppLocalizations l,
    ThemeData theme,
  ) {
    final onColor = theme.colorScheme.onTertiaryContainer;
    final recommendations = <String>[
      l.botDemoGapItemFaq,
      l.botDemoGapItemFeatures,
      l.botDemoGapItemGuide,
      l.botDemoGapItemSteps,
      l.botDemoGapItemScreenshots,
      l.botDemoGapItemRequirements,
    ];
    return [
      const SizedBox(height: 10),
      Text(
        l.botDemoNoKnowledge,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: onColor,
          height: 1.4,
        ),
      ),
      if (result.missingTerms.isNotEmpty) ...[
        const SizedBox(height: 12),
        Text(
          l.botDemoGapTermsLabel,
          style: theme.textTheme.labelMedium?.copyWith(
            color: onColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final term in result.missingTerms) _TermChip(term: term),
          ],
        ),
      ],
      const SizedBox(height: 14),
      Text(
        l.botDemoGapRecommendTitle,
        style: theme.textTheme.labelMedium?.copyWith(
          color: onColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 6),
      for (final item in recommendations) _Bullet(text: item, color: onColor),
      const SizedBox(height: 12),
      Text(
        l.botDemoGapClosing,
        style: theme.textTheme.bodySmall?.copyWith(color: onColor, height: 1.4),
      ),
    ];
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '•  ',
            style: theme.textTheme.bodyMedium?.copyWith(color: color),
          ),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _TermChip extends StatelessWidget {
  const _TermChip({required this.term});

  final String term;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withAlpha(160),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Text(term, style: theme.textTheme.labelSmall),
    );
  }
}

class _HumanReviewHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          Icons.verified_user_outlined,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            l.botDemoHumanReview,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProviderBadge extends StatelessWidget {
  const _ProviderBadge({required this.result});

  final GroundedAnswerResult result;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final label = result.isMock
        ? l.botDemoProviderMock
        : result.providerDisplayName;
    final model = (!result.isMock && result.model != null)
        ? ' · ${result.model}'
        : '';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${l.botDemoProviderLabel}: $label$model',
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }
}

class _GroundedChip extends StatelessWidget {
  const _GroundedChip({required this.grounded});

  final bool grounded;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final color = grounded ? Colors.green : theme.colorScheme.tertiary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            grounded ? Icons.menu_book_outlined : Icons.help_outline,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              grounded ? l.botDemoGrounded : l.botDemoNotGrounded,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoverageChip extends StatelessWidget {
  const _CoverageChip({required this.coverage});

  final GroundedEvidenceCoverage coverage;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final (label, color, icon) = switch (coverage) {
      GroundedEvidenceCoverage.fullyAnswerable => (
        l.botDemoCoverageFull,
        Colors.green,
        Icons.verified_outlined,
      ),
      GroundedEvidenceCoverage.partiallyAnswerable => (
        l.botDemoCoveragePartial,
        theme.colorScheme.tertiary,
        Icons.info_outline,
      ),
      GroundedEvidenceCoverage.notAnswerable => (
        l.botDemoCoverageNone,
        theme.colorScheme.error,
        Icons.help_outline,
      ),
      GroundedEvidenceCoverage.sensitiveReview => (
        l.botDemoCoverageSensitive,
        theme.colorScheme.error,
        Icons.health_and_safety_outlined,
      ),
    };
    return Container(
      key: const Key('grounded-coverage-status'),
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceCard extends StatelessWidget {
  const _SourceCard({required this.source});

  final GroundedSource source;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.description_outlined,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    source.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    knowledgeCategoryLabel(context, source.category),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              source.excerpt,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                size: 16,
                color: theme.colorScheme.onErrorContainer,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(onPressed: onRetry, child: Text(l.botDemoRetry)),
          ),
        ],
      ),
    );
  }
}
