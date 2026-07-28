import 'package:flutter/material.dart';

import '../../ai/ai_controller.dart';
import '../../ai/ai_transport.dart';
import '../../ai/grounded_answer_service.dart';
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

    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });

    try {
      final result = await _service().answer(
        GroundedAnswerRequest(
          question: question,
          workspace: AppState.of(context).selectedWorkspace,
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
            TextField(
              controller: _controller,
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

class _ResultView extends StatelessWidget {
  const _ResultView({required this.result});

  final GroundedAnswerResult result;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

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
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.botDemoAnswerTitle,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(_answerText(l)),
            ],
          ),
        ),
        if (result.sources.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            l.botDemoSources,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          for (final s in result.sources) _SourceCard(source: s),
        ],
        const SizedBox(height: 10),
        Row(
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
        ),
      ],
    );
  }

  String _answerText(AppLocalizations l) {
    return switch (result.outcome) {
      GroundedOutcome.answered => result.answer,
      GroundedOutcome.noKnowledge => l.botDemoNoKnowledge,
      GroundedOutcome.blockedTopic => l.botDemoBlocked,
    };
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

class _SourceCard extends StatelessWidget {
  const _SourceCard({required this.source});

  final GroundedSource source;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    source.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  knowledgeCategoryLabel(context, source.category),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(source.excerpt, style: theme.textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
              source.id,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
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
