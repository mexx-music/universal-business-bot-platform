import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_controller.dart';
import '../demo/demo_mode_controller.dart';
import '../jury/jury_mode_controller.dart';

/// The single transition into BusinessBrain's existing full platform.
///
/// It never creates another shell or navigation tree. Signed-in and local
/// users continue with their regular workspace. A public unauthenticated
/// visitor receives the already existing isolated demo workspace so the
/// protected platform can be explored without touching production data.
Future<void> openFullPlatform(BuildContext context) async {
  JuryModeController.maybeOf(context)?.disable();

  final auth = AuthController.of(context);
  final demo = DemoModeController.of(context);
  if (!auth.canOpenProtectedRoutes && !demo.isActive) {
    await demo.enterDemo();
  }
  demo.dismissTour();

  if (context.mounted) context.go('/dashboard');
}
