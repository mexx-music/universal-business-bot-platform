import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_controller.dart';
import '../data/app_state.dart';
import '../demo/demo_mode_controller.dart';
import '../l10n/app_localizations.dart';
import '../onboarding/onboarding_controller.dart';
import '../router/app_router.dart';
import '../tenant_selection/tenant_selection_controller.dart';
import 'app_dependencies.dart';
import 'app_locale_controller.dart';

class UniversalBusinessApp extends StatefulWidget {
  UniversalBusinessApp({super.key, AppDependencies? dependencies})
    : _dependencies = dependencies ?? AppDependencies.local();

  final AppDependencies _dependencies;

  @override
  State<UniversalBusinessApp> createState() => _UniversalBusinessAppState();
}

class _UniversalBusinessAppState extends State<UniversalBusinessApp> {
  late final AppLocaleController _localeController;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _localeController = AppLocaleController()..restore();
    final dependencies = widget._dependencies;
    _router = createAppRouter(
      dependencies.authController,
      publicIntakeService: dependencies.publicIntakeService,
      demoModeController: dependencies.demoModeController,
    );
  }

  @override
  void dispose() {
    _localeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dependencies = widget._dependencies;
    return AppLocaleScope(
      notifier: _localeController,
      child: AnimatedBuilder(
        animation: _localeController,
        builder: (context, _) {
          return AuthScope(
            notifier: dependencies.authController,
            child: DemoScope(
              notifier: dependencies.demoModeController,
              child: OnboardingScope(
                notifier: dependencies.onboardingController,
                child: TenantSelectionScope(
                  notifier: dependencies.tenantSelectionController,
                  child: AppStateScope(
                    notifier: dependencies.appState,
                    child: MaterialApp.router(
                      title: 'Universal Business Bot Platform',
                      debugShowCheckedModeBanner: false,
                      localizationsDelegates:
                          AppLocalizations.localizationsDelegates,
                      supportedLocales: AppLocalizations.supportedLocales,
                      locale: _localeController.locale,
                      theme: ThemeData(
                        useMaterial3: true,
                        colorScheme: ColorScheme.fromSeed(
                          seedColor: const Color(0xFF3F51B5),
                          brightness: Brightness.light,
                        ),
                        cardTheme: CardThemeData(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: const Color(0xFF3F51B5).withAlpha(30),
                            ),
                          ),
                        ),
                      ),
                      routerConfig: _router,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
