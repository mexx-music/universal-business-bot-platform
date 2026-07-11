import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

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
  web.Event? _deferredInstallPrompt;
  late final web.EventListener _beforeInstallPromptListener;
  late final web.EventListener _appInstalledListener;

  PwaInstallController() {
    _beforeInstallPromptListener = ((web.Event event) {
      event.preventDefault();
      _deferredInstallPrompt = event;
      notifyListeners();
    }).toJS;
    _appInstalledListener = ((web.Event _) {
      _deferredInstallPrompt = null;
      notifyListeners();
    }).toJS;

    web.window.addEventListener(
      'beforeinstallprompt',
      _beforeInstallPromptListener,
    );
    web.window.addEventListener('appinstalled', _appInstalledListener);
  }

  PwaInstallStatus get status => PwaInstallStatus(
    isWeb: true,
    isStandalone: _isStandalone,
    canInstall: _deferredInstallPrompt != null,
    isLikelyIosSafari: _isLikelyIosSafari,
  );

  Future<void> promptInstall() async {
    final promptEvent = _deferredInstallPrompt;
    if (promptEvent == null) return;
    _deferredInstallPrompt = null;
    notifyListeners();

    try {
      await BeforeInstallPromptEvent(promptEvent).prompt().toDart;
    } catch (_) {
      // Browsers can reject programmatic installation prompts; the app stays
      // usable in the browser and the regular browser menu remains available.
    }
  }

  bool get _isStandalone {
    final displayModeStandalone = web.window
        .matchMedia('(display-mode: standalone)')
        .matches;
    final iosStandalone =
        IosStandaloneNavigator(web.window.navigator).standalone == true;
    return displayModeStandalone || iosStandalone;
  }

  bool get _isLikelyIosSafari {
    final userAgent = web.window.navigator.userAgent.toLowerCase();
    final isIos =
        userAgent.contains('iphone') ||
        userAgent.contains('ipad') ||
        userAgent.contains('ipod');
    final isSafari =
        userAgent.contains('safari') &&
        !userAgent.contains('crios') &&
        !userAgent.contains('fxios') &&
        !userAgent.contains('edgios');
    return isIos && isSafari;
  }

  @override
  void dispose() {
    web.window.removeEventListener(
      'beforeinstallprompt',
      _beforeInstallPromptListener,
    );
    web.window.removeEventListener('appinstalled', _appInstalledListener);
    super.dispose();
  }
}

extension type BeforeInstallPromptEvent(web.Event _) implements web.Event {
  external JSPromise<JSAny?> prompt();
}

extension type IosStandaloneNavigator(web.Navigator _)
    implements web.Navigator {
  external bool? get standalone;
}
