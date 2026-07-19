import 'external_link_opener_base.dart';
import 'external_link_opener_stub.dart'
    if (dart.library.html) 'external_link_opener_web.dart'
    as implementation;

export 'external_link_opener_base.dart';

PreparedExternalLink? prepareExternalLink() {
  return implementation.prepareExternalLink();
}

bool openExternalLink(String url) {
  return implementation.openExternalLink(url);
}
