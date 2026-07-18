import '../models/intake_invitation.dart';
import '../models/intake_session.dart';

abstract class IntakeInvitationRepository {
  Future<IntakeInvitation> createIntakeInvitation({
    required String greeting,
  });

  Future<IntakeInvitation> regenerateIntakeInvitation({
    String? greeting,
  });

  Future<IntakeInvitation?> deactivateIntakeInvitation();

  Future<IntakeSession> updateIntakeSession(
    IntakeSession session, {
    IntakeInvitation? invitation,
  });
}

abstract class ReloadableWorkspaceRepository {
  Future<void> reload();
}
