import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_controller.dart';
import '../auth/auth_status.dart';
import '../demo/demo_mode_controller.dart';
import '../public_intake/public_intake_service.dart';
import '../widgets/app_shell.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/tenant_selection_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/public/landing_screen.dart';
import '../screens/public/companies_screen.dart';
import '../screens/public/public_intake_screen.dart';
import '../screens/check_in/check_in_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/next_actions/next_actions_screen.dart';
import '../screens/project_status/project_status_screen.dart';
import '../screens/business_intelligence/business_intelligence_screen.dart';
import '../screens/business_strategy/business_strategy_screen.dart';
import '../screens/marketing_strategy/marketing_strategy_screen.dart';
import '../screens/intake/intake_chat_screen.dart';
import '../screens/intake/intake_screen.dart';
import '../screens/company/company_screen.dart';
import '../screens/audit/audit_screen.dart';
import '../screens/knowledge/knowledge_screen.dart';
import '../screens/bot_test/bot_test_screen.dart';
import '../screens/bot_settings/bot_settings_screen.dart';
import '../screens/sources/sources_screen.dart';
import '../screens/review/review_screen.dart';

GoRouter createAppRouter(
  AuthController authController, {
  PublicIntakeService publicIntakeService =
      const UnsupportedPublicIntakeService(),
  DemoModeController? demoModeController,
}) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: demoModeController == null
        ? authController
        : Listenable.merge([authController, demoModeController]),
    redirect: (context, state) {
      // The competition demo runs entirely on local demo data: every route
      // is reachable without login, and Supabase is never contacted.
      if (demoModeController?.isActive ?? false) return null;

      final location = state.uri.path;
      final isPublicRoute = location == '/' || location == '/login';
      final isPublicIntakeRoute = location.startsWith('/onboarding/');
      final isLogin = location == '/login';
      final isOnboarding = location == '/onboarding';
      final isTenantSelect = location == '/select-tenant';
      final isManualTenantSwitch = state.uri.queryParameters['switch'] == '1';

      if (authController.status == AuthStatus.initializing) return null;
      if (authController.status == AuthStatus.local) return null;

      if (authController.status == AuthStatus.unauthenticated) {
        if (isPublicRoute || isPublicIntakeRoute) return null;
        final from = Uri.encodeComponent(state.uri.toString());
        return '/login?from=$from';
      }

      if (authController.status == AuthStatus.onboardingRequired) {
        if (isPublicIntakeRoute) return null;
        if (isOnboarding) return null;
        return '/onboarding';
      }

      if (authController.status == AuthStatus.tenantSelectionRequired ||
          authController.status == AuthStatus.switchingTenant) {
        if (isTenantSelect) return null;
        return '/select-tenant';
      }

      if (authController.status == AuthStatus.authenticated &&
          (isLogin ||
              isOnboarding ||
              (isTenantSelect && !isManualTenantSwitch))) {
        final from = state.uri.queryParameters['from'];
        if (from != null &&
            from.isNotEmpty &&
            from != '/login' &&
            from != '/onboarding' &&
            from != '/select-tenant') {
          return Uri.decodeComponent(from);
        }
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const LandingScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/onboarding/:token',
        builder: (context, state) => PublicOnboardingChatScreen(
          token: state.pathParameters['token'] ?? '',
          publicIntakeService: publicIntakeService,
        ),
      ),
      GoRoute(
        path: '/select-tenant',
        builder: (context, state) => const TenantSelectionScreen(),
      ),
      GoRoute(
        path: '/companies',
        builder: (context, state) => const CompaniesScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(currentLocation: state.matchedLocation, child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/next-actions',
            builder: (context, state) => const NextActionsScreen(),
          ),
          GoRoute(
            path: '/check-in',
            builder: (context, state) => const CheckInScreen(),
          ),
          GoRoute(
            path: '/project-status',
            builder: (context, state) => const ProjectStatusScreen(),
          ),
          GoRoute(
            path: '/business-intelligence',
            builder: (context, state) => const BusinessIntelligenceScreen(),
          ),
          GoRoute(
            path: '/business-strategy',
            builder: (context, state) => const BusinessStrategyScreen(),
          ),
          GoRoute(
            path: '/marketing-strategy',
            builder: (context, state) => const MarketingStrategyScreen(),
          ),
          GoRoute(
            path: '/intake',
            builder: (context, state) => const IntakeScreen(),
          ),
          GoRoute(
            path: '/intake-chat',
            builder: (context, state) => const IntakeChatScreen(),
          ),
          GoRoute(
            path: '/company',
            builder: (context, state) => const CompanyScreen(),
          ),
          GoRoute(
            path: '/audit',
            builder: (context, state) => const AuditScreen(),
          ),
          GoRoute(
            path: '/knowledge',
            builder: (context, state) => const KnowledgeScreen(),
          ),
          GoRoute(
            path: '/bot-test',
            builder: (context, state) => const BotTestScreen(),
          ),
          GoRoute(
            path: '/bot-settings',
            builder: (context, state) => const BotSettingsScreen(),
          ),
          GoRoute(
            path: '/sources',
            builder: (context, state) => const SourcesScreen(),
          ),
          GoRoute(
            path: '/review',
            builder: (context, state) => const ReviewScreen(),
          ),
        ],
      ),
    ],
  );
}
