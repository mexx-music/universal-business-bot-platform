import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In de, this message translates to:
  /// **'UniversalBiz'**
  String get appName;

  /// No description provided for @appStage.
  ///
  /// In de, this message translates to:
  /// **'Stufe 1'**
  String get appStage;

  /// No description provided for @landingHeadline.
  ///
  /// In de, this message translates to:
  /// **'Universal Business Bot Plattform'**
  String get landingHeadline;

  /// No description provided for @landingSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Verwalte Business-Wissen, sichere Bot-Antworten, Audit-Checks und Human Review für mehrere Firmen in einem lokalen Demo-Workspace.'**
  String get landingSubtitle;

  /// No description provided for @landingFeatureKnowledge.
  ///
  /// In de, this message translates to:
  /// **'Business-Wissen'**
  String get landingFeatureKnowledge;

  /// No description provided for @landingFeatureBot.
  ///
  /// In de, this message translates to:
  /// **'Bot'**
  String get landingFeatureBot;

  /// No description provided for @landingFeatureAudit.
  ///
  /// In de, this message translates to:
  /// **'Audit'**
  String get landingFeatureAudit;

  /// No description provided for @landingFeatureReview.
  ///
  /// In de, this message translates to:
  /// **'Human Review'**
  String get landingFeatureReview;

  /// No description provided for @landingDemoTitle.
  ///
  /// In de, this message translates to:
  /// **'Demo-Firmen'**
  String get landingDemoTitle;

  /// No description provided for @landingOpenDemo.
  ///
  /// In de, this message translates to:
  /// **'Demo öffnen'**
  String get landingOpenDemo;

  /// No description provided for @landingBackHome.
  ///
  /// In de, this message translates to:
  /// **'Zur Startseite'**
  String get landingBackHome;

  /// No description provided for @companySelectTitle.
  ///
  /// In de, this message translates to:
  /// **'Firma auswählen'**
  String get companySelectTitle;

  /// No description provided for @companySelectHeadline.
  ///
  /// In de, this message translates to:
  /// **'Workspace wählen'**
  String get companySelectHeadline;

  /// No description provided for @companySelectSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Wähle eine Demo-Firma. Dashboard, Firma, Audit, Wissensbasis, Bot-Test, Prüfung und Quellen arbeiten danach mit getrennten lokalen Daten.'**
  String get companySelectSubtitle;

  /// No description provided for @companySelectButton.
  ///
  /// In de, this message translates to:
  /// **'Auswählen'**
  String get companySelectButton;

  /// No description provided for @companySwitch.
  ///
  /// In de, this message translates to:
  /// **'Firma wechseln'**
  String get companySwitch;

  /// No description provided for @companyCurrent.
  ///
  /// In de, this message translates to:
  /// **'Aktuelle Firma'**
  String get companyCurrent;

  /// No description provided for @companyCreatePlaceholder.
  ///
  /// In de, this message translates to:
  /// **'Neue Firma anlegen (später)'**
  String get companyCreatePlaceholder;

  /// No description provided for @companyProductCount.
  ///
  /// In de, this message translates to:
  /// **'{count} Produkte'**
  String companyProductCount(int count);

  /// No description provided for @companyKnowledgeCount.
  ///
  /// In de, this message translates to:
  /// **'{count} Wissenseinträge'**
  String companyKnowledgeCount(int count);

  /// No description provided for @companyLogCount.
  ///
  /// In de, this message translates to:
  /// **'{count} Logs'**
  String companyLogCount(int count);

  /// No description provided for @navHome.
  ///
  /// In de, this message translates to:
  /// **'Startseite'**
  String get navHome;

  /// No description provided for @navDashboard.
  ///
  /// In de, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navCompany.
  ///
  /// In de, this message translates to:
  /// **'Firma'**
  String get navCompany;

  /// No description provided for @navAudit.
  ///
  /// In de, this message translates to:
  /// **'Audit'**
  String get navAudit;

  /// No description provided for @navKnowledge.
  ///
  /// In de, this message translates to:
  /// **'Wissensbasis'**
  String get navKnowledge;

  /// No description provided for @navBotTest.
  ///
  /// In de, this message translates to:
  /// **'Bot-Test'**
  String get navBotTest;

  /// No description provided for @navSources.
  ///
  /// In de, this message translates to:
  /// **'Quellen'**
  String get navSources;

  /// No description provided for @btnCancel.
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get btnCancel;

  /// No description provided for @btnSave.
  ///
  /// In de, this message translates to:
  /// **'Speichern'**
  String get btnSave;

  /// No description provided for @btnEdit.
  ///
  /// In de, this message translates to:
  /// **'Bearbeiten'**
  String get btnEdit;

  /// No description provided for @btnDelete.
  ///
  /// In de, this message translates to:
  /// **'Löschen'**
  String get btnDelete;

  /// No description provided for @btnAdd.
  ///
  /// In de, this message translates to:
  /// **'Hinzufügen'**
  String get btnAdd;

  /// No description provided for @btnReset.
  ///
  /// In de, this message translates to:
  /// **'Zurücksetzen'**
  String get btnReset;

  /// No description provided for @fieldCompanyName.
  ///
  /// In de, this message translates to:
  /// **'Firmenname'**
  String get fieldCompanyName;

  /// No description provided for @fieldIndustry.
  ///
  /// In de, this message translates to:
  /// **'Branche'**
  String get fieldIndustry;

  /// No description provided for @fieldDescription.
  ///
  /// In de, this message translates to:
  /// **'Beschreibung'**
  String get fieldDescription;

  /// No description provided for @fieldWebsite.
  ///
  /// In de, this message translates to:
  /// **'Website'**
  String get fieldWebsite;

  /// No description provided for @fieldEmail.
  ///
  /// In de, this message translates to:
  /// **'E-Mail'**
  String get fieldEmail;

  /// No description provided for @fieldPhone.
  ///
  /// In de, this message translates to:
  /// **'Telefon'**
  String get fieldPhone;

  /// No description provided for @fieldAddress.
  ///
  /// In de, this message translates to:
  /// **'Adresse'**
  String get fieldAddress;

  /// No description provided for @fieldTitle.
  ///
  /// In de, this message translates to:
  /// **'Titel'**
  String get fieldTitle;

  /// No description provided for @fieldContent.
  ///
  /// In de, this message translates to:
  /// **'Inhalt'**
  String get fieldContent;

  /// No description provided for @fieldCategory.
  ///
  /// In de, this message translates to:
  /// **'Kategorie'**
  String get fieldCategory;

  /// No description provided for @fieldKeywords.
  ///
  /// In de, this message translates to:
  /// **'Schlüsselwörter (kommagetrennt)'**
  String get fieldKeywords;

  /// No description provided for @fieldSource.
  ///
  /// In de, this message translates to:
  /// **'Quelle'**
  String get fieldSource;

  /// No description provided for @dashboardSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Übersicht · {companyName}'**
  String dashboardSubtitle(String companyName);

  /// No description provided for @statKnowledgeEntries.
  ///
  /// In de, this message translates to:
  /// **'Wissenseinträge'**
  String get statKnowledgeEntries;

  /// No description provided for @statBotRequests.
  ///
  /// In de, this message translates to:
  /// **'Bot-Anfragen'**
  String get statBotRequests;

  /// No description provided for @statMatchRate.
  ///
  /// In de, this message translates to:
  /// **'Match-Rate'**
  String get statMatchRate;

  /// No description provided for @statProducts.
  ///
  /// In de, this message translates to:
  /// **'Produkte & Leistungen'**
  String get statProducts;

  /// No description provided for @dashboardRecentRequests.
  ///
  /// In de, this message translates to:
  /// **'Letzte Bot-Anfragen'**
  String get dashboardRecentRequests;

  /// No description provided for @dashboardTotal.
  ///
  /// In de, this message translates to:
  /// **'{count} gesamt'**
  String dashboardTotal(int count);

  /// No description provided for @dashboardNoLogs.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Bot-Anfragen. Starte den Bot-Test.'**
  String get dashboardNoLogs;

  /// No description provided for @logNoAnswer.
  ///
  /// In de, this message translates to:
  /// **'Keine Antwort gefunden'**
  String get logNoAnswer;

  /// No description provided for @companyTitle.
  ///
  /// In de, this message translates to:
  /// **'Firma'**
  String get companyTitle;

  /// No description provided for @companyEditDialogTitle.
  ///
  /// In de, this message translates to:
  /// **'Firmendaten bearbeiten'**
  String get companyEditDialogTitle;

  /// No description provided for @companyProducts.
  ///
  /// In de, this message translates to:
  /// **'Produkte & Leistungen'**
  String get companyProducts;

  /// No description provided for @auditTitle.
  ///
  /// In de, this message translates to:
  /// **'Audit'**
  String get auditTitle;

  /// No description provided for @auditSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Vollständigkeitscheck für den Bot-Einsatz'**
  String get auditSubtitle;

  /// No description provided for @auditTotalScore.
  ///
  /// In de, this message translates to:
  /// **'Gesamtscore'**
  String get auditTotalScore;

  /// No description provided for @auditScoreLabel.
  ///
  /// In de, this message translates to:
  /// **'{score} / {max} Punkte'**
  String auditScoreLabel(int score, int max);

  /// No description provided for @auditExcellent.
  ///
  /// In de, this message translates to:
  /// **'Ausgezeichnet – Bot ist bereit!'**
  String get auditExcellent;

  /// No description provided for @auditGood.
  ///
  /// In de, this message translates to:
  /// **'Gut – kleine Lücken noch schließen.'**
  String get auditGood;

  /// No description provided for @auditMedium.
  ///
  /// In de, this message translates to:
  /// **'Mittelmäßig – Wissen ausbauen empfohlen.'**
  String get auditMedium;

  /// No description provided for @auditPoor.
  ///
  /// In de, this message translates to:
  /// **'Unvollständig – Bot noch nicht einsatzbereit.'**
  String get auditPoor;

  /// No description provided for @auditChecklist.
  ///
  /// In de, this message translates to:
  /// **'Checkliste'**
  String get auditChecklist;

  /// No description provided for @auditPoints.
  ///
  /// In de, this message translates to:
  /// **'+{points} Pkt.'**
  String auditPoints(int points);

  /// No description provided for @auditCheckCompanyName.
  ///
  /// In de, this message translates to:
  /// **'Firmenname eingetragen'**
  String get auditCheckCompanyName;

  /// No description provided for @auditCheckIndustry.
  ///
  /// In de, this message translates to:
  /// **'Branche definiert'**
  String get auditCheckIndustry;

  /// No description provided for @auditCheckDescription.
  ///
  /// In de, this message translates to:
  /// **'Firmenbeschreibung vorhanden'**
  String get auditCheckDescription;

  /// No description provided for @auditCheckWebsite.
  ///
  /// In de, this message translates to:
  /// **'Website eingetragen'**
  String get auditCheckWebsite;

  /// No description provided for @auditCheckProducts.
  ///
  /// In de, this message translates to:
  /// **'Produkte / Leistungen erfasst'**
  String get auditCheckProducts;

  /// No description provided for @auditCheckKnowledge.
  ///
  /// In de, this message translates to:
  /// **'Wissenseinträge vorhanden'**
  String get auditCheckKnowledge;

  /// No description provided for @auditCheckKnowledge10.
  ///
  /// In de, this message translates to:
  /// **'Mindestens 10 Wissenseinträge'**
  String get auditCheckKnowledge10;

  /// No description provided for @auditCheckBotTest.
  ///
  /// In de, this message translates to:
  /// **'Bot-Test durchgeführt'**
  String get auditCheckBotTest;

  /// No description provided for @auditDescChars.
  ///
  /// In de, this message translates to:
  /// **'{count} Zeichen'**
  String auditDescChars(int count);

  /// No description provided for @auditDescTooShort.
  ///
  /// In de, this message translates to:
  /// **'Zu kurz (mind. 50 Zeichen)'**
  String get auditDescTooShort;

  /// No description provided for @auditDescEntries.
  ///
  /// In de, this message translates to:
  /// **'{count} Einträge'**
  String auditDescEntries(int count);

  /// No description provided for @auditDescAchieved.
  ///
  /// In de, this message translates to:
  /// **'Erreicht'**
  String get auditDescAchieved;

  /// No description provided for @auditDescOfTotal.
  ///
  /// In de, this message translates to:
  /// **'{current} von {total}'**
  String auditDescOfTotal(int current, int total);

  /// No description provided for @auditDescNoTest.
  ///
  /// In de, this message translates to:
  /// **'Noch kein Test'**
  String get auditDescNoTest;

  /// No description provided for @auditDescTestCount.
  ///
  /// In de, this message translates to:
  /// **'{count} Testanfragen'**
  String auditDescTestCount(int count);

  /// No description provided for @auditBusinessSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Business-Status und Bot-Bereitschaft · {companyName}'**
  String auditBusinessSubtitle(String companyName);

  /// No description provided for @auditBusinessStatusTitle.
  ///
  /// In de, this message translates to:
  /// **'Status-Erhebung'**
  String get auditBusinessStatusTitle;

  /// No description provided for @auditItemsComplete.
  ///
  /// In de, this message translates to:
  /// **'vollständig'**
  String get auditItemsComplete;

  /// No description provided for @auditMissingCount.
  ///
  /// In de, this message translates to:
  /// **'{count} fehlt'**
  String auditMissingCount(int count);

  /// No description provided for @auditPartialCount.
  ///
  /// In de, this message translates to:
  /// **'{count} teilweise'**
  String auditPartialCount(int count);

  /// No description provided for @auditCompleteCount.
  ///
  /// In de, this message translates to:
  /// **'{count} vollständig'**
  String auditCompleteCount(int count);

  /// No description provided for @auditHighPriorityOpenCount.
  ///
  /// In de, this message translates to:
  /// **'{count} High-Priority offen'**
  String auditHighPriorityOpenCount(int count);

  /// No description provided for @auditAreaCompanyProfile.
  ///
  /// In de, this message translates to:
  /// **'Firmenprofil'**
  String get auditAreaCompanyProfile;

  /// No description provided for @auditAreaWebsite.
  ///
  /// In de, this message translates to:
  /// **'Website / Webauftritt'**
  String get auditAreaWebsite;

  /// No description provided for @auditAreaProducts.
  ///
  /// In de, this message translates to:
  /// **'Produkte / Dienstleistungen'**
  String get auditAreaProducts;

  /// No description provided for @auditAreaSupportKnowledge.
  ///
  /// In de, this message translates to:
  /// **'FAQ / Supportwissen'**
  String get auditAreaSupportKnowledge;

  /// No description provided for @auditAreaTrustMaterial.
  ///
  /// In de, this message translates to:
  /// **'Rezensionen / Vertrauensmaterial'**
  String get auditAreaTrustMaterial;

  /// No description provided for @auditAreaSocialPresence.
  ///
  /// In de, this message translates to:
  /// **'Social Media / Außenwirkung'**
  String get auditAreaSocialPresence;

  /// No description provided for @auditAreaSources.
  ///
  /// In de, this message translates to:
  /// **'Quellen / Dokumente'**
  String get auditAreaSources;

  /// No description provided for @auditAreaRiskRules.
  ///
  /// In de, this message translates to:
  /// **'Risiko / No-Go-Regeln'**
  String get auditAreaRiskRules;

  /// No description provided for @auditAreaBotReadiness.
  ///
  /// In de, this message translates to:
  /// **'Bot-Bereitschaft'**
  String get auditAreaBotReadiness;

  /// No description provided for @auditStatusMissing.
  ///
  /// In de, this message translates to:
  /// **'Fehlt'**
  String get auditStatusMissing;

  /// No description provided for @auditStatusPartial.
  ///
  /// In de, this message translates to:
  /// **'Teilweise'**
  String get auditStatusPartial;

  /// No description provided for @auditStatusComplete.
  ///
  /// In de, this message translates to:
  /// **'Vollständig'**
  String get auditStatusComplete;

  /// No description provided for @auditPriorityLow.
  ///
  /// In de, this message translates to:
  /// **'Niedrig'**
  String get auditPriorityLow;

  /// No description provided for @auditPriorityMedium.
  ///
  /// In de, this message translates to:
  /// **'Mittel'**
  String get auditPriorityMedium;

  /// No description provided for @auditPriorityHigh.
  ///
  /// In de, this message translates to:
  /// **'Hoch'**
  String get auditPriorityHigh;

  /// No description provided for @auditNote.
  ///
  /// In de, this message translates to:
  /// **'Notiz'**
  String get auditNote;

  /// No description provided for @auditRecommendation.
  ///
  /// In de, this message translates to:
  /// **'Empfehlung'**
  String get auditRecommendation;

  /// No description provided for @auditEditNote.
  ///
  /// In de, this message translates to:
  /// **'Notiz bearbeiten'**
  String get auditEditNote;

  /// No description provided for @auditNoteHint.
  ///
  /// In de, this message translates to:
  /// **'Interne Notiz zu diesem Auditpunkt …'**
  String get auditNoteHint;

  /// No description provided for @knowledgeTitle.
  ///
  /// In de, this message translates to:
  /// **'Wissensbasis'**
  String get knowledgeTitle;

  /// No description provided for @knowledgeEntryCount.
  ///
  /// In de, this message translates to:
  /// **'{count} Einträge'**
  String knowledgeEntryCount(int count);

  /// No description provided for @knowledgeFilterAll.
  ///
  /// In de, this message translates to:
  /// **'Alle'**
  String get knowledgeFilterAll;

  /// No description provided for @knowledgeNoEntries.
  ///
  /// In de, this message translates to:
  /// **'Keine Einträge in dieser Kategorie.'**
  String get knowledgeNoEntries;

  /// No description provided for @knowledgeAddEntry.
  ///
  /// In de, this message translates to:
  /// **'Eintrag hinzufügen'**
  String get knowledgeAddEntry;

  /// No description provided for @knowledgeDeleteTitle.
  ///
  /// In de, this message translates to:
  /// **'Eintrag löschen?'**
  String get knowledgeDeleteTitle;

  /// No description provided for @knowledgeDeleteConfirm.
  ///
  /// In de, this message translates to:
  /// **'\"{title}\" wird unwiderruflich entfernt.'**
  String knowledgeDeleteConfirm(String title);

  /// No description provided for @knowledgeNewEntry.
  ///
  /// In de, this message translates to:
  /// **'Neuer Wissenseintrag'**
  String get knowledgeNewEntry;

  /// No description provided for @botTestTitle.
  ///
  /// In de, this message translates to:
  /// **'Bot-Test'**
  String get botTestTitle;

  /// No description provided for @botTestSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Simulierter Bot ohne echte KI – Antworten basieren auf der Wissensbasis.'**
  String get botTestSubtitle;

  /// No description provided for @botTestGreeting.
  ///
  /// In de, this message translates to:
  /// **'Hallo! Ich bin dein Bot-Assistent. Stelle mir eine Frage über das Unternehmen.'**
  String get botTestGreeting;

  /// No description provided for @botTestInputHint.
  ///
  /// In de, this message translates to:
  /// **'Frage eingeben …'**
  String get botTestInputHint;

  /// No description provided for @botTestNoMatch.
  ///
  /// In de, this message translates to:
  /// **'Keine passende Antwort gefunden. Bitte kontaktieren Sie uns direkt.'**
  String get botTestNoMatch;

  /// No description provided for @botTestResetMessage.
  ///
  /// In de, this message translates to:
  /// **'Chat zurückgesetzt. Stelle mir eine neue Frage!'**
  String get botTestResetMessage;

  /// No description provided for @sourcesTitle.
  ///
  /// In de, this message translates to:
  /// **'Quellen'**
  String get sourcesTitle;

  /// No description provided for @sourcesSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Herkunft der Wissenseinträge'**
  String get sourcesSubtitle;

  /// No description provided for @sourcesCount.
  ///
  /// In de, this message translates to:
  /// **'{count} Quellen'**
  String sourcesCount(int count);

  /// No description provided for @sourcesEntriesCount.
  ///
  /// In de, this message translates to:
  /// **'{count} Einträge'**
  String sourcesEntriesCount(int count);

  /// No description provided for @sourcesEmpty.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Quellen vorhanden.'**
  String get sourcesEmpty;

  /// No description provided for @sourcesEntryInfo.
  ///
  /// In de, this message translates to:
  /// **'{count} Einträge · {type}'**
  String sourcesEntryInfo(int count, String type);

  /// No description provided for @sourceTypeUrl.
  ///
  /// In de, this message translates to:
  /// **'Website'**
  String get sourceTypeUrl;

  /// No description provided for @sourceTypeDocument.
  ///
  /// In de, this message translates to:
  /// **'Dokument'**
  String get sourceTypeDocument;

  /// No description provided for @sourceTypeManual.
  ///
  /// In de, this message translates to:
  /// **'Manuell'**
  String get sourceTypeManual;

  /// No description provided for @sourcesStage2Hint.
  ///
  /// In de, this message translates to:
  /// **'In Stufe 2 können Quellen direkt importiert werden (Websites, PDFs, Dokumente).'**
  String get sourcesStage2Hint;

  /// No description provided for @categoryFaq.
  ///
  /// In de, this message translates to:
  /// **'FAQ'**
  String get categoryFaq;

  /// No description provided for @categoryProdukt.
  ///
  /// In de, this message translates to:
  /// **'Produkt'**
  String get categoryProdukt;

  /// No description provided for @categoryProzess.
  ///
  /// In de, this message translates to:
  /// **'Prozess'**
  String get categoryProzess;

  /// No description provided for @categoryAllgemein.
  ///
  /// In de, this message translates to:
  /// **'Allgemein'**
  String get categoryAllgemein;

  /// No description provided for @typeProdukt.
  ///
  /// In de, this message translates to:
  /// **'Produkt'**
  String get typeProdukt;

  /// No description provided for @typeDienstleistung.
  ///
  /// In de, this message translates to:
  /// **'Dienstleistung'**
  String get typeDienstleistung;

  /// No description provided for @riskGreen.
  ///
  /// In de, this message translates to:
  /// **'Sicher'**
  String get riskGreen;

  /// No description provided for @riskYellow.
  ///
  /// In de, this message translates to:
  /// **'Wellness'**
  String get riskYellow;

  /// No description provided for @riskRed.
  ///
  /// In de, this message translates to:
  /// **'Gesperrt'**
  String get riskRed;

  /// No description provided for @botTestRedirectMessage.
  ///
  /// In de, this message translates to:
  /// **'Diese Frage berührt medizinische oder rechtliche Bereiche, die ich nicht beantworten darf. Bitte wenden Sie sich an eine qualifizierte Fachstelle oder kontaktieren Sie unseren Support direkt: {supportEmail}'**
  String botTestRedirectMessage(String supportEmail);

  /// No description provided for @botTestYellowDisclaimer.
  ///
  /// In de, this message translates to:
  /// **'Hinweis: Diese Antwort dient nur zur allgemeinen Information und ersetzt keine ärztliche Beratung.'**
  String get botTestYellowDisclaimer;

  /// No description provided for @statOpenRequests.
  ///
  /// In de, this message translates to:
  /// **'Offene Anfragen'**
  String get statOpenRequests;

  /// No description provided for @statRedirects.
  ///
  /// In de, this message translates to:
  /// **'Weiterleitungen'**
  String get statRedirects;

  /// No description provided for @statAuditScore.
  ///
  /// In de, this message translates to:
  /// **'Audit-Score'**
  String get statAuditScore;

  /// No description provided for @statAuditMissing.
  ///
  /// In de, this message translates to:
  /// **'Audit fehlt'**
  String get statAuditMissing;

  /// No description provided for @statAuditPartial.
  ///
  /// In de, this message translates to:
  /// **'Audit teilweise'**
  String get statAuditPartial;

  /// No description provided for @statAuditComplete.
  ///
  /// In de, this message translates to:
  /// **'Audit vollständig'**
  String get statAuditComplete;

  /// No description provided for @statAuditHighPriorityOpen.
  ///
  /// In de, this message translates to:
  /// **'High-Priority-Lücken'**
  String get statAuditHighPriorityOpen;

  /// No description provided for @statReviewOpen.
  ///
  /// In de, this message translates to:
  /// **'Offen zur Prüfung'**
  String get statReviewOpen;

  /// No description provided for @dashboardRiskTitle.
  ///
  /// In de, this message translates to:
  /// **'Wissensbasis nach Risikostufe'**
  String get dashboardRiskTitle;

  /// No description provided for @knowledgeRisk.
  ///
  /// In de, this message translates to:
  /// **'Risikostufe'**
  String get knowledgeRisk;

  /// No description provided for @navReview.
  ///
  /// In de, this message translates to:
  /// **'Prüfung'**
  String get navReview;

  /// No description provided for @reviewTitle.
  ///
  /// In de, this message translates to:
  /// **'Human Review'**
  String get reviewTitle;

  /// No description provided for @reviewSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Bot-Anfragen zur manuellen Prüfung'**
  String get reviewSubtitle;

  /// No description provided for @reviewEmpty.
  ///
  /// In de, this message translates to:
  /// **'Keine Einträge zur Prüfung.'**
  String get reviewEmpty;

  /// No description provided for @reviewFilterAll.
  ///
  /// In de, this message translates to:
  /// **'Alle'**
  String get reviewFilterAll;

  /// No description provided for @reviewOpenCount.
  ///
  /// In de, this message translates to:
  /// **'{count} offen'**
  String reviewOpenCount(int count);

  /// No description provided for @reviewStatusOpen.
  ///
  /// In de, this message translates to:
  /// **'Offen'**
  String get reviewStatusOpen;

  /// No description provided for @reviewStatusReviewed.
  ///
  /// In de, this message translates to:
  /// **'Geprüft'**
  String get reviewStatusReviewed;

  /// No description provided for @reviewStatusClosed.
  ///
  /// In de, this message translates to:
  /// **'Erledigt'**
  String get reviewStatusClosed;

  /// No description provided for @reviewReasonNoMatch.
  ///
  /// In de, this message translates to:
  /// **'Kein Match'**
  String get reviewReasonNoMatch;

  /// No description provided for @reviewReasonRedFlag.
  ///
  /// In de, this message translates to:
  /// **'Rote Frage'**
  String get reviewReasonRedFlag;

  /// No description provided for @reviewReasonYellowRisk.
  ///
  /// In de, this message translates to:
  /// **'Gelbe Antwort'**
  String get reviewReasonYellowRisk;

  /// No description provided for @reviewReasonLowConfidence.
  ///
  /// In de, this message translates to:
  /// **'Niedrige Sicherheit'**
  String get reviewReasonLowConfidence;

  /// No description provided for @reviewBotAnswer.
  ///
  /// In de, this message translates to:
  /// **'Bot-Antwort'**
  String get reviewBotAnswer;

  /// No description provided for @reviewHumanNote.
  ///
  /// In de, this message translates to:
  /// **'Notiz'**
  String get reviewHumanNote;

  /// No description provided for @reviewNoteHint.
  ///
  /// In de, this message translates to:
  /// **'Notiz für das Team …'**
  String get reviewNoteHint;

  /// No description provided for @reviewSaveNote.
  ///
  /// In de, this message translates to:
  /// **'Notiz speichern'**
  String get reviewSaveNote;

  /// No description provided for @reviewAddNote.
  ///
  /// In de, this message translates to:
  /// **'Notiz bearbeiten'**
  String get reviewAddNote;

  /// No description provided for @reviewMarkReviewed.
  ///
  /// In de, this message translates to:
  /// **'Als geprüft markieren'**
  String get reviewMarkReviewed;

  /// No description provided for @reviewMarkClosed.
  ///
  /// In de, this message translates to:
  /// **'Als erledigt schließen'**
  String get reviewMarkClosed;

  /// No description provided for @reviewCreateKnowledgeEntry.
  ///
  /// In de, this message translates to:
  /// **'Als Wissenseintrag anlegen'**
  String get reviewCreateKnowledgeEntry;

  /// No description provided for @reviewKnowledgeSourceOptional.
  ///
  /// In de, this message translates to:
  /// **'Quelle (optional)'**
  String get reviewKnowledgeSourceOptional;

  /// No description provided for @reviewKnowledgeDefaultSource.
  ///
  /// In de, this message translates to:
  /// **'Human Review'**
  String get reviewKnowledgeDefaultSource;

  /// No description provided for @reviewKnowledgeCreatedNote.
  ///
  /// In de, this message translates to:
  /// **'Als Wissenseintrag übernommen'**
  String get reviewKnowledgeCreatedNote;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
