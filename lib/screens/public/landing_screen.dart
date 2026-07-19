import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../demo/demo_mode_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../platform/pwa_install.dart';
import '../../widgets/public/landing_audience_section.dart';
import '../../widgets/public/landing_benefits_section.dart';
import '../../widgets/public/landing_cta_section.dart';
import '../../widgets/public/landing_demo_section.dart';
import '../../widgets/public/landing_faq_section.dart';
import '../../widgets/public/landing_features_section.dart';
import '../../widgets/public/landing_footer_section.dart';
import '../../widgets/public/landing_hero_section.dart';
import '../../widgets/public/landing_preview_section.dart';
import '../../widgets/public/landing_workflow_section.dart';
import '../../widgets/public/pwa_install_notice.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  static bool _pwaHintDismissedInSession = false;

  final _scrollController = ScrollController();
  final _platformKey = GlobalKey();
  final _demoKey = GlobalKey();
  final _contactKey = GlobalKey();
  late final PwaInstallController _pwaInstallController;
  late bool _pwaHintDismissed;

  @override
  void initState() {
    super.initState();
    _pwaInstallController = PwaInstallController();
    _pwaHintDismissed = _pwaHintDismissedInSession;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pwaInstallController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primaryContainer.withAlpha(92),
              theme.colorScheme.surface,
              theme.colorScheme.surface,
            ],
            stops: const [0, 0.42, 1],
          ),
        ),
        child: SafeArea(
          child: ListView(
            controller: _scrollController,
            padding: EdgeInsets.zero,
            children: [
              _PageBand(
                child: Column(
                  children: [
                    _LandingNav(
                      onDemo: () => _scrollTo(_demoKey),
                      onContact: () => _scrollTo(_contactKey),
                    ),
                    LandingHeroSection(
                      onStartDemo: () => _startDemo(context),
                      onRegister: () => context.go('/login'),
                      onLearnMore: () => _scrollTo(_platformKey),
                      onDemo: () => _scrollTo(_demoKey),
                      onContact: () => _scrollTo(_contactKey),
                    ),
                    PwaInstallNotice(
                      controller: _pwaInstallController,
                      dismissed: _pwaHintDismissed,
                      onDismiss: () {
                        setState(() {
                          _pwaHintDismissed = true;
                          _pwaHintDismissedInSession = true;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const _PageBand(child: LandingBenefitsSection()),
              _PageBand(
                key: _platformKey,
                child: const LandingWorkflowSection(),
              ),
              const _PageBand(child: LandingPreviewSection()),
              const _PageBand(child: LandingFeaturesSection()),
              _PageBand(
                key: _demoKey,
                child: LandingDemoSection(onDemo: () => _startDemo(context)),
              ),
              const _PageBand(child: LandingAudienceSection()),
              const _PageBand(child: LandingFaqSection()),
              _PageBand(
                key: _contactKey,
                child: LandingCtaSection(onRequest: _showPlaceholderMessage),
              ),
              _PageBand(
                child: LandingFooterSection(
                  onPlaceholder: _showPlaceholderMessage,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// Enters the competition demo (no login, no Supabase) and opens the
  /// demo company selection.
  Future<void> _startDemo(BuildContext context) async {
    final demo = DemoModeController.of(context);
    await demo.enterDemo();
    if (context.mounted) context.go('/companies');
  }

  void _scrollTo(GlobalKey key) {
    final context = key.currentContext;
    if (context == null) return;
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutCubic,
      alignment: 0.04,
    );
  }

  void _showPlaceholderMessage() {
    final l = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(l.landingPlaceholderAction)));
  }
}

class _LandingNav extends StatelessWidget {
  final VoidCallback onDemo;
  final VoidCallback onContact;

  const _LandingNav({required this.onDemo, required this.onContact});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 28),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 640;
          final brand = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.hub_rounded,
                  color: theme.colorScheme.onPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  l.landingBrandName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          );
          final actions = Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: compact ? WrapAlignment.start : WrapAlignment.end,
            children: [
              TextButton(onPressed: onDemo, child: Text(l.landingDemoButton)),
              OutlinedButton(
                onPressed: onContact,
                child: Text(l.landingContactButton),
              ),
            ],
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [brand, const SizedBox(height: 14), actions],
            );
          }

          return Row(
            children: [
              Expanded(child: brand),
              actions,
            ],
          );
        },
      ),
    );
  }
}

class _PageBand extends StatelessWidget {
  final Widget child;

  const _PageBand({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = width < 520
        ? 18.0
        : width < 900
        ? 24.0
        : 32.0;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1280),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: child,
        ),
      ),
    );
  }
}
