import 'package:go_router/go_router.dart';
import '../widgets/app_shell.dart';
import '../screens/public/landing_screen.dart';
import '../screens/public/companies_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/intake/intake_chat_screen.dart';
import '../screens/intake/intake_screen.dart';
import '../screens/company/company_screen.dart';
import '../screens/audit/audit_screen.dart';
import '../screens/knowledge/knowledge_screen.dart';
import '../screens/bot_test/bot_test_screen.dart';
import '../screens/bot_settings/bot_settings_screen.dart';
import '../screens/sources/sources_screen.dart';
import '../screens/review/review_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const LandingScreen()),
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
