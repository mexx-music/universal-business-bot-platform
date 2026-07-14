import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/l10n/app_localizations.dart';
import 'package:universalbusiness/platform/pwa_install.dart';

void main() {
  test('manifest contains installable PWA metadata', () {
    final manifest =
        jsonDecode(File('web/manifest.json').readAsStringSync())
            as Map<String, Object?>;
    final icons = manifest['icons'] as List<Object?>;

    expect(manifest['name'], 'Universal Business Bot Platform');
    expect(manifest['short_name'], 'Business Platform');
    expect(manifest['start_url'], '/');
    expect(manifest['scope'], '/');
    expect(manifest['display'], 'standalone');
    expect(manifest['orientation'], 'any');
    expect(manifest['theme_color'], '#3F51B5');
    expect(icons, hasLength(greaterThanOrEqualTo(4)));
    expect(
      icons,
      contains(
        allOf(
          isA<Map<String, Object?>>(),
          containsPair('src', 'icons/Icon-192.png'),
          containsPair('sizes', '192x192'),
        ),
      ),
    );
    expect(
      icons,
      contains(
        allOf(
          isA<Map<String, Object?>>(),
          containsPair('src', 'icons/Icon-512.png'),
          containsPair('sizes', '512x512'),
        ),
      ),
    );
    expect(
      icons,
      contains(
        allOf(
          isA<Map<String, Object?>>(),
          containsPair('src', 'icons/Icon-maskable-192.png'),
          containsPair('purpose', 'maskable'),
        ),
      ),
    );
    expect(
      icons,
      contains(
        allOf(
          isA<Map<String, Object?>>(),
          containsPair('src', 'icons/Icon-maskable-512.png'),
          containsPair('purpose', 'maskable'),
        ),
      ),
    );
  });

  test('index.html contains mobile and PWA metadata', () {
    final index = File('web/index.html').readAsStringSync();

    expect(index, contains('<title>Universal Business Bot Platform</title>'));
    expect(index, contains('<link rel="manifest" href="manifest.json">'));
    expect(index, contains('<meta name="theme-color" content="#3F51B5">'));
    expect(index, contains('viewport-fit=cover'));
    expect(index, contains('mobile-web-app-capable'));
    expect(index, contains('apple-mobile-web-app-capable'));
    expect(index, contains('apple-mobile-web-app-title'));
    expect(index, contains('rel="apple-touch-icon"'));
    expect(index, contains('rel="icon"'));
  });

  test('Cloudflare Pages SPA fallback is present', () {
    final redirects = File('web/_redirects').readAsStringSync().trim();

    expect(redirects, '/* /index.html 200');
  });

  test(
    'non-web PWA install controller stays inert for tests and native builds',
    () {
      final controller = PwaInstallController();

      expect(controller.status.isWeb, isFalse);
      expect(controller.status.isStandalone, isFalse);
      expect(controller.status.canInstall, isFalse);
    },
  );

  test('PWA install hint is localized in German and English', () {
    final de = lookupAppLocalizations(const Locale('de'));
    final en = lookupAppLocalizations(const Locale('en'));

    expect(
      de.landingPwaHint,
      'Sie können die Plattform direkt im Browser verwenden oder für schnelleren Zugriff zum Startbildschirm hinzufügen.',
    );
    expect(
      en.landingPwaHint,
      'You can use the platform directly in your browser or add it to your home screen for faster access.',
    );
    expect(de.landingPwaAddToHome, 'Zum Startbildschirm hinzufügen');
    expect(en.landingPwaAddToHome, 'Add to home screen');
  });
}
