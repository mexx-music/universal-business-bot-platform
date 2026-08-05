import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../ai/ai_controller.dart';
import '../../ai/ai_models.dart';
import '../../ai/gemini_process_proposals.dart';
import '../../demo_data/demo_data_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../operations/operations_demo.dart';
import '../../operations/operations_insight_rules.dart';

/// A transparent visualisation of deterministic demo operations data. Gemini
/// may prioritize already-proven weekly insights, but it never creates metrics,
/// tracks users, makes decisions or mutates company knowledge.
class OperationsDashboardScreen extends StatefulWidget {
  const OperationsDashboardScreen({super.key});

  @override
  State<OperationsDashboardScreen> createState() =>
      _OperationsDashboardScreenState();
}

class _OperationsDashboardScreenState extends State<OperationsDashboardScreen> {
  int _periodDays = 7;
  List<OperationsInsightKind> _geminiWeeklyInsights = const [];
  String? _weeklyRequestKey;

  AiController? get _ambientAiController =>
      context.dependOnInheritedWidgetOfExactType<AiScope>()?.notifier;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = _ambientAiController;
    final demoEnabled = DemoDataController.enabledOf(context);
    final language = Localizations.localeOf(context).languageCode;
    final requestKey =
        '${controller?.activeProviderId.name ?? 'none'}-$language-$demoEnabled';
    if (_weeklyRequestKey == requestKey) return;
    _weeklyRequestKey = requestKey;
    _geminiWeeklyInsights = const [];
    if (demoEnabled && canRequestGeminiProposals(controller)) {
      unawaited(
        _loadGeminiWeeklySummary(
          controller: controller!,
          language: language,
          requestKey: requestKey,
        ),
      );
    }
  }

  Future<void> _loadGeminiWeeklySummary({
    required AiController controller,
    required String language,
    required String requestKey,
  }) async {
    List<OperationsInsightKind> selected = const [];
    try {
      final available = OperationsInsightRules.evaluate();
      final allowedIds = available.map((insight) => insight.name).toSet();
      final recent = OperationsDemo.historyForDays(7);
      final previous = OperationsDemo.history
          .skip(OperationsDemo.history.length - 14)
          .take(7);
      final response = await controller.generate(
        AiRequest(
          temperature: 0,
          maxTokens: 220,
          metadata: const {'feature': 'operations-weekly-summary'},
          messages: [
            AiMessage.system(
              'You summarize only the supplied company operations data. Do '
              'not forecast, invent values or add claims. Select and order '
              'only the supplied proven insight IDs. Return JSON only as '
              '{"insightIds": [...]}. Use at most five IDs. The requested '
              'display language is $language.',
            ),
            AiMessage.user(
              jsonEncode({
                'allowedInsightIds': allowedIds.toList(),
                'today': {
                  'questions': OperationsDemo.today.questions,
                  'answered': OperationsDemo.today.answered,
                  'knowledgeGaps': OperationsDemo.today.knowledgeGaps,
                  'websiteRedirects': OperationsDemo.today.websiteRedirects,
                  'priceRedirects': OperationsDemo.priceRedirects,
                },
                'frequentProducts': [
                  for (final item in OperationsDemo.frequentProducts)
                    {'key': item.key, 'count': item.count},
                ],
                'searchedTopics': [
                  for (final item in OperationsDemo.searchedTopics)
                    {'key': item.key, 'count': item.count},
                ],
                'recentSupportQuestions': recent.fold<int>(
                  0,
                  (sum, day) => sum + day.supportQuestions,
                ),
                'previousSupportQuestions': previous.fold<int>(
                  0,
                  (sum, day) => sum + day.supportQuestions,
                ),
              }),
            ),
          ],
        ),
      );
      final ids = parseGeminiOperationsInsightIds(
        response,
        allowedIds: allowedIds,
      );
      selected = [
        for (final id in ids)
          OperationsInsightKind.values.firstWhere((kind) => kind.name == id),
      ];
    } catch (_) {
      // The existing deterministic insight block is the complete fallback.
    }
    if (!mounted || requestKey != _weeklyRequestKey) return;
    setState(() => _geminiWeeklyInsights = selected);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final demoEnabled = DemoDataController.enabledOf(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1240),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(l: l, theme: theme),
                  const SizedBox(height: 16),
                  if (!demoEnabled)
                    _DemoDisabledCard(l: l)
                  else ...[
                    const _DemoNotice(),
                    const SizedBox(height: 16),
                    const _TodayActivitySection(),
                    const SizedBox(height: 16),
                    _HistorySection(
                      periodDays: _periodDays,
                      onPeriodChanged: (value) {
                        if (value != null) {
                          setState(() => _periodDays = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    const _KnowledgeGrowthSection(),
                    const SizedBox(height: 16),
                    const _CustomerInsightsSection(),
                    const SizedBox(height: 16),
                    const _BusinessImpactSection(),
                    const SizedBox(height: 16),
                    const _KnowledgeQualitySection(),
                    const SizedBox(height: 16),
                    if (_geminiWeeklyInsights.isNotEmpty) ...[
                      _GeminiWeeklySummarySection(
                        insights: _geminiWeeklyInsights,
                      ),
                      const SizedBox(height: 16),
                    ],
                    const _BusinessInsightsSection(),
                    const SizedBox(height: 16),
                    const _HumanControlFooter(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.l, required this.theme});

  final AppLocalizations l;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.monitor_heart_outlined,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l.opTitle,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          l.opSubtitle,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _DemoBadge extends StatelessWidget {
  const _DemoBadge({this.onPrimary = false});

  final bool onPrimary;

  @override
  Widget build(BuildContext context) {
    if (!DemoDataController.enabledOf(context)) return const SizedBox.shrink();
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      key: const Key('operations-demo-badge'),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: onPrimary
            ? theme.colorScheme.onPrimaryContainer.withAlpha(36)
            : theme.colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        l.opDemoBadge,
        style: theme.textTheme.labelSmall?.copyWith(
          color: onPrimary
              ? theme.colorScheme.onPrimaryContainer
              : theme.colorScheme.onTertiaryContainer,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _DemoNotice extends StatelessWidget {
  const _DemoNotice();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      key: const Key('operations-demo-notice'),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer.withAlpha(130),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.science_outlined, color: theme.colorScheme.tertiary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l.opDemoNoticeTitle,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const _DemoBadge(),
                  ],
                ),
                const SizedBox(height: 4),
                Text(l.opDemoNoticeBody, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoDisabledCard extends StatelessWidget {
  const _DemoDisabledCard({required this.l});

  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      key: const Key('operations-demo-disabled'),
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.visibility_off_outlined, color: theme.colorScheme.primary),
          const SizedBox(height: 12),
          Text(
            l.opDemoDisabledTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(l.opDemoDisabledBody),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.keyName,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
    this.trailing,
  });

  final String keyName;
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      key: Key(keyName),
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const _DemoBadge(),
            ],
          ),
          if (trailing case final widget?) ...[
            const SizedBox(height: 12),
            Align(alignment: Alignment.centerRight, child: widget),
          ],
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _TodayActivitySection extends StatelessWidget {
  const _TodayActivitySection();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final day = OperationsDemo.today;
    final decimal = Localizations.localeOf(context).languageCode == 'de'
        ? day.averageResponseSeconds.toStringAsFixed(1).replaceFirst('.', ',')
        : day.averageResponseSeconds.toStringAsFixed(1);
    final metrics = <_MetricData>[
      _MetricData(
        Icons.mark_chat_read_outlined,
        '${day.answered}',
        l.opMetricAnswered,
      ),
      _MetricData(
        Icons.lightbulb_outline,
        '${day.knowledgeGaps}',
        l.opMetricGaps,
      ),
      _MetricData(
        Icons.how_to_reg_outlined,
        '${day.humanReviews}',
        l.opMetricReviews,
      ),
      _MetricData(
        Icons.library_add_outlined,
        '${day.newEntries}',
        l.opMetricEntriesAdopted,
      ),
      _MetricData(
        Icons.open_in_new,
        '${day.websiteRedirects}',
        l.opMetricRedirects,
      ),
      _MetricData(
        Icons.document_scanner_outlined,
        '${day.documentsAnalyzed}',
        l.opMetricDocumentsAnalyzed,
      ),
      _MetricData(
        Icons.speed_outlined,
        '$decimal ${l.opSecondsShort}',
        l.opMetricAvgResponseTime,
      ),
    ];
    return _SectionCard(
      keyName: 'operations-today-activity',
      icon: Icons.today_outlined,
      title: l.opActivityTitle,
      subtitle: l.opActivitySubtitle,
      child: _MetricGrid(metrics: metrics, large: true),
    );
  }
}

class _MetricData {
  const _MetricData(this.icon, this.value, this.label);

  final IconData icon;
  final String value;
  final String label;
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.metrics, this.large = false});

  final List<_MetricData> metrics;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 4
            : constraints.maxWidth >= 560
            ? 3
            : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: metrics.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            mainAxisExtent: large ? 132 : 116,
          ),
          itemBuilder: (context, index) =>
              _MetricTile(data: metrics[index], large: large),
        );
      },
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.data, required this.large});

  final _MetricData data;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(data.icon, size: 19, color: theme.colorScheme.primary),
          const Spacer(),
          Text(
            data.value,
            maxLines: 1,
            style:
                (large
                        ? theme.textTheme.headlineSmall
                        : theme.textTheme.titleLarge)
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
          ),
          const SizedBox(height: 2),
          Text(
            data.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(height: 1.2),
          ),
        ],
      ),
    );
  }
}

class _HistorySection extends StatelessWidget {
  const _HistorySection({
    required this.periodDays,
    required this.onPeriodChanged,
  });

  final int periodDays;
  final ValueChanged<int?> onPeriodChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final days = OperationsDemo.historyForDays(periodDays);
    final selector = SegmentedButton<int>(
      key: const Key('operations-period-selector'),
      segments: [
        ButtonSegment(value: 7, label: Text(l.opPeriod7)),
        ButtonSegment(value: 30, label: Text(l.opPeriod30)),
      ],
      selected: {periodDays},
      showSelectedIcon: false,
      onSelectionChanged: (selection) => onPeriodChanged(selection.first),
    );
    return _SectionCard(
      keyName: 'operations-history',
      icon: Icons.stacked_line_chart,
      title: l.opHistoryTitle,
      subtitle: l.opHistorySubtitle,
      trailing: selector,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final charts = [
            _HistoryChart(
              keyName: 'operations-answer-history-$periodDays',
              title: l.opHistoryAnswersTitle,
              firstLabel: l.opHistoryAnswered,
              secondLabel: l.opHistoryGaps,
              firstValues: days.map((day) => day.answered).toList(),
              secondValues: days.map((day) => day.knowledgeGaps).toList(),
              periodDays: periodDays,
            ),
            _HistoryChart(
              keyName: 'operations-knowledge-history-$periodDays',
              title: l.opHistoryKnowledgeTitle,
              firstLabel: l.opHistoryEntries,
              secondLabel: l.opHistoryRedirects,
              firstValues: days.map((day) => day.newEntries).toList(),
              secondValues: days.map((day) => day.websiteRedirects).toList(),
              periodDays: periodDays,
            ),
          ];
          if (constraints.maxWidth < 760) {
            return Column(
              children: [charts.first, const SizedBox(height: 12), charts.last],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: charts.first),
              const SizedBox(width: 12),
              Expanded(child: charts.last),
            ],
          );
        },
      ),
    );
  }
}

class _HistoryChart extends StatelessWidget {
  const _HistoryChart({
    required this.keyName,
    required this.title,
    required this.firstLabel,
    required this.secondLabel,
    required this.firstValues,
    required this.secondValues,
    required this.periodDays,
  });

  final String keyName;
  final String title;
  final String firstLabel;
  final String secondLabel;
  final List<int> firstValues;
  final List<int> secondValues;
  final int periodDays;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    return Semantics(
      label: '$title, $periodDays',
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 126,
              width: double.infinity,
              child: CustomPaint(
                key: Key(keyName),
                painter: _BarsPainter(
                  firstValues: firstValues,
                  secondValues: secondValues,
                  firstColor: theme.colorScheme.primary,
                  secondColor: theme.colorScheme.tertiary,
                  gridColor: theme.colorScheme.outlineVariant,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _LegendDot(color: theme.colorScheme.primary, label: firstLabel),
                const SizedBox(width: 12),
                _LegendDot(
                  color: theme.colorScheme.tertiary,
                  label: secondLabel,
                ),
                const Spacer(),
                Text(l.opHistoryToday, style: theme.textTheme.labelSmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _BarsPainter extends CustomPainter {
  const _BarsPainter({
    required this.firstValues,
    required this.secondValues,
    required this.firstColor,
    required this.secondColor,
    required this.gridColor,
  });

  final List<int> firstValues;
  final List<int> secondValues;
  final Color firstColor;
  final Color secondColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    final maxValue = math.max(
      1,
      [...firstValues, ...secondValues].reduce(math.max),
    );
    final gridPaint = Paint()
      ..color = gridColor.withAlpha(130)
      ..strokeWidth = 1;
    for (var line = 0; line <= 3; line++) {
      final y = size.height * line / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final groupWidth = size.width / firstValues.length;
    final barWidth = math.max(1.5, math.min(7.0, groupWidth * 0.28));
    final baseline = size.height;
    final firstPaint = Paint()..color = firstColor;
    final secondPaint = Paint()..color = secondColor;
    for (var index = 0; index < firstValues.length; index++) {
      final center = groupWidth * (index + 0.5);
      final firstHeight = size.height * firstValues[index] / maxValue;
      final secondHeight = size.height * secondValues[index] / maxValue;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            center - barWidth - 1,
            baseline - firstHeight,
            barWidth,
            firstHeight,
          ),
          const Radius.circular(2),
        ),
        firstPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            center + 1,
            baseline - secondHeight,
            barWidth,
            secondHeight,
          ),
          const Radius.circular(2),
        ),
        secondPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarsPainter oldDelegate) =>
      oldDelegate.firstValues != firstValues ||
      oldDelegate.secondValues != secondValues ||
      oldDelegate.firstColor != firstColor ||
      oldDelegate.secondColor != secondColor;
}

class _KnowledgeGrowthSection extends StatelessWidget {
  const _KnowledgeGrowthSection();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final data = OperationsDemo.knowledgeGrowth;
    return _SectionCard(
      keyName: 'operations-knowledge-growth',
      icon: Icons.psychology_alt_outlined,
      title: l.opGrowthTitle,
      subtitle: l.opGrowthSubtitle,
      child: _MetricGrid(
        metrics: [
          _MetricData(
            Icons.verified_outlined,
            '${data.confirmedEntries}',
            l.opGrowthConfirmed,
          ),
          _MetricData(Icons.quiz_outlined, '+${data.newFaq}', l.opGrowthFaq),
          _MetricData(
            Icons.inventory_2_outlined,
            '${data.productKnowledge}',
            l.opGrowthProduct,
          ),
          _MetricData(
            Icons.support_agent_outlined,
            '${data.supportKnowledge}',
            l.opGrowthSupport,
          ),
          _MetricData(
            Icons.description_outlined,
            '${data.documents}',
            l.opGrowthDocuments,
          ),
          _MetricData(Icons.sell_outlined, '${data.tags}', l.opGrowthTags),
        ],
      ),
    );
  }
}

class _CustomerInsightsSection extends StatelessWidget {
  const _CustomerInsightsSection();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final groups = [
      (
        l.opCustomerQuestions,
        OperationsDemo.frequentQuestions,
        Icons.question_answer_outlined,
      ),
      (
        l.opCustomerProducts,
        OperationsDemo.frequentProducts,
        Icons.inventory_2_outlined,
      ),
      (
        l.opCustomerGaps,
        OperationsDemo.openKnowledgeGaps,
        Icons.lightbulb_outline,
      ),
      (
        l.opCustomerTopics,
        OperationsDemo.searchedTopics,
        Icons.search_outlined,
      ),
      (
        l.opCustomerSupport,
        OperationsDemo.supportProblems,
        Icons.support_agent_outlined,
      ),
    ];
    return _SectionCard(
      keyName: 'operations-customer-insights',
      icon: Icons.manage_search_outlined,
      title: l.opCustomerTitle,
      subtitle: l.opCustomerSubtitle,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth >= 700
              ? (constraints.maxWidth - 12) / 2
              : constraints.maxWidth;
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final group in groups)
                SizedBox(
                  width: itemWidth,
                  child: _RankingBlock(
                    title: group.$1,
                    items: group.$2,
                    icon: group.$3,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _RankingBlock extends StatelessWidget {
  const _RankingBlock({
    required this.title,
    required this.items,
    required this.icon,
  });

  final String title;
  final List<OperationsRankedItem> items;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxValue = items.first.count;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final item in items.take(2))
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _rankedItemLabel(context, item.key),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${item.count}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      key: ValueKey('operations-ranking-${item.key}'),
                      value: item.count / maxValue,
                      minHeight: 6,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
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

String _rankedItemLabel(BuildContext context, String key) {
  final l = AppLocalizations.of(context)!;
  return switch (key) {
    'curebaseUsage' => l.opItemCurebaseUsage,
    'appConnection' => l.opItemAppConnection,
    'pricing' => l.opItemPricing,
    'curebase' => 'CureBase',
    'hbCureApp' => 'HB Cure App',
    'cureclip' => 'CureClip',
    'priceDetails' => l.opItemPriceDetails,
    'firmwareHelp' => l.opItemFirmwareHelp,
    'compatibility' => l.opItemCompatibility,
    'bluetooth' => 'Bluetooth',
    'firmware' => 'Firmware',
    'programs' => l.opItemPrograms,
    'bluetoothConnection' => l.opItemBluetoothConnection,
    'firmwareUpdate' => l.opItemFirmwareUpdate,
    'appPairing' => l.opItemAppPairing,
    _ => key,
  };
}

class _BusinessImpactSection extends StatelessWidget {
  const _BusinessImpactSection();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final minutes = OperationsDemo.estimatedMinutesSaved;
    final savedTime = l.opHoursMinutes(minutes ~/ 60, minutes % 60);
    return _SectionCard(
      keyName: 'operations-business-impact',
      icon: Icons.trending_up_outlined,
      title: l.opImpactTitle,
      subtitle: l.opImpactSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MetricGrid(
            metrics: [
              _MetricData(
                Icons.schedule_outlined,
                savedTime,
                l.opImpactTimeSaved,
              ),
              _MetricData(
                Icons.support_agent_outlined,
                '${OperationsDemo.avoidedSupportRequests}',
                l.opImpactAvoidedSupport,
              ),
              _MetricData(
                Icons.fact_check_outlined,
                '${OperationsDemo.consistentAnswers}',
                l.opImpactConsistent,
              ),
              _MetricData(
                Icons.source_outlined,
                '${OperationsDemo.today.sourcesUsed}',
                l.opImpactSources,
              ),
              _MetricData(
                Icons.how_to_reg_outlined,
                '${OperationsDemo.humanReviewRate} %',
                l.opImpactReviewRate,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoNote(icon: Icons.calculate_outlined, text: l.opImpactMethodNote),
        ],
      ),
    );
  }
}

class _KnowledgeQualitySection extends StatelessWidget {
  const _KnowledgeQualitySection();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final data = OperationsDemo.knowledgeQuality;
    return _SectionCard(
      keyName: 'operations-knowledge-quality',
      icon: Icons.health_and_safety_outlined,
      title: l.opKnowledgeQualityTitle,
      subtitle: l.opKnowledgeQualitySubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AnswerabilityBar(data: data),
          const SizedBox(height: 14),
          _MetricGrid(
            metrics: [
              _MetricData(
                Icons.check_circle_outline,
                '${data.fullyAnswerable}',
                l.opQualityFull,
              ),
              _MetricData(
                Icons.adjust_outlined,
                '${data.partlyAnswerable}',
                l.opQualityPartial,
              ),
              _MetricData(
                Icons.help_outline,
                '${data.noInformation}',
                l.opQualityMissing,
              ),
              _MetricData(
                Icons.medical_information_outlined,
                '${data.medicallySensitive}',
                l.opQualitySensitive,
              ),
              _MetricData(
                Icons.open_in_new,
                '${data.redirects}',
                l.opQualityRedirects,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnswerabilityBar extends StatelessWidget {
  const _AnswerabilityBar({required this.data});

  final KnowledgeQualityDemo data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      key: const Key('operations-answerability-chart'),
      borderRadius: BorderRadius.circular(7),
      child: SizedBox(
        height: 14,
        child: Row(
          children: [
            Expanded(
              flex: data.fullyAnswerable,
              child: ColoredBox(color: theme.colorScheme.primary),
            ),
            Expanded(
              flex: data.partlyAnswerable,
              child: ColoredBox(color: theme.colorScheme.tertiary),
            ),
            Expanded(
              flex: data.noInformation,
              child: ColoredBox(color: theme.colorScheme.error),
            ),
          ],
        ),
      ),
    );
  }
}

class _GeminiWeeklySummarySection extends StatelessWidget {
  const _GeminiWeeklySummarySection({required this.insights});

  final List<OperationsInsightKind> insights;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return _SectionCard(
      keyName: 'operations-gemini-weekly-summary',
      icon: Icons.auto_awesome,
      title: l.opGeminiWeeklyTitle,
      subtitle: l.opGeminiWeeklySubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            key: const Key('operations-gemini-summary-badge'),
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              l.opGeminiSummaryBadge,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (final insight in insights)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _InsightTile(content: _insightContent(l, insight)),
            ),
          _InfoNote(
            icon: Icons.verified_outlined,
            text: l.opGeminiConfirmedInformation,
          ),
          const SizedBox(height: 6),
          _InfoNote(icon: Icons.trending_flat, text: l.opGeminiNoForecasts),
        ],
      ),
    );
  }
}

class _BusinessInsightsSection extends StatelessWidget {
  const _BusinessInsightsSection();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final insights = OperationsInsightRules.evaluate();
    return _SectionCard(
      keyName: 'operations-business-insights',
      icon: Icons.lightbulb_circle_outlined,
      title: l.opInsightsTitle,
      subtitle: l.opInsightsSubtitle,
      child: Column(
        children: [
          for (final insight in insights)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _InsightTile(content: _insightContent(l, insight)),
            ),
          _InfoNote(icon: Icons.rule_outlined, text: l.opInsightsMethodNote),
        ],
      ),
    );
  }
}

({IconData icon, String title, String body}) _insightContent(
  AppLocalizations l,
  OperationsInsightKind kind,
) => switch (kind) {
  OperationsInsightKind.leadingProduct => (
    icon: Icons.inventory_2_outlined,
    title: l.opInsightLeadingTitle,
    body: l.opInsightLeadingBody(OperationsDemo.frequentProducts.first.count),
  ),
  OperationsInsightKind.risingSupport => (
    icon: Icons.trending_up,
    title: l.opInsightSupportTitle,
    body: l.opInsightSupportBody,
  ),
  OperationsInsightKind.firmwareDemand => (
    icon: Icons.system_update_alt,
    title: l.opInsightFirmwareTitle,
    body: l.opInsightFirmwareBody(
      OperationsDemo.searchedTopics
          .firstWhere((item) => item.key == 'firmware')
          .count,
    ),
  ),
  OperationsInsightKind.priceInterest => (
    icon: Icons.sell_outlined,
    title: l.opInsightPriceTitle,
    body: l.opInsightPriceBody(OperationsDemo.priceRedirects),
  ),
  OperationsInsightKind.faqOpportunity => (
    icon: Icons.quiz_outlined,
    title: l.opInsightFaqTitle,
    body: l.opInsightFaqBody(OperationsDemo.today.knowledgeGaps),
  ),
};

class _InsightTile extends StatelessWidget {
  const _InsightTile({required this.content});

  final ({IconData icon, String title, String body}) content;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withAlpha(90),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(content.icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(content.body, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoNote extends StatelessWidget {
  const _InfoNote({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _HumanControlFooter extends StatelessWidget {
  const _HumanControlFooter();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      key: const Key('operations-human-control'),
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.verified_user_outlined,
            color: theme.colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l.opClosingTitle,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const _DemoBadge(onPrimary: true),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  l.opClosingBody,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    height: 1.4,
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
