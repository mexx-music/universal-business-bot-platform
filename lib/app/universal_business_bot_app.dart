import 'package:flutter/material.dart';
import '../auth/auth_controller.dart';
import '../data/app_state.dart';
import '../demo/demo_mode_controller.dart';
import '../l10n/app_localizations.dart';
import '../onboarding/onboarding_controller.dart';
import '../router/app_router.dart';
import '../tenant_selection/tenant_selection_controller.dart';
import 'app_dependencies.dart';

class UniversalBusinessApp extends StatelessWidget {
  UniversalBusinessApp({super.key, AppDependencies? dependencies})
    : _dependencies = dependencies ?? AppDependencies.local();

  final AppDependencies _dependencies;

  @override
  Widget build(BuildContext context) {
    return AuthScope(
      notifier: _dependencies.authController,
      child: DemoScope(
        notifier: _dependencies.demoModeController,
        child: OnboardingScope(
          notifier: _dependencies.onboardingController,
          child: TenantSelectionScope(
            notifier: _dependencies.tenantSelectionController,
            child: AppStateScope(
              notifier: _dependencies.appState,
              child: MaterialApp.router(
                title: 'Universal Business Bot Platform',
                debugShowCheckedModeBanner: false,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                locale: const Locale('de'),
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
                routerConfig: createAppRouter(
                  _dependencies.authController,
                  publicIntakeService: _dependencies.publicIntakeService,
                  demoModeController: _dependencies.demoModeController,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
