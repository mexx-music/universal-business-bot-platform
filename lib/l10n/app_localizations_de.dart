// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'UniversalBiz';

  @override
  String get appStage => 'Stufe 1';

  @override
  String get landingHeadline => 'Universal Business Bot Plattform';

  @override
  String get landingSubtitle =>
      'Verwalte Business-Wissen, sichere Bot-Antworten, Audit-Checks und Human Review für mehrere Firmen in einem lokalen Demo-Workspace.';

  @override
  String get landingFeatureKnowledge => 'Business-Wissen';

  @override
  String get landingFeatureBot => 'Bot';

  @override
  String get landingFeatureAudit => 'Audit';

  @override
  String get landingFeatureReview => 'Human Review';

  @override
  String get landingStepsTitle => 'Demo-Flow';

  @override
  String get landingStepCompanyTitle => 'Firma erfassen';

  @override
  String get landingStepCompanyDescription =>
      'Business Core, Kontaktwege und Regeln pro Workspace pflegen.';

  @override
  String get landingStepKnowledgeTitle => 'Wissen strukturieren';

  @override
  String get landingStepKnowledgeDescription =>
      'FAQ, Quellen und Supportwissen in sichere Einträge überführen.';

  @override
  String get landingStepBotTitle => 'Bot sicher testen';

  @override
  String get landingStepBotDescription =>
      'Bot-Fragen prüfen, blockieren und per Human Review absichern.';

  @override
  String get landingDemoTitle => 'Demo-Firmen';

  @override
  String get landingOpenDemo => 'Demo öffnen';

  @override
  String get landingBackHome => 'Zur Startseite';

  @override
  String get companySelectTitle => 'Firma auswählen';

  @override
  String get companySelectHeadline => 'Workspace wählen';

  @override
  String get companySelectSubtitle =>
      'Wähle eine Demo-Firma. Dashboard, Firma, Audit, Wissensbasis, Bot-Test, Prüfung und Quellen arbeiten danach mit getrennten lokalen Daten.';

  @override
  String get companySelectButton => 'Auswählen';

  @override
  String get companySwitch => 'Firma wechseln';

  @override
  String get companyCurrent => 'Aktuelle Firma';

  @override
  String get companyCreatePlaceholder => 'Neue Firma anlegen (später)';

  @override
  String companyProductCount(int count) {
    return '$count Produkte';
  }

  @override
  String companyKnowledgeCount(int count) {
    return '$count Wissenseinträge';
  }

  @override
  String companyLogCount(int count) {
    return '$count Logs';
  }

  @override
  String companyAuditScore(int score) {
    return 'Audit $score%';
  }

  @override
  String companyOpenReviewCount(int count) {
    return '$count offene Reviews';
  }

  @override
  String get navHome => 'Startseite';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navCompany => 'Firma';

  @override
  String get navAudit => 'Audit';

  @override
  String get navKnowledge => 'Wissensbasis';

  @override
  String get navBotTest => 'Bot-Test';

  @override
  String get navBotSettings => 'Bot-Einstellungen';

  @override
  String get navSources => 'Quellen';

  @override
  String get btnCancel => 'Abbrechen';

  @override
  String get btnSave => 'Speichern';

  @override
  String get btnEdit => 'Bearbeiten';

  @override
  String get btnDelete => 'Löschen';

  @override
  String get btnAdd => 'Hinzufügen';

  @override
  String get btnReset => 'Zurücksetzen';

  @override
  String get fieldCompanyName => 'Firmenname';

  @override
  String get fieldIndustry => 'Branche';

  @override
  String get fieldDescription => 'Beschreibung';

  @override
  String get fieldWebsite => 'Website';

  @override
  String get fieldEmail => 'E-Mail';

  @override
  String get fieldPhone => 'Telefon';

  @override
  String get fieldAddress => 'Adresse';

  @override
  String get fieldCountry => 'Land';

  @override
  String get fieldPrimaryLanguage => 'Primäre Sprache';

  @override
  String get fieldSupportEmail => 'Support-E-Mail';

  @override
  String get fieldSupportPhone => 'Support-Telefon';

  @override
  String get fieldFacebook => 'Facebook';

  @override
  String get fieldInstagram => 'Instagram';

  @override
  String get fieldYoutube => 'YouTube';

  @override
  String get fieldTelegram => 'Telegram';

  @override
  String get fieldTitle => 'Titel';

  @override
  String get fieldContent => 'Inhalt';

  @override
  String get fieldCategory => 'Kategorie';

  @override
  String get fieldKeywords => 'Schlüsselwörter (kommagetrennt)';

  @override
  String get fieldSource => 'Quelle';

  @override
  String dashboardSubtitle(String companyName) {
    return 'Übersicht · $companyName';
  }

  @override
  String get statKnowledgeEntries => 'Wissenseinträge';

  @override
  String get statBotRequests => 'Bot-Anfragen';

  @override
  String get statMatchRate => 'Match-Rate';

  @override
  String get statProducts => 'Produkte & Leistungen';

  @override
  String get dashboardRecentRequests => 'Letzte Bot-Anfragen';

  @override
  String dashboardTotal(int count) {
    return '$count gesamt';
  }

  @override
  String get dashboardNoLogs => 'Noch keine Bot-Anfragen. Starte den Bot-Test.';

  @override
  String get logNoAnswer => 'Keine Antwort gefunden';

  @override
  String get dashboardNextStepsTitle => 'Nächste empfohlene Schritte';

  @override
  String get dashboardRecommendationAuditTitle => 'Audit-Lücken schließen';

  @override
  String dashboardRecommendationAuditDescription(int count) {
    return '$count High-Priority-Auditpunkte fehlen noch.';
  }

  @override
  String get dashboardRecommendationKnowledgeTitle => 'Wissensbasis erweitern';

  @override
  String dashboardRecommendationKnowledgeDescription(int count) {
    return 'Aktuell sind $count Wissenseinträge vorhanden. Für eine Demo sollten mehr sichere FAQ und Supportfälle ergänzt werden.';
  }

  @override
  String get dashboardRecommendationReviewTitle => 'Human Review prüfen';

  @override
  String dashboardRecommendationReviewDescription(int count) {
    return '$count Bot-Fragen warten auf Prüfung.';
  }

  @override
  String get dashboardRecommendationProfileTitle => 'Firmenprofil ergänzen';

  @override
  String get dashboardRecommendationProfileDescription =>
      'Business Core, Kontaktwege oder Business Rules sind noch nicht vollständig gepflegt.';

  @override
  String get dashboardRecommendationAllDoneTitle =>
      'Workspace wirkt demo-bereit';

  @override
  String get dashboardRecommendationAllDoneDescription =>
      'Keine dringenden nächsten Schritte aus den aktuellen Workspace-Daten ableitbar.';

  @override
  String get dashboardRecommendationBotSettingsTitle =>
      'Bot-Einstellungen prüfen';

  @override
  String get dashboardRecommendationBotSettingsDescription =>
      'Der Bot ist noch im Entwurf. Prüfe Status, Eskalation und Handover-Regeln vor dem Test.';

  @override
  String get companyTitle => 'Firma';

  @override
  String get companyEditDialogTitle => 'Firmendaten bearbeiten';

  @override
  String get companyProducts => 'Produkte & Leistungen';

  @override
  String get companyCoreSubtitle =>
      'Business Core für Audit, Wissensbasis, Bot und externe Kanäle';

  @override
  String get companyProfileSection => 'Firmenprofil';

  @override
  String get companyContactWebSection => 'Kontakt & Web';

  @override
  String get companySocialSection => 'Social / Kanäle';

  @override
  String get companyBusinessRulesSection => 'Business Rules';

  @override
  String get companyInternalNotesSection => 'Interne Notizen';

  @override
  String get companyNoSocialLinks =>
      'Noch keine Social- oder Kanal-Links gepflegt.';

  @override
  String get companyNoInternalNotes => 'Noch keine internen Notizen gepflegt.';

  @override
  String get companyBrandVoice => 'Brand Voice / Tonalität';

  @override
  String get companyDoNotSay => 'Do-not-say / No-Go-Regeln';

  @override
  String get companyAllowedSupportTopics => 'Erlaubte Support-Themen';

  @override
  String get companyEscalationNotes => 'Eskalationshinweise';

  @override
  String get companyDisclaimerText => 'Disclaimer-Text';

  @override
  String get companyProfileComplete => 'Vollständig';

  @override
  String get companyProfilePartial => 'Teilweise';

  @override
  String get companyProfileIncomplete => 'Unvollständig';

  @override
  String get auditTitle => 'Audit';

  @override
  String get auditSubtitle => 'Vollständigkeitscheck für den Bot-Einsatz';

  @override
  String get auditTotalScore => 'Gesamtscore';

  @override
  String auditScoreLabel(int score, int max) {
    return '$score / $max Punkte';
  }

  @override
  String get auditExcellent => 'Ausgezeichnet – Bot ist bereit!';

  @override
  String get auditGood => 'Gut – kleine Lücken noch schließen.';

  @override
  String get auditMedium => 'Mittelmäßig – Wissen ausbauen empfohlen.';

  @override
  String get auditPoor => 'Unvollständig – Bot noch nicht einsatzbereit.';

  @override
  String get auditChecklist => 'Checkliste';

  @override
  String auditPoints(int points) {
    return '+$points Pkt.';
  }

  @override
  String get auditCheckCompanyName => 'Firmenname eingetragen';

  @override
  String get auditCheckIndustry => 'Branche definiert';

  @override
  String get auditCheckDescription => 'Firmenbeschreibung vorhanden';

  @override
  String get auditCheckWebsite => 'Website eingetragen';

  @override
  String get auditCheckProducts => 'Produkte / Leistungen erfasst';

  @override
  String get auditCheckKnowledge => 'Wissenseinträge vorhanden';

  @override
  String get auditCheckKnowledge10 => 'Mindestens 10 Wissenseinträge';

  @override
  String get auditCheckBotTest => 'Bot-Test durchgeführt';

  @override
  String auditDescChars(int count) {
    return '$count Zeichen';
  }

  @override
  String get auditDescTooShort => 'Zu kurz (mind. 50 Zeichen)';

  @override
  String auditDescEntries(int count) {
    return '$count Einträge';
  }

  @override
  String get auditDescAchieved => 'Erreicht';

  @override
  String auditDescOfTotal(int current, int total) {
    return '$current von $total';
  }

  @override
  String get auditDescNoTest => 'Noch kein Test';

  @override
  String auditDescTestCount(int count) {
    return '$count Testanfragen';
  }

  @override
  String auditBusinessSubtitle(String companyName) {
    return 'Business-Status und Bot-Bereitschaft · $companyName';
  }

  @override
  String get auditBusinessStatusTitle => 'Status-Erhebung';

  @override
  String get auditItemsComplete => 'vollständig';

  @override
  String auditMissingCount(int count) {
    return '$count fehlt';
  }

  @override
  String auditPartialCount(int count) {
    return '$count teilweise';
  }

  @override
  String auditCompleteCount(int count) {
    return '$count vollständig';
  }

  @override
  String auditHighPriorityOpenCount(int count) {
    return '$count High-Priority offen';
  }

  @override
  String get auditAreaCompanyProfile => 'Firmenprofil';

  @override
  String get auditAreaWebsite => 'Website / Webauftritt';

  @override
  String get auditAreaProducts => 'Produkte / Dienstleistungen';

  @override
  String get auditAreaSupportKnowledge => 'FAQ / Supportwissen';

  @override
  String get auditAreaTrustMaterial => 'Rezensionen / Vertrauensmaterial';

  @override
  String get auditAreaSocialPresence => 'Social Media / Außenwirkung';

  @override
  String get auditAreaSources => 'Quellen / Dokumente';

  @override
  String get auditAreaRiskRules => 'Risiko / No-Go-Regeln';

  @override
  String get auditAreaBotReadiness => 'Bot-Bereitschaft';

  @override
  String get auditStatusMissing => 'Fehlt';

  @override
  String get auditStatusPartial => 'Teilweise';

  @override
  String get auditStatusComplete => 'Vollständig';

  @override
  String get auditPriorityLow => 'Niedrig';

  @override
  String get auditPriorityMedium => 'Mittel';

  @override
  String get auditPriorityHigh => 'Hoch';

  @override
  String get auditNote => 'Notiz';

  @override
  String get auditRecommendation => 'Empfehlung';

  @override
  String get auditEditNote => 'Notiz bearbeiten';

  @override
  String get auditNoteHint => 'Interne Notiz zu diesem Auditpunkt …';

  @override
  String get knowledgeTitle => 'Wissensbasis';

  @override
  String knowledgeEntryCount(int count) {
    return '$count Einträge';
  }

  @override
  String get knowledgeFilterAll => 'Alle';

  @override
  String get knowledgeNoEntries => 'Keine Einträge in dieser Kategorie.';

  @override
  String get knowledgeAddEntry => 'Eintrag hinzufügen';

  @override
  String get knowledgeDeleteTitle => 'Eintrag löschen?';

  @override
  String knowledgeDeleteConfirm(String title) {
    return '\"$title\" wird unwiderruflich entfernt.';
  }

  @override
  String get knowledgeNewEntry => 'Neuer Wissenseintrag';

  @override
  String get botTestTitle => 'Bot-Test';

  @override
  String get botTestSubtitle =>
      'Simulierter Bot ohne echte KI – Antworten basieren auf der Wissensbasis.';

  @override
  String get botTestGreeting =>
      'Hallo! Ich bin dein Bot-Assistent. Stelle mir eine Frage über das Unternehmen.';

  @override
  String get botTestInputHint => 'Frage eingeben …';

  @override
  String get botTestNoMatch =>
      'Keine passende Antwort gefunden. Bitte kontaktieren Sie uns direkt.';

  @override
  String get botTestResetMessage =>
      'Chat zurückgesetzt. Stelle mir eine neue Frage!';

  @override
  String get sourcesTitle => 'Quellen';

  @override
  String get sourcesSubtitle => 'Herkunft der Wissenseinträge';

  @override
  String sourcesCount(int count) {
    return '$count Quellen';
  }

  @override
  String sourcesEntriesCount(int count) {
    return '$count Einträge';
  }

  @override
  String get sourcesEmpty => 'Noch keine Quellen vorhanden.';

  @override
  String sourcesEntryInfo(int count, String type) {
    return '$count Einträge · $type';
  }

  @override
  String get sourceTypeUrl => 'Website';

  @override
  String get sourceTypeDocument => 'Dokument';

  @override
  String get sourceTypeManual => 'Manuell';

  @override
  String get sourcesStage2Hint =>
      'In Stufe 2 können Quellen direkt importiert werden (Websites, PDFs, Dokumente).';

  @override
  String get categoryFaq => 'FAQ';

  @override
  String get categoryProdukt => 'Produkt';

  @override
  String get categoryProzess => 'Prozess';

  @override
  String get categoryAllgemein => 'Allgemein';

  @override
  String get typeProdukt => 'Produkt';

  @override
  String get typeDienstleistung => 'Dienstleistung';

  @override
  String get riskGreen => 'Sicher';

  @override
  String get riskYellow => 'Wellness';

  @override
  String get riskRed => 'Gesperrt';

  @override
  String botTestRedirectMessage(String supportEmail) {
    return 'Diese Frage berührt medizinische oder rechtliche Bereiche, die ich nicht beantworten darf. Bitte wenden Sie sich an eine qualifizierte Fachstelle oder kontaktieren Sie unseren Support direkt: $supportEmail';
  }

  @override
  String get botTestYellowDisclaimer =>
      'Hinweis: Diese Antwort dient nur zur allgemeinen Information und ersetzt keine ärztliche Beratung.';

  @override
  String get statOpenRequests => 'Offene Anfragen';

  @override
  String get statRedirects => 'Weiterleitungen';

  @override
  String get statReviewedBotQuestions => 'Geprüfte Bot-Fragen';

  @override
  String get statAuditScore => 'Audit-Score';

  @override
  String get statAuditMissing => 'Audit fehlt';

  @override
  String get statAuditPartial => 'Audit teilweise';

  @override
  String get statAuditComplete => 'Audit vollständig';

  @override
  String get statAuditHighPriorityOpen => 'High-Priority-Lücken';

  @override
  String get statCompanyProfile => 'Firmenprofil';

  @override
  String get statBotStatus => 'Bot-Status';

  @override
  String get statReviewOpen => 'Offen zur Prüfung';

  @override
  String get dashboardRiskTitle => 'Wissensbasis nach Risikostufe';

  @override
  String get knowledgeRisk => 'Risikostufe';

  @override
  String get navReview => 'Prüfung';

  @override
  String get reviewTitle => 'Human Review';

  @override
  String get reviewSubtitle => 'Bot-Anfragen zur manuellen Prüfung';

  @override
  String get reviewEmpty => 'Keine Einträge zur Prüfung.';

  @override
  String get reviewFilterAll => 'Alle';

  @override
  String reviewOpenCount(int count) {
    return '$count offen';
  }

  @override
  String get reviewStatusOpen => 'Offen';

  @override
  String get reviewStatusReviewed => 'Geprüft';

  @override
  String get reviewStatusClosed => 'Erledigt';

  @override
  String get reviewReasonNoMatch => 'Kein Match';

  @override
  String get reviewReasonRedFlag => 'Rote Frage';

  @override
  String get reviewReasonYellowRisk => 'Gelbe Antwort';

  @override
  String get reviewReasonLowConfidence => 'Niedrige Sicherheit';

  @override
  String get reviewBotAnswer => 'Bot-Antwort';

  @override
  String get reviewHumanNote => 'Notiz';

  @override
  String get reviewNoteHint => 'Notiz für das Team …';

  @override
  String get reviewSaveNote => 'Notiz speichern';

  @override
  String get reviewAddNote => 'Notiz bearbeiten';

  @override
  String get reviewMarkReviewed => 'Als geprüft markieren';

  @override
  String get reviewMarkClosed => 'Als erledigt schließen';

  @override
  String get reviewCreateKnowledgeEntry => 'Als Wissenseintrag anlegen';

  @override
  String get reviewKnowledgeSourceOptional => 'Quelle (optional)';

  @override
  String get reviewKnowledgeDefaultSource => 'Human Review';

  @override
  String get reviewKnowledgeCreatedNote => 'Als Wissenseintrag übernommen';

  @override
  String get botSettingsTitle => 'Bot-Einstellungen';

  @override
  String botSettingsSubtitle(String companyName) {
    return 'Konfiguration für $companyName';
  }

  @override
  String get botSettingsStatus => 'Status';

  @override
  String get botSettingsAnswerStyle => 'Antwortstil';

  @override
  String get botSettingsLanguage => 'Sprache';

  @override
  String get botSettingsDisclaimer => 'Disclaimer';

  @override
  String get botSettingsUseDisclaimer =>
      'Disclaimer bei gelben Antworten anzeigen';

  @override
  String get botSettingsDisclaimerText => 'Disclaimer-Text';

  @override
  String get botSettingsNoDisclaimer => 'Kein Disclaimer gepflegt.';

  @override
  String get botSettingsEscalation => 'Eskalation / Human Handover';

  @override
  String get botSettingsEscalateRedFlags => 'Rote Fragen immer eskalieren';

  @override
  String get botSettingsEscalateNoMatch => 'No-Match-Fragen in Review schicken';

  @override
  String get botSettingsEscalateYellowRisk =>
      'Gelbe Antworten in Review schicken';

  @override
  String get botSettingsHandoverMessage => 'Handover-Nachricht';

  @override
  String get botSettingsNoHandover => 'Keine Handover-Nachricht gepflegt.';

  @override
  String get botSettingsAllowedTopics => 'Erlaubte Themen';

  @override
  String get botSettingsBlockedTopics => 'Gesperrte Themen';

  @override
  String get botSettingsNoAllowedTopics =>
      'Noch keine erlaubten Themen gepflegt.';

  @override
  String get botSettingsNoBlockedTopics =>
      'Noch keine gesperrten Themen gepflegt.';

  @override
  String get botStatusDraft => 'Entwurf';

  @override
  String get botStatusTestReady => 'Testbereit';

  @override
  String get botStatusActive => 'Aktiv';

  @override
  String get botAnswerStyleShort => 'Kurz';

  @override
  String get botAnswerStyleBalanced => 'Ausgewogen';

  @override
  String get botAnswerStyleDetailed => 'Detailliert';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageEnglish => 'Englisch';
}
