import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/public_intake/public_intake_url.dart';

void main() {
  test('builds public intake URL from Cloudflare HTTPS origin', () {
    final url = buildPublicIntakeUrl(
      'secure-token',
      baseUri: Uri.parse(
        'https://businessbrain.pages.dev/dashboard?tab=company#section',
      ),
    );

    expect(
      url.toString(),
      'https://businessbrain.pages.dev/onboarding/secure-token',
    );
  });

  test('builds public intake URL from localhost origin', () {
    final url = buildPublicIntakeUrl(
      'local-token',
      baseUri: Uri.parse('http://localhost:52344/company'),
    );

    expect(url.toString(), 'http://localhost:52344/onboarding/local-token');
  });

  test('uses configured PUBLIC_APP_URL when current base is file', () {
    final url = buildPublicIntakeUrl(
      'configured-token',
      baseUri: Uri.parse('file:///Users/demo/index.html'),
      publicAppUrl: 'https://businessbrain.example.com/app/?ignored=true#nope',
    );

    expect(
      url.toString(),
      'https://businessbrain.example.com/onboarding/configured-token',
    );
  });

  test('rejects file URL without configured public base URL', () {
    expect(
      () => buildPublicIntakeUrl(
        'missing-base',
        baseUri: Uri.parse('file:///Users/demo/index.html'),
      ),
      throwsA(isA<PublicIntakeUrlException>()),
    );
  });

  test('encodes token as a safe path segment', () {
    final url = buildPublicIntakeUrl(
      'abc/def ghi?<x>',
      baseUri: Uri.parse('https://businessbrain.example.com'),
    );

    expect(
      url.toString(),
      'https://businessbrain.example.com/onboarding/abc%2Fdef%20ghi%3F%3Cx%3E',
    );
  });
}
