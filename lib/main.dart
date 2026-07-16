import 'package:flutter/material.dart';
import 'app/app_dependencies.dart';
import 'app/universal_business_bot_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load persisted workspaces before the first frame so the UI never renders
  // (or overwrites) stale seed data while storage is still loading.
  final dependencies = await AppDependencies.create();
  runApp(UniversalBusinessApp(dependencies: dependencies));
}
