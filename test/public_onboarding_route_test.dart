import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/auth/auth_controller.dart';
import 'package:universalbusiness/auth/local_auth_service.dart';
import 'package:universalbusiness/data/mock_data.dart';
import 'package:universalbusiness/l10n/app_localizations.dart';
import 'package:universalbusiness/models/company_workspace.dart';
import 'package:universalbusiness/models/intake_invitation.dart';
import 'package:universalbusiness/models/intake_session.dart';
import 'package:universalbusiness/public_intake/public_intake_service.dart';
import 'package:universalbusiness/router/app_router.dart';

void main() {
  testWidgets('/onboarding/:token opens the public intake chat directly', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final auth = AuthController(LocalAuthService());
    await auth.initialize();
    final service = _FakePublicIntakeService(_publicWorkspace());
    final router = createAppRouter(auth, publicIntakeService: service);

    await tester.pumpWidget(
      MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('de'),
        routerConfig: router,
      ),
    );

    router.go('/onboarding/valid-public-token');
    await tester.pumpAndSettle();

    expect(service.openedToken, 'valid-public-token');
    expect(find.text('Firmenfragebogen: HB Cure'), findsOneWidget);
    expect(
      find.textContaining('Willkommen bei BusinessBrain AI'),
      findsOneWidget,
    );
    expect(find.text('Dashboard'), findsNothing);
    expect(find.text('Startseite'), findsNothing);
    expect(find.text('Anmelden'), findsNothing);
    expect(find.text('Plattform kennenlernen'), findsNothing);
  });
}

CompanyWorkspace _publicWorkspace() {
  final base = MockData.companyWorkspaces.first;
  final now = DateTime(2026, 7, 19);
  return CompanyWorkspace(
    company: base.company,
    products: const [],
    knowledgeEntries: const [],
    botLogs: const [],
    auditItems: const [],
    businessRules: base.businessRules,
    botConfiguration: base.botConfiguration,
    sourceMaterials: const [],
    intakeSession: IntakeSession.empty(companyId: base.company.id),
    intakeInvitation: IntakeInvitation(
      id: 'invite-test',
      token: '',
      status: IntakeInvitationStatus.started,
      greeting: 'Hallo Klaus.',
      createdAt: now,
      updatedAt: now,
      startedAt: now,
    ),
  );
}

class _FakePublicIntakeService implements PublicIntakeService {
  _FakePublicIntakeService(this.workspace);

  final CompanyWorkspace workspace;
  String? openedToken;

  @override
  bool get isSupported => true;

  @override
  Future<PublicIntakeOpenResponse> open(String token) async {
    openedToken = token;
    return PublicIntakeOpenResponse(
      status: PublicIntakeRemoteStatus.opened,
      workspace: workspace,
    );
  }

  @override
  Future<PublicIntakeOpenResponse> save({
    required String token,
    required IntakeSession session,
  }) async {
    return PublicIntakeOpenResponse(
      status: PublicIntakeRemoteStatus.opened,
      workspace: workspace.copyWith(intakeSession: session),
    );
  }
}
