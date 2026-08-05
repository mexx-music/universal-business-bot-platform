import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'app/app_dependencies.dart';
import 'app/universal_business_bot_app.dart';

Future<void> main() async {
  // Use path-based URLs (no leading #). Direct deep links like
  // /knowledge-builder are then parsed by the router instead of being ignored
  // by the hash strategy (which always booted at '/'). No-op off the web.
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  // Load persisted workspaces before the first frame so the UI never renders
  // (or overwrites) stale seed data while storage is still loading.
  final dependencies = await AppDependencies.create();
  runApp(UniversalBusinessApp(dependencies: dependencies));
}
