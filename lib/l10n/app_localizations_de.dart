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
  String get navIntake => 'Firmenaufnahme';

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
  String get btnBack => 'Zurück';

  @override
  String get btnNext => 'Weiter';

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
  String get statSourcesTotal => 'Quellen gesamt';

  @override
  String get statSourcesNew => 'Neue Quellen';

  @override
  String get statIntakeStatus => 'Firmenaufnahme';

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
  String get dashboardRecommendationSourcesTitle => 'Quellen prüfen';

  @override
  String dashboardRecommendationSourcesDescription(int count) {
    return '$count neue Quellen warten darauf, geprüft und bei Bedarf in Wissen übernommen zu werden.';
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
  String get dashboardRecommendationIntakeTitle => 'Firmenaufnahme starten';

  @override
  String get dashboardRecommendationIntakeDescription =>
      'Für diesen Workspace gibt es noch keine strukturierte Firmenaufnahme.';

  @override
  String get dashboardRecommendationIntakeImportTitle =>
      'Firmenaufnahme übernehmen';

  @override
  String get dashboardRecommendationIntakeImportDescription =>
      'Die Firmenaufnahme ist abgeschlossen, aber noch nicht kontrolliert in den Workspace übernommen.';

  @override
  String get intakeTitle => 'Firmenaufnahme';

  @override
  String intakeSubtitle(String companyName) {
    return 'Strukturierte Aufnahme für $companyName';
  }

  @override
  String intakeStepOfTotal(int current, int total) {
    return 'Schritt $current von $total';
  }

  @override
  String get intakeStatusDraft => 'Entwurf';

  @override
  String get intakeStatusInProgress => 'In Bearbeitung';

  @override
  String get intakeStatusCompleted => 'Abgeschlossen';

  @override
  String get intakeStatusNotStarted => 'Nicht begonnen';

  @override
  String get intakeImportStatusReady => 'Bereit zur Übernahme';

  @override
  String get intakeImportStatusImported => 'Übernommen';

  @override
  String get intakeSaveDraft => 'Entwurf speichern';

  @override
  String get intakeDraftSaved => 'Entwurf gespeichert.';

  @override
  String get intakeCompleted => 'Firmenaufnahme abgeschlossen.';

  @override
  String get intakeSummaryTitle => 'Zusammenfassung';

  @override
  String get intakeSummaryNotice =>
      'Diese Firmenaufnahme ist gespeichert. Die Übernahme in den Workspace folgt im nächsten Schritt.';

  @override
  String get intakeMarkCompleted => 'Als abgeschlossen markieren';

  @override
  String get intakePrepareImport => 'Übernahme vorbereiten';

  @override
  String get intakeMappingPreviewTitle => 'Übernahme-Vorschau';

  @override
  String get intakeMappingPreviewDescription =>
      'Prüfe, welche Intake-Daten in welche Workspace-Bereiche geschrieben werden. Konflikte sind standardmäßig nicht ausgewählt.';

  @override
  String get intakeMappingConflictWarning =>
      'Einige Vorschläge unterscheiden sich von bestehenden Workspace-Daten und müssen bewusst ausgewählt werden.';

  @override
  String get intakeConflict => 'Konflikt';

  @override
  String get intakeCurrentValue => 'Aktueller Wert';

  @override
  String get intakeProposedValue => 'Vorschlag';

  @override
  String get intakeKnowledgeDraftEmpty =>
      'Leerer FAQ-Entwurf – Antwort muss vor Nutzung ergänzt werden.';

  @override
  String get intakeImportSelected => 'Ausgewählte Daten übernehmen';

  @override
  String get intakeImportConfirmTitle => 'Ausgewählte Daten übernehmen?';

  @override
  String get intakeImportConfirmDescription =>
      'Nur die ausgewählten Vorschläge werden in diesen Workspace geschrieben. Bestehende Daten werden nur bei ausgewählten Konflikten ersetzt.';

  @override
  String get intakeImportSuccess =>
      'Ausgewählte Intake-Daten wurden übernommen.';

  @override
  String get intakeNoAnswer => 'Noch nicht beantwortet';

  @override
  String get intakeStepBasicsTitle => 'Basisdaten';

  @override
  String get intakeStepBasicsDescription =>
      'Grunddaten, Kontaktwege und kurze Einordnung der Firma.';

  @override
  String get intakeStepProductsTitle => 'Produkte / Leistungen';

  @override
  String get intakeStepProductsDescription =>
      'Was angeboten wird, was Priorität hat und was erklärt werden muss.';

  @override
  String get intakeStepTargetGroupsTitle => 'Zielgruppe / Positionierung';

  @override
  String get intakeStepTargetGroupsDescription =>
      'Für wen die Firma arbeitet und welcher Nutzen klar kommuniziert werden soll.';

  @override
  String get intakeStepWebsiteSupportTitle => 'Website / Support / FAQ';

  @override
  String get intakeStepWebsiteSupportDescription =>
      'Wichtige Seiten, häufige Fragen und sensible Supportthemen.';

  @override
  String get intakeStepSourcesReviewsTitle => 'Quellen / Rezensionen';

  @override
  String get intakeStepSourcesReviewsDescription =>
      'Vorhandene Materialien, Rezensionen, Social-Signale und Vertrauenselemente.';

  @override
  String get intakeStepMarketingTitle => 'Marketing / Kanäle';

  @override
  String get intakeStepMarketingDescription =>
      'Bisherige Kanäle, Maßnahmen und Reichweitenprobleme.';

  @override
  String get intakeStepGoalsRisksTitle => 'Ziele / Risiken / No-Go';

  @override
  String get intakeStepGoalsRisksDescription =>
      'Prioritäten, verbotene Aussagen und Themen für Human Review.';

  @override
  String get intakeImportantProducts => 'Wichtigste Produkte / Leistungen';

  @override
  String get intakeMainProduct => 'Hauptprodukt';

  @override
  String get intakeExplanationNeeded => 'Erklärungsbedürftige Produkte';

  @override
  String get intakePriorityProducts => 'Aktuelle Produktprioritäten';

  @override
  String get intakeTargetGroup => 'Zielgruppe';

  @override
  String get intakeMarketType => 'B2B / B2C';

  @override
  String get intakeProblemSolved => 'Welches Problem wird gelöst?';

  @override
  String get intakeCustomerBenefit => 'Wichtigster Kundennutzen';

  @override
  String get intakeDifferentiation => 'Abgrenzung zur Konkurrenz';

  @override
  String get intakeImportantPages => 'Wichtige Website- / Landingpages';

  @override
  String get intakeFrequentQuestions => 'Häufige Kundenfragen';

  @override
  String get intakeSupportProblems => 'Häufige Supportprobleme';

  @override
  String get intakeSensitiveTopics => 'Sensible Fragen / Themen';

  @override
  String get intakeExistingSources => 'Vorhandene Quellen / PDFs / Anleitungen';

  @override
  String get intakeReviews => 'Rezensionen / Testimonials';

  @override
  String get intakeSocialMentions =>
      'Social-Media-Erwähnungen / externe Diskussionen';

  @override
  String get intakeTrustMaterial => 'Trust-Material';

  @override
  String get intakeChannels => 'Bisher genutzte Kanäle';

  @override
  String get intakeCampaigns => 'Bisherige Werbemaßnahmen';

  @override
  String get intakeWorked => 'Was hat funktioniert?';

  @override
  String get intakeNotWorked => 'Was hat nicht funktioniert?';

  @override
  String get intakeReachProblems => 'Aktuelle Reichweitenprobleme';

  @override
  String get intakeCompanyGoals => 'Wichtigste Ziele der Firma';

  @override
  String get intakeShortTermPriorities => 'Kurzfristige Prioritäten';

  @override
  String get intakeForbiddenClaims => 'Sensible / verbotene Aussagen';

  @override
  String get intakeBotRestrictedTopics =>
      'Themen, die ein Bot nicht frei beantworten darf';

  @override
  String get intakeChatTitle => 'Chat-Aufnahme';

  @override
  String get intakeChatSubtitle =>
      'Regelbasierter Fragebogen-Chat ohne KI/API. Antworten werden direkt in die Firmenaufnahme gespeichert.';

  @override
  String get intakeChatStart => 'Chat-Aufnahme starten';

  @override
  String get intakeChatResume => 'Chat-Aufnahme fortsetzen';

  @override
  String get intakeChatSharedDataHint =>
      'Wizard und Chat verwenden dieselben gespeicherten Intake-Daten.';

  @override
  String get intakeChatOpenWizard => 'Zur Wizard-Ansicht';

  @override
  String intakeChatQuestionProgress(int current, int total) {
    return 'Frage $current von $total';
  }

  @override
  String get intakeChatCompletedProgress => 'Abgeschlossen';

  @override
  String get intakeChatInputHint => 'Antwort eingeben …';

  @override
  String get intakeChatDoneInputHint => 'Alle Fragen sind beantwortet.';

  @override
  String get intakeChatYes => 'Ja';

  @override
  String get intakeChatNo => 'Nein';

  @override
  String get intakeChatSkip => 'Überspringen';

  @override
  String get intakeChatPause => 'Später fortsetzen';

  @override
  String get intakeChatGoToSummary => 'Zur Firmenaufnahme-Zusammenfassung';

  @override
  String get intakeChatGreeting =>
      'Hallo! Ich führe dich Schritt für Schritt durch die Firmenaufnahme.';

  @override
  String get intakeChatExplanation =>
      'Ich stelle immer nur eine Frage. Deine Antworten landen direkt in derselben IntakeSession wie der Wizard.';

  @override
  String get intakeChatAllDone =>
      'Die Chat-Aufnahme ist vollständig. Du kannst jetzt zur Zusammenfassung wechseln und die Übernahme vorbereiten.';

  @override
  String get intakeChatEmptyAnswer =>
      'Bitte gib eine Antwort ein oder überspringe die Frage.';

  @override
  String get intakeChatSkipped => 'Frage übersprungen.';

  @override
  String get intakeChatQCompanyName => 'Wie heißt die Firma?';

  @override
  String get intakeChatQShortDescription =>
      'Beschreibe die Firma kurz in 1–3 Sätzen.';

  @override
  String get intakeChatQIndustry =>
      'In welcher Branche oder Kategorie ist die Firma tätig?';

  @override
  String get intakeChatQCountry =>
      'In welchem Land ist die Firma hauptsächlich aktiv?';

  @override
  String get intakeChatQPrimaryLanguage =>
      'Welche Hauptsprache soll der Workspace verwenden?';

  @override
  String get intakeChatQHasWebsite => 'Gibt es bereits eine Website?';

  @override
  String get intakeChatQWebsite => 'Wie lautet die Website-URL?';

  @override
  String get intakeChatQSupportEmail =>
      'Welche Support-E-Mail soll verwendet werden?';

  @override
  String get intakeChatQSupportPhone => 'Gibt es eine Support-Telefonnummer?';

  @override
  String get intakeChatQImportantProducts =>
      'Welche wichtigsten Produkte oder Leistungen gibt es? Du kannst mehrere Zeilen verwenden.';

  @override
  String get intakeChatQMainProduct =>
      'Was ist aktuell das Hauptprodukt oder Hauptangebot?';

  @override
  String get intakeChatQPriorityProducts =>
      'Welche Produkte oder Leistungen haben aktuell Priorität?';

  @override
  String get intakeChatQExplanationNeeded =>
      'Welche Produkte oder Leistungen sind erklärungsbedürftig?';

  @override
  String get intakeChatQTargetGroup => 'Wer ist die wichtigste Zielgruppe?';

  @override
  String get intakeChatQMarketType =>
      'Ist das Angebot eher B2B, B2C oder beides?';

  @override
  String get intakeChatQProblemSolved =>
      'Welches Problem löst das Angebot für Kunden?';

  @override
  String get intakeChatQCustomerBenefit =>
      'Was ist der wichtigste Kundennutzen?';

  @override
  String get intakeChatQDifferentiation =>
      'Wodurch unterscheidet sich die Firma von Alternativen?';

  @override
  String get intakeChatQImportantPages =>
      'Welche Website- oder Landingpages sind wichtig?';

  @override
  String get intakeChatQFrequentQuestions =>
      'Welche Fragen stellen Kunden besonders häufig?';

  @override
  String get intakeChatQSupportProblems =>
      'Welche Supportprobleme treten häufig auf?';

  @override
  String get intakeChatQHasSensitiveTopics =>
      'Gibt es sensible Fragen oder Themen?';

  @override
  String get intakeChatQSensitiveTopics =>
      'Welche sensiblen Fragen oder Themen sollen besonders vorsichtig behandelt werden?';

  @override
  String get intakeChatQExistingSources =>
      'Welche PDFs, Anleitungen, Notizen oder Materialien sind bereits vorhanden?';

  @override
  String get intakeChatQHasReviews => 'Gibt es Rezensionen oder Testimonials?';

  @override
  String get intakeChatQReviews =>
      'Welche Rezensionen oder Testimonials sind relevant?';

  @override
  String get intakeChatQHasSocialMentions =>
      'Gibt es Social-Media-Erwähnungen oder externe Diskussionen?';

  @override
  String get intakeChatQSocialMentions =>
      'Welche Social-Media-Erwähnungen oder externen Diskussionen sind wichtig?';

  @override
  String get intakeChatQHasTrustMaterial =>
      'Gibt es Trust-Material wie Siegel, Referenzen oder Nachweise?';

  @override
  String get intakeChatQTrustMaterial =>
      'Welches Trust-Material ist vorhanden?';

  @override
  String get intakeChatQChannels =>
      'Welche Marketing- oder Kommunikationskanäle wurden bisher genutzt?';

  @override
  String get intakeChatQCampaigns =>
      'Welche Werbemaßnahmen wurden bisher ausprobiert?';

  @override
  String get intakeChatQWorkedNotWorked =>
      'Was hat bisher funktioniert und was nicht?';

  @override
  String get intakeChatQReachProblems =>
      'Wo bestehen aktuell Reichweitenprobleme?';

  @override
  String get intakeChatQCompanyGoals =>
      'Was sind die wichtigsten Ziele der Firma?';

  @override
  String get intakeChatQShortTermPriorities =>
      'Was sind die kurzfristigen Prioritäten?';

  @override
  String get intakeChatQForbiddenClaims =>
      'Welche Aussagen sind sensibel oder verboten?';

  @override
  String get intakeChatQBotRestrictedTopics =>
      'Welche Themen darf ein Bot nicht frei beantworten?';

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
  String get knowledgeSourceMaterialOptional =>
      'Quellenmaterial verknüpfen (optional)';

  @override
  String get knowledgeNoSourceMaterial => 'Keine Quelle verknüpfen';

  @override
  String get knowledgeMarkSourceConverted => 'Quelle als übernommen markieren';

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
  String get sourcesSubtitle => 'Quellen und Materialien dieses Workspaces';

  @override
  String get sourcesAdd => 'Quelle hinzufügen';

  @override
  String sourcesCount(int count) {
    return '$count Quellen';
  }

  @override
  String sourcesNewCount(int count) {
    return '$count neu';
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
  String get sourcesFilterAllTypes => 'Alle Typen';

  @override
  String get sourcesFilterAllStatuses => 'Alle Status';

  @override
  String sourcesLinkedEntries(int count) {
    return '$count verknüpfte Einträge';
  }

  @override
  String get sourcesDeleteTitle => 'Quelle löschen?';

  @override
  String sourcesDeleteConfirm(String title) {
    return '\"$title\" wird aus der Quellenliste entfernt. Wissenseinträge bleiben erhalten.';
  }

  @override
  String get sourcesEdit => 'Quelle bearbeiten';

  @override
  String get sourcesType => 'Quellentyp';

  @override
  String get sourcesStatus => 'Status';

  @override
  String get sourcesUrlOptional => 'URL (optional)';

  @override
  String get sourcesSnippetOptional => 'Inhaltsauszug (optional)';

  @override
  String get sourcesNotesOptional => 'Notizen (optional)';

  @override
  String get sourceTypeUrl => 'Website';

  @override
  String get sourceTypeDocument => 'Dokument';

  @override
  String get sourceTypeManual => 'Manuell';

  @override
  String get sourceMaterialTypeWebsite => 'Website';

  @override
  String get sourceMaterialTypePdf => 'PDF';

  @override
  String get sourceMaterialTypeFaq => 'FAQ';

  @override
  String get sourceMaterialTypeReview => 'Rezension';

  @override
  String get sourceMaterialTypeSocial => 'Social';

  @override
  String get sourceMaterialTypeNote => 'Notiz';

  @override
  String get sourceMaterialTypeOther => 'Sonstiges';

  @override
  String get sourceMaterialStatusNew => 'Neu';

  @override
  String get sourceMaterialStatusReviewed => 'Geprüft';

  @override
  String get sourceMaterialStatusConverted => 'Übernommen';

  @override
  String get sourceMaterialStatusIgnored => 'Ignoriert';

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
