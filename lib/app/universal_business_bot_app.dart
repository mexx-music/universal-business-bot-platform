import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../l10n/app_localizations.dart';
import '../router/app_router.dart';

class UniversalBusinessApp extends StatelessWidget {
  UniversalBusinessApp({super.key});

  final _appState = AppState();

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      notifier: _appState,
      child: MaterialApp.router(
        title: 'Universal Business Bot',
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
              side: BorderSide(color: const Color(0xFF3F51B5).withAlpha(30)),
            ),
          ),
        ),
        routerConfig: appRouter,
      ),
    );
  }
}
