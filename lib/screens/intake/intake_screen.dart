import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/app_state.dart';
import '../../l10n/app_localizations.dart';
import '../../models/intake_mapping_preview.dart';
import '../../models/intake_session.dart';

class IntakeScreen extends StatefulWidget {
  const IntakeScreen({super.key});

  @override
  State<IntakeScreen> createState() => _IntakeScreenState();
}

class _IntakeScreenState extends State<IntakeScreen> {
  final Map<String, TextEditingController> _controllers = {};
  bool _initialized = false;
  int _stepIndex = 0;
  IntakeMappingPreview? _mappingPreview;

  static const _stepCount = 7;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final state = AppState.of(context);
    final session = state.selectedIntakeSession;
    if (session == null) {
      _initialized = true;
      return;
    }
    _stepIndex = session.currentStepIndex.clamp(0, _stepCount);
    _seedControllers(session);
    _initialized = true;
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final session = state.selectedIntakeSession;

    if (session == null) {
      return Scaffold(
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              l.intakeTitle,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l.intakeSubtitle(state.company.name),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.dashboardRecommendationIntakeTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(l.dashboardRecommendationIntakeDescription),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => _startIntake(state),
                      icon: const Icon(Icons.assignment_outlined),
                      label: Text(l.dashboardRecommendationIntakeTitle),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        state.startOrResumeIntake();
                        context.go('/intake-chat');
                      },
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: Text(l.intakeChatStart),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    final showingSummary = _stepIndex >= _stepCount;
    final progress = showingSummary ? 1.0 : (_stepIndex + 1) / _stepCount;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            l.intakeTitle,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l.intakeSubtitle(state.company.name),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          showingSummary
                              ? l.intakeSummaryTitle
                              : l.intakeStepOfTotal(_stepIndex + 1, _stepCount),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _StatusBadge(status: session.status),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      minHeight: 9,
                      value: progress,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _StepNavigation(
                    selectedIndex: _stepIndex,
                    onSelected: (index) => _goToStep(state, index),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => context.go('/intake-chat'),
                        icon: const Icon(Icons.chat_bubble_outline, size: 18),
                        label: Text(
                          session.chatStartedAt == null
                              ? l.intakeChatStart
                              : l.intakeChatResume,
                        ),
                      ),
                      Text(
                        l.intakeChatSharedDataHint,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          if (_mappingPreview != null)
            _MappingPreviewView(
              preview: _mappingPreview!,
              onSelectionChanged: (id, selected) {
                setState(() {
                  _mappingPreview = _mappingPreview!.copyWithSuggestionSelected(
                    id,
                    selected,
                  );
                });
              },
              onImport: () => _confirmImport(state),
              onBack: () => setState(() => _mappingPreview = null),
            )
          else if (showingSummary)
            _SummaryView(
              session: session,
              onComplete: () => _complete(state),
              onPrepareImport: () => _prepareImport(state),
            )
          else
            _StepForm(
              stepIndex: _stepIndex,
              controller: _controller,
              onChanged: () => _saveCurrentStep(state),
            ),
          const SizedBox(height: 18),
          _FooterActions(
            showingSummary: showingSummary || _mappingPreview != null,
            canGoBack: _stepIndex > 0,
            onBack: () => _goToStep(state, _stepIndex - 1),
            onSaveDraft: () => _saveDraft(state),
            onNext: () => _goToStep(state, _stepIndex + 1),
          ),
        ],
      ),
    );
  }

  TextEditingController _controller(String key) {
    return _controllers.putIfAbsent(key, TextEditingController.new);
  }

  void _seed(String key, String value) {
    _controller(key).text = value;
  }

  void _seedControllers(IntakeSession session) {
    final b = session.basics;
    _seed('companyName', b.companyName);
    _seed('shortDescription', b.shortDescription);
    _seed('industry', b.industry);
    _seed('country', b.country);
    _seed('primaryLanguage', b.primaryLanguage);
    _seed('website', b.website);
    _seed('supportEmail', b.supportEmail);
    _seed('supportPhone', b.supportPhone);

    final p = session.products;
    _seed('importantProducts', p.importantProducts);
    _seed('mainProduct', p.mainProduct);
    _seed('explanationNeeded', p.explanationNeeded);
    _seed('priorityProducts', p.priorityProducts);

    final t = session.targetGroups;
    _seed('targetGroup', t.targetGroup);
    _seed('marketType', t.marketType);
    _seed('problemSolved', t.problemSolved);
    _seed('customerBenefit', t.customerBenefit);
    _seed('differentiation', t.differentiation);

    final w = session.websiteAndSupport;
    _seed('importantPages', w.importantPages);
    _seed('frequentQuestions', w.frequentQuestions);
    _seed('supportProblems', w.supportProblems);
    _seed('sensitiveTopics', w.sensitiveTopics);

    final s = session.sourcesAndReviews;
    _seed('existingSources', s.existingSources);
    _seed('reviews', s.reviews);
    _seed('socialMentions', s.socialMentions);
    _seed('trustMaterial', s.trustMaterial);

    final m = session.marketingAndChannels;
    _seed('channels', m.channels);
    _seed('campaigns', m.campaigns);
    _seed('worked', m.worked);
    _seed('notWorked', m.notWorked);
    _seed('reachProblems', m.reachProblems);

    final g = session.goalsAndRisks;
    _seed('companyGoals', g.companyGoals);
    _seed('shortTermPriorities', g.shortTermPriorities);
    _seed('forbiddenClaims', g.forbiddenClaims);
    _seed('botRestrictedTopics', g.botRestrictedTopics);
  }

  String _text(String key) => _controller(key).text.trim();

  void _saveCurrentStep(AppState state) {
    switch (_stepIndex) {
      case 0:
        state.updateIntakeBasics(
          IntakeBasics(
            companyName: _text('companyName'),
            shortDescription: _text('shortDescription'),
            industry: _text('industry'),
            country: _text('country'),
            primaryLanguage: _text('primaryLanguage'),
            website: _text('website'),
            supportEmail: _text('supportEmail'),
            supportPhone: _text('supportPhone'),
          ),
        );
      case 1:
        state.updateIntakeProducts(
          IntakeProducts(
            importantProducts: _text('importantProducts'),
            mainProduct: _text('mainProduct'),
            explanationNeeded: _text('explanationNeeded'),
            priorityProducts: _text('priorityProducts'),
          ),
        );
      case 2:
        state.updateIntakeTargetGroups(
          IntakeTargetGroups(
            targetGroup: _text('targetGroup'),
            marketType: _text('marketType'),
            problemSolved: _text('problemSolved'),
            customerBenefit: _text('customerBenefit'),
            differentiation: _text('differentiation'),
          ),
        );
      case 3:
        state.updateIntakeWebsiteAndSupport(
          IntakeWebsiteAndSupport(
            importantPages: _text('importantPages'),
            frequentQuestions: _text('frequentQuestions'),
            supportProblems: _text('supportProblems'),
            sensitiveTopics: _text('sensitiveTopics'),
          ),
        );
      case 4:
        state.updateIntakeSourcesAndReviews(
          IntakeSourcesAndReviews(
            existingSources: _text('existingSources'),
            reviews: _text('reviews'),
            socialMentions: _text('socialMentions'),
            trustMaterial: _text('trustMaterial'),
          ),
        );
      case 5:
        state.updateIntakeMarketingAndChannels(
          IntakeMarketingAndChannels(
            channels: _text('channels'),
            campaigns: _text('campaigns'),
            worked: _text('worked'),
            notWorked: _text('notWorked'),
            reachProblems: _text('reachProblems'),
          ),
        );
      case 6:
        state.updateIntakeGoalsAndRisks(
          IntakeGoalsAndRisks(
            companyGoals: _text('companyGoals'),
            shortTermPriorities: _text('shortTermPriorities'),
            forbiddenClaims: _text('forbiddenClaims'),
            botRestrictedTopics: _text('botRestrictedTopics'),
          ),
        );
    }
  }

  void _goToStep(AppState state, int stepIndex) {
    if (_stepIndex < _stepCount) {
      _saveCurrentStep(state);
    }
    final next = stepIndex.clamp(0, _stepCount);
    state.setIntakeStep(next);
    setState(() => _stepIndex = next);
  }

  void _saveDraft(AppState state) {
    final l = AppLocalizations.of(context)!;
    if (_stepIndex < _stepCount) {
      _saveCurrentStep(state);
    }
    state.setIntakeStep(_stepIndex);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l.intakeDraftSaved)));
  }

  void _complete(AppState state) {
    state.completeIntake();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.intakeCompleted)),
    );
  }

  void _prepareImport(AppState state) {
    setState(() => _mappingPreview = state.generateIntakeMappingPreview());
  }

  void _confirmImport(AppState state) {
    final preview = _mappingPreview;
    if (preview == null) return;
    final l = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.intakeImportConfirmTitle),
        content: Text(l.intakeImportConfirmDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l.btnCancel),
          ),
          FilledButton(
            onPressed: () {
              state.importSelectedIntakeMapping(preview);
              Navigator.of(context).pop();
              setState(() => _mappingPreview = null);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l.intakeImportSuccess)));
            },
            child: Text(l.intakeImportSelected),
          ),
        ],
      ),
    );
  }

  void _startIntake(AppState state) {
    final session = state.startOrResumeIntake();
    _seedControllers(session);
    setState(() => _stepIndex = session.currentStepIndex);
  }
}

class _StepNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _StepNavigation({
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final labels = _stepTitles(AppLocalizations.of(context)!);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            ChoiceChip(
              label: Text(labels[i]),
              selected: selectedIndex == i,
              onSelected: (_) => onSelected(i),
            ),
            const SizedBox(width: 8),
          ],
          ChoiceChip(
            label: Text(AppLocalizations.of(context)!.intakeSummaryTitle),
            selected: selectedIndex >= labels.length,
            onSelected: (_) => onSelected(labels.length),
          ),
        ],
      ),
    );
  }
}

class _StepForm extends StatelessWidget {
  final int stepIndex;
  final TextEditingController Function(String key) controller;
  final VoidCallback onChanged;

  const _StepForm({
    required this.stepIndex,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final title = _stepTitles(l)[stepIndex];
    final description = _stepDescriptions(l)[stepIndex];
    final fields = _fieldsForStep(l, stepIndex);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),
            ...fields.map(
              (field) => _IntakeField(
                label: field.label,
                controller: controller(field.key),
                maxLines: field.maxLines,
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntakeField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;
  final VoidCallback onChanged;

  const _IntakeField({
    required this.label,
    required this.controller,
    required this.maxLines,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        onChanged: (_) => onChanged(),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }
}

class _FooterActions extends StatelessWidget {
  final bool showingSummary;
  final bool canGoBack;
  final VoidCallback onBack;
  final VoidCallback onSaveDraft;
  final VoidCallback onNext;

  const _FooterActions({
    required this.showingSummary,
    required this.canGoBack,
    required this.onBack,
    required this.onSaveDraft,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.end,
      children: [
        OutlinedButton.icon(
          onPressed: canGoBack ? onBack : null,
          icon: const Icon(Icons.arrow_back),
          label: Text(l.btnBack),
        ),
        OutlinedButton.icon(
          onPressed: onSaveDraft,
          icon: const Icon(Icons.save_outlined),
          label: Text(l.intakeSaveDraft),
        ),
        if (!showingSummary)
          FilledButton.icon(
            onPressed: onNext,
            icon: const Icon(Icons.arrow_forward),
            label: Text(l.btnNext),
          ),
      ],
    );
  }
}

class _SummaryView extends StatelessWidget {
  final IntakeSession session;
  final VoidCallback onComplete;
  final VoidCallback onPrepareImport;

  const _SummaryView({
    required this.session,
    required this.onComplete,
    required this.onPrepareImport,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l.intakeSummaryNotice,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _SummarySection(
          title: l.intakeStepBasicsTitle,
          rows: [
            (l.fieldCompanyName, session.basics.companyName),
            (l.fieldDescription, session.basics.shortDescription),
            (l.fieldIndustry, session.basics.industry),
            (l.fieldCountry, session.basics.country),
            (l.fieldPrimaryLanguage, session.basics.primaryLanguage),
            (l.fieldWebsite, session.basics.website),
            (l.fieldSupportEmail, session.basics.supportEmail),
            (l.fieldSupportPhone, session.basics.supportPhone),
          ],
        ),
        _SummarySection(
          title: l.intakeStepProductsTitle,
          rows: [
            (l.intakeImportantProducts, session.products.importantProducts),
            (l.intakeMainProduct, session.products.mainProduct),
            (l.intakeExplanationNeeded, session.products.explanationNeeded),
            (l.intakePriorityProducts, session.products.priorityProducts),
          ],
        ),
        _SummarySection(
          title: l.intakeStepTargetGroupsTitle,
          rows: [
            (l.intakeTargetGroup, session.targetGroups.targetGroup),
            (l.intakeMarketType, session.targetGroups.marketType),
            (l.intakeProblemSolved, session.targetGroups.problemSolved),
            (l.intakeCustomerBenefit, session.targetGroups.customerBenefit),
            (l.intakeDifferentiation, session.targetGroups.differentiation),
          ],
        ),
        _SummarySection(
          title: l.intakeStepWebsiteSupportTitle,
          rows: [
            (l.intakeImportantPages, session.websiteAndSupport.importantPages),
            (
              l.intakeFrequentQuestions,
              session.websiteAndSupport.frequentQuestions,
            ),
            (
              l.intakeSupportProblems,
              session.websiteAndSupport.supportProblems,
            ),
            (
              l.intakeSensitiveTopics,
              session.websiteAndSupport.sensitiveTopics,
            ),
          ],
        ),
        _SummarySection(
          title: l.intakeStepSourcesReviewsTitle,
          rows: [
            (
              l.intakeExistingSources,
              session.sourcesAndReviews.existingSources,
            ),
            (l.intakeReviews, session.sourcesAndReviews.reviews),
            (l.intakeSocialMentions, session.sourcesAndReviews.socialMentions),
            (l.intakeTrustMaterial, session.sourcesAndReviews.trustMaterial),
          ],
        ),
        _SummarySection(
          title: l.intakeStepMarketingTitle,
          rows: [
            (l.intakeChannels, session.marketingAndChannels.channels),
            (l.intakeCampaigns, session.marketingAndChannels.campaigns),
            (l.intakeWorked, session.marketingAndChannels.worked),
            (l.intakeNotWorked, session.marketingAndChannels.notWorked),
            (l.intakeReachProblems, session.marketingAndChannels.reachProblems),
          ],
        ),
        _SummarySection(
          title: l.intakeStepGoalsRisksTitle,
          rows: [
            (l.intakeCompanyGoals, session.goalsAndRisks.companyGoals),
            (
              l.intakeShortTermPriorities,
              session.goalsAndRisks.shortTermPriorities,
            ),
            (l.intakeForbiddenClaims, session.goalsAndRisks.forbiddenClaims),
            (
              l.intakeBotRestrictedTopics,
              session.goalsAndRisks.botRestrictedTopics,
            ),
          ],
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerRight,
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: onPrepareImport,
                icon: const Icon(Icons.move_down_outlined),
                label: Text(l.intakePrepareImport),
              ),
              FilledButton.icon(
                onPressed: session.status == IntakeStatus.completed
                    ? null
                    : onComplete,
                icon: const Icon(Icons.check_circle_outline),
                label: Text(l.intakeMarkCompleted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MappingPreviewView extends StatelessWidget {
  final IntakeMappingPreview preview;
  final void Function(String id, bool selected) onSelectionChanged;
  final VoidCallback onImport;
  final VoidCallback onBack;

  const _MappingPreviewView({
    required this.preview,
    required this.onSelectionChanged,
    required this.onImport,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final selectedCount = preview.suggestions
        .where((suggestion) => suggestion.selected)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.intakeMappingPreviewTitle,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(l.intakeMappingPreviewDescription),
                if (preview.warnings.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ...preview.warnings.map(
                    (_) => _WarningLine(text: l.intakeMappingConflictWarning),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (final area in IntakeMappingTargetArea.values)
          _MappingAreaCard(
            area: area,
            suggestions: preview.suggestionsFor(area),
            onSelectionChanged: onSelectionChanged,
          ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.end,
          children: [
            OutlinedButton.icon(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back),
              label: Text(l.btnBack),
            ),
            FilledButton.icon(
              onPressed: selectedCount == 0 ? null : onImport,
              icon: const Icon(Icons.download_done_outlined),
              label: Text(l.intakeImportSelected),
            ),
          ],
        ),
      ],
    );
  }
}

class _MappingAreaCard extends StatelessWidget {
  final IntakeMappingTargetArea area;
  final List<IntakeMappingSuggestion> suggestions;
  final void Function(String id, bool selected) onSelectionChanged;

  const _MappingAreaCard({
    required this.area,
    required this.suggestions,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _mappingAreaLabel(l, area),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ...suggestions.map(
              (suggestion) => _MappingSuggestionTile(
                suggestion: suggestion,
                onChanged: (selected) =>
                    onSelectionChanged(suggestion.id, selected),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MappingSuggestionTile extends StatelessWidget {
  final IntakeMappingSuggestion suggestion;
  final ValueChanged<bool> onChanged;

  const _MappingSuggestionTile({
    required this.suggestion,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: suggestion.conflict
            ? Colors.orange.withAlpha(18)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: suggestion.conflict
              ? Colors.orange.withAlpha(90)
              : theme.colorScheme.outlineVariant,
        ),
      ),
      child: CheckboxListTile(
        value: suggestion.selected,
        onChanged: (value) => onChanged(value ?? false),
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        title: Row(
          children: [
            Expanded(
              child: Text(
                _suggestionLabel(l, suggestion),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (suggestion.conflict) _MiniWarningBadge(label: l.intakeConflict),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (suggestion.currentValue != null)
                _PreviewValue(
                  label: l.intakeCurrentValue,
                  value: suggestion.currentValue!,
                ),
              _PreviewValue(
                label: l.intakeProposedValue,
                value: suggestion.proposedValue.isEmpty
                    ? l.intakeKnowledgeDraftEmpty
                    : suggestion.proposedValue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewValue extends StatelessWidget {
  final String label;
  final String value;

  const _PreviewValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: theme.textTheme.bodySmall,
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

class _MiniWarningBadge extends StatelessWidget {
  final String label;

  const _MiniWarningBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.orange.withAlpha(25),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.orange.shade800,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _WarningLine extends StatelessWidget {
  final String text;

  const _WarningLine({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.warning_amber_outlined,
          color: Colors.orange,
          size: 16,
        ),
        const SizedBox(width: 6),
        Expanded(child: Text(text)),
      ],
    );
  }
}

class _SummarySection extends StatelessWidget {
  final String title;
  final List<(String, String)> rows;

  const _SummarySection({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ...rows.map((row) => _SummaryRow(label: row.$1, value: row.$2)),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cleanValue = value.trim();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium),
          const SizedBox(height: 2),
          Text(
            cleanValue.isEmpty
                ? AppLocalizations.of(context)!.intakeNoAnswer
                : cleanValue,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cleanValue.isEmpty
                  ? theme.colorScheme.onSurfaceVariant
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final IntakeStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final color = switch (status) {
      IntakeStatus.draft => Colors.grey,
      IntakeStatus.inProgress => Colors.orange,
      IntakeStatus.completed => Colors.green,
    };
    return Chip(
      avatar: Icon(_statusIcon(status), size: 16, color: color),
      label: Text(_statusLabel(l, status)),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w600),
      side: BorderSide(color: color.withAlpha(80)),
    );
  }
}

class _FieldDef {
  final String key;
  final String label;
  final int maxLines;

  const _FieldDef(this.key, this.label, {this.maxLines = 1});
}

List<String> _stepTitles(AppLocalizations l) => [
  l.intakeStepBasicsTitle,
  l.intakeStepProductsTitle,
  l.intakeStepTargetGroupsTitle,
  l.intakeStepWebsiteSupportTitle,
  l.intakeStepSourcesReviewsTitle,
  l.intakeStepMarketingTitle,
  l.intakeStepGoalsRisksTitle,
];

List<String> _stepDescriptions(AppLocalizations l) => [
  l.intakeStepBasicsDescription,
  l.intakeStepProductsDescription,
  l.intakeStepTargetGroupsDescription,
  l.intakeStepWebsiteSupportDescription,
  l.intakeStepSourcesReviewsDescription,
  l.intakeStepMarketingDescription,
  l.intakeStepGoalsRisksDescription,
];

List<_FieldDef> _fieldsForStep(AppLocalizations l, int stepIndex) {
  return switch (stepIndex) {
    0 => [
      _FieldDef('companyName', l.fieldCompanyName),
      _FieldDef('shortDescription', l.fieldDescription, maxLines: 3),
      _FieldDef('industry', l.fieldIndustry),
      _FieldDef('country', l.fieldCountry),
      _FieldDef('primaryLanguage', l.fieldPrimaryLanguage),
      _FieldDef('website', l.fieldWebsite),
      _FieldDef('supportEmail', l.fieldSupportEmail),
      _FieldDef('supportPhone', l.fieldSupportPhone),
    ],
    1 => [
      _FieldDef('importantProducts', l.intakeImportantProducts, maxLines: 4),
      _FieldDef('mainProduct', l.intakeMainProduct, maxLines: 2),
      _FieldDef('explanationNeeded', l.intakeExplanationNeeded, maxLines: 4),
      _FieldDef('priorityProducts', l.intakePriorityProducts, maxLines: 3),
    ],
    2 => [
      _FieldDef('targetGroup', l.intakeTargetGroup, maxLines: 3),
      _FieldDef('marketType', l.intakeMarketType),
      _FieldDef('problemSolved', l.intakeProblemSolved, maxLines: 3),
      _FieldDef('customerBenefit', l.intakeCustomerBenefit, maxLines: 3),
      _FieldDef('differentiation', l.intakeDifferentiation, maxLines: 3),
    ],
    3 => [
      _FieldDef('importantPages', l.intakeImportantPages, maxLines: 3),
      _FieldDef('frequentQuestions', l.intakeFrequentQuestions, maxLines: 4),
      _FieldDef('supportProblems', l.intakeSupportProblems, maxLines: 4),
      _FieldDef('sensitiveTopics', l.intakeSensitiveTopics, maxLines: 3),
    ],
    4 => [
      _FieldDef('existingSources', l.intakeExistingSources, maxLines: 4),
      _FieldDef('reviews', l.intakeReviews, maxLines: 3),
      _FieldDef('socialMentions', l.intakeSocialMentions, maxLines: 3),
      _FieldDef('trustMaterial', l.intakeTrustMaterial, maxLines: 3),
    ],
    5 => [
      _FieldDef('channels', l.intakeChannels, maxLines: 3),
      _FieldDef('campaigns', l.intakeCampaigns, maxLines: 3),
      _FieldDef('worked', l.intakeWorked, maxLines: 3),
      _FieldDef('notWorked', l.intakeNotWorked, maxLines: 3),
      _FieldDef('reachProblems', l.intakeReachProblems, maxLines: 3),
    ],
    _ => [
      _FieldDef('companyGoals', l.intakeCompanyGoals, maxLines: 4),
      _FieldDef(
        'shortTermPriorities',
        l.intakeShortTermPriorities,
        maxLines: 3,
      ),
      _FieldDef('forbiddenClaims', l.intakeForbiddenClaims, maxLines: 4),
      _FieldDef(
        'botRestrictedTopics',
        l.intakeBotRestrictedTopics,
        maxLines: 4,
      ),
    ],
  };
}

String _statusLabel(AppLocalizations l, IntakeStatus status) {
  return switch (status) {
    IntakeStatus.draft => l.intakeStatusDraft,
    IntakeStatus.inProgress => l.intakeStatusInProgress,
    IntakeStatus.completed => l.intakeStatusCompleted,
  };
}

String _mappingAreaLabel(
  AppLocalizations l,
  IntakeMappingTargetArea targetArea,
) {
  return switch (targetArea) {
    IntakeMappingTargetArea.companyProfile => l.companyProfileSection,
    IntakeMappingTargetArea.products => l.companyProducts,
    IntakeMappingTargetArea.businessRules => l.companyBusinessRulesSection,
    IntakeMappingTargetArea.sources => l.navSources,
    IntakeMappingTargetArea.knowledgeBase => l.navKnowledge,
    IntakeMappingTargetArea.audit => l.navAudit,
    IntakeMappingTargetArea.botSettings => l.navBotSettings,
    IntakeMappingTargetArea.internalNotes => l.companyInternalNotesSection,
  };
}

String _suggestionLabel(
  AppLocalizations l,
  IntakeMappingSuggestion suggestion,
) {
  if (suggestion.action == IntakeMappingAction.updateCompanyField) {
    return switch (suggestion.fieldKey) {
      'name' => l.fieldCompanyName,
      'description' => l.fieldDescription,
      'industry' => l.fieldIndustry,
      'country' => l.fieldCountry,
      'primaryLanguage' => l.fieldPrimaryLanguage,
      'website' => l.fieldWebsite,
      'email' => l.fieldSupportEmail,
      'phone' => l.fieldSupportPhone,
      _ => suggestion.label,
    };
  }
  if (suggestion.action == IntakeMappingAction.setBotEscalateRedFlags) {
    return l.botSettingsEscalateRedFlags;
  }
  if (suggestion.action == IntakeMappingAction.setBotHandoverMessage) {
    return l.botSettingsHandoverMessage;
  }
  return suggestion.label;
}

IconData _statusIcon(IntakeStatus status) {
  return switch (status) {
    IntakeStatus.draft => Icons.edit_note_outlined,
    IntakeStatus.inProgress => Icons.pending_outlined,
    IntakeStatus.completed => Icons.check_circle_outline,
  };
}
