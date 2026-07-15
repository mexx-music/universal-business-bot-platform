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

  /// No description provided for @landingStepsTitle.
  ///
  /// In de, this message translates to:
  /// **'Demo-Flow'**
  String get landingStepsTitle;

  /// No description provided for @landingStepCompanyTitle.
  ///
  /// In de, this message translates to:
  /// **'Firma erfassen'**
  String get landingStepCompanyTitle;

  /// No description provided for @landingStepCompanyDescription.
  ///
  /// In de, this message translates to:
  /// **'Business Core, Kontaktwege und Regeln pro Workspace pflegen.'**
  String get landingStepCompanyDescription;

  /// No description provided for @landingStepKnowledgeTitle.
  ///
  /// In de, this message translates to:
  /// **'Wissen strukturieren'**
  String get landingStepKnowledgeTitle;

  /// No description provided for @landingStepKnowledgeDescription.
  ///
  /// In de, this message translates to:
  /// **'FAQ, Quellen und Supportwissen in sichere Einträge überführen.'**
  String get landingStepKnowledgeDescription;

  /// No description provided for @landingStepBotTitle.
  ///
  /// In de, this message translates to:
  /// **'Bot sicher testen'**
  String get landingStepBotTitle;

  /// No description provided for @landingStepBotDescription.
  ///
  /// In de, this message translates to:
  /// **'Bot-Fragen prüfen, blockieren und per Human Review absichern.'**
  String get landingStepBotDescription;

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

  /// No description provided for @landingPwaHint.
  ///
  /// In de, this message translates to:
  /// **'Sie können die Plattform direkt im Browser verwenden oder für schnelleren Zugriff zum Startbildschirm hinzufügen.'**
  String get landingPwaHint;

  /// No description provided for @landingPwaAddToHome.
  ///
  /// In de, this message translates to:
  /// **'Zum Startbildschirm hinzufügen'**
  String get landingPwaAddToHome;

  /// No description provided for @landingPwaDismiss.
  ///
  /// In de, this message translates to:
  /// **'Ausblenden'**
  String get landingPwaDismiss;

  /// No description provided for @landingPwaBrowserMenuHint.
  ///
  /// In de, this message translates to:
  /// **'Nutzen Sie dafür bei Bedarf das Browser-Menü.'**
  String get landingPwaBrowserMenuHint;

  /// No description provided for @landingPwaIosHint.
  ///
  /// In de, this message translates to:
  /// **'Nutzen Sie dafür auf iPhone oder iPad das Teilen-Menü und „Zum Home-Bildschirm“.'**
  String get landingPwaIosHint;

  /// No description provided for @landingBrandName.
  ///
  /// In de, this message translates to:
  /// **'Universal Business Bot Platform'**
  String get landingBrandName;

  /// No description provided for @landingPlaceholderAction.
  ///
  /// In de, this message translates to:
  /// **'Diese Aktion ist im MVP noch ein Platzhalter.'**
  String get landingPlaceholderAction;

  /// No description provided for @landingHeroEyebrow.
  ///
  /// In de, this message translates to:
  /// **'Öffentliche Plattformvorschau'**
  String get landingHeroEyebrow;

  /// No description provided for @landingHeroTitle.
  ///
  /// In de, this message translates to:
  /// **'Die intelligente Plattform\nfür Unternehmenswissen\nund digitales Wachstum'**
  String get landingHeroTitle;

  /// No description provided for @landingHeroSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Erfassen Sie Ihr Unternehmen, organisieren Sie Wissen, automatisieren Sie Prozesse und unterstützen Sie Ihre Mitarbeiter mit intelligenter KI.'**
  String get landingHeroSubtitle;

  /// No description provided for @landingLearnMoreButton.
  ///
  /// In de, this message translates to:
  /// **'Plattform kennenlernen'**
  String get landingLearnMoreButton;

  /// No description provided for @landingDemoButton.
  ///
  /// In de, this message translates to:
  /// **'Demo ansehen'**
  String get landingDemoButton;

  /// No description provided for @landingContactButton.
  ///
  /// In de, this message translates to:
  /// **'Kontakt'**
  String get landingContactButton;

  /// No description provided for @landingHeroFlowCompany.
  ///
  /// In de, this message translates to:
  /// **'Unternehmen'**
  String get landingHeroFlowCompany;

  /// No description provided for @landingHeroFlowKnowledge.
  ///
  /// In de, this message translates to:
  /// **'Wissensbasis'**
  String get landingHeroFlowKnowledge;

  /// No description provided for @landingHeroFlowBot.
  ///
  /// In de, this message translates to:
  /// **'Bot'**
  String get landingHeroFlowBot;

  /// No description provided for @landingHeroFlowMarketing.
  ///
  /// In de, this message translates to:
  /// **'Marketing'**
  String get landingHeroFlowMarketing;

  /// No description provided for @landingHeroFlowControlling.
  ///
  /// In de, this message translates to:
  /// **'Controlling'**
  String get landingHeroFlowControlling;

  /// No description provided for @landingWorkflowTitle.
  ///
  /// In de, this message translates to:
  /// **'So funktioniert es'**
  String get landingWorkflowTitle;

  /// No description provided for @landingWorkflowSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Vom Unternehmensprofil bis zur nutzbaren KI-Unterstützung bleibt der Ablauf klar, kontrolliert und nachvollziehbar.'**
  String get landingWorkflowSubtitle;

  /// No description provided for @landingWorkflowStep1Title.
  ///
  /// In de, this message translates to:
  /// **'Unternehmen erfassen'**
  String get landingWorkflowStep1Title;

  /// No description provided for @landingWorkflowStep1Text.
  ///
  /// In de, this message translates to:
  /// **'Alle wichtigen Unternehmensinformationen werden strukturiert aufgenommen.'**
  String get landingWorkflowStep1Text;

  /// No description provided for @landingWorkflowStep2Title.
  ///
  /// In de, this message translates to:
  /// **'Wissen organisieren'**
  String get landingWorkflowStep2Title;

  /// No description provided for @landingWorkflowStep2Text.
  ///
  /// In de, this message translates to:
  /// **'Produkte, FAQs, Dokumente und Prozesse werden übersichtlich verwaltet.'**
  String get landingWorkflowStep2Text;

  /// No description provided for @landingWorkflowStep3Title.
  ///
  /// In de, this message translates to:
  /// **'Potenziale erkennen'**
  String get landingWorkflowStep3Title;

  /// No description provided for @landingWorkflowStep3Text.
  ///
  /// In de, this message translates to:
  /// **'Die Plattform unterstützt bei Marketing, Support und Unternehmensentwicklung.'**
  String get landingWorkflowStep3Text;

  /// No description provided for @landingTimelineStep1.
  ///
  /// In de, this message translates to:
  /// **'Unternehmen anlegen'**
  String get landingTimelineStep1;

  /// No description provided for @landingTimelineStep1Text.
  ///
  /// In de, this message translates to:
  /// **'Profil, Kontaktwege und Regeln werden strukturiert erfasst.'**
  String get landingTimelineStep1Text;

  /// No description provided for @landingTimelineStep2.
  ///
  /// In de, this message translates to:
  /// **'Wissen importieren'**
  String get landingTimelineStep2;

  /// No description provided for @landingTimelineStep2Text.
  ///
  /// In de, this message translates to:
  /// **'FAQ, Quellen und Prozesse werden in verwaltbares Wissen überführt.'**
  String get landingTimelineStep2Text;

  /// No description provided for @landingTimelineStep3.
  ///
  /// In de, this message translates to:
  /// **'KI konfigurieren'**
  String get landingTimelineStep3;

  /// No description provided for @landingTimelineStep3Text.
  ///
  /// In de, this message translates to:
  /// **'Antwortstil, Themen und menschliche Übergabe werden festgelegt.'**
  String get landingTimelineStep3Text;

  /// No description provided for @landingTimelineStep4.
  ///
  /// In de, this message translates to:
  /// **'Bot beantwortet Fragen'**
  String get landingTimelineStep4;

  /// No description provided for @landingTimelineStep4Text.
  ///
  /// In de, this message translates to:
  /// **'Supportfragen werden sicher getestet und bei Bedarf geprüft.'**
  String get landingTimelineStep4Text;

  /// No description provided for @landingTimelineStep5.
  ///
  /// In de, this message translates to:
  /// **'Unternehmen wächst'**
  String get landingTimelineStep5;

  /// No description provided for @landingTimelineStep5Text.
  ///
  /// In de, this message translates to:
  /// **'Empfehlungen zeigen Chancen für Support, Marketing und Entwicklung.'**
  String get landingTimelineStep5Text;

  /// No description provided for @landingPreviewTitle.
  ///
  /// In de, this message translates to:
  /// **'Interaktive Vorschau'**
  String get landingPreviewTitle;

  /// No description provided for @landingPreviewSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Ein stilisiertes Mockup zeigt, wie die Plattform auf Desktop, Tablet und Smartphone wirken kann.'**
  String get landingPreviewSubtitle;

  /// No description provided for @landingPreviewDesktop.
  ///
  /// In de, this message translates to:
  /// **'Desktop'**
  String get landingPreviewDesktop;

  /// No description provided for @landingPreviewTablet.
  ///
  /// In de, this message translates to:
  /// **'Tablet'**
  String get landingPreviewTablet;

  /// No description provided for @landingPreviewPhone.
  ///
  /// In de, this message translates to:
  /// **'Smartphone'**
  String get landingPreviewPhone;

  /// No description provided for @landingFeaturesTitle.
  ///
  /// In de, this message translates to:
  /// **'Funktionen'**
  String get landingFeaturesTitle;

  /// No description provided for @landingFeaturesSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Ein öffentlicher Überblick über die Bausteine der Plattform. Einige Bereiche sind im MVP vorbereitet und werden schrittweise ausgebaut.'**
  String get landingFeaturesSubtitle;

  /// No description provided for @landingFeatureIntake.
  ///
  /// In de, this message translates to:
  /// **'Firmenaufnahme'**
  String get landingFeatureIntake;

  /// No description provided for @landingFeatureAuditFull.
  ///
  /// In de, this message translates to:
  /// **'Audit'**
  String get landingFeatureAuditFull;

  /// No description provided for @landingFeatureKnowledgeFull.
  ///
  /// In de, this message translates to:
  /// **'Wissensbasis'**
  String get landingFeatureKnowledgeFull;

  /// No description provided for @landingFeatureSources.
  ///
  /// In de, this message translates to:
  /// **'Quellenverwaltung'**
  String get landingFeatureSources;

  /// No description provided for @landingFeatureBotTest.
  ///
  /// In de, this message translates to:
  /// **'Bot-Test'**
  String get landingFeatureBotTest;

  /// No description provided for @landingFeatureHumanReview.
  ///
  /// In de, this message translates to:
  /// **'Human Review'**
  String get landingFeatureHumanReview;

  /// No description provided for @landingFeatureMarketing.
  ///
  /// In de, this message translates to:
  /// **'Marketing-Empfehlungen'**
  String get landingFeatureMarketing;

  /// No description provided for @landingFeatureControlling.
  ///
  /// In de, this message translates to:
  /// **'Controlling'**
  String get landingFeatureControlling;

  /// No description provided for @landingComingSoon.
  ///
  /// In de, this message translates to:
  /// **'Coming Soon'**
  String get landingComingSoon;

  /// No description provided for @landingBenefitsTitle.
  ///
  /// In de, this message translates to:
  /// **'Vorteile auf einen Blick'**
  String get landingBenefitsTitle;

  /// No description provided for @landingBenefitsSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Die Plattform verbindet Unternehmensdaten, Wissen und Assistenzfunktionen in einem gemeinsamen Arbeitsbereich.'**
  String get landingBenefitsSubtitle;

  /// No description provided for @landingBenefitCompanyTitle.
  ///
  /// In de, this message translates to:
  /// **'Unternehmen'**
  String get landingBenefitCompanyTitle;

  /// No description provided for @landingBenefitCompanyText.
  ///
  /// In de, this message translates to:
  /// **'Profile, Angebote und Regeln werden sauber an einem Ort gepflegt.'**
  String get landingBenefitCompanyText;

  /// No description provided for @landingBenefitAssistantTitle.
  ///
  /// In de, this message translates to:
  /// **'KI-Assistent'**
  String get landingBenefitAssistantTitle;

  /// No description provided for @landingBenefitAssistantText.
  ///
  /// In de, this message translates to:
  /// **'Antworten werden kontrolliert vorbereitet und bei Risiko an Menschen übergeben.'**
  String get landingBenefitAssistantText;

  /// No description provided for @landingBenefitDatabaseTitle.
  ///
  /// In de, this message translates to:
  /// **'Wissensdatenbank'**
  String get landingBenefitDatabaseTitle;

  /// No description provided for @landingBenefitDatabaseText.
  ///
  /// In de, this message translates to:
  /// **'FAQ, Dokumente und Quellen werden auffindbar und wiederverwendbar.'**
  String get landingBenefitDatabaseText;

  /// No description provided for @landingBenefitMarketingTitle.
  ///
  /// In de, this message translates to:
  /// **'Marketing'**
  String get landingBenefitMarketingTitle;

  /// No description provided for @landingBenefitMarketingText.
  ///
  /// In de, this message translates to:
  /// **'Potenziale, Lücken und nächste Schritte werden verständlich sichtbar.'**
  String get landingBenefitMarketingText;

  /// No description provided for @landingBenefitControllingTitle.
  ///
  /// In de, this message translates to:
  /// **'Controlling'**
  String get landingBenefitControllingTitle;

  /// No description provided for @landingBenefitControllingText.
  ///
  /// In de, this message translates to:
  /// **'Status, offene Prüfungen und Fortschritt bleiben nachvollziehbar.'**
  String get landingBenefitControllingText;

  /// No description provided for @landingBenefitOnePlace.
  ///
  /// In de, this message translates to:
  /// **'Alles an einem Ort'**
  String get landingBenefitOnePlace;

  /// No description provided for @landingBenefitLessSupport.
  ///
  /// In de, this message translates to:
  /// **'Weniger Supportaufwand'**
  String get landingBenefitLessSupport;

  /// No description provided for @landingBenefitStructuredData.
  ///
  /// In de, this message translates to:
  /// **'Strukturierte Unternehmensdaten'**
  String get landingBenefitStructuredData;

  /// No description provided for @landingBenefitHumanAi.
  ///
  /// In de, this message translates to:
  /// **'KI und Mensch arbeiten zusammen'**
  String get landingBenefitHumanAi;

  /// No description provided for @landingBenefitTransparency.
  ///
  /// In de, this message translates to:
  /// **'Mehr Transparenz'**
  String get landingBenefitTransparency;

  /// No description provided for @landingBenefitScalable.
  ///
  /// In de, this message translates to:
  /// **'Skalierbare Plattform'**
  String get landingBenefitScalable;

  /// No description provided for @landingDemoSectionTitle.
  ///
  /// In de, this message translates to:
  /// **'Demo'**
  String get landingDemoSectionTitle;

  /// No description provided for @landingDemoSectionSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Die Videofläche ist vorbereitet und kann später durch ein echtes Produktvideo ersetzt werden.'**
  String get landingDemoSectionSubtitle;

  /// No description provided for @landingDemoVideoComing.
  ///
  /// In de, this message translates to:
  /// **'Demovideo folgt'**
  String get landingDemoVideoComing;

  /// No description provided for @landingAudienceTitle.
  ///
  /// In de, this message translates to:
  /// **'Zielgruppen'**
  String get landingAudienceTitle;

  /// No description provided for @landingAudienceServices.
  ///
  /// In de, this message translates to:
  /// **'Dienstleister'**
  String get landingAudienceServices;

  /// No description provided for @landingAudienceCraft.
  ///
  /// In de, this message translates to:
  /// **'Handwerk'**
  String get landingAudienceCraft;

  /// No description provided for @landingAudienceDoctors.
  ///
  /// In de, this message translates to:
  /// **'Ärzte'**
  String get landingAudienceDoctors;

  /// No description provided for @landingAudienceManufacturers.
  ///
  /// In de, this message translates to:
  /// **'Hersteller'**
  String get landingAudienceManufacturers;

  /// No description provided for @landingAudienceCommerce.
  ///
  /// In de, this message translates to:
  /// **'Onlinehandel'**
  String get landingAudienceCommerce;

  /// No description provided for @landingAudienceSoftware.
  ///
  /// In de, this message translates to:
  /// **'Software'**
  String get landingAudienceSoftware;

  /// No description provided for @landingAudienceConsulting.
  ///
  /// In de, this message translates to:
  /// **'Beratung'**
  String get landingAudienceConsulting;

  /// No description provided for @landingAudienceHealth.
  ///
  /// In de, this message translates to:
  /// **'Gesundheitsunternehmen'**
  String get landingAudienceHealth;

  /// No description provided for @landingAudienceShops.
  ///
  /// In de, this message translates to:
  /// **'Shops'**
  String get landingAudienceShops;

  /// No description provided for @landingAudienceHotels.
  ///
  /// In de, this message translates to:
  /// **'Hotels'**
  String get landingAudienceHotels;

  /// No description provided for @landingAudienceAssociations.
  ///
  /// In de, this message translates to:
  /// **'Vereine'**
  String get landingAudienceAssociations;

  /// No description provided for @landingFaqTitle.
  ///
  /// In de, this message translates to:
  /// **'Häufige Fragen'**
  String get landingFaqTitle;

  /// No description provided for @landingFaqSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Kurz beantwortet für eine erste Orientierung.'**
  String get landingFaqSubtitle;

  /// No description provided for @landingFaqQuestion1.
  ///
  /// In de, this message translates to:
  /// **'Ist die Plattform bereits ein fertiges Produkt?'**
  String get landingFaqQuestion1;

  /// No description provided for @landingFaqAnswer1.
  ///
  /// In de, this message translates to:
  /// **'Aktuell ist sie ein MVP mit lokalem Demo-Workspace. Die öffentliche Landingpage zeigt die Richtung und die geplante Produktlogik.'**
  String get landingFaqAnswer1;

  /// No description provided for @landingFaqQuestion2.
  ///
  /// In de, this message translates to:
  /// **'Muss ich die App installieren?'**
  String get landingFaqQuestion2;

  /// No description provided for @landingFaqAnswer2.
  ///
  /// In de, this message translates to:
  /// **'Nein. Die Plattform läuft direkt im Browser. Unterstützte Browser können sie optional zum Startbildschirm hinzufügen.'**
  String get landingFaqAnswer2;

  /// No description provided for @landingFaqQuestion3.
  ///
  /// In de, this message translates to:
  /// **'Sind echte KI-Funktionen schon angebunden?'**
  String get landingFaqQuestion3;

  /// No description provided for @landingFaqAnswer3.
  ///
  /// In de, this message translates to:
  /// **'Noch nicht. Bot-Test und Review-Flows arbeiten im MVP lokal und regelbasiert, ohne echte KI-API.'**
  String get landingFaqAnswer3;

  /// No description provided for @landingFaqQuestion4.
  ///
  /// In de, this message translates to:
  /// **'Können mehrere Firmen verwaltet werden?'**
  String get landingFaqQuestion4;

  /// No description provided for @landingFaqAnswer4.
  ///
  /// In de, this message translates to:
  /// **'Ja. Demo-Workspaces sind getrennt aufgebaut, damit Daten pro Firma betrachtet und getestet werden können.'**
  String get landingFaqAnswer4;

  /// No description provided for @landingFaqQuestion5.
  ///
  /// In de, this message translates to:
  /// **'Was passiert bei riskanten Antworten?'**
  String get landingFaqQuestion5;

  /// No description provided for @landingFaqAnswer5.
  ///
  /// In de, this message translates to:
  /// **'Riskante oder unklare Fragen werden im Human-Review-Bereich gesammelt und können kontrolliert in Wissen überführt werden.'**
  String get landingFaqAnswer5;

  /// No description provided for @landingFaqQuestion6.
  ///
  /// In de, this message translates to:
  /// **'Ist das schon für produktive Kundendaten gedacht?'**
  String get landingFaqQuestion6;

  /// No description provided for @landingFaqAnswer6.
  ///
  /// In de, this message translates to:
  /// **'Nein. Für produktive Kundendaten fehlen noch Authentifizierung, Backend, Datenbank und dauerhafte sichere Speicherung.'**
  String get landingFaqAnswer6;

  /// No description provided for @landingCtaTitle.
  ///
  /// In de, this message translates to:
  /// **'Bereit für den nächsten Schritt?'**
  String get landingCtaTitle;

  /// No description provided for @landingCtaText.
  ///
  /// In de, this message translates to:
  /// **'Starten Sie mit einer strukturierten Firmenaufnahme.'**
  String get landingCtaText;

  /// No description provided for @landingCtaButton.
  ///
  /// In de, this message translates to:
  /// **'Firmenaufnahme anfragen'**
  String get landingCtaButton;

  /// No description provided for @landingFooterVersion.
  ///
  /// In de, this message translates to:
  /// **'Internal MVP / Work in progress'**
  String get landingFooterVersion;

  /// No description provided for @landingFooterGithub.
  ///
  /// In de, this message translates to:
  /// **'GitHub'**
  String get landingFooterGithub;

  /// No description provided for @landingFooterImprint.
  ///
  /// In de, this message translates to:
  /// **'Impressum'**
  String get landingFooterImprint;

  /// No description provided for @landingFooterPrivacy.
  ///
  /// In de, this message translates to:
  /// **'Datenschutz'**
  String get landingFooterPrivacy;

  /// No description provided for @landingFooterContact.
  ///
  /// In de, this message translates to:
  /// **'Kontakt'**
  String get landingFooterContact;

  /// No description provided for @landingFooterLanguages.
  ///
  /// In de, this message translates to:
  /// **'DE / EN'**
  String get landingFooterLanguages;

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

  /// No description provided for @companyAuditScore.
  ///
  /// In de, this message translates to:
  /// **'Audit {score}%'**
  String companyAuditScore(int score);

  /// No description provided for @companyOpenReviewCount.
  ///
  /// In de, this message translates to:
  /// **'{count} offene Reviews'**
  String companyOpenReviewCount(int count);

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

  /// No description provided for @navIntake.
  ///
  /// In de, this message translates to:
  /// **'Firmenaufnahme'**
  String get navIntake;

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

  /// No description provided for @navBotSettings.
  ///
  /// In de, this message translates to:
  /// **'Bot-Einstellungen'**
  String get navBotSettings;

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

  /// No description provided for @btnBack.
  ///
  /// In de, this message translates to:
  /// **'Zurück'**
  String get btnBack;

  /// No description provided for @btnNext.
  ///
  /// In de, this message translates to:
  /// **'Weiter'**
  String get btnNext;

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

  /// No description provided for @fieldCountry.
  ///
  /// In de, this message translates to:
  /// **'Land'**
  String get fieldCountry;

  /// No description provided for @fieldPrimaryLanguage.
  ///
  /// In de, this message translates to:
  /// **'Primäre Sprache'**
  String get fieldPrimaryLanguage;

  /// No description provided for @fieldSupportEmail.
  ///
  /// In de, this message translates to:
  /// **'Support-E-Mail'**
  String get fieldSupportEmail;

  /// No description provided for @fieldSupportPhone.
  ///
  /// In de, this message translates to:
  /// **'Support-Telefon'**
  String get fieldSupportPhone;

  /// No description provided for @fieldFacebook.
  ///
  /// In de, this message translates to:
  /// **'Facebook'**
  String get fieldFacebook;

  /// No description provided for @fieldInstagram.
  ///
  /// In de, this message translates to:
  /// **'Instagram'**
  String get fieldInstagram;

  /// No description provided for @fieldYoutube.
  ///
  /// In de, this message translates to:
  /// **'YouTube'**
  String get fieldYoutube;

  /// No description provided for @fieldTelegram.
  ///
  /// In de, this message translates to:
  /// **'Telegram'**
  String get fieldTelegram;

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

  /// No description provided for @statSourcesTotal.
  ///
  /// In de, this message translates to:
  /// **'Quellen gesamt'**
  String get statSourcesTotal;

  /// No description provided for @statSourcesNew.
  ///
  /// In de, this message translates to:
  /// **'Neue Quellen'**
  String get statSourcesNew;

  /// No description provided for @statIntakeStatus.
  ///
  /// In de, this message translates to:
  /// **'Firmenaufnahme'**
  String get statIntakeStatus;

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

  /// No description provided for @dashboardNextStepsTitle.
  ///
  /// In de, this message translates to:
  /// **'Nächste empfohlene Schritte'**
  String get dashboardNextStepsTitle;

  /// No description provided for @dashboardRecommendationAuditTitle.
  ///
  /// In de, this message translates to:
  /// **'Audit-Lücken schließen'**
  String get dashboardRecommendationAuditTitle;

  /// No description provided for @dashboardRecommendationAuditDescription.
  ///
  /// In de, this message translates to:
  /// **'{count} High-Priority-Auditpunkte fehlen noch.'**
  String dashboardRecommendationAuditDescription(int count);

  /// No description provided for @dashboardRecommendationKnowledgeTitle.
  ///
  /// In de, this message translates to:
  /// **'Wissensbasis erweitern'**
  String get dashboardRecommendationKnowledgeTitle;

  /// No description provided for @dashboardRecommendationKnowledgeDescription.
  ///
  /// In de, this message translates to:
  /// **'Aktuell sind {count} Wissenseinträge vorhanden. Für eine Demo sollten mehr sichere FAQ und Supportfälle ergänzt werden.'**
  String dashboardRecommendationKnowledgeDescription(int count);

  /// No description provided for @dashboardRecommendationSourcesTitle.
  ///
  /// In de, this message translates to:
  /// **'Quellen prüfen'**
  String get dashboardRecommendationSourcesTitle;

  /// No description provided for @dashboardRecommendationSourcesDescription.
  ///
  /// In de, this message translates to:
  /// **'{count} neue Quellen warten darauf, geprüft und bei Bedarf in Wissen übernommen zu werden.'**
  String dashboardRecommendationSourcesDescription(int count);

  /// No description provided for @dashboardRecommendationReviewTitle.
  ///
  /// In de, this message translates to:
  /// **'Human Review prüfen'**
  String get dashboardRecommendationReviewTitle;

  /// No description provided for @dashboardRecommendationReviewDescription.
  ///
  /// In de, this message translates to:
  /// **'{count} Bot-Fragen warten auf Prüfung.'**
  String dashboardRecommendationReviewDescription(int count);

  /// No description provided for @dashboardRecommendationProfileTitle.
  ///
  /// In de, this message translates to:
  /// **'Firmenprofil ergänzen'**
  String get dashboardRecommendationProfileTitle;

  /// No description provided for @dashboardRecommendationProfileDescription.
  ///
  /// In de, this message translates to:
  /// **'Business Core, Kontaktwege oder Business Rules sind noch nicht vollständig gepflegt.'**
  String get dashboardRecommendationProfileDescription;

  /// No description provided for @dashboardRecommendationAllDoneTitle.
  ///
  /// In de, this message translates to:
  /// **'Workspace wirkt demo-bereit'**
  String get dashboardRecommendationAllDoneTitle;

  /// No description provided for @dashboardRecommendationAllDoneDescription.
  ///
  /// In de, this message translates to:
  /// **'Keine dringenden nächsten Schritte aus den aktuellen Workspace-Daten ableitbar.'**
  String get dashboardRecommendationAllDoneDescription;

  /// No description provided for @dashboardRecommendationBotSettingsTitle.
  ///
  /// In de, this message translates to:
  /// **'Bot-Einstellungen prüfen'**
  String get dashboardRecommendationBotSettingsTitle;

  /// No description provided for @dashboardRecommendationBotSettingsDescription.
  ///
  /// In de, this message translates to:
  /// **'Der Bot ist noch im Entwurf. Prüfe Status, Eskalation und Handover-Regeln vor dem Test.'**
  String get dashboardRecommendationBotSettingsDescription;

  /// No description provided for @dashboardRecommendationIntakeTitle.
  ///
  /// In de, this message translates to:
  /// **'Firmenaufnahme starten'**
  String get dashboardRecommendationIntakeTitle;

  /// No description provided for @dashboardRecommendationIntakeDescription.
  ///
  /// In de, this message translates to:
  /// **'Für diesen Workspace gibt es noch keine strukturierte Firmenaufnahme.'**
  String get dashboardRecommendationIntakeDescription;

  /// No description provided for @dashboardRecommendationIntakeImportTitle.
  ///
  /// In de, this message translates to:
  /// **'Firmenaufnahme übernehmen'**
  String get dashboardRecommendationIntakeImportTitle;

  /// No description provided for @dashboardRecommendationIntakeImportDescription.
  ///
  /// In de, this message translates to:
  /// **'Die Firmenaufnahme ist abgeschlossen, aber noch nicht kontrolliert in den Workspace übernommen.'**
  String get dashboardRecommendationIntakeImportDescription;

  /// No description provided for @intakeTitle.
  ///
  /// In de, this message translates to:
  /// **'Firmenaufnahme'**
  String get intakeTitle;

  /// No description provided for @intakeSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Strukturierte Aufnahme für {companyName}'**
  String intakeSubtitle(String companyName);

  /// No description provided for @intakeStepOfTotal.
  ///
  /// In de, this message translates to:
  /// **'Schritt {current} von {total}'**
  String intakeStepOfTotal(int current, int total);

  /// No description provided for @intakeStatusDraft.
  ///
  /// In de, this message translates to:
  /// **'Entwurf'**
  String get intakeStatusDraft;

  /// No description provided for @intakeStatusInProgress.
  ///
  /// In de, this message translates to:
  /// **'In Bearbeitung'**
  String get intakeStatusInProgress;

  /// No description provided for @intakeStatusCompleted.
  ///
  /// In de, this message translates to:
  /// **'Abgeschlossen'**
  String get intakeStatusCompleted;

  /// No description provided for @intakeStatusNotStarted.
  ///
  /// In de, this message translates to:
  /// **'Nicht begonnen'**
  String get intakeStatusNotStarted;

  /// No description provided for @intakeImportStatusReady.
  ///
  /// In de, this message translates to:
  /// **'Bereit zur Übernahme'**
  String get intakeImportStatusReady;

  /// No description provided for @intakeImportStatusImported.
  ///
  /// In de, this message translates to:
  /// **'Übernommen'**
  String get intakeImportStatusImported;

  /// No description provided for @intakeSaveDraft.
  ///
  /// In de, this message translates to:
  /// **'Entwurf speichern'**
  String get intakeSaveDraft;

  /// No description provided for @intakeDraftSaved.
  ///
  /// In de, this message translates to:
  /// **'Entwurf gespeichert.'**
  String get intakeDraftSaved;

  /// No description provided for @intakeCompleted.
  ///
  /// In de, this message translates to:
  /// **'Firmenaufnahme abgeschlossen.'**
  String get intakeCompleted;

  /// No description provided for @intakeSummaryTitle.
  ///
  /// In de, this message translates to:
  /// **'Zusammenfassung'**
  String get intakeSummaryTitle;

  /// No description provided for @intakeSummaryNotice.
  ///
  /// In de, this message translates to:
  /// **'Diese Firmenaufnahme ist gespeichert. Die Übernahme in den Workspace folgt im nächsten Schritt.'**
  String get intakeSummaryNotice;

  /// No description provided for @intakeMarkCompleted.
  ///
  /// In de, this message translates to:
  /// **'Als abgeschlossen markieren'**
  String get intakeMarkCompleted;

  /// No description provided for @intakePrepareImport.
  ///
  /// In de, this message translates to:
  /// **'Übernahme vorbereiten'**
  String get intakePrepareImport;

  /// No description provided for @intakeMappingPreviewTitle.
  ///
  /// In de, this message translates to:
  /// **'Übernahme-Vorschau'**
  String get intakeMappingPreviewTitle;

  /// No description provided for @intakeMappingPreviewDescription.
  ///
  /// In de, this message translates to:
  /// **'Prüfe, welche Intake-Daten in welche Workspace-Bereiche geschrieben werden. Konflikte sind standardmäßig nicht ausgewählt.'**
  String get intakeMappingPreviewDescription;

  /// No description provided for @intakeMappingConflictWarning.
  ///
  /// In de, this message translates to:
  /// **'Einige Vorschläge unterscheiden sich von bestehenden Workspace-Daten und müssen bewusst ausgewählt werden.'**
  String get intakeMappingConflictWarning;

  /// No description provided for @intakeConflict.
  ///
  /// In de, this message translates to:
  /// **'Konflikt'**
  String get intakeConflict;

  /// No description provided for @intakeCurrentValue.
  ///
  /// In de, this message translates to:
  /// **'Aktueller Wert'**
  String get intakeCurrentValue;

  /// No description provided for @intakeProposedValue.
  ///
  /// In de, this message translates to:
  /// **'Vorschlag'**
  String get intakeProposedValue;

  /// No description provided for @intakeKnowledgeDraftEmpty.
  ///
  /// In de, this message translates to:
  /// **'Leerer FAQ-Entwurf – Antwort muss vor Nutzung ergänzt werden.'**
  String get intakeKnowledgeDraftEmpty;

  /// No description provided for @intakeImportSelected.
  ///
  /// In de, this message translates to:
  /// **'Ausgewählte Daten übernehmen'**
  String get intakeImportSelected;

  /// No description provided for @intakeImportConfirmTitle.
  ///
  /// In de, this message translates to:
  /// **'Ausgewählte Daten übernehmen?'**
  String get intakeImportConfirmTitle;

  /// No description provided for @intakeImportConfirmDescription.
  ///
  /// In de, this message translates to:
  /// **'Nur die ausgewählten Vorschläge werden in diesen Workspace geschrieben. Bestehende Daten werden nur bei ausgewählten Konflikten ersetzt.'**
  String get intakeImportConfirmDescription;

  /// No description provided for @intakeImportSuccess.
  ///
  /// In de, this message translates to:
  /// **'Ausgewählte Intake-Daten wurden übernommen.'**
  String get intakeImportSuccess;

  /// No description provided for @intakeNoAnswer.
  ///
  /// In de, this message translates to:
  /// **'Noch nicht beantwortet'**
  String get intakeNoAnswer;

  /// No description provided for @intakeStepBasicsTitle.
  ///
  /// In de, this message translates to:
  /// **'Basisdaten'**
  String get intakeStepBasicsTitle;

  /// No description provided for @intakeStepBasicsDescription.
  ///
  /// In de, this message translates to:
  /// **'Grunddaten, Kontaktwege und kurze Einordnung der Firma.'**
  String get intakeStepBasicsDescription;

  /// No description provided for @intakeStepProductsTitle.
  ///
  /// In de, this message translates to:
  /// **'Produkte / Leistungen'**
  String get intakeStepProductsTitle;

  /// No description provided for @intakeStepProductsDescription.
  ///
  /// In de, this message translates to:
  /// **'Was angeboten wird, was Priorität hat und was erklärt werden muss.'**
  String get intakeStepProductsDescription;

  /// No description provided for @intakeStepTargetGroupsTitle.
  ///
  /// In de, this message translates to:
  /// **'Zielgruppe / Positionierung'**
  String get intakeStepTargetGroupsTitle;

  /// No description provided for @intakeStepTargetGroupsDescription.
  ///
  /// In de, this message translates to:
  /// **'Für wen die Firma arbeitet und welcher Nutzen klar kommuniziert werden soll.'**
  String get intakeStepTargetGroupsDescription;

  /// No description provided for @intakeStepWebsiteSupportTitle.
  ///
  /// In de, this message translates to:
  /// **'Website / Support / FAQ'**
  String get intakeStepWebsiteSupportTitle;

  /// No description provided for @intakeStepWebsiteSupportDescription.
  ///
  /// In de, this message translates to:
  /// **'Wichtige Seiten, häufige Fragen und sensible Supportthemen.'**
  String get intakeStepWebsiteSupportDescription;

  /// No description provided for @intakeStepSourcesReviewsTitle.
  ///
  /// In de, this message translates to:
  /// **'Quellen / Rezensionen'**
  String get intakeStepSourcesReviewsTitle;

  /// No description provided for @intakeStepSourcesReviewsDescription.
  ///
  /// In de, this message translates to:
  /// **'Vorhandene Materialien, Rezensionen, Social-Signale und Vertrauenselemente.'**
  String get intakeStepSourcesReviewsDescription;

  /// No description provided for @intakeStepMarketingTitle.
  ///
  /// In de, this message translates to:
  /// **'Marketing / Kanäle'**
  String get intakeStepMarketingTitle;

  /// No description provided for @intakeStepMarketingDescription.
  ///
  /// In de, this message translates to:
  /// **'Bisherige Kanäle, Maßnahmen und Reichweitenprobleme.'**
  String get intakeStepMarketingDescription;

  /// No description provided for @intakeStepGoalsRisksTitle.
  ///
  /// In de, this message translates to:
  /// **'Ziele / Risiken / No-Go'**
  String get intakeStepGoalsRisksTitle;

  /// No description provided for @intakeStepGoalsRisksDescription.
  ///
  /// In de, this message translates to:
  /// **'Prioritäten, verbotene Aussagen und Themen für Human Review.'**
  String get intakeStepGoalsRisksDescription;

  /// No description provided for @intakeImportantProducts.
  ///
  /// In de, this message translates to:
  /// **'Wichtigste Produkte / Leistungen'**
  String get intakeImportantProducts;

  /// No description provided for @intakeMainProduct.
  ///
  /// In de, this message translates to:
  /// **'Hauptprodukt'**
  String get intakeMainProduct;

  /// No description provided for @intakeExplanationNeeded.
  ///
  /// In de, this message translates to:
  /// **'Erklärungsbedürftige Produkte'**
  String get intakeExplanationNeeded;

  /// No description provided for @intakePriorityProducts.
  ///
  /// In de, this message translates to:
  /// **'Aktuelle Produktprioritäten'**
  String get intakePriorityProducts;

  /// No description provided for @intakeTargetGroup.
  ///
  /// In de, this message translates to:
  /// **'Zielgruppe'**
  String get intakeTargetGroup;

  /// No description provided for @intakeMarketType.
  ///
  /// In de, this message translates to:
  /// **'B2B / B2C'**
  String get intakeMarketType;

  /// No description provided for @intakeProblemSolved.
  ///
  /// In de, this message translates to:
  /// **'Welches Problem wird gelöst?'**
  String get intakeProblemSolved;

  /// No description provided for @intakeCustomerBenefit.
  ///
  /// In de, this message translates to:
  /// **'Wichtigster Kundennutzen'**
  String get intakeCustomerBenefit;

  /// No description provided for @intakeDifferentiation.
  ///
  /// In de, this message translates to:
  /// **'Abgrenzung zur Konkurrenz'**
  String get intakeDifferentiation;

  /// No description provided for @intakeImportantPages.
  ///
  /// In de, this message translates to:
  /// **'Wichtige Website- / Landingpages'**
  String get intakeImportantPages;

  /// No description provided for @intakeFrequentQuestions.
  ///
  /// In de, this message translates to:
  /// **'Häufige Kundenfragen'**
  String get intakeFrequentQuestions;

  /// No description provided for @intakeSupportProblems.
  ///
  /// In de, this message translates to:
  /// **'Häufige Supportprobleme'**
  String get intakeSupportProblems;

  /// No description provided for @intakeSensitiveTopics.
  ///
  /// In de, this message translates to:
  /// **'Sensible Fragen / Themen'**
  String get intakeSensitiveTopics;

  /// No description provided for @intakeExistingSources.
  ///
  /// In de, this message translates to:
  /// **'Vorhandene Quellen / PDFs / Anleitungen'**
  String get intakeExistingSources;

  /// No description provided for @intakeReviews.
  ///
  /// In de, this message translates to:
  /// **'Rezensionen / Testimonials'**
  String get intakeReviews;

  /// No description provided for @intakeSocialMentions.
  ///
  /// In de, this message translates to:
  /// **'Social-Media-Erwähnungen / externe Diskussionen'**
  String get intakeSocialMentions;

  /// No description provided for @intakeTrustMaterial.
  ///
  /// In de, this message translates to:
  /// **'Trust-Material'**
  String get intakeTrustMaterial;

  /// No description provided for @intakeChannels.
  ///
  /// In de, this message translates to:
  /// **'Bisher genutzte Kanäle'**
  String get intakeChannels;

  /// No description provided for @intakeCampaigns.
  ///
  /// In de, this message translates to:
  /// **'Bisherige Werbemaßnahmen'**
  String get intakeCampaigns;

  /// No description provided for @intakeWorked.
  ///
  /// In de, this message translates to:
  /// **'Was hat funktioniert?'**
  String get intakeWorked;

  /// No description provided for @intakeNotWorked.
  ///
  /// In de, this message translates to:
  /// **'Was hat nicht funktioniert?'**
  String get intakeNotWorked;

  /// No description provided for @intakeReachProblems.
  ///
  /// In de, this message translates to:
  /// **'Aktuelle Reichweitenprobleme'**
  String get intakeReachProblems;

  /// No description provided for @intakeCompanyGoals.
  ///
  /// In de, this message translates to:
  /// **'Wichtigste Ziele der Firma'**
  String get intakeCompanyGoals;

  /// No description provided for @intakeShortTermPriorities.
  ///
  /// In de, this message translates to:
  /// **'Kurzfristige Prioritäten'**
  String get intakeShortTermPriorities;

  /// No description provided for @intakeForbiddenClaims.
  ///
  /// In de, this message translates to:
  /// **'Sensible / verbotene Aussagen'**
  String get intakeForbiddenClaims;

  /// No description provided for @intakeBotRestrictedTopics.
  ///
  /// In de, this message translates to:
  /// **'Themen, die ein Bot nicht frei beantworten darf'**
  String get intakeBotRestrictedTopics;

  /// No description provided for @intakeChatTitle.
  ///
  /// In de, this message translates to:
  /// **'Chat-Aufnahme'**
  String get intakeChatTitle;

  /// No description provided for @intakeChatSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Schritt-für-Schritt-Fragebogen für Firmenprofil, Website, Support, Material und Ziele.'**
  String get intakeChatSubtitle;

  /// No description provided for @intakeChatStart.
  ///
  /// In de, this message translates to:
  /// **'Chat-Aufnahme starten'**
  String get intakeChatStart;

  /// No description provided for @intakeChatResume.
  ///
  /// In de, this message translates to:
  /// **'Chat-Aufnahme fortsetzen'**
  String get intakeChatResume;

  /// No description provided for @intakeChatSharedDataHint.
  ///
  /// In de, this message translates to:
  /// **'Alle Antworten werden automatisch gespeichert.'**
  String get intakeChatSharedDataHint;

  /// No description provided for @intakeChatOpenWizard.
  ///
  /// In de, this message translates to:
  /// **'Zur Übersicht'**
  String get intakeChatOpenWizard;

  /// No description provided for @intakeChatQuestionProgress.
  ///
  /// In de, this message translates to:
  /// **'Frage {current} von {total}'**
  String intakeChatQuestionProgress(int current, int total);

  /// No description provided for @intakeChatCompletedProgress.
  ///
  /// In de, this message translates to:
  /// **'Abgeschlossen'**
  String get intakeChatCompletedProgress;

  /// No description provided for @intakeChatInputHint.
  ///
  /// In de, this message translates to:
  /// **'Antwort eingeben …'**
  String get intakeChatInputHint;

  /// No description provided for @intakeChatDoneInputHint.
  ///
  /// In de, this message translates to:
  /// **'Alle Fragen sind beantwortet.'**
  String get intakeChatDoneInputHint;

  /// No description provided for @intakeChatYes.
  ///
  /// In de, this message translates to:
  /// **'Ja'**
  String get intakeChatYes;

  /// No description provided for @intakeChatNo.
  ///
  /// In de, this message translates to:
  /// **'Nein'**
  String get intakeChatNo;

  /// No description provided for @intakeChatSkip.
  ///
  /// In de, this message translates to:
  /// **'Überspringen'**
  String get intakeChatSkip;

  /// No description provided for @intakeChatEnterAnswer.
  ///
  /// In de, this message translates to:
  /// **'Antwort eingeben'**
  String get intakeChatEnterAnswer;

  /// No description provided for @intakeChatDialogCancel.
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get intakeChatDialogCancel;

  /// No description provided for @intakeChatDialogDefer.
  ///
  /// In de, this message translates to:
  /// **'Später beantworten'**
  String get intakeChatDialogDefer;

  /// No description provided for @intakeChatDialogSave.
  ///
  /// In de, this message translates to:
  /// **'Speichern'**
  String get intakeChatDialogSave;

  /// No description provided for @intakeChatDialogSaveContinue.
  ///
  /// In de, this message translates to:
  /// **'Speichern und weiter'**
  String get intakeChatDialogSaveContinue;

  /// No description provided for @intakeChatPause.
  ///
  /// In de, this message translates to:
  /// **'Später fortsetzen'**
  String get intakeChatPause;

  /// No description provided for @intakeChatGoToSummary.
  ///
  /// In de, this message translates to:
  /// **'Zur Firmenaufnahme-Zusammenfassung'**
  String get intakeChatGoToSummary;

  /// No description provided for @intakeChatGreeting.
  ///
  /// In de, this message translates to:
  /// **'Hallo! Ich führe dich Schritt für Schritt durch die Firmenaufnahme.'**
  String get intakeChatGreeting;

  /// No description provided for @intakeChatExplanation.
  ///
  /// In de, this message translates to:
  /// **'Beantworte einfach die aktuelle Frage. Danach geht es automatisch mit dem nächsten passenden Schritt weiter.'**
  String get intakeChatExplanation;

  /// No description provided for @intakeChatAllDone.
  ///
  /// In de, this message translates to:
  /// **'Die Chat-Aufnahme ist vollständig. Du kannst jetzt zur Zusammenfassung wechseln und die Übernahme vorbereiten.'**
  String get intakeChatAllDone;

  /// No description provided for @intakeChatEmptyAnswer.
  ///
  /// In de, this message translates to:
  /// **'Bitte gib eine Antwort ein oder überspringe die Frage.'**
  String get intakeChatEmptyAnswer;

  /// No description provided for @intakeChatSkipped.
  ///
  /// In de, this message translates to:
  /// **'Frage übersprungen.'**
  String get intakeChatSkipped;

  /// No description provided for @intakeChatRequiredAnswer.
  ///
  /// In de, this message translates to:
  /// **'Diese Frage ist erforderlich. Bitte gib eine Antwort ein.'**
  String get intakeChatRequiredAnswer;

  /// No description provided for @intakeChatYesNoWarning.
  ///
  /// In de, this message translates to:
  /// **'Bitte antworte mit Ja oder Nein.'**
  String get intakeChatYesNoWarning;

  /// No description provided for @intakeChatUrlWarning.
  ///
  /// In de, this message translates to:
  /// **'Die Adresse wirkt nicht wie eine Website-URL. Bitte prüfe sie kurz.'**
  String get intakeChatUrlWarning;

  /// No description provided for @intakeChatEmailWarning.
  ///
  /// In de, this message translates to:
  /// **'Die E-Mail-Adresse wirkt ungültig. Bitte prüfe das Format.'**
  String get intakeChatEmailWarning;

  /// No description provided for @intakeChatDeferred.
  ///
  /// In de, this message translates to:
  /// **'Später beantworten.'**
  String get intakeChatDeferred;

  /// No description provided for @intakeChatAnswerSaved.
  ///
  /// In de, this message translates to:
  /// **'Antwort gespeichert.'**
  String get intakeChatAnswerSaved;

  /// No description provided for @intakeChatExampleShortDescription.
  ///
  /// In de, this message translates to:
  /// **'Beispiel: Wir entwickeln und verkaufen Zubehör für Katzenhalter im deutschsprachigen Raum.'**
  String get intakeChatExampleShortDescription;

  /// No description provided for @intakeChatExampleIndustry.
  ///
  /// In de, this message translates to:
  /// **'Beispiel: Onlinehandel, Beratung, Software oder Gesundheitsprodukte'**
  String get intakeChatExampleIndustry;

  /// No description provided for @intakeChatExampleWebsiteUrl.
  ///
  /// In de, this message translates to:
  /// **'Beispiel: https://www.meinefirma.de'**
  String get intakeChatExampleWebsiteUrl;

  /// No description provided for @intakeChatExampleShopUrl.
  ///
  /// In de, this message translates to:
  /// **'Beispiel: https://shop.meinefirma.de'**
  String get intakeChatExampleShopUrl;

  /// No description provided for @intakeChatExampleFaqUrl.
  ///
  /// In de, this message translates to:
  /// **'Beispiel: https://www.meinefirma.de/faq'**
  String get intakeChatExampleFaqUrl;

  /// No description provided for @intakeChatExampleSupportEmail.
  ///
  /// In de, this message translates to:
  /// **'Beispiel: support@meinefirma.de'**
  String get intakeChatExampleSupportEmail;

  /// No description provided for @intakeChatExampleSupportPhone.
  ///
  /// In de, this message translates to:
  /// **'Beispiel: +43 660 1234567'**
  String get intakeChatExampleSupportPhone;

  /// No description provided for @intakeChatExampleImportantProducts.
  ///
  /// In de, this message translates to:
  /// **'Beispiel: Mobile App, Relax-Kissen, Zubehör'**
  String get intakeChatExampleImportantProducts;

  /// No description provided for @intakeChatExampleMainProduct.
  ///
  /// In de, this message translates to:
  /// **'Beispiel: Unser meistverkauftes Produkt ist ...'**
  String get intakeChatExampleMainProduct;

  /// No description provided for @intakeChatExampleTargetGroup.
  ///
  /// In de, this message translates to:
  /// **'Beispiel: Privatkunden im DACH-Raum und kleine Fachhändler'**
  String get intakeChatExampleTargetGroup;

  /// No description provided for @intakeChatExampleCustomerBenefit.
  ///
  /// In de, this message translates to:
  /// **'Beispiel: Kunden sparen Zeit, erhalten verständliche Informationen oder lösen ein konkretes Alltagsproblem.'**
  String get intakeChatExampleCustomerBenefit;

  /// No description provided for @intakeChatExampleWebsitePages.
  ///
  /// In de, this message translates to:
  /// **'Beispiel: Produktseite, FAQ, Kontakt, Shop, Händlerbereich'**
  String get intakeChatExampleWebsitePages;

  /// No description provided for @intakeChatExampleSupportQuestions.
  ///
  /// In de, this message translates to:
  /// **'Beispiel: Wie lange dauert die Lieferung? Wie funktioniert die Einrichtung?'**
  String get intakeChatExampleSupportQuestions;

  /// No description provided for @intakeChatExampleSupportProblems.
  ///
  /// In de, this message translates to:
  /// **'Beispiel: Verbindungsprobleme, falsche Bestellung, fehlende Anleitung'**
  String get intakeChatExampleSupportProblems;

  /// No description provided for @intakeChatExampleReviewCount.
  ///
  /// In de, this message translates to:
  /// **'Beispiel: ca. 20 Bewertungen oder ungefähr 150 Sternebewertungen'**
  String get intakeChatExampleReviewCount;

  /// No description provided for @intakeChatExampleReviewLinks.
  ///
  /// In de, this message translates to:
  /// **'Beispiel: Google-Profil, Facebook-Seite oder Screenshot-Datei'**
  String get intakeChatExampleReviewLinks;

  /// No description provided for @intakeChatExampleMaterials.
  ///
  /// In de, this message translates to:
  /// **'Beispiel: Bedienungsanleitung, PDF-Broschüre, Präsentation oder Preisliste'**
  String get intakeChatExampleMaterials;

  /// No description provided for @intakeChatExampleMaterialLocations.
  ///
  /// In de, this message translates to:
  /// **'Beispiel: Website, Google Drive, interner Ordner oder gedruckte Unterlagen'**
  String get intakeChatExampleMaterialLocations;

  /// No description provided for @intakeChatExampleSocialProfileLinks.
  ///
  /// In de, this message translates to:
  /// **'Beispiel: https://facebook.com/meinefirma'**
  String get intakeChatExampleSocialProfileLinks;

  /// No description provided for @intakeChatExamplePostingFrequency.
  ///
  /// In de, this message translates to:
  /// **'Beispiel: zweimal pro Woche oder unregelmäßig'**
  String get intakeChatExamplePostingFrequency;

  /// No description provided for @intakeChatExampleCampaigns.
  ///
  /// In de, this message translates to:
  /// **'Beispiel: Facebook-Kampagne für Produkt X im Frühjahr'**
  String get intakeChatExampleCampaigns;

  /// No description provided for @intakeChatExampleAdBudget.
  ///
  /// In de, this message translates to:
  /// **'Beispiel: ca. 500 € pro Monat'**
  String get intakeChatExampleAdBudget;

  /// No description provided for @intakeChatExampleAdResults.
  ///
  /// In de, this message translates to:
  /// **'Beispiel: 300 Klicks, 12 Anfragen und 3 Verkäufe'**
  String get intakeChatExampleAdResults;

  /// No description provided for @intakeChatExampleGoals.
  ///
  /// In de, this message translates to:
  /// **'Beispiel: mehr Anfragen, bessere Sichtbarkeit und weniger Supportaufwand'**
  String get intakeChatExampleGoals;

  /// No description provided for @intakeChatExampleSensitiveTopics.
  ///
  /// In de, this message translates to:
  /// **'Beispiel: medizinische Aussagen, Rückerstattungen oder individuelle Rechtsberatung'**
  String get intakeChatExampleSensitiveTopics;

  /// No description provided for @intakeChatExampleNoGoStatements.
  ///
  /// In de, this message translates to:
  /// **'Beispiel: keine Heilversprechen und keine verbindliche Rechtsauskunft'**
  String get intakeChatExampleNoGoStatements;

  /// No description provided for @intakeChatExampleEscalationTopics.
  ///
  /// In de, this message translates to:
  /// **'Beispiel: Beschwerden, rechtliche Drohungen oder individuelle Gesundheitsfragen'**
  String get intakeChatExampleEscalationTopics;

  /// No description provided for @intakeChatAnswerModeYesNo.
  ///
  /// In de, this message translates to:
  /// **'Wähle Ja oder Nein.'**
  String get intakeChatAnswerModeYesNo;

  /// No description provided for @intakeChatAnswerModeChoice.
  ///
  /// In de, this message translates to:
  /// **'Wähle eine Antwort aus.'**
  String get intakeChatAnswerModeChoice;

  /// No description provided for @intakeChatAnswerModeMultiChoice.
  ///
  /// In de, this message translates to:
  /// **'Wähle alle passenden Antworten aus.'**
  String get intakeChatAnswerModeMultiChoice;

  /// No description provided for @intakeChatAnswerModeShortText.
  ///
  /// In de, this message translates to:
  /// **'Gib eine kurze Antwort ein.'**
  String get intakeChatAnswerModeShortText;

  /// No description provided for @intakeChatAnswerModeLongText.
  ///
  /// In de, this message translates to:
  /// **'Gib eine kurze Beschreibung ein.'**
  String get intakeChatAnswerModeLongText;

  /// No description provided for @intakeChatAnswerModeList.
  ///
  /// In de, this message translates to:
  /// **'Gib eine oder mehrere Angaben ein.'**
  String get intakeChatAnswerModeList;

  /// No description provided for @intakeChatAnswerModeUrl.
  ///
  /// In de, this message translates to:
  /// **'Gib eine Internetadresse ein.'**
  String get intakeChatAnswerModeUrl;

  /// No description provided for @intakeChatAnswerModeEmail.
  ///
  /// In de, this message translates to:
  /// **'Gib eine E-Mail-Adresse ein.'**
  String get intakeChatAnswerModeEmail;

  /// No description provided for @intakeChatAnswerModeApproximateNumber.
  ///
  /// In de, this message translates to:
  /// **'Gib eine Zahl oder grobe Schätzung ein.'**
  String get intakeChatAnswerModeApproximateNumber;

  /// No description provided for @intakeChatListHint.
  ///
  /// In de, this message translates to:
  /// **'Mehrere Angaben bitte durch Komma oder Zeilenumbruch trennen.'**
  String get intakeChatListHint;

  /// No description provided for @intakeChatDetailWebsite.
  ///
  /// In de, this message translates to:
  /// **'Danke. Dann erfassen wir jetzt kurz die Details zur Website.'**
  String get intakeChatDetailWebsite;

  /// No description provided for @intakeChatDetailSupport.
  ///
  /// In de, this message translates to:
  /// **'Danke. Dann sammeln wir kurz die wichtigsten Supportfragen.'**
  String get intakeChatDetailSupport;

  /// No description provided for @intakeChatDetailSensitive.
  ///
  /// In de, this message translates to:
  /// **'Danke. Dann halten wir die sensiblen Regeln genauer fest.'**
  String get intakeChatDetailSensitive;

  /// No description provided for @intakeChatDetailMaterials.
  ///
  /// In de, this message translates to:
  /// **'Danke. Dann erfassen wir kurz die vorhandenen Materialien.'**
  String get intakeChatDetailMaterials;

  /// No description provided for @intakeChatDetailReviews.
  ///
  /// In de, this message translates to:
  /// **'Danke. Dann gehen wir die Review- und Trust-Details durch.'**
  String get intakeChatDetailReviews;

  /// No description provided for @intakeChatDetailSocial.
  ///
  /// In de, this message translates to:
  /// **'Danke. Dann erfassen wir kurz die Social-Media-Details.'**
  String get intakeChatDetailSocial;

  /// No description provided for @intakeChatDetailAds.
  ///
  /// In de, this message translates to:
  /// **'Danke. Dann sammeln wir kurz die bisherigen Werbeerfahrungen.'**
  String get intakeChatDetailAds;

  /// No description provided for @intakeChatQCompanyName.
  ///
  /// In de, this message translates to:
  /// **'Wie heißt die Firma?'**
  String get intakeChatQCompanyName;

  /// No description provided for @intakeChatQShortDescription.
  ///
  /// In de, this message translates to:
  /// **'Beschreibe die Firma kurz in 1–3 Sätzen.'**
  String get intakeChatQShortDescription;

  /// No description provided for @intakeChatQIndustry.
  ///
  /// In de, this message translates to:
  /// **'In welcher Branche oder Kategorie ist die Firma tätig?'**
  String get intakeChatQIndustry;

  /// No description provided for @intakeChatQCountry.
  ///
  /// In de, this message translates to:
  /// **'In welchem Land ist die Firma hauptsächlich aktiv?'**
  String get intakeChatQCountry;

  /// No description provided for @intakeChatQPrimaryLanguage.
  ///
  /// In de, this message translates to:
  /// **'Welche Hauptsprache soll der Workspace verwenden?'**
  String get intakeChatQPrimaryLanguage;

  /// No description provided for @intakeChatQAdditionalLanguages.
  ///
  /// In de, this message translates to:
  /// **'Welche weiteren Sprachen sind wichtig?'**
  String get intakeChatQAdditionalLanguages;

  /// No description provided for @intakeChatQHasWebsite.
  ///
  /// In de, this message translates to:
  /// **'Gibt es bereits eine Website?'**
  String get intakeChatQHasWebsite;

  /// No description provided for @intakeChatQWebsite.
  ///
  /// In de, this message translates to:
  /// **'Wie lautet die Website-URL?'**
  String get intakeChatQWebsite;

  /// No description provided for @intakeChatQHasShop.
  ///
  /// In de, this message translates to:
  /// **'Gibt es einen Online-Shop?'**
  String get intakeChatQHasShop;

  /// No description provided for @intakeChatQShopUrl.
  ///
  /// In de, this message translates to:
  /// **'Wie lautet die Shop-Adresse?'**
  String get intakeChatQShopUrl;

  /// No description provided for @intakeChatQHasFaqArea.
  ///
  /// In de, this message translates to:
  /// **'Gibt es einen FAQ- oder Supportbereich auf der Website?'**
  String get intakeChatQHasFaqArea;

  /// No description provided for @intakeChatQFaqUrl.
  ///
  /// In de, this message translates to:
  /// **'Wie lautet die URL des FAQ- oder Supportbereichs?'**
  String get intakeChatQFaqUrl;

  /// No description provided for @intakeChatQWebsiteMaintainer.
  ///
  /// In de, this message translates to:
  /// **'Wer pflegt die Website aktuell?'**
  String get intakeChatQWebsiteMaintainer;

  /// No description provided for @intakeChatQCanEditWebsiteQuickly.
  ///
  /// In de, this message translates to:
  /// **'Kann die Firma Website-Inhalte kurzfristig selbst ändern?'**
  String get intakeChatQCanEditWebsiteQuickly;

  /// No description provided for @intakeChatQWebsitePlanned.
  ///
  /// In de, this message translates to:
  /// **'Ist eine Website geplant?'**
  String get intakeChatQWebsitePlanned;

  /// No description provided for @intakeChatQSupportEmail.
  ///
  /// In de, this message translates to:
  /// **'Welche Support-E-Mail soll verwendet werden?'**
  String get intakeChatQSupportEmail;

  /// No description provided for @intakeChatQSupportPhone.
  ///
  /// In de, this message translates to:
  /// **'Gibt es eine Support-Telefonnummer?'**
  String get intakeChatQSupportPhone;

  /// No description provided for @intakeChatQImportantProducts.
  ///
  /// In de, this message translates to:
  /// **'Welche wichtigsten Produkte oder Leistungen gibt es? Du kannst mehrere Zeilen verwenden.'**
  String get intakeChatQImportantProducts;

  /// No description provided for @intakeChatQMainProduct.
  ///
  /// In de, this message translates to:
  /// **'Was ist aktuell das Hauptprodukt oder Hauptangebot?'**
  String get intakeChatQMainProduct;

  /// No description provided for @intakeChatQPriorityProducts.
  ///
  /// In de, this message translates to:
  /// **'Welche Produkte oder Leistungen haben aktuell Priorität?'**
  String get intakeChatQPriorityProducts;

  /// No description provided for @intakeChatQExplanationNeeded.
  ///
  /// In de, this message translates to:
  /// **'Welche Produkte oder Leistungen sind erklärungsbedürftig?'**
  String get intakeChatQExplanationNeeded;

  /// No description provided for @intakeChatQTargetGroup.
  ///
  /// In de, this message translates to:
  /// **'Wer ist die wichtigste Zielgruppe?'**
  String get intakeChatQTargetGroup;

  /// No description provided for @intakeChatQMarketType.
  ///
  /// In de, this message translates to:
  /// **'Ist das Angebot eher B2B, B2C oder beides?'**
  String get intakeChatQMarketType;

  /// No description provided for @intakeChatQProblemSolved.
  ///
  /// In de, this message translates to:
  /// **'Welches Problem löst das Angebot für Kunden?'**
  String get intakeChatQProblemSolved;

  /// No description provided for @intakeChatQCustomerBenefit.
  ///
  /// In de, this message translates to:
  /// **'Was ist der wichtigste Kundennutzen?'**
  String get intakeChatQCustomerBenefit;

  /// No description provided for @intakeChatQDifferentiation.
  ///
  /// In de, this message translates to:
  /// **'Wodurch unterscheidet sich die Firma von Alternativen?'**
  String get intakeChatQDifferentiation;

  /// No description provided for @intakeChatQImportantPages.
  ///
  /// In de, this message translates to:
  /// **'Welche Website- oder Landingpages sind wichtig?'**
  String get intakeChatQImportantPages;

  /// No description provided for @intakeChatQHasSupportQuestions.
  ///
  /// In de, this message translates to:
  /// **'Gibt es wiederkehrende Supportfragen oder Kundenprobleme?'**
  String get intakeChatQHasSupportQuestions;

  /// No description provided for @intakeChatQSupportChannels.
  ///
  /// In de, this message translates to:
  /// **'Über welche Kanäle kommen Supportfragen herein?'**
  String get intakeChatQSupportChannels;

  /// No description provided for @intakeChatQPreSalesQuestions.
  ///
  /// In de, this message translates to:
  /// **'Welche Fragen kommen vor dem Kauf häufig vor?'**
  String get intakeChatQPreSalesQuestions;

  /// No description provided for @intakeChatQAfterSalesQuestions.
  ///
  /// In de, this message translates to:
  /// **'Welche Fragen kommen nach dem Kauf häufig vor?'**
  String get intakeChatQAfterSalesQuestions;

  /// No description provided for @intakeChatQTechnicalProblems.
  ///
  /// In de, this message translates to:
  /// **'Welche technischen Probleme treten häufig auf?'**
  String get intakeChatQTechnicalProblems;

  /// No description provided for @intakeChatQComplaintsOrMisunderstandings.
  ///
  /// In de, this message translates to:
  /// **'Welche Beschwerden oder Missverständnisse gibt es?'**
  String get intakeChatQComplaintsOrMisunderstandings;

  /// No description provided for @intakeChatQSupportOwner.
  ///
  /// In de, this message translates to:
  /// **'Wer beantwortet diese Fragen aktuell?'**
  String get intakeChatQSupportOwner;

  /// No description provided for @intakeChatQStandardizableQuestions.
  ///
  /// In de, this message translates to:
  /// **'Welche Fragen könnten standardisiert beantwortet werden?'**
  String get intakeChatQStandardizableQuestions;

  /// No description provided for @intakeChatQFrequentQuestions.
  ///
  /// In de, this message translates to:
  /// **'Welche Fragen stellen Kunden besonders häufig?'**
  String get intakeChatQFrequentQuestions;

  /// No description provided for @intakeChatQSupportProblems.
  ///
  /// In de, this message translates to:
  /// **'Welche Supportprobleme treten häufig auf?'**
  String get intakeChatQSupportProblems;

  /// No description provided for @intakeChatQHasSensitiveTopics.
  ///
  /// In de, this message translates to:
  /// **'Gibt es sensible Fragen oder Themen?'**
  String get intakeChatQHasSensitiveTopics;

  /// No description provided for @intakeChatQSensitiveTopics.
  ///
  /// In de, this message translates to:
  /// **'Welche sensiblen Fragen oder Themen sollen besonders vorsichtig behandelt werden?'**
  String get intakeChatQSensitiveTopics;

  /// No description provided for @intakeChatQProhibitedStatements.
  ///
  /// In de, this message translates to:
  /// **'Welche Aussagen oder Formulierungen sollen vermieden werden?'**
  String get intakeChatQProhibitedStatements;

  /// No description provided for @intakeChatQAlwaysEscalateTopics.
  ///
  /// In de, this message translates to:
  /// **'Bei welchen Themen soll immer an einen Menschen weitergeleitet werden?'**
  String get intakeChatQAlwaysEscalateTopics;

  /// No description provided for @intakeChatQLegalRestrictions.
  ///
  /// In de, this message translates to:
  /// **'Gibt es rechtliche oder branchenspezifische Einschränkungen?'**
  String get intakeChatQLegalRestrictions;

  /// No description provided for @intakeChatQHasMaterials.
  ///
  /// In de, this message translates to:
  /// **'Gibt es bereits Materialien wie PDFs, Anleitungen oder Präsentationen?'**
  String get intakeChatQHasMaterials;

  /// No description provided for @intakeChatQMaterialDetails.
  ///
  /// In de, this message translates to:
  /// **'Welche Materialien gibt es konkret?'**
  String get intakeChatQMaterialDetails;

  /// No description provided for @intakeChatQMaterialLocations.
  ///
  /// In de, this message translates to:
  /// **'Wo befinden sich diese Materialien?'**
  String get intakeChatQMaterialLocations;

  /// No description provided for @intakeChatQMaterialFreshness.
  ///
  /// In de, this message translates to:
  /// **'Sind die Materialien aktuell oder teilweise veraltet?'**
  String get intakeChatQMaterialFreshness;

  /// No description provided for @intakeChatQImportantMaterials.
  ///
  /// In de, this message translates to:
  /// **'Welche Materialien sind besonders wichtig?'**
  String get intakeChatQImportantMaterials;

  /// No description provided for @intakeChatQMaterialsUsableForKnowledgeBase.
  ///
  /// In de, this message translates to:
  /// **'Dürfen diese Materialien für die Wissensbasis verwendet werden?'**
  String get intakeChatQMaterialsUsableForKnowledgeBase;

  /// No description provided for @intakeChatQExistingSources.
  ///
  /// In de, this message translates to:
  /// **'Welche PDFs, Anleitungen, Notizen oder Materialien sind bereits vorhanden?'**
  String get intakeChatQExistingSources;

  /// No description provided for @intakeChatQHasReviews.
  ///
  /// In de, this message translates to:
  /// **'Gibt es Rezensionen oder Testimonials?'**
  String get intakeChatQHasReviews;

  /// No description provided for @intakeChatQReviewPlatforms.
  ///
  /// In de, this message translates to:
  /// **'Wo befinden sich diese Rezensionen?'**
  String get intakeChatQReviewPlatforms;

  /// No description provided for @intakeChatQReviewCountEstimate.
  ///
  /// In de, this message translates to:
  /// **'Wie viele Rezensionen gibt es ungefähr?'**
  String get intakeChatQReviewCountEstimate;

  /// No description provided for @intakeChatQReviewLinksOrFiles.
  ///
  /// In de, this message translates to:
  /// **'Gibt es Links, Dateien oder Screenshots zu den Rezensionen?'**
  String get intakeChatQReviewLinksOrFiles;

  /// No description provided for @intakeChatQReviewTypes.
  ///
  /// In de, this message translates to:
  /// **'Um welche Art von Rezensionen handelt es sich?'**
  String get intakeChatQReviewTypes;

  /// No description provided for @intakeChatQReviewsPubliclyUsable.
  ///
  /// In de, this message translates to:
  /// **'Sind die Rezensionen öffentlich nutzbar?'**
  String get intakeChatQReviewsPubliclyUsable;

  /// No description provided for @intakeChatQReviewsEmbeddedOnWebsite.
  ///
  /// In de, this message translates to:
  /// **'Sind sie bereits auf der Website eingebunden?'**
  String get intakeChatQReviewsEmbeddedOnWebsite;

  /// No description provided for @intakeChatQCollectReviewsPlanned.
  ///
  /// In de, this message translates to:
  /// **'Soll künftig gezielt Trust- oder Review-Material gesammelt werden?'**
  String get intakeChatQCollectReviewsPlanned;

  /// No description provided for @intakeChatQReviews.
  ///
  /// In de, this message translates to:
  /// **'Welche Rezensionen oder Testimonials sind relevant?'**
  String get intakeChatQReviews;

  /// No description provided for @intakeChatQHasSocialMentions.
  ///
  /// In de, this message translates to:
  /// **'Gibt es Social-Media-Erwähnungen oder externe Diskussionen?'**
  String get intakeChatQHasSocialMentions;

  /// No description provided for @intakeChatQSocialMentions.
  ///
  /// In de, this message translates to:
  /// **'Welche Social-Media-Erwähnungen oder externen Diskussionen sind wichtig?'**
  String get intakeChatQSocialMentions;

  /// No description provided for @intakeChatQHasTrustMaterial.
  ///
  /// In de, this message translates to:
  /// **'Gibt es Trust-Material wie Siegel, Referenzen oder Nachweise?'**
  String get intakeChatQHasTrustMaterial;

  /// No description provided for @intakeChatQTrustMaterial.
  ///
  /// In de, this message translates to:
  /// **'Welches Trust-Material ist vorhanden?'**
  String get intakeChatQTrustMaterial;

  /// No description provided for @intakeChatQHasSocialChannels.
  ///
  /// In de, this message translates to:
  /// **'Gibt es aktive Social-Media-Kanäle?'**
  String get intakeChatQHasSocialChannels;

  /// No description provided for @intakeChatQSocialPlatforms.
  ///
  /// In de, this message translates to:
  /// **'Welche Plattformen werden genutzt?'**
  String get intakeChatQSocialPlatforms;

  /// No description provided for @intakeChatQSocialProfileLinks.
  ///
  /// In de, this message translates to:
  /// **'Wie lauten die Links oder Profilnamen?'**
  String get intakeChatQSocialProfileLinks;

  /// No description provided for @intakeChatQActiveChannels.
  ///
  /// In de, this message translates to:
  /// **'Welche Kanäle sind aktuell aktiv?'**
  String get intakeChatQActiveChannels;

  /// No description provided for @intakeChatQPostingFrequency.
  ///
  /// In de, this message translates to:
  /// **'Wie oft wird ungefähr gepostet?'**
  String get intakeChatQPostingFrequency;

  /// No description provided for @intakeChatQWorkingChannels.
  ///
  /// In de, this message translates to:
  /// **'Welche Kanäle funktionieren gut?'**
  String get intakeChatQWorkingChannels;

  /// No description provided for @intakeChatQInactiveChannels.
  ///
  /// In de, this message translates to:
  /// **'Welche Kanäle liegen brach?'**
  String get intakeChatQInactiveChannels;

  /// No description provided for @intakeChatQFutureSocialPlatforms.
  ///
  /// In de, this message translates to:
  /// **'Welche Plattform wäre grundsätzlich interessant?'**
  String get intakeChatQFutureSocialPlatforms;

  /// No description provided for @intakeChatQChannels.
  ///
  /// In de, this message translates to:
  /// **'Welche Marketing- oder Kommunikationskanäle wurden bisher genutzt?'**
  String get intakeChatQChannels;

  /// No description provided for @intakeChatQHasRunAds.
  ///
  /// In de, this message translates to:
  /// **'Wurde bereits Werbung geschaltet?'**
  String get intakeChatQHasRunAds;

  /// No description provided for @intakeChatQAdvertisingChannels.
  ///
  /// In de, this message translates to:
  /// **'Auf welchen Kanälen wurde Werbung geschaltet?'**
  String get intakeChatQAdvertisingChannels;

  /// No description provided for @intakeChatQCampaigns.
  ///
  /// In de, this message translates to:
  /// **'Welche Werbemaßnahmen wurden bisher ausprobiert?'**
  String get intakeChatQCampaigns;

  /// No description provided for @intakeChatQApproximateBudget.
  ///
  /// In de, this message translates to:
  /// **'Wie hoch war das ungefähre Budget?'**
  String get intakeChatQApproximateBudget;

  /// No description provided for @intakeChatQSuccessfulMeasures.
  ///
  /// In de, this message translates to:
  /// **'Was hat funktioniert?'**
  String get intakeChatQSuccessfulMeasures;

  /// No description provided for @intakeChatQUnsuccessfulMeasures.
  ///
  /// In de, this message translates to:
  /// **'Was hat nicht funktioniert?'**
  String get intakeChatQUnsuccessfulMeasures;

  /// No description provided for @intakeChatQAvailableMetrics.
  ///
  /// In de, this message translates to:
  /// **'Gibt es Zahlen zu Klicks, Leads, Verkäufen oder Anfragen?'**
  String get intakeChatQAvailableMetrics;

  /// No description provided for @intakeChatQAdAccountAccess.
  ///
  /// In de, this message translates to:
  /// **'Gibt es Zugriff auf Werbekonten oder Berichte?'**
  String get intakeChatQAdAccountAccess;

  /// No description provided for @intakeChatQFutureAdChannels.
  ///
  /// In de, this message translates to:
  /// **'Welche Werbekanäle sollen zukünftig geprüft werden?'**
  String get intakeChatQFutureAdChannels;

  /// No description provided for @intakeChatQWorkedNotWorked.
  ///
  /// In de, this message translates to:
  /// **'Was hat bisher funktioniert und was nicht?'**
  String get intakeChatQWorkedNotWorked;

  /// No description provided for @intakeChatQReachProblems.
  ///
  /// In de, this message translates to:
  /// **'Wo bestehen aktuell Reichweitenprobleme?'**
  String get intakeChatQReachProblems;

  /// No description provided for @intakeChatQCompanyGoals.
  ///
  /// In de, this message translates to:
  /// **'Was sind die wichtigsten Ziele der Firma?'**
  String get intakeChatQCompanyGoals;

  /// No description provided for @intakeChatQShortTermPriorities.
  ///
  /// In de, this message translates to:
  /// **'Was sind die kurzfristigen Prioritäten?'**
  String get intakeChatQShortTermPriorities;

  /// No description provided for @intakeChatQForbiddenClaims.
  ///
  /// In de, this message translates to:
  /// **'Welche Aussagen sind sensibel oder verboten?'**
  String get intakeChatQForbiddenClaims;

  /// No description provided for @intakeChatQBotRestrictedTopics.
  ///
  /// In de, this message translates to:
  /// **'Welche Themen darf ein Bot nicht frei beantworten?'**
  String get intakeChatQBotRestrictedTopics;

  /// No description provided for @intakeChoiceOther.
  ///
  /// In de, this message translates to:
  /// **'Andere'**
  String get intakeChoiceOther;

  /// No description provided for @intakeChoiceOtherHint.
  ///
  /// In de, this message translates to:
  /// **'Andere Antwort eingeben'**
  String get intakeChoiceOtherHint;

  /// No description provided for @intakeChoiceDialogSingleHint.
  ///
  /// In de, this message translates to:
  /// **'Tippe eine Option an.'**
  String get intakeChoiceDialogSingleHint;

  /// No description provided for @intakeChoiceDialogMultiHint.
  ///
  /// In de, this message translates to:
  /// **'Tippe alle passenden Optionen an.'**
  String get intakeChoiceDialogMultiHint;

  /// No description provided for @intakeChoiceDialogSelectionRequired.
  ///
  /// In de, this message translates to:
  /// **'Bitte wähle mindestens eine Option aus.'**
  String get intakeChoiceDialogSelectionRequired;

  /// No description provided for @intakeChoiceDialogSaveContinue.
  ///
  /// In de, this message translates to:
  /// **'Auswahl speichern und weiter'**
  String get intakeChoiceDialogSaveContinue;

  /// No description provided for @intakeChoiceLanguageOptions.
  ///
  /// In de, this message translates to:
  /// **'Deutsch|Englisch|Französisch|Italienisch|Spanisch|Niederländisch|Polnisch'**
  String get intakeChoiceLanguageOptions;

  /// No description provided for @intakeChoiceRegionOptions.
  ///
  /// In de, this message translates to:
  /// **'Inland|DACH|EU|Europa|weltweit|einzelne Länder'**
  String get intakeChoiceRegionOptions;

  /// No description provided for @intakeChoiceTargetGroupOptions.
  ///
  /// In de, this message translates to:
  /// **'Privatkunden|Unternehmen|Händler|Therapeuten|Behörden|Vereine|Bildungseinrichtungen|Tierhalter|internationale Kunden'**
  String get intakeChoiceTargetGroupOptions;

  /// No description provided for @intakeChoiceMarketTypeOptions.
  ///
  /// In de, this message translates to:
  /// **'B2C|B2B|beides'**
  String get intakeChoiceMarketTypeOptions;

  /// No description provided for @intakeChoiceSupportChannelOptions.
  ///
  /// In de, this message translates to:
  /// **'Telefon|E-Mail|WhatsApp|Telegram|Website-Formular|Live-Chat|Facebook Messenger|Instagram|persönlich vor Ort|Händler|keine feste Struktur'**
  String get intakeChoiceSupportChannelOptions;

  /// No description provided for @intakeChoiceSensitiveCategoryOptions.
  ///
  /// In de, this message translates to:
  /// **'medizinische Aussagen|rechtliche Fragen|Datenschutz|Preise/Rabatte|Beschwerden|Rückerstattungen|Produktsicherheit|technische Störungen|individuelle Beratung|vertrauliche Firmendaten'**
  String get intakeChoiceSensitiveCategoryOptions;

  /// No description provided for @intakeChoiceMaterialOptions.
  ///
  /// In de, this message translates to:
  /// **'Bedienungsanleitung|PDF|Broschüre|Präsentation|Preislisten|Produkttexte|FAQ-Liste|Antwortvorlagen|Videos|Bilder|Screenshots|interne Notizen|E-Mails'**
  String get intakeChoiceMaterialOptions;

  /// No description provided for @intakeChoiceReviewPlatformOptions.
  ///
  /// In de, this message translates to:
  /// **'eigene Website|Google|Facebook|Trustpilot|Amazon|App Store|Google Play|YouTube|E-Mail|Screenshots|Foren'**
  String get intakeChoiceReviewPlatformOptions;

  /// No description provided for @intakeChoiceSocialPlatformOptions.
  ///
  /// In de, this message translates to:
  /// **'Facebook|Instagram|TikTok|YouTube|LinkedIn|WhatsApp|Telegram|Reddit|X|Pinterest|Snapchat|eigener Blog|Newsletter|keine'**
  String get intakeChoiceSocialPlatformOptions;

  /// No description provided for @intakeChoiceAdvertisingChannelOptions.
  ///
  /// In de, this message translates to:
  /// **'Google Ads|Facebook Ads|Instagram Ads|TikTok Ads|YouTube Ads|LinkedIn Ads|Influencer|SEO|Newsletter|Print|Flyer|Messen|Telegram-/Community-Marketing|keine'**
  String get intakeChoiceAdvertisingChannelOptions;

  /// No description provided for @intakeChoiceGoalOptions.
  ///
  /// In de, this message translates to:
  /// **'mehr Verkäufe|mehr Anfragen|größere Reichweite|bessere Sichtbarkeit|weniger Supportaufwand|bessere Kundeninformation|mehr Rezensionen|bessere Website|Social Media ausbauen|Werbung optimieren|neue Märkte|interne Abläufe verbessern'**
  String get intakeChoiceGoalOptions;

  /// No description provided for @intakeChoiceReachProblemOptions.
  ///
  /// In de, this message translates to:
  /// **'zu wenig Website-Besucher|zu wenig Anfragen|zu wenig Verkäufe|wenig Social-Reichweite|zu wenig Rezensionen|unklare Positionierung|schwache Landingpage|zu wenig Vertrauen|zu wenig Content|falsche Werbekanäle|keine Messdaten'**
  String get intakeChoiceReachProblemOptions;

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

  /// No description provided for @companyCoreSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Business Core für Audit, Wissensbasis, Bot und externe Kanäle'**
  String get companyCoreSubtitle;

  /// No description provided for @companyProfileSection.
  ///
  /// In de, this message translates to:
  /// **'Firmenprofil'**
  String get companyProfileSection;

  /// No description provided for @companyContactWebSection.
  ///
  /// In de, this message translates to:
  /// **'Kontakt & Web'**
  String get companyContactWebSection;

  /// No description provided for @companySocialSection.
  ///
  /// In de, this message translates to:
  /// **'Social / Kanäle'**
  String get companySocialSection;

  /// No description provided for @companyBusinessRulesSection.
  ///
  /// In de, this message translates to:
  /// **'Business Rules'**
  String get companyBusinessRulesSection;

  /// No description provided for @companyInternalNotesSection.
  ///
  /// In de, this message translates to:
  /// **'Interne Notizen'**
  String get companyInternalNotesSection;

  /// No description provided for @companyNoSocialLinks.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Social- oder Kanal-Links gepflegt.'**
  String get companyNoSocialLinks;

  /// No description provided for @companyNoInternalNotes.
  ///
  /// In de, this message translates to:
  /// **'Noch keine internen Notizen gepflegt.'**
  String get companyNoInternalNotes;

  /// No description provided for @companyBrandVoice.
  ///
  /// In de, this message translates to:
  /// **'Brand Voice / Tonalität'**
  String get companyBrandVoice;

  /// No description provided for @companyDoNotSay.
  ///
  /// In de, this message translates to:
  /// **'Do-not-say / No-Go-Regeln'**
  String get companyDoNotSay;

  /// No description provided for @companyAllowedSupportTopics.
  ///
  /// In de, this message translates to:
  /// **'Erlaubte Support-Themen'**
  String get companyAllowedSupportTopics;

  /// No description provided for @companyEscalationNotes.
  ///
  /// In de, this message translates to:
  /// **'Eskalationshinweise'**
  String get companyEscalationNotes;

  /// No description provided for @companyDisclaimerText.
  ///
  /// In de, this message translates to:
  /// **'Disclaimer-Text'**
  String get companyDisclaimerText;

  /// No description provided for @companyProfileComplete.
  ///
  /// In de, this message translates to:
  /// **'Vollständig'**
  String get companyProfileComplete;

  /// No description provided for @companyProfilePartial.
  ///
  /// In de, this message translates to:
  /// **'Teilweise'**
  String get companyProfilePartial;

  /// No description provided for @companyProfileIncomplete.
  ///
  /// In de, this message translates to:
  /// **'Unvollständig'**
  String get companyProfileIncomplete;

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

  /// No description provided for @knowledgeSourceMaterialOptional.
  ///
  /// In de, this message translates to:
  /// **'Quellenmaterial verknüpfen (optional)'**
  String get knowledgeSourceMaterialOptional;

  /// No description provided for @knowledgeNoSourceMaterial.
  ///
  /// In de, this message translates to:
  /// **'Keine Quelle verknüpfen'**
  String get knowledgeNoSourceMaterial;

  /// No description provided for @knowledgeMarkSourceConverted.
  ///
  /// In de, this message translates to:
  /// **'Quelle als übernommen markieren'**
  String get knowledgeMarkSourceConverted;

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
  /// **'Quellen und Materialien dieses Workspaces'**
  String get sourcesSubtitle;

  /// No description provided for @sourcesAdd.
  ///
  /// In de, this message translates to:
  /// **'Quelle hinzufügen'**
  String get sourcesAdd;

  /// No description provided for @sourcesCount.
  ///
  /// In de, this message translates to:
  /// **'{count} Quellen'**
  String sourcesCount(int count);

  /// No description provided for @sourcesNewCount.
  ///
  /// In de, this message translates to:
  /// **'{count} neu'**
  String sourcesNewCount(int count);

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

  /// No description provided for @sourcesFilterAllTypes.
  ///
  /// In de, this message translates to:
  /// **'Alle Typen'**
  String get sourcesFilterAllTypes;

  /// No description provided for @sourcesFilterAllStatuses.
  ///
  /// In de, this message translates to:
  /// **'Alle Status'**
  String get sourcesFilterAllStatuses;

  /// No description provided for @sourcesLinkedEntries.
  ///
  /// In de, this message translates to:
  /// **'{count} verknüpfte Einträge'**
  String sourcesLinkedEntries(int count);

  /// No description provided for @sourcesDeleteTitle.
  ///
  /// In de, this message translates to:
  /// **'Quelle löschen?'**
  String get sourcesDeleteTitle;

  /// No description provided for @sourcesDeleteConfirm.
  ///
  /// In de, this message translates to:
  /// **'\"{title}\" wird aus der Quellenliste entfernt. Wissenseinträge bleiben erhalten.'**
  String sourcesDeleteConfirm(String title);

  /// No description provided for @sourcesEdit.
  ///
  /// In de, this message translates to:
  /// **'Quelle bearbeiten'**
  String get sourcesEdit;

  /// No description provided for @sourcesType.
  ///
  /// In de, this message translates to:
  /// **'Quellentyp'**
  String get sourcesType;

  /// No description provided for @sourcesStatus.
  ///
  /// In de, this message translates to:
  /// **'Status'**
  String get sourcesStatus;

  /// No description provided for @sourcesUrlOptional.
  ///
  /// In de, this message translates to:
  /// **'URL (optional)'**
  String get sourcesUrlOptional;

  /// No description provided for @sourcesSnippetOptional.
  ///
  /// In de, this message translates to:
  /// **'Inhaltsauszug (optional)'**
  String get sourcesSnippetOptional;

  /// No description provided for @sourcesNotesOptional.
  ///
  /// In de, this message translates to:
  /// **'Notizen (optional)'**
  String get sourcesNotesOptional;

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

  /// No description provided for @sourceMaterialTypeWebsite.
  ///
  /// In de, this message translates to:
  /// **'Website'**
  String get sourceMaterialTypeWebsite;

  /// No description provided for @sourceMaterialTypePdf.
  ///
  /// In de, this message translates to:
  /// **'PDF'**
  String get sourceMaterialTypePdf;

  /// No description provided for @sourceMaterialTypeFaq.
  ///
  /// In de, this message translates to:
  /// **'FAQ'**
  String get sourceMaterialTypeFaq;

  /// No description provided for @sourceMaterialTypeReview.
  ///
  /// In de, this message translates to:
  /// **'Rezension'**
  String get sourceMaterialTypeReview;

  /// No description provided for @sourceMaterialTypeSocial.
  ///
  /// In de, this message translates to:
  /// **'Social'**
  String get sourceMaterialTypeSocial;

  /// No description provided for @sourceMaterialTypeNote.
  ///
  /// In de, this message translates to:
  /// **'Notiz'**
  String get sourceMaterialTypeNote;

  /// No description provided for @sourceMaterialTypeOther.
  ///
  /// In de, this message translates to:
  /// **'Sonstiges'**
  String get sourceMaterialTypeOther;

  /// No description provided for @sourceMaterialStatusNew.
  ///
  /// In de, this message translates to:
  /// **'Neu'**
  String get sourceMaterialStatusNew;

  /// No description provided for @sourceMaterialStatusReviewed.
  ///
  /// In de, this message translates to:
  /// **'Geprüft'**
  String get sourceMaterialStatusReviewed;

  /// No description provided for @sourceMaterialStatusConverted.
  ///
  /// In de, this message translates to:
  /// **'Übernommen'**
  String get sourceMaterialStatusConverted;

  /// No description provided for @sourceMaterialStatusIgnored.
  ///
  /// In de, this message translates to:
  /// **'Ignoriert'**
  String get sourceMaterialStatusIgnored;

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

  /// No description provided for @statReviewedBotQuestions.
  ///
  /// In de, this message translates to:
  /// **'Geprüfte Bot-Fragen'**
  String get statReviewedBotQuestions;

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

  /// No description provided for @statCompanyProfile.
  ///
  /// In de, this message translates to:
  /// **'Firmenprofil'**
  String get statCompanyProfile;

  /// No description provided for @statBotStatus.
  ///
  /// In de, this message translates to:
  /// **'Bot-Status'**
  String get statBotStatus;

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

  /// No description provided for @botSettingsTitle.
  ///
  /// In de, this message translates to:
  /// **'Bot-Einstellungen'**
  String get botSettingsTitle;

  /// No description provided for @botSettingsSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Konfiguration für {companyName}'**
  String botSettingsSubtitle(String companyName);

  /// No description provided for @botSettingsStatus.
  ///
  /// In de, this message translates to:
  /// **'Status'**
  String get botSettingsStatus;

  /// No description provided for @botSettingsAnswerStyle.
  ///
  /// In de, this message translates to:
  /// **'Antwortstil'**
  String get botSettingsAnswerStyle;

  /// No description provided for @botSettingsLanguage.
  ///
  /// In de, this message translates to:
  /// **'Sprache'**
  String get botSettingsLanguage;

  /// No description provided for @botSettingsDisclaimer.
  ///
  /// In de, this message translates to:
  /// **'Disclaimer'**
  String get botSettingsDisclaimer;

  /// No description provided for @botSettingsUseDisclaimer.
  ///
  /// In de, this message translates to:
  /// **'Disclaimer bei gelben Antworten anzeigen'**
  String get botSettingsUseDisclaimer;

  /// No description provided for @botSettingsDisclaimerText.
  ///
  /// In de, this message translates to:
  /// **'Disclaimer-Text'**
  String get botSettingsDisclaimerText;

  /// No description provided for @botSettingsNoDisclaimer.
  ///
  /// In de, this message translates to:
  /// **'Kein Disclaimer gepflegt.'**
  String get botSettingsNoDisclaimer;

  /// No description provided for @botSettingsEscalation.
  ///
  /// In de, this message translates to:
  /// **'Eskalation / Human Handover'**
  String get botSettingsEscalation;

  /// No description provided for @botSettingsEscalateRedFlags.
  ///
  /// In de, this message translates to:
  /// **'Rote Fragen immer eskalieren'**
  String get botSettingsEscalateRedFlags;

  /// No description provided for @botSettingsEscalateNoMatch.
  ///
  /// In de, this message translates to:
  /// **'No-Match-Fragen in Review schicken'**
  String get botSettingsEscalateNoMatch;

  /// No description provided for @botSettingsEscalateYellowRisk.
  ///
  /// In de, this message translates to:
  /// **'Gelbe Antworten in Review schicken'**
  String get botSettingsEscalateYellowRisk;

  /// No description provided for @botSettingsHandoverMessage.
  ///
  /// In de, this message translates to:
  /// **'Handover-Nachricht'**
  String get botSettingsHandoverMessage;

  /// No description provided for @botSettingsNoHandover.
  ///
  /// In de, this message translates to:
  /// **'Keine Handover-Nachricht gepflegt.'**
  String get botSettingsNoHandover;

  /// No description provided for @botSettingsAllowedTopics.
  ///
  /// In de, this message translates to:
  /// **'Erlaubte Themen'**
  String get botSettingsAllowedTopics;

  /// No description provided for @botSettingsBlockedTopics.
  ///
  /// In de, this message translates to:
  /// **'Gesperrte Themen'**
  String get botSettingsBlockedTopics;

  /// No description provided for @botSettingsNoAllowedTopics.
  ///
  /// In de, this message translates to:
  /// **'Noch keine erlaubten Themen gepflegt.'**
  String get botSettingsNoAllowedTopics;

  /// No description provided for @botSettingsNoBlockedTopics.
  ///
  /// In de, this message translates to:
  /// **'Noch keine gesperrten Themen gepflegt.'**
  String get botSettingsNoBlockedTopics;

  /// No description provided for @botStatusDraft.
  ///
  /// In de, this message translates to:
  /// **'Entwurf'**
  String get botStatusDraft;

  /// No description provided for @botStatusTestReady.
  ///
  /// In de, this message translates to:
  /// **'Testbereit'**
  String get botStatusTestReady;

  /// No description provided for @botStatusActive.
  ///
  /// In de, this message translates to:
  /// **'Aktiv'**
  String get botStatusActive;

  /// No description provided for @botAnswerStyleShort.
  ///
  /// In de, this message translates to:
  /// **'Kurz'**
  String get botAnswerStyleShort;

  /// No description provided for @botAnswerStyleBalanced.
  ///
  /// In de, this message translates to:
  /// **'Ausgewogen'**
  String get botAnswerStyleBalanced;

  /// No description provided for @botAnswerStyleDetailed.
  ///
  /// In de, this message translates to:
  /// **'Detailliert'**
  String get botAnswerStyleDetailed;

  /// No description provided for @languageGerman.
  ///
  /// In de, this message translates to:
  /// **'Deutsch'**
  String get languageGerman;

  /// No description provided for @languageEnglish.
  ///
  /// In de, this message translates to:
  /// **'Englisch'**
  String get languageEnglish;

  /// No description provided for @navProjectStatus.
  ///
  /// In de, this message translates to:
  /// **'Projektstatus'**
  String get navProjectStatus;

  /// No description provided for @projectStatusTitle.
  ///
  /// In de, this message translates to:
  /// **'Projektstatus'**
  String get projectStatusTitle;

  /// No description provided for @projectStatusSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Gesamtfortschritt und nächste Schritte für {companyName}'**
  String projectStatusSubtitle(String companyName);

  /// No description provided for @projectNextStep.
  ///
  /// In de, this message translates to:
  /// **'Nächster empfohlener Schritt'**
  String get projectNextStep;

  /// No description provided for @projectOpenNow.
  ///
  /// In de, this message translates to:
  /// **'Jetzt öffnen'**
  String get projectOpenNow;

  /// No description provided for @projectCompletedTasks.
  ///
  /// In de, this message translates to:
  /// **'{count} erledigt'**
  String projectCompletedTasks(int count);

  /// No description provided for @projectOpenTasks.
  ///
  /// In de, this message translates to:
  /// **'{count} offen'**
  String projectOpenTasks(int count);

  /// No description provided for @projectHighPriorityTasks.
  ///
  /// In de, this message translates to:
  /// **'{count} hohe Priorität'**
  String projectHighPriorityTasks(int count);

  /// No description provided for @projectCurrentPhase.
  ///
  /// In de, this message translates to:
  /// **'Aktuelle Phase: {phase}'**
  String projectCurrentPhase(String phase);

  /// No description provided for @projectPhasesTitle.
  ///
  /// In de, this message translates to:
  /// **'Projektphasen'**
  String get projectPhasesTitle;

  /// No description provided for @projectTasksTitle.
  ///
  /// In de, this message translates to:
  /// **'Statuspunkte'**
  String get projectTasksTitle;

  /// No description provided for @projectRecommendationsTitle.
  ///
  /// In de, this message translates to:
  /// **'Nächste empfohlene Schritte'**
  String get projectRecommendationsTitle;

  /// No description provided for @projectRecommendationsEmpty.
  ///
  /// In de, this message translates to:
  /// **'Alle wichtigen nächsten Schritte sind aktuell erledigt.'**
  String get projectRecommendationsEmpty;

  /// No description provided for @projectPhaseCompany.
  ///
  /// In de, this message translates to:
  /// **'Phase 1 · Unternehmen'**
  String get projectPhaseCompany;

  /// No description provided for @projectPhaseKnowledge.
  ///
  /// In de, this message translates to:
  /// **'Phase 2 · Wissen'**
  String get projectPhaseKnowledge;

  /// No description provided for @projectPhaseAi.
  ///
  /// In de, this message translates to:
  /// **'Phase 3 · KI'**
  String get projectPhaseAi;

  /// No description provided for @projectPhaseMarketing.
  ///
  /// In de, this message translates to:
  /// **'Phase 4 · Marketing'**
  String get projectPhaseMarketing;

  /// No description provided for @projectPhaseControlling.
  ///
  /// In de, this message translates to:
  /// **'Phase 5 · Controlling'**
  String get projectPhaseControlling;

  /// No description provided for @projectPhaseCompanyDescription.
  ///
  /// In de, this message translates to:
  /// **'Firmenprofil, Aufnahme und Grundregeln klären.'**
  String get projectPhaseCompanyDescription;

  /// No description provided for @projectPhaseKnowledgeDescription.
  ///
  /// In de, this message translates to:
  /// **'Wissen, Quellen, Website und Audit strukturieren.'**
  String get projectPhaseKnowledgeDescription;

  /// No description provided for @projectPhaseAiDescription.
  ///
  /// In de, this message translates to:
  /// **'Bot konfigurieren, testen und Reviews schließen.'**
  String get projectPhaseAiDescription;

  /// No description provided for @projectPhaseMarketingDescription.
  ///
  /// In de, this message translates to:
  /// **'Kanäle, Inhalte und Wachstumsschritte vorbereiten.'**
  String get projectPhaseMarketingDescription;

  /// No description provided for @projectPhaseControllingDescription.
  ///
  /// In de, this message translates to:
  /// **'Nutzung, offene Aufgaben und Wirkung beobachten.'**
  String get projectPhaseControllingDescription;

  /// No description provided for @projectPriorityLow.
  ///
  /// In de, this message translates to:
  /// **'Niedrig'**
  String get projectPriorityLow;

  /// No description provided for @projectPriorityMedium.
  ///
  /// In de, this message translates to:
  /// **'Mittel'**
  String get projectPriorityMedium;

  /// No description provided for @projectPriorityHigh.
  ///
  /// In de, this message translates to:
  /// **'Hoch'**
  String get projectPriorityHigh;

  /// No description provided for @projectCompletionMissing.
  ///
  /// In de, this message translates to:
  /// **'Offen'**
  String get projectCompletionMissing;

  /// No description provided for @projectCompletionPartial.
  ///
  /// In de, this message translates to:
  /// **'Teilweise'**
  String get projectCompletionPartial;

  /// No description provided for @projectCompletionComplete.
  ///
  /// In de, this message translates to:
  /// **'Erledigt'**
  String get projectCompletionComplete;

  /// No description provided for @projectTaskCompanyProfileTitle.
  ///
  /// In de, this message translates to:
  /// **'Firmenprofil'**
  String get projectTaskCompanyProfileTitle;

  /// No description provided for @projectTaskCompanyProfileDescription.
  ///
  /// In de, this message translates to:
  /// **'Profil, Kontaktwege und Geschäftsregeln sind gepflegt.'**
  String get projectTaskCompanyProfileDescription;

  /// No description provided for @projectTaskIntakeTitle.
  ///
  /// In de, this message translates to:
  /// **'Firmenaufnahme'**
  String get projectTaskIntakeTitle;

  /// No description provided for @projectTaskIntakeDescription.
  ///
  /// In de, this message translates to:
  /// **'Der geführte Fragebogen wurde ausgefüllt und übernommen.'**
  String get projectTaskIntakeDescription;

  /// No description provided for @projectTaskKnowledgeTitle.
  ///
  /// In de, this message translates to:
  /// **'Wissensbasis'**
  String get projectTaskKnowledgeTitle;

  /// No description provided for @projectTaskKnowledgeDescription.
  ///
  /// In de, this message translates to:
  /// **'Ausreichend FAQ- und Supportwissen ist vorhanden.'**
  String get projectTaskKnowledgeDescription;

  /// No description provided for @projectTaskSourcesTitle.
  ///
  /// In de, this message translates to:
  /// **'Quellen'**
  String get projectTaskSourcesTitle;

  /// No description provided for @projectTaskSourcesDescription.
  ///
  /// In de, this message translates to:
  /// **'Materialien wurden gesammelt, geprüft und in Wissen überführt.'**
  String get projectTaskSourcesDescription;

  /// No description provided for @projectTaskAuditTitle.
  ///
  /// In de, this message translates to:
  /// **'Audit'**
  String get projectTaskAuditTitle;

  /// No description provided for @projectTaskAuditDescription.
  ///
  /// In de, this message translates to:
  /// **'Wichtige Lücken und Risiken sind bewertet.'**
  String get projectTaskAuditDescription;

  /// No description provided for @projectTaskWebsiteTitle.
  ///
  /// In de, this message translates to:
  /// **'Website analysieren'**
  String get projectTaskWebsiteTitle;

  /// No description provided for @projectTaskWebsiteDescription.
  ///
  /// In de, this message translates to:
  /// **'Website-Inhalte sind als Quelle geprüft.'**
  String get projectTaskWebsiteDescription;

  /// No description provided for @projectTaskMarketingTitle.
  ///
  /// In de, this message translates to:
  /// **'Marketing vorbereiten'**
  String get projectTaskMarketingTitle;

  /// No description provided for @projectTaskMarketingDescription.
  ///
  /// In de, this message translates to:
  /// **'Kanäle, Kampagnen und nächste Wachstumsschritte sind erfasst.'**
  String get projectTaskMarketingDescription;

  /// No description provided for @projectTaskBotTitle.
  ///
  /// In de, this message translates to:
  /// **'Bot aktivieren'**
  String get projectTaskBotTitle;

  /// No description provided for @projectTaskBotDescription.
  ///
  /// In de, this message translates to:
  /// **'Antwortstil, Grenzen und Übergabe an Menschen sind eingerichtet.'**
  String get projectTaskBotDescription;

  /// No description provided for @projectTaskReviewTitle.
  ///
  /// In de, this message translates to:
  /// **'Human Review abschließen'**
  String get projectTaskReviewTitle;

  /// No description provided for @projectTaskReviewDescription.
  ///
  /// In de, this message translates to:
  /// **'Offene Bot-Fragen wurden geprüft oder erledigt.'**
  String get projectTaskReviewDescription;

  /// No description provided for @projectTaskControllingTitle.
  ///
  /// In de, this message translates to:
  /// **'Controlling aktivieren'**
  String get projectTaskControllingTitle;

  /// No description provided for @projectTaskControllingDescription.
  ///
  /// In de, this message translates to:
  /// **'Aktivität und Fortschritt können nachvollzogen werden.'**
  String get projectTaskControllingDescription;

  /// No description provided for @projectRecommendationProfile.
  ///
  /// In de, this message translates to:
  /// **'Ergänzen Sie fehlende Unternehmensdaten und Regeln.'**
  String get projectRecommendationProfile;

  /// No description provided for @projectRecommendationIntake.
  ///
  /// In de, this message translates to:
  /// **'Führen Sie die Firmenaufnahme weiter oder übernehmen Sie die Antworten.'**
  String get projectRecommendationIntake;

  /// No description provided for @projectRecommendationKnowledge.
  ///
  /// In de, this message translates to:
  /// **'Erweitern Sie FAQ- und Supportwissen für sichere Antworten.'**
  String get projectRecommendationKnowledge;

  /// No description provided for @projectRecommendationSources.
  ///
  /// In de, this message translates to:
  /// **'Prüfen Sie neue Quellen und übernehmen Sie verwertbares Wissen.'**
  String get projectRecommendationSources;

  /// No description provided for @projectRecommendationAudit.
  ///
  /// In de, this message translates to:
  /// **'Schließen Sie wichtige Audit-Lücken vor dem weiteren Ausbau.'**
  String get projectRecommendationAudit;

  /// No description provided for @projectRecommendationWebsite.
  ///
  /// In de, this message translates to:
  /// **'Erfassen oder prüfen Sie Website-Inhalte als Quelle.'**
  String get projectRecommendationWebsite;

  /// No description provided for @projectRecommendationMarketing.
  ///
  /// In de, this message translates to:
  /// **'Ergänzen Sie Kanäle, Kampagnen und Wachstumshinweise.'**
  String get projectRecommendationMarketing;

  /// No description provided for @projectRecommendationBot.
  ///
  /// In de, this message translates to:
  /// **'Prüfen Sie Bot-Einstellungen und testen Sie den Antwortfluss.'**
  String get projectRecommendationBot;

  /// No description provided for @projectRecommendationReview.
  ///
  /// In de, this message translates to:
  /// **'Bearbeiten Sie offene Fragen im Human Review.'**
  String get projectRecommendationReview;

  /// No description provided for @projectRecommendationControlling.
  ///
  /// In de, this message translates to:
  /// **'Sammeln Sie mehr Aktivität, damit Fortschritt messbar wird.'**
  String get projectRecommendationControlling;

  /// No description provided for @navMarketingStrategy.
  ///
  /// In de, this message translates to:
  /// **'Marketing'**
  String get navMarketingStrategy;

  /// No description provided for @marketingStrategyTitle.
  ///
  /// In de, this message translates to:
  /// **'Marketing Strategy'**
  String get marketingStrategyTitle;

  /// No description provided for @marketingStrategySubtitle.
  ///
  /// In de, this message translates to:
  /// **'Strategie, Maßnahmen und Budgetplanung für {companyName}'**
  String marketingStrategySubtitle(String companyName);

  /// No description provided for @marketingScore.
  ///
  /// In de, this message translates to:
  /// **'Marketing Score'**
  String get marketingScore;

  /// No description provided for @marketingOpenActions.
  ///
  /// In de, this message translates to:
  /// **'{count} offen'**
  String marketingOpenActions(int count);

  /// No description provided for @marketingRunningActions.
  ///
  /// In de, this message translates to:
  /// **'{count} in Arbeit'**
  String marketingRunningActions(int count);

  /// No description provided for @marketingCompletedActions.
  ///
  /// In de, this message translates to:
  /// **'{count} abgeschlossen'**
  String marketingCompletedActions(int count);

  /// No description provided for @marketingRecommendationsTitle.
  ///
  /// In de, this message translates to:
  /// **'Automatische Empfehlungen'**
  String get marketingRecommendationsTitle;

  /// No description provided for @marketingRecommendationsEmpty.
  ///
  /// In de, this message translates to:
  /// **'Aktuell gibt es keine dringenden Marketing-Empfehlungen.'**
  String get marketingRecommendationsEmpty;

  /// No description provided for @marketingActionsTitle.
  ///
  /// In de, this message translates to:
  /// **'Maßnahmen'**
  String get marketingActionsTitle;

  /// No description provided for @marketingActionStatus.
  ///
  /// In de, this message translates to:
  /// **'Status'**
  String get marketingActionStatus;

  /// No description provided for @marketingActionNotes.
  ///
  /// In de, this message translates to:
  /// **'Notizen'**
  String get marketingActionNotes;

  /// No description provided for @marketingEditAction.
  ///
  /// In de, this message translates to:
  /// **'Bearbeiten'**
  String get marketingEditAction;

  /// No description provided for @marketingNoNotes.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Notizen.'**
  String get marketingNoNotes;

  /// No description provided for @marketingNoBudget.
  ///
  /// In de, this message translates to:
  /// **'Kein Budget geplant'**
  String get marketingNoBudget;

  /// No description provided for @marketingBudgetPlanned.
  ///
  /// In de, this message translates to:
  /// **'Budget geplant'**
  String get marketingBudgetPlanned;

  /// No description provided for @marketingBudgetUsed.
  ///
  /// In de, this message translates to:
  /// **'Budget verwendet'**
  String get marketingBudgetUsed;

  /// No description provided for @marketingBudgetComment.
  ///
  /// In de, this message translates to:
  /// **'Budget-Kommentar'**
  String get marketingBudgetComment;

  /// No description provided for @marketingBudgetSummary.
  ///
  /// In de, this message translates to:
  /// **'Budget {planned} / verwendet {used}'**
  String marketingBudgetSummary(String planned, String used);

  /// No description provided for @marketingStatusNotStarted.
  ///
  /// In de, this message translates to:
  /// **'Nicht begonnen'**
  String get marketingStatusNotStarted;

  /// No description provided for @marketingStatusPlanned.
  ///
  /// In de, this message translates to:
  /// **'Geplant'**
  String get marketingStatusPlanned;

  /// No description provided for @marketingStatusInProgress.
  ///
  /// In de, this message translates to:
  /// **'In Arbeit'**
  String get marketingStatusInProgress;

  /// No description provided for @marketingStatusCompleted.
  ///
  /// In de, this message translates to:
  /// **'Abgeschlossen'**
  String get marketingStatusCompleted;

  /// No description provided for @marketingStatusPostponed.
  ///
  /// In de, this message translates to:
  /// **'Zurückgestellt'**
  String get marketingStatusPostponed;

  /// No description provided for @marketingEffortLow.
  ///
  /// In de, this message translates to:
  /// **'Aufwand niedrig'**
  String get marketingEffortLow;

  /// No description provided for @marketingEffortMedium.
  ///
  /// In de, this message translates to:
  /// **'Aufwand mittel'**
  String get marketingEffortMedium;

  /// No description provided for @marketingEffortHigh.
  ///
  /// In de, this message translates to:
  /// **'Aufwand hoch'**
  String get marketingEffortHigh;

  /// No description provided for @marketingImpactLow.
  ///
  /// In de, this message translates to:
  /// **'Nutzen niedrig'**
  String get marketingImpactLow;

  /// No description provided for @marketingImpactMedium.
  ///
  /// In de, this message translates to:
  /// **'Nutzen mittel'**
  String get marketingImpactMedium;

  /// No description provided for @marketingImpactHigh.
  ///
  /// In de, this message translates to:
  /// **'Nutzen hoch'**
  String get marketingImpactHigh;

  /// No description provided for @marketingActionOptimizeWebsite.
  ///
  /// In de, this message translates to:
  /// **'Website optimieren'**
  String get marketingActionOptimizeWebsite;

  /// No description provided for @marketingActionOptimizeWebsiteDesc.
  ///
  /// In de, this message translates to:
  /// **'Startseite, Vertrauen und klare nächste Schritte verbessern.'**
  String get marketingActionOptimizeWebsiteDesc;

  /// No description provided for @marketingActionGoogleBusiness.
  ///
  /// In de, this message translates to:
  /// **'Google Business anlegen'**
  String get marketingActionGoogleBusiness;

  /// No description provided for @marketingActionGoogleBusinessDesc.
  ///
  /// In de, this message translates to:
  /// **'Lokale Auffindbarkeit und Basisinformationen pflegen.'**
  String get marketingActionGoogleBusinessDesc;

  /// No description provided for @marketingActionFacebook.
  ///
  /// In de, this message translates to:
  /// **'Facebook pflegen'**
  String get marketingActionFacebook;

  /// No description provided for @marketingActionFacebookDesc.
  ///
  /// In de, this message translates to:
  /// **'Profil, Öffnungszeiten und aktuelle Beiträge sauber halten.'**
  String get marketingActionFacebookDesc;

  /// No description provided for @marketingActionInstagram.
  ///
  /// In de, this message translates to:
  /// **'Instagram starten'**
  String get marketingActionInstagram;

  /// No description provided for @marketingActionInstagramDesc.
  ///
  /// In de, this message translates to:
  /// **'Visuelle Inhalte und einfache Produktgeschichten vorbereiten.'**
  String get marketingActionInstagramDesc;

  /// No description provided for @marketingActionLinkedIn.
  ///
  /// In de, this message translates to:
  /// **'LinkedIn nutzen'**
  String get marketingActionLinkedIn;

  /// No description provided for @marketingActionLinkedInDesc.
  ///
  /// In de, this message translates to:
  /// **'B2B-Sichtbarkeit, Team- und Fachinhalte strukturieren.'**
  String get marketingActionLinkedInDesc;

  /// No description provided for @marketingActionFaq.
  ///
  /// In de, this message translates to:
  /// **'FAQ erweitern'**
  String get marketingActionFaq;

  /// No description provided for @marketingActionFaqDesc.
  ///
  /// In de, this message translates to:
  /// **'Häufige Fragen aus Support und Bot-Test in Inhalte überführen.'**
  String get marketingActionFaqDesc;

  /// No description provided for @marketingActionReviews.
  ///
  /// In de, this message translates to:
  /// **'Bewertungen sammeln'**
  String get marketingActionReviews;

  /// No description provided for @marketingActionReviewsDesc.
  ///
  /// In de, this message translates to:
  /// **'Trustmaterial sammeln und zulässige Nutzung dokumentieren.'**
  String get marketingActionReviewsDesc;

  /// No description provided for @marketingActionNewsletter.
  ///
  /// In de, this message translates to:
  /// **'Newsletter vorbereiten'**
  String get marketingActionNewsletter;

  /// No description provided for @marketingActionNewsletterDesc.
  ///
  /// In de, this message translates to:
  /// **'Themen, Zielgruppen und einfache Versandlogik planen.'**
  String get marketingActionNewsletterDesc;

  /// No description provided for @marketingActionBotWebsite.
  ///
  /// In de, this message translates to:
  /// **'Bot auf Website integrieren'**
  String get marketingActionBotWebsite;

  /// No description provided for @marketingActionBotWebsiteDesc.
  ///
  /// In de, this message translates to:
  /// **'Bot erst nach Test und Review als Website-Hilfe einplanen.'**
  String get marketingActionBotWebsiteDesc;

  /// No description provided for @marketingActionSeo.
  ///
  /// In de, this message translates to:
  /// **'SEO verbessern'**
  String get marketingActionSeo;

  /// No description provided for @marketingActionSeoDesc.
  ///
  /// In de, this message translates to:
  /// **'Quellen, FAQ und Seitenstruktur für Suchmaschinen nutzbar machen.'**
  String get marketingActionSeoDesc;

  /// No description provided for @marketingActionGoogleAds.
  ///
  /// In de, this message translates to:
  /// **'Google Ads prüfen'**
  String get marketingActionGoogleAds;

  /// No description provided for @marketingActionGoogleAdsDesc.
  ///
  /// In de, this message translates to:
  /// **'Kampagnenpotenzial, Budget und Zielseiten grob bewerten.'**
  String get marketingActionGoogleAdsDesc;

  /// No description provided for @marketingActionFacebookAds.
  ///
  /// In de, this message translates to:
  /// **'Facebook Ads prüfen'**
  String get marketingActionFacebookAds;

  /// No description provided for @marketingActionFacebookAdsDesc.
  ///
  /// In de, this message translates to:
  /// **'Social-Kampagnen nur mit klaren Inhalten und Budget planen.'**
  String get marketingActionFacebookAdsDesc;

  /// No description provided for @navBusinessStrategy.
  ///
  /// In de, this message translates to:
  /// **'Unternehmensstrategie'**
  String get navBusinessStrategy;

  /// No description provided for @businessStrategyTitle.
  ///
  /// In de, this message translates to:
  /// **'Unternehmensstrategie'**
  String get businessStrategyTitle;

  /// No description provided for @businessStrategySubtitle.
  ///
  /// In de, this message translates to:
  /// **'Ziele, Fortschritt und Modulbeiträge für {companyName}'**
  String businessStrategySubtitle(String companyName);

  /// No description provided for @businessGoalAdd.
  ///
  /// In de, this message translates to:
  /// **'Ziel anlegen'**
  String get businessGoalAdd;

  /// No description provided for @businessGoalEdit.
  ///
  /// In de, this message translates to:
  /// **'Ziel bearbeiten'**
  String get businessGoalEdit;

  /// No description provided for @businessGoalsTitle.
  ///
  /// In de, this message translates to:
  /// **'Unternehmensziele'**
  String get businessGoalsTitle;

  /// No description provided for @businessGoalsEmpty.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Unternehmensziele angelegt.'**
  String get businessGoalsEmpty;

  /// No description provided for @businessGoalTitle.
  ///
  /// In de, this message translates to:
  /// **'Titel'**
  String get businessGoalTitle;

  /// No description provided for @businessGoalDescription.
  ///
  /// In de, this message translates to:
  /// **'Beschreibung'**
  String get businessGoalDescription;

  /// No description provided for @businessGoalPriority.
  ///
  /// In de, this message translates to:
  /// **'Priorität'**
  String get businessGoalPriority;

  /// No description provided for @businessGoalStatus.
  ///
  /// In de, this message translates to:
  /// **'Status'**
  String get businessGoalStatus;

  /// No description provided for @businessGoalOwner.
  ///
  /// In de, this message translates to:
  /// **'Verantwortlicher'**
  String get businessGoalOwner;

  /// No description provided for @businessGoalComment.
  ///
  /// In de, this message translates to:
  /// **'Kommentar'**
  String get businessGoalComment;

  /// No description provided for @businessGoalLinkedAreas.
  ///
  /// In de, this message translates to:
  /// **'Verknüpfte Bereiche'**
  String get businessGoalLinkedAreas;

  /// No description provided for @businessGoalDefaultOwner.
  ///
  /// In de, this message translates to:
  /// **'Team'**
  String get businessGoalDefaultOwner;

  /// No description provided for @businessActiveGoals.
  ///
  /// In de, this message translates to:
  /// **'{count} aktive Unternehmensziele'**
  String businessActiveGoals(int count);

  /// No description provided for @businessAverageProgress.
  ///
  /// In de, this message translates to:
  /// **'Fortschritt {progress}%'**
  String businessAverageProgress(int progress);

  /// No description provided for @businessMainGoal.
  ///
  /// In de, this message translates to:
  /// **'Aktuelles Hauptziel: {goal}'**
  String businessMainGoal(String goal);

  /// No description provided for @businessNoMainGoal.
  ///
  /// In de, this message translates to:
  /// **'Noch kein aktives Hauptziel.'**
  String get businessNoMainGoal;

  /// No description provided for @businessNoRecommendation.
  ///
  /// In de, this message translates to:
  /// **'Aktuell keine zielbezogene Empfehlung.'**
  String get businessNoRecommendation;

  /// No description provided for @businessGoalRecommendation.
  ///
  /// In de, this message translates to:
  /// **'{area} könnte sinnvoll sein, um Ihr Ziel „{goal}“ zu unterstützen.'**
  String businessGoalRecommendation(String area, String goal);

  /// No description provided for @businessDashboardNextAction.
  ///
  /// In de, this message translates to:
  /// **'Nächste Maßnahme für „{goal}“'**
  String businessDashboardNextAction(String goal);

  /// No description provided for @projectMainGoalTitle.
  ///
  /// In de, this message translates to:
  /// **'Aktuelles Hauptziel'**
  String get projectMainGoalTitle;

  /// No description provided for @businessFlowGoal.
  ///
  /// In de, this message translates to:
  /// **'Unternehmensziel'**
  String get businessFlowGoal;

  /// No description provided for @businessFlowMarketing.
  ///
  /// In de, this message translates to:
  /// **'Marketing'**
  String get businessFlowMarketing;

  /// No description provided for @businessFlowBot.
  ///
  /// In de, this message translates to:
  /// **'Bot'**
  String get businessFlowBot;

  /// No description provided for @businessFlowKnowledge.
  ///
  /// In de, this message translates to:
  /// **'Knowledge'**
  String get businessFlowKnowledge;

  /// No description provided for @businessFlowAudit.
  ///
  /// In de, this message translates to:
  /// **'Audit'**
  String get businessFlowAudit;

  /// No description provided for @businessFlowReview.
  ///
  /// In de, this message translates to:
  /// **'Human Review'**
  String get businessFlowReview;

  /// No description provided for @businessFlowControlling.
  ///
  /// In de, this message translates to:
  /// **'Controlling'**
  String get businessFlowControlling;

  /// No description provided for @businessStatusNotStarted.
  ///
  /// In de, this message translates to:
  /// **'Nicht begonnen'**
  String get businessStatusNotStarted;

  /// No description provided for @businessStatusPlanned.
  ///
  /// In de, this message translates to:
  /// **'Geplant'**
  String get businessStatusPlanned;

  /// No description provided for @businessStatusInProgress.
  ///
  /// In de, this message translates to:
  /// **'In Arbeit'**
  String get businessStatusInProgress;

  /// No description provided for @businessStatusAchieved.
  ///
  /// In de, this message translates to:
  /// **'Erreicht'**
  String get businessStatusAchieved;

  /// No description provided for @businessStatusPaused.
  ///
  /// In de, this message translates to:
  /// **'Pausiert'**
  String get businessStatusPaused;

  /// No description provided for @businessStatusCanceled.
  ///
  /// In de, this message translates to:
  /// **'Abgebrochen'**
  String get businessStatusCanceled;

  /// No description provided for @businessAreaMarketing.
  ///
  /// In de, this message translates to:
  /// **'Marketing'**
  String get businessAreaMarketing;

  /// No description provided for @businessAreaAudit.
  ///
  /// In de, this message translates to:
  /// **'Audit'**
  String get businessAreaAudit;

  /// No description provided for @businessAreaKnowledge.
  ///
  /// In de, this message translates to:
  /// **'Wissensbasis'**
  String get businessAreaKnowledge;

  /// No description provided for @businessAreaBot.
  ///
  /// In de, this message translates to:
  /// **'Bot'**
  String get businessAreaBot;

  /// No description provided for @businessAreaReview.
  ///
  /// In de, this message translates to:
  /// **'Human Review'**
  String get businessAreaReview;

  /// No description provided for @businessAreaSources.
  ///
  /// In de, this message translates to:
  /// **'Quellen'**
  String get businessAreaSources;

  /// No description provided for @businessAreaCompany.
  ///
  /// In de, this message translates to:
  /// **'Firmenprofil'**
  String get businessAreaCompany;

  /// No description provided for @businessAreaProject.
  ///
  /// In de, this message translates to:
  /// **'Projektstatus'**
  String get businessAreaProject;

  /// No description provided for @businessAreaControlling.
  ///
  /// In de, this message translates to:
  /// **'Controlling'**
  String get businessAreaControlling;
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
