import 'package:flutter/material.dart';

import '../../ai/ai_controller.dart';
import '../../ai/ai_transport.dart';
import '../../ai/grounded_answer_service.dart';
import '../../ai/grounded_question_strategy.dart';
import '../../ai/transports/edge_function_client.dart';
import '../../data/app_state.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/label_helpers.dart';

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

    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });

    try {
      final result = await _service().answer(
        GroundedAnswerRequest(
          question: question,
          workspace: AppState.of(context).groundedAnswerWorkspace,
          language: Localizations.localeOf(context).languageCode,
        ),
      );
      if (!mounted) return;
      setState(() => _result = result);
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
              _ResultView(result: _result!),
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
  const _ResultView({required this.result});

  final GroundedAnswerResult result;

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
      ],
    );
  }

  List<Widget> _answeredBody(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return [
      _AnswerCard(answer: result.answer),
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
