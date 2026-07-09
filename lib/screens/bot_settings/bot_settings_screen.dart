import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../../l10n/app_localizations.dart';
import '../../models/bot_configuration.dart';

class BotSettingsScreen extends StatelessWidget {
  const BotSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final config = state.botConfiguration;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            l.botSettingsTitle,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l.botSettingsSubtitle(state.company.name),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          _SettingsCard(
            title: l.botSettingsStatus,
            icon: Icons.power_settings_new_outlined,
            child: _SegmentedEnum<BotStatus>(
              value: config.status,
              values: BotStatus.values,
              label: (status) => botStatusLabel(l, status),
              onChanged: (status) =>
                  state.updateBotConfiguration(config.copyWith(status: status)),
            ),
          ),
          _SettingsCard(
            title: l.botSettingsAnswerStyle,
            icon: Icons.short_text_outlined,
            child: _SegmentedEnum<BotAnswerStyle>(
              value: config.answerStyle,
              values: BotAnswerStyle.values,
              label: (style) => answerStyleLabel(l, style),
              onChanged: (style) => state.updateBotConfiguration(
                config.copyWith(answerStyle: style),
              ),
            ),
          ),
          _SettingsCard(
            title: l.botSettingsLanguage,
            icon: Icons.translate_outlined,
            child: SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'de', label: Text(l.languageGerman)),
                ButtonSegment(value: 'en', label: Text(l.languageEnglish)),
              ],
              selected: {config.defaultLanguage},
              onSelectionChanged: (values) => state.updateBotConfiguration(
                config.copyWith(defaultLanguage: values.first),
              ),
            ),
          ),
          _SettingsCard(
            title: l.botSettingsDisclaimer,
            icon: Icons.info_outline,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l.botSettingsUseDisclaimer),
                  value: config.useDisclaimer,
                  onChanged: (value) => state.updateBotConfiguration(
                    config.copyWith(useDisclaimer: value),
                  ),
                ),
                const SizedBox(height: 8),
                _EditableTextBlock(
                  text: config.disclaimerText,
                  emptyText: l.botSettingsNoDisclaimer,
                  onEdit: () => _showTextDialog(
                    context,
                    title: l.botSettingsDisclaimerText,
                    initialValue: config.disclaimerText,
                    maxLines: 4,
                    onSave: (value) => state.updateBotConfiguration(
                      config.copyWith(disclaimerText: value.trim()),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _SettingsCard(
            title: l.botSettingsEscalation,
            icon: Icons.support_agent_outlined,
            child: Column(
              children: [
                _SwitchRow(
                  label: l.botSettingsEscalateRedFlags,
                  value: config.alwaysEscalateRedFlags,
                  onChanged: (value) => state.updateBotConfiguration(
                    config.copyWith(alwaysEscalateRedFlags: value),
                  ),
                ),
                _SwitchRow(
                  label: l.botSettingsEscalateNoMatch,
                  value: config.escalateNoMatch,
                  onChanged: (value) => state.updateBotConfiguration(
                    config.copyWith(escalateNoMatch: value),
                  ),
                ),
                _SwitchRow(
                  label: l.botSettingsEscalateYellowRisk,
                  value: config.escalateYellowRisk,
                  onChanged: (value) => state.updateBotConfiguration(
                    config.copyWith(escalateYellowRisk: value),
                  ),
                ),
                const SizedBox(height: 8),
                _EditableTextBlock(
                  text: config.handoverMessage,
                  emptyText: l.botSettingsNoHandover,
                  onEdit: () => _showTextDialog(
                    context,
                    title: l.botSettingsHandoverMessage,
                    initialValue: config.handoverMessage,
                    maxLines: 4,
                    onSave: (value) => state.updateBotConfiguration(
                      config.copyWith(handoverMessage: value.trim()),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _SettingsCard(
            title: l.botSettingsAllowedTopics,
            icon: Icons.check_circle_outline,
            child: _TopicListEditor(
              items: config.allowedTopics,
              emptyText: l.botSettingsNoAllowedTopics,
              onEdit: () => _showTextDialog(
                context,
                title: l.botSettingsAllowedTopics,
                initialValue: config.allowedTopics.join('\n'),
                maxLines: 8,
                onSave: (value) => state.updateBotConfiguration(
                  config.copyWith(allowedTopics: _lines(value)),
                ),
              ),
            ),
          ),
          _SettingsCard(
            title: l.botSettingsBlockedTopics,
            icon: Icons.block_outlined,
            child: _TopicListEditor(
              items: config.blockedTopics,
              emptyText: l.botSettingsNoBlockedTopics,
              onEdit: () => _showTextDialog(
                context,
                title: l.botSettingsBlockedTopics,
                initialValue: config.blockedTopics.join('\n'),
                maxLines: 8,
                onSave: (value) => state.updateBotConfiguration(
                  config.copyWith(blockedTopics: _lines(value)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SettingsCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _SegmentedEnum<T> extends StatelessWidget {
  final T value;
  final List<T> values;
  final String Function(T value) label;
  final ValueChanged<T> onChanged;

  const _SegmentedEnum({
    required this.value,
    required this.values,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<T>(
      segments: values
          .map(
            (value) => ButtonSegment(value: value, label: Text(label(value))),
          )
          .toList(),
      selected: {value},
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      value: value,
      onChanged: onChanged,
    );
  }
}

class _EditableTextBlock extends StatelessWidget {
  final String text;
  final String emptyText;
  final VoidCallback onEdit;

  const _EditableTextBlock({
    required this.text,
    required this.emptyText,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              text.trim().isEmpty ? emptyText : text,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: Text(l.btnEdit),
          ),
        ],
      ),
    );
  }
}

class _TopicListEditor extends StatelessWidget {
  final List<String> items;
  final String emptyText;
  final VoidCallback onEdit;

  const _TopicListEditor({
    required this.items,
    required this.emptyText,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (items.isEmpty)
          Text(emptyText)
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) => Chip(label: Text(item))).toList(),
          ),
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: Text(l.btnEdit),
        ),
      ],
    );
  }
}

void _showTextDialog(
  BuildContext context, {
  required String title,
  required String initialValue,
  required int maxLines,
  required ValueChanged<String> onSave,
}) {
  final controller = TextEditingController(text: initialValue);
  final l = AppLocalizations.of(context)!;
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 520,
        child: TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.btnCancel),
        ),
        FilledButton(
          onPressed: () {
            onSave(controller.text);
            Navigator.of(context).pop();
          },
          child: Text(l.btnSave),
        ),
      ],
    ),
  ).then((_) => controller.dispose());
}

List<String> _lines(String value) {
  return value
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();
}

String botStatusLabel(AppLocalizations l, BotStatus status) {
  return switch (status) {
    BotStatus.draft => l.botStatusDraft,
    BotStatus.testReady => l.botStatusTestReady,
    BotStatus.active => l.botStatusActive,
  };
}

String answerStyleLabel(AppLocalizations l, BotAnswerStyle style) {
  return switch (style) {
    BotAnswerStyle.short => l.botAnswerStyleShort,
    BotAnswerStyle.balanced => l.botAnswerStyleBalanced,
    BotAnswerStyle.detailed => l.botAnswerStyleDetailed,
  };
}
