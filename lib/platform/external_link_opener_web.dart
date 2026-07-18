import 'package:web/web.dart' as web;

import 'external_link_opener_base.dart';

class _WebPreparedExternalLink implements PreparedExternalLink {
  _WebPreparedExternalLink(this._window);

  final web.Window? _window;

  @override
  bool open(String url) {
    final window = _window;
    if (window == null) return openExternalLink(url);
    try {
      window.location.href = url;
      return true;
    } catch (_) {
      return openExternalLink(url);
    }
  }

  @override
  void close() {
    try {
      _window?.close();
    } catch (_) {
      // Browser implementations can reject closing windows they did not open.
    }
  }
}

PreparedExternalLink? prepareExternalLink() {
  try {
    return _WebPreparedExternalLink(web.window.open('', '_blank'));
  } catch (_) {
    return null;
  }
}

bool openExternalLink(String url) {
  try {
    return web.window.open(url, '_blank', 'noopener,noreferrer') != null;
  } catch (_) {
    return false;
  }
}
