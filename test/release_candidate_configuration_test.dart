import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _read(String path) => File(path).readAsStringSync();

void main() {
  group('XPRIZE release configuration', () {
    test('Cloudflare production build explicitly selects live Gemini', () {
      final workflow = _read('.github/workflows/cloudflare-pages.yml');

      expect(workflow, contains('AI_PROVIDER: "gemini"'));
      expect(workflow, contains(r'--dart-define=AI_PROVIDER="$AI_PROVIDER"'));
      expect(workflow, contains('--dart-define=SUPABASE_URL='));
      expect(workflow, contains('--dart-define=SUPABASE_PUBLISHABLE_KEY='));
      expect(workflow, isNot(contains('--dart-define=GEMINI_API_KEY=')));
    });

    test('Gemini gateway is JWT protected and server configured', () {
      final config = _read('supabase/config.toml');
      final handler = _read('supabase/functions/ai-generate/handler.ts');

      expect(config, contains('[functions.ai-generate]'));
      expect(config, contains('verify_jwt = true'));
      expect(handler, contains('deps.env("GEMINI_API_KEY")'));
      expect(handler, contains('deps.env("ALLOWED_ORIGINS")'));
    });

    test('CORS is allow-list based and never uses a wildcard', () {
      final cors = _read('supabase/functions/_shared/cors.ts');

      expect(cors, contains('parseAllowedOrigins'));
      expect(cors, contains('Access-Control-Allow-Origin'));
      expect(cors, isNot(contains('"Access-Control-Allow-Origin": "*"')));
    });

    test('Cloudflare artifact keeps direct jury routes refresh-safe', () {
      final redirects = _read('web/_redirects');

      expect(redirects.trim(), '/* /index.html 200');
    });

    test('release report records the canonical production origin', () {
      final report = _read('docs/XPRIZE_RELEASE_CANDIDATE.md');

      expect(
        report,
        contains('https://universal-business-bot-platform.pages.dev'),
      );
      expect(report, contains('ACTION REQUIRED'));
      expect(report, contains('Google Gemini'));
      expect(report, contains('Video-Checkliste'));
    });
  });
}
