import 'package:flutter/foundation.dart';

class PwaInstallStatus {
  final bool isWeb;
  final bool isStandalone;
  final bool canInstall;
  final bool isLikelyIosSafari;

  const PwaInstallStatus({
    required this.isWeb,
    required this.isStandalone,
    required this.canInstall,
    required this.isLikelyIosSafari,
  });
}

class PwaInstallController extends ChangeNotifier {
  PwaInstallStatus get status => const PwaInstallStatus(
    isWeb: false,
    isStandalone: false,
    canInstall: false,
    isLikelyIosSafari: false,
  );

  Future<void> promptInstall() async {}
}
