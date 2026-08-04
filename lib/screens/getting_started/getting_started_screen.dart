import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../getting_started/getting_started_demo.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/language_switcher.dart';

/// Public, local-only onboarding demonstration. Nothing entered or selected on
/// this page is uploaded, registered, analysed, persisted or sent to a service.
class GettingStartedScreen extends StatefulWidget {
  const GettingStartedScreen({super.key});

  @override
  State<GettingStartedScreen> createState() => _GettingStartedScreenState();
}

class _GettingStartedScreenState extends State<GettingStartedScreen> {
  final _companyController = TextEditingController();
  final _industryController = TextEditingController();
  final _websiteController = TextEditingController();

  int _currentStep = 0;
  bool _completed = false;
  bool _logoSelected = false;
  String _country = 'de';
  String _companyLanguage = 'de';
  final Set<String> _selectedImports = {'website', 'pdf', 'faq'};
  final Set<String> _confirmedProposals = {'faq'};

  @override
  void dispose() {
    _companyController.dispose();
    _industryController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  void _selectStep(int index) {
    setState(() {
      _currentStep = index;
      _completed = false;
    });
  }

  void _next() {
    if (_currentStep == gettingStartedSteps.length - 1) {
      setState(() => _completed = true);
      return;
    }
    setState(() => _currentStep++);
  }

  void _back() {
    if (_currentStep == 0) return;
    setState(() {
      _currentStep--;
      _completed = false;
    });
  }

  void _restart() {
    setState(() {
      _currentStep = 0;
      _completed = false;
      _logoSelected = false;
      _country = 'de';
      _companyLanguage = 'de';
      _selectedImports
        ..clear()
        ..addAll({'website', 'pdf', 'faq'});
      _confirmedProposals
        ..clear()
        ..add('faq');
      _companyController.clear();
      _industryController.clear();
      _websiteController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final progress = _completed
        ? 1.0
        : (_currentStep + 1) / gettingStartedSteps.length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface.withAlpha(245),
        title: Text(l.gettingStartedNavTitle),
        leading: IconButton(
          tooltip: l.gettingStartedBackHome,
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: LanguageSwitcher(compact: true),
          ),
          SizedBox(width: 10),
        ],
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primaryContainer.withAlpha(66),
              theme.colorScheme.surface,
              theme.colorScheme.surface,
            ],
            stops: const [0, 0.22, 1],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 48),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _GettingStartedHero(),
                  const SizedBox(height: 22),
                  _ProgressHeader(
                    currentStep: _currentStep,
                    completed: _completed,
                    progress: progress,
                  ),
                  const SizedBox(height: 14),
                  _JourneyLayout(
                    currentStep: _currentStep,
                    completed: _completed,
                    onStepSelected: _selectStep,
                    onBack: _back,
                    onNext: _next,
                    onRestart: _restart,
                    companyController: _companyController,
                    industryController: _industryController,
                    websiteController: _websiteController,
                    country: _country,
                    companyLanguage: _companyLanguage,
                    logoSelected: _logoSelected,
                    onCountryChanged: (value) =>
                        setState(() => _country = value),
                    onLanguageChanged: (value) =>
                        setState(() => _companyLanguage = value),
                    onLogoToggle: () =>
                        setState(() => _logoSelected = !_logoSelected),
                    selectedImports: _selectedImports,
                    onImportToggle: (key) {
                      setState(() {
                        if (!_selectedImports.remove(key)) {
                          _selectedImports.add(key);
                        }
                      });
                    },
                    confirmedProposals: _confirmedProposals,
                    onProposalToggle: (key) {
                      setState(() {
                        if (!_confirmedProposals.remove(key)) {
                          _confirmedProposals.add(key);
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 22),
                  const _EstimatedTimeCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GettingStartedHero extends StatelessWidget {
  const _GettingStartedHero();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      key: const Key('getting-started-hero'),
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 700;
          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _DemoBadge(),
              const SizedBox(height: 16),
              Text(
                l.gettingStartedHeroTitle,
                style:
                    (compact
                            ? theme.textTheme.headlineMedium
                            : theme.textTheme.displaySmall)
                        ?.copyWith(fontWeight: FontWeight.w900, height: 1.08),
              ),
              const SizedBox(height: 12),
              Text(
                l.gettingStartedHeroBody,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 13),
              _InfoBanner(
                icon: Icons.lock_outline,
                text: l.gettingStartedDemoBoundary,
              ),
            ],
          );
          const visual = _SetupVisual();
          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [copy, const SizedBox(height: 22), visual],
            );
          }
          return Row(
            children: [
              Expanded(flex: 3, child: copy),
              const SizedBox(width: 28),
              const Expanded(flex: 2, child: visual),
            ],
          );
        },
      ),
    );
  }
}

class _SetupVisual extends StatelessWidget {
  const _SetupVisual();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    final nodes = [
      (Icons.business_outlined, l.gettingStartedVisualCompany),
      (Icons.library_books_outlined, l.gettingStartedVisualKnowledge),
      (Icons.smart_toy_outlined, l.gettingStartedVisualReady),
    ];
    return Container(
      constraints: const BoxConstraints(minHeight: 190),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withAlpha(105),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              for (var index = 0; index < nodes.length; index++) ...[
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: index == 0
                              ? theme.colorScheme.primary
                              : theme.colorScheme.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant,
                          ),
                        ),
                        child: Icon(
                          nodes[index].$1,
                          color: index == 0
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        nodes[index].$2,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                if (index < nodes.length - 1)
                  Expanded(
                    child: Divider(
                      thickness: 2,
                      color: theme.colorScheme.primary.withAlpha(90),
                    ),
                  ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          Text(
            l.gettingStartedVisualCaption,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoBadge extends StatelessWidget {
  const _DemoBadge({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      key: const Key('getting-started-demo-badge'),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 7 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        l.gettingStartedDemoBadge,
        style:
            (compact ? theme.textTheme.labelSmall : theme.textTheme.labelMedium)
                ?.copyWith(
                  color: theme.colorScheme.onTertiaryContainer,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({
    required this.currentStep,
    required this.completed,
    required this.progress,
  });

  final int currentStep;
  final bool completed;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      key: const Key('getting-started-progress'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  completed
                      ? l.gettingStartedProgressComplete
                      : l.gettingStartedProgress(
                          currentStep + 1,
                          gettingStartedSteps.length,
                        ),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const _DemoBadge(compact: true),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              key: ValueKey('getting-started-progress-$currentStep-$completed'),
              value: progress,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class _JourneyLayout extends StatelessWidget {
  const _JourneyLayout({
    required this.currentStep,
    required this.completed,
    required this.onStepSelected,
    required this.onBack,
    required this.onNext,
    required this.onRestart,
    required this.companyController,
    required this.industryController,
    required this.websiteController,
    required this.country,
    required this.companyLanguage,
    required this.logoSelected,
    required this.onCountryChanged,
    required this.onLanguageChanged,
    required this.onLogoToggle,
    required this.selectedImports,
    required this.onImportToggle,
    required this.confirmedProposals,
    required this.onProposalToggle,
  });

  final int currentStep;
  final bool completed;
  final ValueChanged<int> onStepSelected;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onRestart;
  final TextEditingController companyController;
  final TextEditingController industryController;
  final TextEditingController websiteController;
  final String country;
  final String companyLanguage;
  final bool logoSelected;
  final ValueChanged<String> onCountryChanged;
  final ValueChanged<String> onLanguageChanged;
  final VoidCallback onLogoToggle;
  final Set<String> selectedImports;
  final ValueChanged<String> onImportToggle;
  final Set<String> confirmedProposals;
  final ValueChanged<String> onProposalToggle;

  @override
  Widget build(BuildContext context) {
    final detail = AnimatedSwitcher(
      duration: const Duration(milliseconds: 240),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: completed
          ? _SuccessCard(
              key: const Key('getting-started-success'),
              onRestart: onRestart,
            )
          : _ActiveStepCard(
              key: ValueKey('getting-started-detail-$currentStep'),
              currentStep: currentStep,
              onBack: onBack,
              onNext: onNext,
              companyController: companyController,
              industryController: industryController,
              websiteController: websiteController,
              country: country,
              companyLanguage: companyLanguage,
              logoSelected: logoSelected,
              onCountryChanged: onCountryChanged,
              onLanguageChanged: onLanguageChanged,
              onLogoToggle: onLogoToggle,
              selectedImports: selectedImports,
              onImportToggle: onImportToggle,
              confirmedProposals: confirmedProposals,
              onProposalToggle: onProposalToggle,
            ),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 900;
        final timeline = _StepTimeline(
          currentStep: currentStep,
          completed: completed,
          onSelected: onStepSelected,
        );
        if (!desktop) {
          return Column(
            children: [timeline, const SizedBox(height: 14), detail],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 290, child: timeline),
            const SizedBox(width: 16),
            Expanded(child: detail),
          ],
        );
      },
    );
  }
}

class _StepTimeline extends StatelessWidget {
  const _StepTimeline({
    required this.currentStep,
    required this.completed,
    required this.onSelected,
  });

  final int currentStep;
  final bool completed;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('getting-started-timeline'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          for (var index = 0; index < gettingStartedSteps.length; index++) ...[
            _StepNode(
              definition: gettingStartedSteps[index],
              index: index,
              active: !completed && index == currentStep,
              done: completed || index < currentStep,
              onTap: () => onSelected(index),
            ),
            if (index < gettingStartedSteps.length - 1)
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(left: 22),
                  width: 2,
                  height: 12,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _StepNode extends StatelessWidget {
  const _StepNode({
    required this.definition,
    required this.index,
    required this.active,
    required this.done,
    required this.onTap,
  });

  final GettingStartedStepDefinition definition;
  final int index;
  final bool active;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final title = _stepTitle(l, definition.id);
    return Semantics(
      button: true,
      selected: active,
      label: '${index + 1}. $title',
      child: AnimatedContainer(
        key: ValueKey('getting-started-step-${definition.id.name}'),
        duration: const Duration(milliseconds: 210),
        decoration: BoxDecoration(
          color: active
              ? theme.colorScheme.primaryContainer.withAlpha(130)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(13),
          border: active ? Border.all(color: theme.colorScheme.primary) : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(13),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: done || active
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surfaceContainerLowest,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                    child: Icon(
                      done ? Icons.check : definition.icon,
                      size: 21,
                      color: done || active
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          done
                              ? l.gettingStartedStatusDone
                              : active
                              ? l.gettingStartedStatusActive
                              : l.gettingStartedStatusUpcoming,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActiveStepCard extends StatelessWidget {
  const _ActiveStepCard({
    super.key,
    required this.currentStep,
    required this.onBack,
    required this.onNext,
    required this.companyController,
    required this.industryController,
    required this.websiteController,
    required this.country,
    required this.companyLanguage,
    required this.logoSelected,
    required this.onCountryChanged,
    required this.onLanguageChanged,
    required this.onLogoToggle,
    required this.selectedImports,
    required this.onImportToggle,
    required this.confirmedProposals,
    required this.onProposalToggle,
  });

  final int currentStep;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final TextEditingController companyController;
  final TextEditingController industryController;
  final TextEditingController websiteController;
  final String country;
  final String companyLanguage;
  final bool logoSelected;
  final ValueChanged<String> onCountryChanged;
  final ValueChanged<String> onLanguageChanged;
  final VoidCallback onLogoToggle;
  final Set<String> selectedImports;
  final ValueChanged<String> onImportToggle;
  final Set<String> confirmedProposals;
  final ValueChanged<String> onProposalToggle;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final definition = gettingStartedSteps[currentStep];
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    definition.icon,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _stepTitle(l, definition.id),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _stepDescription(l, definition.id),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const _DemoBadge(compact: true),
              ],
            ),
            const SizedBox(height: 20),
            _stepBody(context, definition.id),
            const SizedBox(height: 22),
            _StepActions(
              currentStep: currentStep,
              onBack: onBack,
              onNext: onNext,
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepBody(BuildContext context, GettingStartedStepId id) =>
      switch (id) {
        GettingStartedStepId.companyProfile => _CompanyProfileStep(
          companyController: companyController,
          industryController: industryController,
          websiteController: websiteController,
          country: country,
          companyLanguage: companyLanguage,
          logoSelected: logoSelected,
          onCountryChanged: onCountryChanged,
          onLanguageChanged: onLanguageChanged,
          onLogoToggle: onLogoToggle,
        ),
        GettingStartedStepId.knowledgeImport => _KnowledgeImportStep(
          selected: selectedImports,
          onToggle: onImportToggle,
        ),
        GettingStartedStepId.analysis => const _AnalysisStep(),
        GettingStartedStepId.humanReview => _HumanReviewStep(
          confirmed: confirmedProposals,
          onToggle: onProposalToggle,
        ),
        GettingStartedStepId.ready => const _ReadyStep(),
      };
}

class _StepActions extends StatelessWidget {
  const _StepActions({
    required this.currentStep,
    required this.onBack,
    required this.onNext,
  });

  final int currentStep;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final previous = OutlinedButton.icon(
      key: const Key('getting-started-previous'),
      onPressed: onBack,
      icon: const Icon(Icons.arrow_back),
      label: Text(l.gettingStartedPrevious),
    );
    final next = FilledButton.icon(
      key: const Key('getting-started-next'),
      onPressed: onNext,
      icon: Icon(
        currentStep == gettingStartedSteps.length - 1
            ? Icons.check
            : Icons.arrow_forward,
      ),
      label: Text(
        currentStep == gettingStartedSteps.length - 1
            ? l.gettingStartedFinish
            : l.gettingStartedNext,
      ),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 340) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (currentStep > 0) ...[previous, const SizedBox(height: 10)],
              next,
            ],
          );
        }
        return Row(
          children: [if (currentStep > 0) previous, const Spacer(), next],
        );
      },
    );
  }
}

class _CompanyProfileStep extends StatelessWidget {
  const _CompanyProfileStep({
    required this.companyController,
    required this.industryController,
    required this.websiteController,
    required this.country,
    required this.companyLanguage,
    required this.logoSelected,
    required this.onCountryChanged,
    required this.onLanguageChanged,
    required this.onLogoToggle,
  });

  final TextEditingController companyController;
  final TextEditingController industryController;
  final TextEditingController websiteController;
  final String country;
  final String companyLanguage;
  final bool logoSelected;
  final ValueChanged<String> onCountryChanged;
  final ValueChanged<String> onLanguageChanged;
  final VoidCallback onLogoToggle;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final fields = <Widget>[
      TextField(
        key: const Key('getting-started-company'),
        controller: companyController,
        decoration: InputDecoration(
          labelText: l.gettingStartedCompanyName,
          hintText: l.gettingStartedCompanyHint,
          border: const OutlineInputBorder(),
        ),
      ),
      TextField(
        key: const Key('getting-started-industry'),
        controller: industryController,
        decoration: InputDecoration(
          labelText: l.gettingStartedIndustry,
          hintText: l.gettingStartedIndustryHint,
          border: const OutlineInputBorder(),
        ),
      ),
      DropdownButtonFormField<String>(
        key: const Key('getting-started-country'),
        initialValue: country,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: l.gettingStartedCountry,
          border: const OutlineInputBorder(),
        ),
        items: [
          DropdownMenuItem(value: 'de', child: Text(l.gettingStartedCountryDe)),
          DropdownMenuItem(value: 'at', child: Text(l.gettingStartedCountryAt)),
          DropdownMenuItem(value: 'ch', child: Text(l.gettingStartedCountryCh)),
          DropdownMenuItem(
            value: 'other',
            child: Text(l.gettingStartedCountryOther),
          ),
        ],
        onChanged: (value) => onCountryChanged(value ?? country),
      ),
      DropdownButtonFormField<String>(
        key: const Key('getting-started-language'),
        initialValue: companyLanguage,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: l.gettingStartedLanguage,
          border: const OutlineInputBorder(),
        ),
        items: [
          DropdownMenuItem(value: 'de', child: Text(l.languageGerman)),
          DropdownMenuItem(value: 'en', child: Text(l.languageEnglish)),
        ],
        onChanged: (value) => onLanguageChanged(value ?? companyLanguage),
      ),
      TextField(
        key: const Key('getting-started-website'),
        controller: websiteController,
        keyboardType: TextInputType.url,
        decoration: InputDecoration(
          labelText: l.gettingStartedWebsite,
          hintText: 'https://example.com',
          border: const OutlineInputBorder(),
        ),
      ),
      OutlinedButton.icon(
        key: const Key('getting-started-logo'),
        onPressed: onLogoToggle,
        icon: Icon(
          logoSelected ? Icons.check_circle_outline : Icons.image_outlined,
        ),
        label: Text(
          logoSelected ? l.gettingStartedLogoSelected : l.gettingStartedLogo,
        ),
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoBanner(
          icon: Icons.edit_note_outlined,
          text: l.gettingStartedOptionalNote,
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 620) {
              return Column(
                children: [
                  for (var index = 0; index < fields.length; index++) ...[
                    SizedBox(width: double.infinity, child: fields[index]),
                    if (index < fields.length - 1) const SizedBox(height: 12),
                  ],
                ],
              );
            }
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final field in fields)
                  SizedBox(
                    width: (constraints.maxWidth - 12) / 2,
                    child: field,
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _KnowledgeImportStep extends StatelessWidget {
  const _KnowledgeImportStep({required this.selected, required this.onToggle});

  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final icons = <String, IconData>{
      'website': Icons.language_outlined,
      'pdf': Icons.picture_as_pdf_outlined,
      'faq': Icons.quiz_outlined,
      'manuals': Icons.menu_book_outlined,
      'products': Icons.inventory_2_outlined,
      'support': Icons.support_agent_outlined,
      'videos': Icons.play_circle_outline,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoBanner(
          icon: Icons.visibility_outlined,
          text: l.gettingStartedImportBoundary,
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth < 560
                ? constraints.maxWidth
                : (constraints.maxWidth - 12) / 2;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final key in gettingStartedImportKeys)
                  SizedBox(
                    width: width,
                    child: _SelectionCard(
                      key: ValueKey('getting-started-import-$key'),
                      icon: icons[key]!,
                      label: _importLabel(l, key),
                      selected: selected.contains(key),
                      onTap: () => onToggle(key),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _SelectionCard extends StatelessWidget {
  const _SelectionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: selected
            ? theme.colorScheme.primaryContainer.withAlpha(130)
            : theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                  selected ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: selected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnalysisStep extends StatelessWidget {
  const _AnalysisStep();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final icons = <String, IconData>{
      'products': Icons.inventory_2_outlined,
      'faq': Icons.quiz_outlined,
      'documents': Icons.description_outlined,
      'support': Icons.support_agent_outlined,
      'downloads': Icons.download_outlined,
      'contact': Icons.contact_mail_outlined,
      'knowledgeAreas': Icons.account_tree_outlined,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TweenAnimationBuilder<double>(
          key: const Key('getting-started-analysis-animation'),
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(value: value, minHeight: 8),
              const SizedBox(height: 7),
              Text(
                l.gettingStartedAnalysisSimulation,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final key in gettingStartedAnalysisKeys)
              Chip(
                key: ValueKey('getting-started-detected-$key'),
                avatar: Icon(icons[key], size: 17),
                label: Text(_analysisLabel(l, key)),
              ),
          ],
        ),
        const SizedBox(height: 16),
        _InfoBanner(
          icon: Icons.how_to_reg_outlined,
          text: l.gettingStartedAnalysisHumanNote,
          emphasized: true,
        ),
      ],
    );
  }
}

class _HumanReviewStep extends StatelessWidget {
  const _HumanReviewStep({required this.confirmed, required this.onToggle});

  final Set<String> confirmed;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ReviewProposal(
          proposalKey: 'faq',
          title: l.gettingStartedReviewFaqTitle,
          body: l.gettingStartedReviewFaqBody,
          confirmed: confirmed.contains('faq'),
          onToggle: () => onToggle('faq'),
        ),
        const SizedBox(height: 12),
        _ReviewProposal(
          proposalKey: 'support',
          title: l.gettingStartedReviewSupportTitle,
          body: l.gettingStartedReviewSupportBody,
          confirmed: confirmed.contains('support'),
          onToggle: () => onToggle('support'),
        ),
        const SizedBox(height: 14),
        _InfoBanner(
          icon: Icons.verified_user_outlined,
          text: l.gettingStartedReviewBoundary,
          emphasized: true,
        ),
      ],
    );
  }
}

class _ReviewProposal extends StatelessWidget {
  const _ReviewProposal({
    required this.proposalKey,
    required this.title,
    required this.body,
    required this.confirmed,
    required this.onToggle,
  });

  final String proposalKey;
  final String title;
  final String body;
  final bool confirmed;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    return Container(
      key: ValueKey('getting-started-review-$proposalKey'),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: confirmed
            ? theme.colorScheme.primaryContainer.withAlpha(100)
            : theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: confirmed
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final button = FilledButton.tonalIcon(
            onPressed: onToggle,
            icon: Icon(confirmed ? Icons.check : Icons.how_to_reg_outlined),
            label: Text(
              confirmed
                  ? l.gettingStartedReviewConfirmed
                  : l.gettingStartedReviewConfirm,
            ),
          );
          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                body,
                style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
              ),
            ],
          );
          if (constraints.maxWidth < 560) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [copy, const SizedBox(height: 10), button],
            );
          }
          return Row(
            children: [
              Expanded(child: copy),
              const SizedBox(width: 12),
              button,
            ],
          );
        },
      ),
    );
  }
}

class _ReadyStep extends StatelessWidget {
  const _ReadyStep();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final items = [
      (Icons.question_answer_outlined, l.gettingStartedReadyQuestions),
      (Icons.verified_outlined, l.gettingStartedReadyGrounded),
      (Icons.monitor_heart_outlined, l.gettingStartedReadyOperations),
    ];
    return Column(
      children: [
        for (final item in items)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withAlpha(90),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(item.$1, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(child: Text(item.$2)),
                Icon(Icons.check_circle, color: theme.colorScheme.primary),
              ],
            ),
          ),
        _InfoBanner(
          icon: Icons.info_outline,
          text: l.gettingStartedReadyBoundary,
        ),
      ],
    );
  }
}

class _SuccessCard extends StatelessWidget {
  const _SuccessCard({super.key, required this.onRestart});

  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final items = [
      l.gettingStartedSuccessCompany,
      l.gettingStartedSuccessDocuments,
      l.gettingStartedSuccessKnowledge,
      l.gettingStartedSuccessAi,
      l.gettingStartedSuccessOperations,
    ];
    return Card(
      elevation: 0,
      color: theme.colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 38,
                  color: theme.colorScheme.primary,
                ),
                const Spacer(),
                const _DemoBadge(),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              l.gettingStartedSuccessTitle,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              l.gettingStartedSuccessBody,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            for (final item in items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.check,
                      size: 19,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              key: const Key('getting-started-restart'),
              onPressed: onRestart,
              icon: const Icon(Icons.replay),
              label: Text(l.gettingStartedRestart),
            ),
          ],
        ),
      ),
    );
  }
}

class _EstimatedTimeCard extends StatelessWidget {
  const _EstimatedTimeCard();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final rows = [
      (
        Icons.business_outlined,
        l.gettingStartedTimeProfile,
        l.gettingStartedTime2,
      ),
      (
        Icons.description_outlined,
        l.gettingStartedTimeDocuments,
        l.gettingStartedTime5,
      ),
      (
        Icons.how_to_reg_outlined,
        l.gettingStartedTimeReview,
        l.gettingStartedTime10,
      ),
    ];
    return Container(
      key: const Key('getting-started-time'),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule_outlined, color: theme.colorScheme.primary),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  l.gettingStartedTimeTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const _DemoBadge(compact: true),
            ],
          ),
          const SizedBox(height: 14),
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(row.$1, size: 19, color: theme.colorScheme.primary),
                  const SizedBox(width: 9),
                  Expanded(child: Text(row.$2)),
                  Text(
                    row.$3,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          const Divider(height: 22),
          Row(
            children: [
              Expanded(
                child: Text(
                  l.gettingStartedTimeReady,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                l.gettingStartedTimeUnder20,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l.gettingStartedTimeDisclaimer,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({
    required this.icon,
    required this.text,
    this.emphasized = false,
  });

  final IconData icon;
  final String text;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: emphasized
            ? theme.colorScheme.primaryContainer.withAlpha(105)
            : theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                height: 1.4,
                fontWeight: emphasized ? FontWeight.w600 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _stepTitle(AppLocalizations l, GettingStartedStepId id) => switch (id) {
  GettingStartedStepId.companyProfile => l.gettingStartedStep1Title,
  GettingStartedStepId.knowledgeImport => l.gettingStartedStep2Title,
  GettingStartedStepId.analysis => l.gettingStartedStep3Title,
  GettingStartedStepId.humanReview => l.gettingStartedStep4Title,
  GettingStartedStepId.ready => l.gettingStartedStep5Title,
};

String _stepDescription(AppLocalizations l, GettingStartedStepId id) =>
    switch (id) {
      GettingStartedStepId.companyProfile => l.gettingStartedStep1Description,
      GettingStartedStepId.knowledgeImport => l.gettingStartedStep2Description,
      GettingStartedStepId.analysis => l.gettingStartedStep3Description,
      GettingStartedStepId.humanReview => l.gettingStartedStep4Description,
      GettingStartedStepId.ready => l.gettingStartedStep5Description,
    };

String _importLabel(AppLocalizations l, String key) => switch (key) {
  'website' => l.gettingStartedImportWebsite,
  'pdf' => l.gettingStartedImportPdf,
  'faq' => l.gettingStartedImportFaq,
  'manuals' => l.gettingStartedImportManuals,
  'products' => l.gettingStartedImportProducts,
  'support' => l.gettingStartedImportSupport,
  'videos' => l.gettingStartedImportVideos,
  _ => key,
};

String _analysisLabel(AppLocalizations l, String key) => switch (key) {
  'products' => l.gettingStartedDetectedProducts,
  'faq' => l.gettingStartedDetectedFaq,
  'documents' => l.gettingStartedDetectedDocuments,
  'support' => l.gettingStartedDetectedSupport,
  'downloads' => l.gettingStartedDetectedDownloads,
  'contact' => l.gettingStartedDetectedContact,
  'knowledgeAreas' => l.gettingStartedDetectedKnowledgeAreas,
  _ => key,
};
