import '../models/company_workspace.dart';

/// Stable knowledge-area identifiers stored on knowledge entries.
///
/// They describe content scope only. They are deliberately unrelated to
/// roles, permissions or visibility; every area remains available in the
/// current demo.
abstract final class KnowledgeAreas {
  static const businessBrainPlatform = 'businessbrain_platform';
  static const hbCureCompany = 'hb_cure_company';
  static const hbCureApp = 'hb_cure_app';
  static const cureBase = 'curebase';
  static const cureClip = 'cureclip';
  static const schnurrPurr = 'schnurrpurr';
  static const otherProduct = 'other_product';

  static String label(String? area, {required String languageCode}) {
    final de = languageCode.toLowerCase().startsWith('de');
    return switch (area) {
      businessBrainPlatform => 'BusinessBrain Plattform',
      hbCureCompany => 'HB Cure Unternehmen',
      hbCureApp => 'HB Cure App',
      cureBase => 'CureBase',
      cureClip => 'CureClip',
      schnurrPurr => 'SchnurrPurr',
      otherProduct => de ? 'Weiteres Produkt' : 'Other product',
      _ => de ? 'Allgemeines Unternehmenswissen' : 'General company knowledge',
    };
  }
}

/// Deterministic scope and topic detection shared by Knowledge Builder and
/// grounded retrieval. It only classifies text; it never changes knowledge.
class KnowledgeContextDetector {
  const KnowledgeContextDetector();

  String? detectArea(String text, {CompanyWorkspace? workspace}) {
    final value = _normalize(text);
    final workspaceText = workspace == null
        ? ''
        : _normalize(
            '${workspace.company.id} ${workspace.company.name} '
            '${workspace.products.map((p) => p.name).join(' ')}',
          );

    if (_has(value, const ['businessbrain', 'business brain'])) {
      return KnowledgeAreas.businessBrainPlatform;
    }
    if (_has(value, const ['curebase', 'cure base'])) {
      return KnowledgeAreas.cureBase;
    }
    if (_has(value, const ['cureclip', 'cure clip'])) {
      return KnowledgeAreas.cureClip;
    }
    if (value.contains('schnurrpurr')) return KnowledgeAreas.schnurrPurr;

    final appCue = _has(value, const [
      ' app ',
      'anwendung',
      'application',
      'smartphone',
      'bluetooth',
      'firmware',
      'pairing',
      'koppeln',
      'timer',
    ]);
    final hbCue = _has(value, const [
      'hb cure',
      'healing und balance',
      'healing balance',
    ]);
    final hbWorkspace = _has(workspaceText, const [
      'hb cure',
      'healing und balance',
      'healing balance',
    ]);
    final schnurrWorkspace = workspaceText.contains('schnurrpurr');
    final otherProductCue = _has(value, const [
      ' produkt ',
      ' product ',
      ' weiteres produkt ',
      ' other product ',
    ]);

    if (appCue && (hbCue || hbWorkspace)) return KnowledgeAreas.hbCureApp;
    if (appCue && schnurrWorkspace) return KnowledgeAreas.schnurrPurr;
    if (hbCue) return KnowledgeAreas.hbCureCompany;
    if (appCue) return KnowledgeAreas.otherProduct;
    if (otherProductCue) return KnowledgeAreas.otherProduct;
    if (hbWorkspace) return KnowledgeAreas.hbCureCompany;
    if (schnurrWorkspace) return KnowledgeAreas.schnurrPurr;
    return null;
  }

  /// Returns user-facing topics in the language of the input where a topic has
  /// a natural localized name. Product and technology names remain unchanged.
  List<String> detectTopics(String text, {required String? languageCode}) {
    final value = _normalize(text);
    final de = languageCode == 'de';
    final topics = <String>[];

    void addIf(List<String> signals, String label) {
      if (_has(value, signals) && !topics.contains(label)) topics.add(label);
    }

    addIf(const ['bluetooth', 'pairing', 'koppeln'], 'Bluetooth');
    addIf(const ['firmware'], 'Firmware');
    addIf(const ['programm', 'program'], de ? 'Programme' : 'Programs');
    addIf(const ['timer'], 'Timer');
    addIf(const [
      'verbindung',
      'verbinden',
      'connection',
      'connect',
    ], de ? 'Verbindung' : 'Connection');
    addIf(const ['gerät', 'device', 'hardware'], de ? 'Gerät' : 'Device');
    addIf(const [' app ', 'anwendung', 'application'], 'App');
    addIf(const ['android'], 'Android');
    addIf(const [' ios ', 'iphone'], 'iOS');
    addIf(const [
      'installation',
      'installier',
      'setup',
    ], de ? 'Installation' : 'Installation');
    addIf(const ['support', 'hilfe', 'help'], de ? 'Support' : 'Support');
    return List.unmodifiable(topics);
  }

  String _normalize(String text) =>
      ' ${text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9äöüß]+'), ' ').trim()} ';

  bool _has(String value, List<String> signals) =>
      signals.any((signal) => value.contains(signal));
}
