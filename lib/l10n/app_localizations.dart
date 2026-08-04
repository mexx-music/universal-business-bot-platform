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

  /// No description provided for @workspaceLoadingTitle.
  ///
  /// In de, this message translates to:
  /// **'Workspace wird geladen'**
  String get workspaceLoadingTitle;

  /// No description provided for @workspaceLoadingMessage.
  ///
  /// In de, this message translates to:
  /// **'Die Unternehmensdaten werden aus dem aktiven Konto geladen.'**
  String get workspaceLoadingMessage;

  /// No description provided for @workspaceEmptyTitle.
  ///
  /// In de, this message translates to:
  /// **'Kein Workspace verfügbar'**
  String get workspaceEmptyTitle;

  /// No description provided for @workspaceEmptyMessage.
  ///
  /// In de, this message translates to:
  /// **'Für dieses Konto sind noch keine Unternehmensdaten verfügbar.'**
  String get workspaceEmptyMessage;

  /// No description provided for @workspaceOnboardingTitle.
  ///
  /// In de, this message translates to:
  /// **'Unternehmen noch nicht zugeordnet'**
  String get workspaceOnboardingTitle;

  /// No description provided for @workspaceOnboardingMessage.
  ///
  /// In de, this message translates to:
  /// **'Ihr Konto ist angemeldet, aber noch keinem Unternehmen zugeordnet. Der sichere Onboarding-Schritt folgt.'**
  String get workspaceOnboardingMessage;

  /// No description provided for @workspaceErrorTitle.
  ///
  /// In de, this message translates to:
  /// **'Workspace konnte nicht geladen werden'**
  String get workspaceErrorTitle;

  /// No description provided for @workspaceErrorMessage.
  ///
  /// In de, this message translates to:
  /// **'Die Unternehmensdaten konnten gerade nicht geladen werden. Bitte versuchen Sie es später erneut oder melden Sie sich neu an.'**
  String get workspaceErrorMessage;

  /// No description provided for @tenantSelectTitle.
  ///
  /// In de, this message translates to:
  /// **'Firma auswählen'**
  String get tenantSelectTitle;

  /// No description provided for @tenantSelectHeading.
  ///
  /// In de, this message translates to:
  /// **'Welche Firma möchten Sie öffnen?'**
  String get tenantSelectHeading;

  /// No description provided for @tenantSelectSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Ihr Konto hat Zugriff auf mehrere Firmen. Wählen Sie die Firma, mit der Sie jetzt arbeiten möchten.'**
  String get tenantSelectSubtitle;

  /// No description provided for @tenantOpen.
  ///
  /// In de, this message translates to:
  /// **'Öffnen'**
  String get tenantOpen;

  /// No description provided for @tenantCurrent.
  ///
  /// In de, this message translates to:
  /// **'Aktuelle Firma'**
  String get tenantCurrent;

  /// No description provided for @tenantSwitch.
  ///
  /// In de, this message translates to:
  /// **'Firma wechseln'**
  String get tenantSwitch;

  /// No description provided for @tenantCurrentRole.
  ///
  /// In de, this message translates to:
  /// **'Rolle'**
  String get tenantCurrentRole;

  /// No description provided for @tenantWorkspaceCount.
  ///
  /// In de, this message translates to:
  /// **'{count} Workspaces'**
  String tenantWorkspaceCount(int count);

  /// No description provided for @tenantAccessActive.
  ///
  /// In de, this message translates to:
  /// **'Zugriff aktiv'**
  String get tenantAccessActive;

  /// No description provided for @tenantRetry.
  ///
  /// In de, this message translates to:
  /// **'Erneut versuchen'**
  String get tenantRetry;

  /// No description provided for @tenantSwitching.
  ///
  /// In de, this message translates to:
  /// **'Wechsel läuft'**
  String get tenantSwitching;

  /// No description provided for @tenantSwitchFailed.
  ///
  /// In de, this message translates to:
  /// **'Die Firma konnte nicht geöffnet werden. Bitte versuchen Sie es erneut.'**
  String get tenantSwitchFailed;

  /// No description provided for @tenantNoneTitle.
  ///
  /// In de, this message translates to:
  /// **'Für dieses Konto ist keine Firma verfügbar.'**
  String get tenantNoneTitle;

  /// No description provided for @tenantAddPlaceholder.
  ///
  /// In de, this message translates to:
  /// **'Weitere Firma hinzufügen'**
  String get tenantAddPlaceholder;

  /// No description provided for @tenantAddPlaceholderSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Diese Funktion folgt in einem späteren Schritt.'**
  String get tenantAddPlaceholderSubtitle;

  /// No description provided for @tenantUnsavedChanges.
  ///
  /// In de, this message translates to:
  /// **'Es gibt noch ungespeicherte Änderungen.'**
  String get tenantUnsavedChanges;

  /// No description provided for @tenantDiscardChanges.
  ///
  /// In de, this message translates to:
  /// **'Änderungen verwerfen'**
  String get tenantDiscardChanges;

  /// No description provided for @tenantCancelSwitch.
  ///
  /// In de, this message translates to:
  /// **'Wechsel abbrechen'**
  String get tenantCancelSwitch;

  /// No description provided for @tenantRoleOwner.
  ///
  /// In de, this message translates to:
  /// **'Owner'**
  String get tenantRoleOwner;

  /// No description provided for @tenantRoleAdmin.
  ///
  /// In de, this message translates to:
  /// **'Admin'**
  String get tenantRoleAdmin;

  /// No description provided for @tenantRoleEditor.
  ///
  /// In de, this message translates to:
  /// **'Bearbeiten'**
  String get tenantRoleEditor;

  /// No description provided for @tenantRoleReviewer.
  ///
  /// In de, this message translates to:
  /// **'Prüfen'**
  String get tenantRoleReviewer;

  /// No description provided for @tenantRoleViewer.
  ///
  /// In de, this message translates to:
  /// **'Lesen'**
  String get tenantRoleViewer;

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

  /// No description provided for @authLocalMode.
  ///
  /// In de, this message translates to:
  /// **'Lokaler Modus'**
  String get authLocalMode;

  /// No description provided for @authSignedIn.
  ///
  /// In de, this message translates to:
  /// **'Angemeldet'**
  String get authSignedIn;

  /// No description provided for @authLogout.
  ///
  /// In de, this message translates to:
  /// **'Abmelden'**
  String get authLogout;

  /// No description provided for @authSignInTitle.
  ///
  /// In de, this message translates to:
  /// **'Anmelden'**
  String get authSignInTitle;

  /// No description provided for @authSignInSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Melden Sie sich an, wenn diese Installation mit Supabase verbunden ist.'**
  String get authSignInSubtitle;

  /// No description provided for @authSignUpTitle.
  ///
  /// In de, this message translates to:
  /// **'Konto erstellen'**
  String get authSignUpTitle;

  /// No description provided for @authSignUpSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Erstellen Sie ein Konto. Der Unternehmenszugang wird danach vorbereitet.'**
  String get authSignUpSubtitle;

  /// No description provided for @authResetTitle.
  ///
  /// In de, this message translates to:
  /// **'Passwort zurücksetzen'**
  String get authResetTitle;

  /// No description provided for @authResetSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Geben Sie Ihre E-Mail-Adresse ein. Sie erhalten einen Link zum Zurücksetzen.'**
  String get authResetSubtitle;

  /// No description provided for @authEmailLabel.
  ///
  /// In de, this message translates to:
  /// **'E-Mail'**
  String get authEmailLabel;

  /// No description provided for @authPasswordLabel.
  ///
  /// In de, this message translates to:
  /// **'Passwort'**
  String get authPasswordLabel;

  /// No description provided for @authDisplayNameLabel.
  ///
  /// In de, this message translates to:
  /// **'Name (optional)'**
  String get authDisplayNameLabel;

  /// No description provided for @authInvalidEmail.
  ///
  /// In de, this message translates to:
  /// **'Bitte eine gültige E-Mail-Adresse eingeben.'**
  String get authInvalidEmail;

  /// No description provided for @authPasswordTooShort.
  ///
  /// In de, this message translates to:
  /// **'Das Passwort muss mindestens 6 Zeichen lang sein.'**
  String get authPasswordTooShort;

  /// No description provided for @authAcceptTerms.
  ///
  /// In de, this message translates to:
  /// **'Ich stimme Datenschutz und Nutzungsbedingungen zu.'**
  String get authAcceptTerms;

  /// No description provided for @authTermsRequired.
  ///
  /// In de, this message translates to:
  /// **'Bitte stimmen Sie Datenschutz und Nutzungsbedingungen zu.'**
  String get authTermsRequired;

  /// No description provided for @authSignInButton.
  ///
  /// In de, this message translates to:
  /// **'Anmelden'**
  String get authSignInButton;

  /// No description provided for @authSignUpButton.
  ///
  /// In de, this message translates to:
  /// **'Konto erstellen'**
  String get authSignUpButton;

  /// No description provided for @authResetButton.
  ///
  /// In de, this message translates to:
  /// **'Reset-Link senden'**
  String get authResetButton;

  /// No description provided for @authCreateAccount.
  ///
  /// In de, this message translates to:
  /// **'Konto erstellen'**
  String get authCreateAccount;

  /// No description provided for @authBackToSignIn.
  ///
  /// In de, this message translates to:
  /// **'Zur Anmeldung'**
  String get authBackToSignIn;

  /// No description provided for @authForgotPassword.
  ///
  /// In de, this message translates to:
  /// **'Passwort vergessen'**
  String get authForgotPassword;

  /// No description provided for @authBackHome.
  ///
  /// In de, this message translates to:
  /// **'Zurück zur Startseite'**
  String get authBackHome;

  /// No description provided for @authPleaseWait.
  ///
  /// In de, this message translates to:
  /// **'Bitte warten ...'**
  String get authPleaseWait;

  /// No description provided for @authVerificationHint.
  ///
  /// In de, this message translates to:
  /// **'Konto erstellt. Bitte prüfen Sie Ihre E-Mails, falls die Verifikation aktiv ist.'**
  String get authVerificationHint;

  /// No description provided for @authResetSent.
  ///
  /// In de, this message translates to:
  /// **'Wenn ein Konto existiert, wurde ein Reset-Link gesendet.'**
  String get authResetSent;

  /// No description provided for @authOnboardingRequired.
  ///
  /// In de, this message translates to:
  /// **'Ihr Konto ist angemeldet, aber noch keinem Unternehmen zugeordnet. Richten Sie jetzt Ihren ersten Workspace ein.'**
  String get authOnboardingRequired;

  /// No description provided for @authGenericError.
  ///
  /// In de, this message translates to:
  /// **'Anmeldung fehlgeschlagen. Bitte prüfen Sie E-Mail und Passwort.'**
  String get authGenericError;

  /// No description provided for @onboardingTitle.
  ///
  /// In de, this message translates to:
  /// **'Ersten Workspace einrichten'**
  String get onboardingTitle;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Legen Sie Ihr Unternehmen an. Danach öffnet sich automatisch Ihr neuer Arbeitsbereich.'**
  String get onboardingSubtitle;

  /// No description provided for @onboardingCompanyNameLabel.
  ///
  /// In de, this message translates to:
  /// **'Firmenname'**
  String get onboardingCompanyNameLabel;

  /// No description provided for @onboardingCompanyNameHelper.
  ///
  /// In de, this message translates to:
  /// **'Beispiel: Muster GmbH'**
  String get onboardingCompanyNameHelper;

  /// No description provided for @onboardingCompanyNameRequired.
  ///
  /// In de, this message translates to:
  /// **'Bitte geben Sie den Firmennamen ein.'**
  String get onboardingCompanyNameRequired;

  /// No description provided for @onboardingCompanyNameTooShort.
  ///
  /// In de, this message translates to:
  /// **'Der Firmenname muss mindestens 2 Zeichen lang sein.'**
  String get onboardingCompanyNameTooShort;

  /// No description provided for @onboardingCompanyNameTooLong.
  ///
  /// In de, this message translates to:
  /// **'Der Firmenname darf maximal 120 Zeichen lang sein.'**
  String get onboardingCompanyNameTooLong;

  /// No description provided for @onboardingCompanyNameInvalid.
  ///
  /// In de, this message translates to:
  /// **'Bitte verwenden Sie einen erkennbaren Firmennamen.'**
  String get onboardingCompanyNameInvalid;

  /// No description provided for @onboardingWebsiteLabel.
  ///
  /// In de, this message translates to:
  /// **'Website (optional)'**
  String get onboardingWebsiteLabel;

  /// No description provided for @onboardingWebsiteHelper.
  ///
  /// In de, this message translates to:
  /// **'Beispiel: www.firma.at'**
  String get onboardingWebsiteHelper;

  /// No description provided for @onboardingWebsiteInvalid.
  ///
  /// In de, this message translates to:
  /// **'Bitte geben Sie eine gültige HTTPS-Website oder Domain ein.'**
  String get onboardingWebsiteInvalid;

  /// No description provided for @onboardingIndustryLabel.
  ///
  /// In de, this message translates to:
  /// **'Branche (optional)'**
  String get onboardingIndustryLabel;

  /// No description provided for @onboardingIndustryHelper.
  ///
  /// In de, this message translates to:
  /// **'Beispiel: Beratung, Handwerk, Hotel'**
  String get onboardingIndustryHelper;

  /// No description provided for @onboardingDescriptionLabel.
  ///
  /// In de, this message translates to:
  /// **'Kurzbeschreibung (optional)'**
  String get onboardingDescriptionLabel;

  /// No description provided for @onboardingDescriptionHelper.
  ///
  /// In de, this message translates to:
  /// **'Was macht Ihr Unternehmen in wenigen Sätzen?'**
  String get onboardingDescriptionHelper;

  /// No description provided for @onboardingDescriptionTooLong.
  ///
  /// In de, this message translates to:
  /// **'Die Beschreibung darf maximal 600 Zeichen lang sein.'**
  String get onboardingDescriptionTooLong;

  /// No description provided for @onboardingLanguageLabel.
  ///
  /// In de, this message translates to:
  /// **'Sprache'**
  String get onboardingLanguageLabel;

  /// No description provided for @onboardingLanguageInvalid.
  ///
  /// In de, this message translates to:
  /// **'Bitte wählen Sie Deutsch oder Englisch.'**
  String get onboardingLanguageInvalid;

  /// No description provided for @onboardingWorkspaceLabel.
  ///
  /// In de, this message translates to:
  /// **'Workspace-Name (optional)'**
  String get onboardingWorkspaceLabel;

  /// No description provided for @onboardingWorkspaceHelper.
  ///
  /// In de, this message translates to:
  /// **'Leer lassen, um den Firmennamen zu verwenden.'**
  String get onboardingWorkspaceHelper;

  /// No description provided for @onboardingSubmit.
  ///
  /// In de, this message translates to:
  /// **'Workspace erstellen'**
  String get onboardingSubmit;

  /// No description provided for @onboardingSubmitting.
  ///
  /// In de, this message translates to:
  /// **'Workspace wird erstellt ...'**
  String get onboardingSubmitting;

  /// No description provided for @onboardingSuccess.
  ///
  /// In de, this message translates to:
  /// **'Ihr Workspace wurde erstellt.'**
  String get onboardingSuccess;

  /// No description provided for @onboardingRemoteError.
  ///
  /// In de, this message translates to:
  /// **'Der Workspace konnte nicht erstellt werden. Bitte versuchen Sie es erneut.'**
  String get onboardingRemoteError;

  /// No description provided for @onboardingAlreadyCompleted.
  ///
  /// In de, this message translates to:
  /// **'Ihr Konto hat bereits einen Workspace. Der Arbeitsbereich wird geladen.'**
  String get onboardingAlreadyCompleted;

  /// No description provided for @onboardingSessionExpired.
  ///
  /// In de, this message translates to:
  /// **'Ihre Sitzung ist abgelaufen. Bitte melden Sie sich erneut an.'**
  String get onboardingSessionExpired;

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

  /// No description provided for @intakeResetAction.
  ///
  /// In de, this message translates to:
  /// **'Firmenaufnahme zurücksetzen'**
  String get intakeResetAction;

  /// No description provided for @intakeResetConfirmTitle.
  ///
  /// In de, this message translates to:
  /// **'Firmenaufnahme zurücksetzen?'**
  String get intakeResetConfirmTitle;

  /// No description provided for @intakeResetConfirmText.
  ///
  /// In de, this message translates to:
  /// **'Alle bisher gespeicherten Antworten dieser Firmenaufnahme werden gelöscht. Der Chat beginnt anschließend wieder mit der ersten Frage.'**
  String get intakeResetConfirmText;

  /// No description provided for @intakeResetCancel.
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get intakeResetCancel;

  /// No description provided for @intakeResetConfirmAction.
  ///
  /// In de, this message translates to:
  /// **'Zurücksetzen'**
  String get intakeResetConfirmAction;

  /// No description provided for @intakeResetSuccess.
  ///
  /// In de, this message translates to:
  /// **'Firmenaufnahme wurde zurückgesetzt.'**
  String get intakeResetSuccess;

  /// No description provided for @intakeResetFailure.
  ///
  /// In de, this message translates to:
  /// **'Firmenaufnahme konnte nicht zurückgesetzt werden.'**
  String get intakeResetFailure;

  /// No description provided for @intakeChatGreeting.
  ///
  /// In de, this message translates to:
  /// **'Hallo! Ich führe dich Schritt für Schritt durch die Firmenaufnahme.'**
  String get intakeChatGreeting;

  /// No description provided for @publicIntakeTitle.
  ///
  /// In de, this message translates to:
  /// **'Firmenfragebogen: {company}'**
  String publicIntakeTitle(String company);

  /// No description provided for @publicIntakeGreeting.
  ///
  /// In de, this message translates to:
  /// **'Willkommen bei BusinessBrain AI.\nIch begleite Sie jetzt Schritt für Schritt durch die Einrichtung Ihres Unternehmens.'**
  String get publicIntakeGreeting;

  /// No description provided for @publicIntakeNotFoundTitle.
  ///
  /// In de, this message translates to:
  /// **'Einladungslink nicht gefunden'**
  String get publicIntakeNotFoundTitle;

  /// No description provided for @publicIntakeNotFoundMessage.
  ///
  /// In de, this message translates to:
  /// **'Dieser Link ist ungültig oder gehört zu keiner aktiven Einladung.'**
  String get publicIntakeNotFoundMessage;

  /// No description provided for @publicIntakeDisabledTitle.
  ///
  /// In de, this message translates to:
  /// **'Einladungslink deaktiviert'**
  String get publicIntakeDisabledTitle;

  /// No description provided for @publicIntakeDisabledMessage.
  ///
  /// In de, this message translates to:
  /// **'Dieser Fragebogen-Link wurde deaktiviert. Bitte wenden Sie sich an die Person, die Sie eingeladen hat.'**
  String get publicIntakeDisabledMessage;

  /// No description provided for @publicIntakeExpiredTitle.
  ///
  /// In de, this message translates to:
  /// **'Einladungslink abgelaufen'**
  String get publicIntakeExpiredTitle;

  /// No description provided for @publicIntakeExpiredMessage.
  ///
  /// In de, this message translates to:
  /// **'Dieser Fragebogen-Link ist abgelaufen. Bitte fordern Sie einen neuen Link an.'**
  String get publicIntakeExpiredMessage;

  /// No description provided for @publicIntakeNotConfiguredTitle.
  ///
  /// In de, this message translates to:
  /// **'Fragebogen nicht konfiguriert'**
  String get publicIntakeNotConfiguredTitle;

  /// No description provided for @publicIntakeNotConfiguredMessage.
  ///
  /// In de, this message translates to:
  /// **'Der öffentliche Fragebogen ist in dieser Version noch nicht mit dem Server verbunden.'**
  String get publicIntakeNotConfiguredMessage;

  /// No description provided for @publicIntakeRemoteErrorTitle.
  ///
  /// In de, this message translates to:
  /// **'Fragebogen nicht erreichbar'**
  String get publicIntakeRemoteErrorTitle;

  /// No description provided for @publicIntakeRemoteErrorMessage.
  ///
  /// In de, this message translates to:
  /// **'Der Fragebogen konnte gerade nicht geladen werden. Bitte versuchen Sie es später erneut.'**
  String get publicIntakeRemoteErrorMessage;

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

  /// No description provided for @companyIntakeInvitationSection.
  ///
  /// In de, this message translates to:
  /// **'Öffentlicher Firmenfragebogen'**
  String get companyIntakeInvitationSection;

  /// No description provided for @companyIntakeInvitationDescription.
  ///
  /// In de, this message translates to:
  /// **'Erstellen Sie einen sicheren Link, über den eine eingeladene Person nur den Fragebogen dieser Firma ausfüllen kann.'**
  String get companyIntakeInvitationDescription;

  /// No description provided for @companyIntakeInvitationTokenHint.
  ///
  /// In de, this message translates to:
  /// **'Sicherer Token-Link'**
  String get companyIntakeInvitationTokenHint;

  /// No description provided for @companyIntakeInvitationCreate.
  ///
  /// In de, this message translates to:
  /// **'Link erstellen'**
  String get companyIntakeInvitationCreate;

  /// No description provided for @companyIntakeInvitationCopy.
  ///
  /// In de, this message translates to:
  /// **'Link kopieren'**
  String get companyIntakeInvitationCopy;

  /// No description provided for @companyIntakeInvitationCopied.
  ///
  /// In de, this message translates to:
  /// **'Link wurde kopiert.'**
  String get companyIntakeInvitationCopied;

  /// No description provided for @companyIntakeInvitationCreated.
  ///
  /// In de, this message translates to:
  /// **'Link erstellt'**
  String get companyIntakeInvitationCreated;

  /// No description provided for @companyIntakeInvitationCopiedShort.
  ///
  /// In de, this message translates to:
  /// **'In Zwischenablage kopiert'**
  String get companyIntakeInvitationCopiedShort;

  /// No description provided for @companyIntakeInvitationOpened.
  ///
  /// In de, this message translates to:
  /// **'Öffentlicher Fragebogen geöffnet'**
  String get companyIntakeInvitationOpened;

  /// No description provided for @companyIntakeInvitationOpen.
  ///
  /// In de, this message translates to:
  /// **'Fragebogen öffnen'**
  String get companyIntakeInvitationOpen;

  /// No description provided for @companyIntakeInvitationOpenBlocked.
  ///
  /// In de, this message translates to:
  /// **'Der Browser hat das automatische Öffnen blockiert. Der Link wurde kopiert.'**
  String get companyIntakeInvitationOpenBlocked;

  /// No description provided for @companyIntakeInvitationOpenBlockedShort.
  ///
  /// In de, this message translates to:
  /// **'Automatisches Öffnen blockiert'**
  String get companyIntakeInvitationOpenBlockedShort;

  /// No description provided for @companyIntakeInvitationUrlUnavailable.
  ///
  /// In de, this message translates to:
  /// **'Es konnte keine gültige öffentliche HTTP-/HTTPS-Adresse für diesen Fragebogen erstellt werden.'**
  String get companyIntakeInvitationUrlUnavailable;

  /// No description provided for @companyIntakeInvitationSetPublicUrl.
  ///
  /// In de, this message translates to:
  /// **'Öffentliche Adresse eintragen'**
  String get companyIntakeInvitationSetPublicUrl;

  /// No description provided for @companyIntakeInvitationPublicUrlTitle.
  ///
  /// In de, this message translates to:
  /// **'Welche öffentliche Adresse hat diese App?'**
  String get companyIntakeInvitationPublicUrlTitle;

  /// No description provided for @companyIntakeInvitationPublicUrlLabel.
  ///
  /// In de, this message translates to:
  /// **'Öffentliche App-Adresse'**
  String get companyIntakeInvitationPublicUrlLabel;

  /// No description provided for @companyIntakeInvitationPublicUrlHint.
  ///
  /// In de, this message translates to:
  /// **'https://ihre-app.pages.dev'**
  String get companyIntakeInvitationPublicUrlHint;

  /// No description provided for @companyIntakeInvitationPublicUrlHelper.
  ///
  /// In de, this message translates to:
  /// **'Die Adresse steht in Cloudflare Pages und beginnt mit https://.'**
  String get companyIntakeInvitationPublicUrlHelper;

  /// No description provided for @companyIntakeInvitationPublicUrlDialog.
  ///
  /// In de, this message translates to:
  /// **'Als Dialog öffnen'**
  String get companyIntakeInvitationPublicUrlDialog;

  /// No description provided for @companyIntakeInvitationPublicUrlInvalid.
  ///
  /// In de, this message translates to:
  /// **'Bitte eine gültige Adresse mit https:// oder http:// eingeben.'**
  String get companyIntakeInvitationPublicUrlInvalid;

  /// No description provided for @companyIntakeInvitationRegenerate.
  ///
  /// In de, this message translates to:
  /// **'Neu generieren'**
  String get companyIntakeInvitationRegenerate;

  /// No description provided for @companyIntakeInvitationDisable.
  ///
  /// In de, this message translates to:
  /// **'Deaktivieren'**
  String get companyIntakeInvitationDisable;

  /// No description provided for @companyIntakeInvitationRefresh.
  ///
  /// In de, this message translates to:
  /// **'Status aktualisieren'**
  String get companyIntakeInvitationRefresh;

  /// No description provided for @companyIntakeInvitationStatusMissing.
  ///
  /// In de, this message translates to:
  /// **'Noch kein Link'**
  String get companyIntakeInvitationStatusMissing;

  /// No description provided for @companyIntakeInvitationStatusInvited.
  ///
  /// In de, this message translates to:
  /// **'Eingeladen'**
  String get companyIntakeInvitationStatusInvited;

  /// No description provided for @companyIntakeInvitationStatusStarted.
  ///
  /// In de, this message translates to:
  /// **'Begonnen'**
  String get companyIntakeInvitationStatusStarted;

  /// No description provided for @companyIntakeInvitationStatusPartial.
  ///
  /// In de, this message translates to:
  /// **'Teilweise ausgefüllt'**
  String get companyIntakeInvitationStatusPartial;

  /// No description provided for @companyIntakeInvitationStatusCompleted.
  ///
  /// In de, this message translates to:
  /// **'Abgeschlossen'**
  String get companyIntakeInvitationStatusCompleted;

  /// No description provided for @companyIntakeInvitationStatusDisabled.
  ///
  /// In de, this message translates to:
  /// **'Deaktiviert'**
  String get companyIntakeInvitationStatusDisabled;

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
  /// **'BusinessBrain Grounded Answers'**
  String get botTestTitle;

  /// No description provided for @botTestSubtitle.
  ///
  /// In de, this message translates to:
  /// **'BusinessBrain beantwortet Fragen ausschließlich mit bestätigtem Wissen aus dem aktiven Unternehmens-Workspace.'**
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

  /// No description provided for @navBusinessIntelligence.
  ///
  /// In de, this message translates to:
  /// **'Business Intelligence'**
  String get navBusinessIntelligence;

  /// No description provided for @businessIntelligenceTitle.
  ///
  /// In de, this message translates to:
  /// **'Business Intelligence'**
  String get businessIntelligenceTitle;

  /// No description provided for @businessIntelligenceSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Entwicklung, Timeline und Kennzahlen für {companyName}'**
  String businessIntelligenceSubtitle(String companyName);

  /// No description provided for @businessTimelineTitle.
  ///
  /// In de, this message translates to:
  /// **'Company Timeline'**
  String get businessTimelineTitle;

  /// No description provided for @businessKpiTitle.
  ///
  /// In de, this message translates to:
  /// **'KPI-Verlauf'**
  String get businessKpiTitle;

  /// No description provided for @businessDevelopmentTitle.
  ///
  /// In de, this message translates to:
  /// **'Unternehmensentwicklung'**
  String get businessDevelopmentTitle;

  /// No description provided for @businessHighlightsTitle.
  ///
  /// In de, this message translates to:
  /// **'Highlights'**
  String get businessHighlightsTitle;

  /// No description provided for @businessMonthlyTitle.
  ///
  /// In de, this message translates to:
  /// **'Aktueller Monat'**
  String get businessMonthlyTitle;

  /// No description provided for @businessLastActivity.
  ///
  /// In de, this message translates to:
  /// **'Letzte Aktivität'**
  String get businessLastActivity;

  /// No description provided for @businessBiggestProgress.
  ///
  /// In de, this message translates to:
  /// **'Größter Fortschritt'**
  String get businessBiggestProgress;

  /// No description provided for @businessNoActivity.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Aktivität vorhanden.'**
  String get businessNoActivity;

  /// No description provided for @businessBiggestProgressNone.
  ///
  /// In de, this message translates to:
  /// **'Noch kein Fortschritt'**
  String get businessBiggestProgressNone;

  /// No description provided for @businessMonthlyChanges.
  ///
  /// In de, this message translates to:
  /// **'Änderungen'**
  String get businessMonthlyChanges;

  /// No description provided for @businessMonthlySources.
  ///
  /// In de, this message translates to:
  /// **'Neue Quellen'**
  String get businessMonthlySources;

  /// No description provided for @businessMonthlyKnowledge.
  ///
  /// In de, this message translates to:
  /// **'Neue Wissenseinträge'**
  String get businessMonthlyKnowledge;

  /// No description provided for @businessMonthlyMarketingCompleted.
  ///
  /// In de, this message translates to:
  /// **'Marketing abgeschlossen'**
  String get businessMonthlyMarketingCompleted;

  /// No description provided for @businessMonthlyGoalsAchieved.
  ///
  /// In de, this message translates to:
  /// **'Ziele erreicht'**
  String get businessMonthlyGoalsAchieved;

  /// No description provided for @businessDashboardLastActivity.
  ///
  /// In de, this message translates to:
  /// **'Letzte Aktivität: {title}'**
  String businessDashboardLastActivity(String title);

  /// No description provided for @businessDashboardBiggestProgress.
  ///
  /// In de, this message translates to:
  /// **'{area} {value}'**
  String businessDashboardBiggestProgress(String area, String value);

  /// No description provided for @businessDashboardDevelopment.
  ///
  /// In de, this message translates to:
  /// **'{area}: {value}'**
  String businessDashboardDevelopment(String area, String value);

  /// No description provided for @projectLatestImprovementTitle.
  ///
  /// In de, this message translates to:
  /// **'Letzte Verbesserung'**
  String get projectLatestImprovementTitle;

  /// No description provided for @projectSinceLastWeek.
  ///
  /// In de, this message translates to:
  /// **'Seit letzter Woche: {summary}'**
  String projectSinceLastWeek(String summary);

  /// No description provided for @businessKpiAuditScore.
  ///
  /// In de, this message translates to:
  /// **'Audit Score'**
  String get businessKpiAuditScore;

  /// No description provided for @businessKpiMarketingScore.
  ///
  /// In de, this message translates to:
  /// **'Marketing Score'**
  String get businessKpiMarketingScore;

  /// No description provided for @businessKpiKnowledgeEntries.
  ///
  /// In de, this message translates to:
  /// **'Wissenseinträge'**
  String get businessKpiKnowledgeEntries;

  /// No description provided for @businessKpiSources.
  ///
  /// In de, this message translates to:
  /// **'Quellen'**
  String get businessKpiSources;

  /// No description provided for @businessKpiReviews.
  ///
  /// In de, this message translates to:
  /// **'Reviews'**
  String get businessKpiReviews;

  /// No description provided for @businessKpiBotStatus.
  ///
  /// In de, this message translates to:
  /// **'Bot-Status'**
  String get businessKpiBotStatus;

  /// No description provided for @businessKpiProjectProgress.
  ///
  /// In de, this message translates to:
  /// **'Projektfortschritt'**
  String get businessKpiProjectProgress;

  /// No description provided for @businessKpiStrategyProgress.
  ///
  /// In de, this message translates to:
  /// **'Strategiefortschritt'**
  String get businessKpiStrategyProgress;

  /// No description provided for @businessTimelineCategoryCompany.
  ///
  /// In de, this message translates to:
  /// **'Firma'**
  String get businessTimelineCategoryCompany;

  /// No description provided for @businessTimelineCategoryWebsite.
  ///
  /// In de, this message translates to:
  /// **'Website'**
  String get businessTimelineCategoryWebsite;

  /// No description provided for @businessTimelineCategoryBot.
  ///
  /// In de, this message translates to:
  /// **'Bot'**
  String get businessTimelineCategoryBot;

  /// No description provided for @businessTimelineCategoryAudit.
  ///
  /// In de, this message translates to:
  /// **'Audit'**
  String get businessTimelineCategoryAudit;

  /// No description provided for @businessTimelineCategoryKnowledge.
  ///
  /// In de, this message translates to:
  /// **'Wissen'**
  String get businessTimelineCategoryKnowledge;

  /// No description provided for @businessTimelineCategoryReview.
  ///
  /// In de, this message translates to:
  /// **'Review'**
  String get businessTimelineCategoryReview;

  /// No description provided for @businessTimelineCategoryMarketing.
  ///
  /// In de, this message translates to:
  /// **'Marketing'**
  String get businessTimelineCategoryMarketing;

  /// No description provided for @businessTimelineCategoryStrategy.
  ///
  /// In de, this message translates to:
  /// **'Strategie'**
  String get businessTimelineCategoryStrategy;

  /// No description provided for @businessTimelineCategorySources.
  ///
  /// In de, this message translates to:
  /// **'Quellen'**
  String get businessTimelineCategorySources;

  /// No description provided for @businessTimelineCategoryProjectStatus.
  ///
  /// In de, this message translates to:
  /// **'Projektstatus'**
  String get businessTimelineCategoryProjectStatus;

  /// No description provided for @businessEventCompanyCreated.
  ///
  /// In de, this message translates to:
  /// **'Unternehmen angelegt'**
  String get businessEventCompanyCreated;

  /// No description provided for @businessEventWebsiteAdded.
  ///
  /// In de, this message translates to:
  /// **'Website ergänzt'**
  String get businessEventWebsiteAdded;

  /// No description provided for @businessEventIntakeCompleted.
  ///
  /// In de, this message translates to:
  /// **'Firmenaufnahme abgeschlossen'**
  String get businessEventIntakeCompleted;

  /// No description provided for @businessEventBotActivated.
  ///
  /// In de, this message translates to:
  /// **'Bot aktiviert'**
  String get businessEventBotActivated;

  /// No description provided for @businessEventAuditImproved.
  ///
  /// In de, this message translates to:
  /// **'Audit verbessert'**
  String get businessEventAuditImproved;

  /// No description provided for @businessEventKnowledgeAdded.
  ///
  /// In de, this message translates to:
  /// **'Knowledge erweitert'**
  String get businessEventKnowledgeAdded;

  /// No description provided for @businessEventFaqAdded.
  ///
  /// In de, this message translates to:
  /// **'Neue FAQ'**
  String get businessEventFaqAdded;

  /// No description provided for @businessEventReviewClosed.
  ///
  /// In de, this message translates to:
  /// **'Review abgeschlossen'**
  String get businessEventReviewClosed;

  /// No description provided for @businessEventMarketingStarted.
  ///
  /// In de, this message translates to:
  /// **'Marketingmaßnahme gestartet'**
  String get businessEventMarketingStarted;

  /// No description provided for @businessEventMarketingCompleted.
  ///
  /// In de, this message translates to:
  /// **'Marketingmaßnahme abgeschlossen'**
  String get businessEventMarketingCompleted;

  /// No description provided for @businessEventStrategyChanged.
  ///
  /// In de, this message translates to:
  /// **'Strategie geändert'**
  String get businessEventStrategyChanged;

  /// No description provided for @businessEventSourceAdded.
  ///
  /// In de, this message translates to:
  /// **'Neue Quelle hinzugefügt'**
  String get businessEventSourceAdded;

  /// No description provided for @businessEventGoalAdded.
  ///
  /// In de, this message translates to:
  /// **'Neues Ziel'**
  String get businessEventGoalAdded;

  /// No description provided for @businessEventProjectStatusImproved.
  ///
  /// In de, this message translates to:
  /// **'Projektstatus verbessert'**
  String get businessEventProjectStatusImproved;

  /// No description provided for @businessHighlightBiggestProgress.
  ///
  /// In de, this message translates to:
  /// **'Größter Fortschritt'**
  String get businessHighlightBiggestProgress;

  /// No description provided for @businessHighlightStrongestModule.
  ///
  /// In de, this message translates to:
  /// **'Stärkstes Modul'**
  String get businessHighlightStrongestModule;

  /// No description provided for @businessHighlightLastImprovement.
  ///
  /// In de, this message translates to:
  /// **'Letzte Verbesserung'**
  String get businessHighlightLastImprovement;

  /// No description provided for @businessHighlightOpenIssue.
  ///
  /// In de, this message translates to:
  /// **'Offene Baustelle'**
  String get businessHighlightOpenIssue;

  /// No description provided for @businessHighlightNextChance.
  ///
  /// In de, this message translates to:
  /// **'Nächste Chance'**
  String get businessHighlightNextChance;

  /// No description provided for @navNextActions.
  ///
  /// In de, this message translates to:
  /// **'Nächste Schritte'**
  String get navNextActions;

  /// No description provided for @nextActionsTitle.
  ///
  /// In de, this message translates to:
  /// **'Meine nächsten Schritte'**
  String get nextActionsTitle;

  /// No description provided for @nextActionsIntro.
  ///
  /// In de, this message translates to:
  /// **'Das sind aktuell Ihre wichtigsten nächsten Schritte.'**
  String get nextActionsIntro;

  /// No description provided for @nextActionsEmpty.
  ///
  /// In de, this message translates to:
  /// **'Aktuell gibt es keine offenen Empfehlungen. Alle wichtigen Schritte sind erledigt oder in Umsetzung.'**
  String get nextActionsEmpty;

  /// No description provided for @actionWhyNow.
  ///
  /// In de, this message translates to:
  /// **'Warum jetzt?'**
  String get actionWhyNow;

  /// No description provided for @actionEvidenceLabel.
  ///
  /// In de, this message translates to:
  /// **'Datengrundlage'**
  String get actionEvidenceLabel;

  /// No description provided for @actionPriorityPrefix.
  ///
  /// In de, this message translates to:
  /// **'Priorität'**
  String get actionPriorityPrefix;

  /// No description provided for @actionEffortPrefix.
  ///
  /// In de, this message translates to:
  /// **'Aufwand'**
  String get actionEffortPrefix;

  /// No description provided for @actionImpactPrefix.
  ///
  /// In de, this message translates to:
  /// **'Nutzen'**
  String get actionImpactPrefix;

  /// No description provided for @actionPriorityCritical.
  ///
  /// In de, this message translates to:
  /// **'Kritisch'**
  String get actionPriorityCritical;

  /// No description provided for @actionPriorityHigh.
  ///
  /// In de, this message translates to:
  /// **'Hoch'**
  String get actionPriorityHigh;

  /// No description provided for @actionPriorityMedium.
  ///
  /// In de, this message translates to:
  /// **'Mittel'**
  String get actionPriorityMedium;

  /// No description provided for @actionPriorityLow.
  ///
  /// In de, this message translates to:
  /// **'Niedrig'**
  String get actionPriorityLow;

  /// No description provided for @actionLevelLow.
  ///
  /// In de, this message translates to:
  /// **'gering'**
  String get actionLevelLow;

  /// No description provided for @actionLevelMedium.
  ///
  /// In de, this message translates to:
  /// **'mittel'**
  String get actionLevelMedium;

  /// No description provided for @actionLevelHigh.
  ///
  /// In de, this message translates to:
  /// **'hoch'**
  String get actionLevelHigh;

  /// No description provided for @actionAccept.
  ///
  /// In de, this message translates to:
  /// **'Annehmen'**
  String get actionAccept;

  /// No description provided for @actionDefer.
  ///
  /// In de, this message translates to:
  /// **'Später'**
  String get actionDefer;

  /// No description provided for @actionDecline.
  ///
  /// In de, this message translates to:
  /// **'Ablehnen'**
  String get actionDecline;

  /// No description provided for @actionStart.
  ///
  /// In de, this message translates to:
  /// **'Als begonnen markieren'**
  String get actionStart;

  /// No description provided for @actionComplete.
  ///
  /// In de, this message translates to:
  /// **'Als erledigt markieren'**
  String get actionComplete;

  /// No description provided for @actionSave.
  ///
  /// In de, this message translates to:
  /// **'Speichern'**
  String get actionSave;

  /// No description provided for @deferDialogTitle.
  ///
  /// In de, this message translates to:
  /// **'Wie lange zurückstellen?'**
  String get deferDialogTitle;

  /// No description provided for @deferOneWeek.
  ///
  /// In de, this message translates to:
  /// **'1 Woche'**
  String get deferOneWeek;

  /// No description provided for @deferOneMonth.
  ///
  /// In de, this message translates to:
  /// **'1 Monat'**
  String get deferOneMonth;

  /// No description provided for @deferThreeMonths.
  ///
  /// In de, this message translates to:
  /// **'3 Monate'**
  String get deferThreeMonths;

  /// No description provided for @declineDialogTitle.
  ///
  /// In de, this message translates to:
  /// **'Empfehlung ablehnen'**
  String get declineDialogTitle;

  /// No description provided for @declineReasonLabel.
  ///
  /// In de, this message translates to:
  /// **'Grund (optional)'**
  String get declineReasonLabel;

  /// No description provided for @completeDialogTitle.
  ///
  /// In de, this message translates to:
  /// **'Maßnahme abschließen'**
  String get completeDialogTitle;

  /// No description provided for @completeDialogQuestion.
  ///
  /// In de, this message translates to:
  /// **'Hat die Maßnahme geholfen?'**
  String get completeDialogQuestion;

  /// No description provided for @ratingHelpedALot.
  ///
  /// In de, this message translates to:
  /// **'Deutlich geholfen'**
  String get ratingHelpedALot;

  /// No description provided for @ratingHelpedSomewhat.
  ///
  /// In de, this message translates to:
  /// **'Etwas geholfen'**
  String get ratingHelpedSomewhat;

  /// No description provided for @ratingNoEffect.
  ///
  /// In de, this message translates to:
  /// **'Kein erkennbarer Effekt'**
  String get ratingNoEffect;

  /// No description provided for @ratingNegative.
  ///
  /// In de, this message translates to:
  /// **'Negativer Effekt'**
  String get ratingNegative;

  /// No description provided for @ratingNotYet.
  ///
  /// In de, this message translates to:
  /// **'Noch nicht bewertbar'**
  String get ratingNotYet;

  /// No description provided for @completeWhatHappened.
  ///
  /// In de, this message translates to:
  /// **'Was ist passiert? (optional)'**
  String get completeWhatHappened;

  /// No description provided for @completeMetricChanged.
  ///
  /// In de, this message translates to:
  /// **'Welche Kennzahl hat sich verändert? (optional)'**
  String get completeMetricChanged;

  /// No description provided for @completeRepeatQuestion.
  ///
  /// In de, this message translates to:
  /// **'Diese Maßnahme später wiederholen?'**
  String get completeRepeatQuestion;

  /// No description provided for @inProgressSectionTitle.
  ///
  /// In de, this message translates to:
  /// **'In Umsetzung'**
  String get inProgressSectionTitle;

  /// No description provided for @awaitingRatingSectionTitle.
  ///
  /// In de, this message translates to:
  /// **'Bewertung ausstehend'**
  String get awaitingRatingSectionTitle;

  /// No description provided for @rateNow.
  ///
  /// In de, this message translates to:
  /// **'Jetzt bewerten'**
  String get rateNow;

  /// No description provided for @historyTitle.
  ///
  /// In de, this message translates to:
  /// **'Maßnahmenhistorie'**
  String get historyTitle;

  /// No description provided for @historyEmpty.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Entscheidungen erfasst. Sobald Sie Empfehlungen annehmen oder ablehnen, entsteht hier Ihr Unternehmensgedächtnis.'**
  String get historyEmpty;

  /// No description provided for @actionStatusSuggested.
  ///
  /// In de, this message translates to:
  /// **'Vorgeschlagen'**
  String get actionStatusSuggested;

  /// No description provided for @actionStatusAccepted.
  ///
  /// In de, this message translates to:
  /// **'Angenommen'**
  String get actionStatusAccepted;

  /// No description provided for @actionStatusInProgress.
  ///
  /// In de, this message translates to:
  /// **'In Umsetzung'**
  String get actionStatusInProgress;

  /// No description provided for @actionStatusCompleted.
  ///
  /// In de, this message translates to:
  /// **'Erledigt'**
  String get actionStatusCompleted;

  /// No description provided for @actionStatusDeferred.
  ///
  /// In de, this message translates to:
  /// **'Zurückgestellt'**
  String get actionStatusDeferred;

  /// No description provided for @actionStatusDeclined.
  ///
  /// In de, this message translates to:
  /// **'Abgelehnt'**
  String get actionStatusDeclined;

  /// No description provided for @dashboardNextActionsTitle.
  ///
  /// In de, this message translates to:
  /// **'Nächste Schritte'**
  String get dashboardNextActionsTitle;

  /// No description provided for @dashboardTopActionLabel.
  ///
  /// In de, this message translates to:
  /// **'Wichtigste Maßnahme'**
  String get dashboardTopActionLabel;

  /// No description provided for @dashboardNoTopAction.
  ///
  /// In de, this message translates to:
  /// **'Keine offene Empfehlung'**
  String get dashboardNoTopAction;

  /// No description provided for @dashboardInProgressLabel.
  ///
  /// In de, this message translates to:
  /// **'In Umsetzung'**
  String get dashboardInProgressLabel;

  /// No description provided for @dashboardAwaitingRatingLabel.
  ///
  /// In de, this message translates to:
  /// **'Zu bewerten'**
  String get dashboardAwaitingRatingLabel;

  /// No description provided for @dashboardOpenNextActions.
  ///
  /// In de, this message translates to:
  /// **'Nächste Schritte öffnen'**
  String get dashboardOpenNextActions;

  /// No description provided for @navCheckIn.
  ///
  /// In de, this message translates to:
  /// **'Monats-Check-in'**
  String get navCheckIn;

  /// No description provided for @checkInTitle.
  ///
  /// In de, this message translates to:
  /// **'Monats-Check-in'**
  String get checkInTitle;

  /// No description provided for @checkInIntro.
  ///
  /// In de, this message translates to:
  /// **'Ein kurzer Rückblick, ehrliche Ergebnisse und Ihre nächsten Schritte – in wenigen Minuten.'**
  String get checkInIntro;

  /// No description provided for @checkInStart.
  ///
  /// In de, this message translates to:
  /// **'Check-in starten'**
  String get checkInStart;

  /// No description provided for @checkInSkip.
  ///
  /// In de, this message translates to:
  /// **'Check-in überspringen'**
  String get checkInSkip;

  /// No description provided for @checkInLastLabel.
  ///
  /// In de, this message translates to:
  /// **'Letzter Check-in'**
  String get checkInLastLabel;

  /// No description provided for @checkInNextLabel.
  ///
  /// In de, this message translates to:
  /// **'Nächster empfohlener Check-in'**
  String get checkInNextLabel;

  /// No description provided for @checkInNever.
  ///
  /// In de, this message translates to:
  /// **'Noch kein Check-in durchgeführt'**
  String get checkInNever;

  /// No description provided for @checkInStep1.
  ///
  /// In de, this message translates to:
  /// **'Seit dem letzten Check-in'**
  String get checkInStep1;

  /// No description provided for @checkInStep2.
  ///
  /// In de, this message translates to:
  /// **'Offene Bewertungen nachholen'**
  String get checkInStep2;

  /// No description provided for @checkInStep3.
  ///
  /// In de, this message translates to:
  /// **'Was hat geholfen – was nicht?'**
  String get checkInStep3;

  /// No description provided for @checkInStep4.
  ///
  /// In de, this message translates to:
  /// **'Eigene Beobachtungen'**
  String get checkInStep4;

  /// No description provided for @checkInStep5.
  ///
  /// In de, this message translates to:
  /// **'Die nächsten drei Schritte'**
  String get checkInStep5;

  /// No description provided for @checkInStep6.
  ///
  /// In de, this message translates to:
  /// **'Abschließen'**
  String get checkInStep6;

  /// No description provided for @checkInNoOpenRatings.
  ///
  /// In de, this message translates to:
  /// **'Keine offenen Bewertungen – alles ist bewertet.'**
  String get checkInNoOpenRatings;

  /// No description provided for @checkInPositiveTitle.
  ///
  /// In de, this message translates to:
  /// **'Was hat geholfen?'**
  String get checkInPositiveTitle;

  /// No description provided for @checkInNegativeTitle.
  ///
  /// In de, this message translates to:
  /// **'Was hat nicht geholfen?'**
  String get checkInNegativeTitle;

  /// No description provided for @checkInNoOutcomes.
  ///
  /// In de, this message translates to:
  /// **'Für diesen Zeitraum liegen noch keine bewerteten Ergebnisse vor.'**
  String get checkInNoOutcomes;

  /// No description provided for @checkInCausalityNote.
  ///
  /// In de, this message translates to:
  /// **'Hinweis: Diese Angaben sind gemeldete Beobachtungen – kein Beweis für Ursache und Wirkung.'**
  String get checkInCausalityNote;

  /// No description provided for @checkInLessonsTitle.
  ///
  /// In de, this message translates to:
  /// **'Was haben wir gelernt?'**
  String get checkInLessonsTitle;

  /// No description provided for @checkInNoLessons.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Erkenntnisse in diesem Zeitraum.'**
  String get checkInNoLessons;

  /// No description provided for @checkInNotesLabel.
  ///
  /// In de, this message translates to:
  /// **'Ihre Beobachtungen (optional)'**
  String get checkInNotesLabel;

  /// No description provided for @checkInNextStepsIntro.
  ///
  /// In de, this message translates to:
  /// **'Das sind die nächsten Schritte für Ihr Unternehmen:'**
  String get checkInNextStepsIntro;

  /// No description provided for @checkInConfidenceLabel.
  ///
  /// In de, this message translates to:
  /// **'Datenbasis'**
  String get checkInConfidenceLabel;

  /// No description provided for @checkInConfidenceLow.
  ///
  /// In de, this message translates to:
  /// **'niedrig'**
  String get checkInConfidenceLow;

  /// No description provided for @checkInConfidenceMedium.
  ///
  /// In de, this message translates to:
  /// **'mittel'**
  String get checkInConfidenceMedium;

  /// No description provided for @checkInConfidenceHigh.
  ///
  /// In de, this message translates to:
  /// **'hoch'**
  String get checkInConfidenceHigh;

  /// No description provided for @checkInHumanReviewHint.
  ///
  /// In de, this message translates to:
  /// **'Eine kurze menschliche Prüfung wäre sinnvoll.'**
  String get checkInHumanReviewHint;

  /// No description provided for @checkInComplete.
  ///
  /// In de, this message translates to:
  /// **'Check-in abschließen'**
  String get checkInComplete;

  /// No description provided for @checkInHistoryTitle.
  ///
  /// In de, this message translates to:
  /// **'Frühere Check-ins'**
  String get checkInHistoryTitle;

  /// No description provided for @checkInStatusActive.
  ///
  /// In de, this message translates to:
  /// **'In Bearbeitung'**
  String get checkInStatusActive;

  /// No description provided for @checkInStatusCompleted.
  ///
  /// In de, this message translates to:
  /// **'Abgeschlossen'**
  String get checkInStatusCompleted;

  /// No description provided for @checkInStatusSkipped.
  ///
  /// In de, this message translates to:
  /// **'Übersprungen'**
  String get checkInStatusSkipped;

  /// No description provided for @dashboardCheckInTitle.
  ///
  /// In de, this message translates to:
  /// **'Monats-Check-in'**
  String get dashboardCheckInTitle;

  /// No description provided for @dashboardStartCheckIn.
  ///
  /// In de, this message translates to:
  /// **'Check-in starten'**
  String get dashboardStartCheckIn;

  /// No description provided for @demoStartButton.
  ///
  /// In de, this message translates to:
  /// **'BusinessBrain in 2 Minuten erleben'**
  String get demoStartButton;

  /// No description provided for @demoRegisterButton.
  ///
  /// In de, this message translates to:
  /// **'Unternehmen anmelden'**
  String get demoRegisterButton;

  /// No description provided for @demoBadgeLabel.
  ///
  /// In de, this message translates to:
  /// **'Demo-Modus'**
  String get demoBadgeLabel;

  /// No description provided for @demoLeaveButton.
  ///
  /// In de, this message translates to:
  /// **'Demo verlassen'**
  String get demoLeaveButton;

  /// No description provided for @demoCreateOwnButton.
  ///
  /// In de, this message translates to:
  /// **'Eigenes Unternehmen anlegen'**
  String get demoCreateOwnButton;

  /// No description provided for @demoSelectHeadline.
  ///
  /// In de, this message translates to:
  /// **'Welche Demo möchten Sie ansehen?'**
  String get demoSelectHeadline;

  /// No description provided for @demoSelectSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Wählen Sie ein Beispielunternehmen. Alle Daten sind Demo-Daten und bleiben auf Ihrem Gerät.'**
  String get demoSelectSubtitle;

  /// No description provided for @demoTourTitle.
  ///
  /// In de, this message translates to:
  /// **'So erkunden Sie die Demo'**
  String get demoTourTitle;

  /// No description provided for @demoTourStep1.
  ///
  /// In de, this message translates to:
  /// **'1. Unternehmen auswählen'**
  String get demoTourStep1;

  /// No description provided for @demoTourStep2.
  ///
  /// In de, this message translates to:
  /// **'2. Kundenfrage prüfen'**
  String get demoTourStep2;

  /// No description provided for @demoTourStep3.
  ///
  /// In de, this message translates to:
  /// **'3. Antwort freigeben'**
  String get demoTourStep3;

  /// No description provided for @demoTourStep4.
  ///
  /// In de, this message translates to:
  /// **'4. Audit ansehen'**
  String get demoTourStep4;

  /// No description provided for @demoTourDismiss.
  ///
  /// In de, this message translates to:
  /// **'Hinweis ausblenden'**
  String get demoTourDismiss;

  /// No description provided for @navCommunityRadar.
  ///
  /// In de, this message translates to:
  /// **'Community Radar'**
  String get navCommunityRadar;

  /// No description provided for @communityRadarTitle.
  ///
  /// In de, this message translates to:
  /// **'Community Radar'**
  String get communityRadarTitle;

  /// No description provided for @communityRadarSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Öffentliche Diskussionen, die zu Ihren Unternehmen passen. Die KI findet und bewertet – veröffentlicht wird nichts automatisch.'**
  String get communityRadarSubtitle;

  /// No description provided for @communityDemoNote.
  ///
  /// In de, this message translates to:
  /// **'Demo-Daten. Es wird nichts veröffentlicht.'**
  String get communityDemoNote;

  /// No description provided for @communityReadOnlyNote.
  ///
  /// In de, this message translates to:
  /// **'Nur-Lese-Vorschau (CR-1): Aufgaben-Aktionen folgen in einem späteren Schritt.'**
  String get communityReadOnlyNote;

  /// No description provided for @communityFilterCompany.
  ///
  /// In de, this message translates to:
  /// **'Unternehmen'**
  String get communityFilterCompany;

  /// No description provided for @communityFilterPlatform.
  ///
  /// In de, this message translates to:
  /// **'Plattform'**
  String get communityFilterPlatform;

  /// No description provided for @communityFilterLanguage.
  ///
  /// In de, this message translates to:
  /// **'Sprache'**
  String get communityFilterLanguage;

  /// No description provided for @communityFilterCountry.
  ///
  /// In de, this message translates to:
  /// **'Land'**
  String get communityFilterCountry;

  /// No description provided for @communityFilterRisk.
  ///
  /// In de, this message translates to:
  /// **'Risiko'**
  String get communityFilterRisk;

  /// No description provided for @communityFilterStatus.
  ///
  /// In de, this message translates to:
  /// **'Status'**
  String get communityFilterStatus;

  /// No description provided for @communityFilterAll.
  ///
  /// In de, this message translates to:
  /// **'Alle'**
  String get communityFilterAll;

  /// No description provided for @communityRelevance.
  ///
  /// In de, this message translates to:
  /// **'Relevanz'**
  String get communityRelevance;

  /// No description provided for @communityEmpty.
  ///
  /// In de, this message translates to:
  /// **'Keine Beiträge für diese Filter.'**
  String get communityEmpty;

  /// No description provided for @communityRecommendedAction.
  ///
  /// In de, this message translates to:
  /// **'Empfohlene Aktion'**
  String get communityRecommendedAction;

  /// No description provided for @communityDetailOriginalText.
  ///
  /// In de, this message translates to:
  /// **'Originalinhalt'**
  String get communityDetailOriginalText;

  /// No description provided for @communityDetailSource.
  ///
  /// In de, this message translates to:
  /// **'Quelle'**
  String get communityDetailSource;

  /// No description provided for @communityDetailSummary.
  ///
  /// In de, this message translates to:
  /// **'KI-Zusammenfassung'**
  String get communityDetailSummary;

  /// No description provided for @communityDetailIntent.
  ///
  /// In de, this message translates to:
  /// **'Erkannte Absicht'**
  String get communityDetailIntent;

  /// No description provided for @communityDetailSentiment.
  ///
  /// In de, this message translates to:
  /// **'Stimmung'**
  String get communityDetailSentiment;

  /// No description provided for @communityDetailRelevanceReason.
  ///
  /// In de, this message translates to:
  /// **'Relevanzbegründung'**
  String get communityDetailRelevanceReason;

  /// No description provided for @communityDetailRisks.
  ///
  /// In de, this message translates to:
  /// **'Risiken'**
  String get communityDetailRisks;

  /// No description provided for @communityDetailNoRisks.
  ///
  /// In de, this message translates to:
  /// **'Keine besonderen Risiken erkannt.'**
  String get communityDetailNoRisks;

  /// No description provided for @communityDetailKnowledge.
  ///
  /// In de, this message translates to:
  /// **'Passende Wissenseinträge'**
  String get communityDetailKnowledge;

  /// No description provided for @communityDetailNoKnowledge.
  ///
  /// In de, this message translates to:
  /// **'Keine passenden Wissenseinträge hinterlegt.'**
  String get communityDetailNoKnowledge;

  /// No description provided for @communityDetailAllowedActions.
  ///
  /// In de, this message translates to:
  /// **'Zulässige Reaktionsarten'**
  String get communityDetailAllowedActions;

  /// No description provided for @communityDetailProhibited.
  ///
  /// In de, this message translates to:
  /// **'Ungeeignete Aussagen'**
  String get communityDetailProhibited;

  /// No description provided for @communityDetailNoProhibited.
  ///
  /// In de, this message translates to:
  /// **'Keine gesperrten Aussagen für diesen Beitrag.'**
  String get communityDetailNoProhibited;

  /// No description provided for @communityDetailMatches.
  ///
  /// In de, this message translates to:
  /// **'Passende Community-Mitglieder'**
  String get communityDetailMatches;

  /// No description provided for @communityDetailNoMatches.
  ///
  /// In de, this message translates to:
  /// **'Noch keine passenden Mitglieder ermittelt.'**
  String get communityDetailNoMatches;

  /// No description provided for @communityMatchScore.
  ///
  /// In de, this message translates to:
  /// **'Übereinstimmung'**
  String get communityMatchScore;

  /// No description provided for @communityMatchReasons.
  ///
  /// In de, this message translates to:
  /// **'Warum es passt'**
  String get communityMatchReasons;

  /// No description provided for @communityMatchWarnings.
  ///
  /// In de, this message translates to:
  /// **'Hinweise'**
  String get communityMatchWarnings;

  /// No description provided for @communityOpenOriginal.
  ///
  /// In de, this message translates to:
  /// **'Original öffnen'**
  String get communityOpenOriginal;

  /// No description provided for @communityDisclosureRequired.
  ///
  /// In de, this message translates to:
  /// **'Offenlegung erforderlich'**
  String get communityDisclosureRequired;

  /// No description provided for @communityBackToRadar.
  ///
  /// In de, this message translates to:
  /// **'Zurück zum Radar'**
  String get communityBackToRadar;

  /// No description provided for @communityPlatformReddit.
  ///
  /// In de, this message translates to:
  /// **'Reddit'**
  String get communityPlatformReddit;

  /// No description provided for @communityPlatformFacebookGroup.
  ///
  /// In de, this message translates to:
  /// **'Facebook-Gruppe'**
  String get communityPlatformFacebookGroup;

  /// No description provided for @communityPlatformForum.
  ///
  /// In de, this message translates to:
  /// **'Forum'**
  String get communityPlatformForum;

  /// No description provided for @communityPlatformInstagram.
  ///
  /// In de, this message translates to:
  /// **'Instagram'**
  String get communityPlatformInstagram;

  /// No description provided for @communityPlatformX.
  ///
  /// In de, this message translates to:
  /// **'X'**
  String get communityPlatformX;

  /// No description provided for @communityPlatformYoutube.
  ///
  /// In de, this message translates to:
  /// **'YouTube'**
  String get communityPlatformYoutube;

  /// No description provided for @communityPlatformOther.
  ///
  /// In de, this message translates to:
  /// **'Andere'**
  String get communityPlatformOther;

  /// No description provided for @communityIntentQuestion.
  ///
  /// In de, this message translates to:
  /// **'Frage'**
  String get communityIntentQuestion;

  /// No description provided for @communityIntentComplaint.
  ///
  /// In de, this message translates to:
  /// **'Beschwerde'**
  String get communityIntentComplaint;

  /// No description provided for @communityIntentRecommendationRequest.
  ///
  /// In de, this message translates to:
  /// **'Empfehlung gesucht'**
  String get communityIntentRecommendationRequest;

  /// No description provided for @communityIntentDiscussion.
  ///
  /// In de, this message translates to:
  /// **'Diskussion'**
  String get communityIntentDiscussion;

  /// No description provided for @communityIntentComparison.
  ///
  /// In de, this message translates to:
  /// **'Vergleich'**
  String get communityIntentComparison;

  /// No description provided for @communityIntentExperienceShare.
  ///
  /// In de, this message translates to:
  /// **'Erfahrungsbericht'**
  String get communityIntentExperienceShare;

  /// No description provided for @communityIntentOther.
  ///
  /// In de, this message translates to:
  /// **'Sonstiges'**
  String get communityIntentOther;

  /// No description provided for @communitySentimentPositive.
  ///
  /// In de, this message translates to:
  /// **'Positiv'**
  String get communitySentimentPositive;

  /// No description provided for @communitySentimentNeutral.
  ///
  /// In de, this message translates to:
  /// **'Neutral'**
  String get communitySentimentNeutral;

  /// No description provided for @communitySentimentNegative.
  ///
  /// In de, this message translates to:
  /// **'Negativ'**
  String get communitySentimentNegative;

  /// No description provided for @communitySentimentMixed.
  ///
  /// In de, this message translates to:
  /// **'Gemischt'**
  String get communitySentimentMixed;

  /// No description provided for @communityStatusNew.
  ///
  /// In de, this message translates to:
  /// **'Neu'**
  String get communityStatusNew;

  /// No description provided for @communityStatusReviewing.
  ///
  /// In de, this message translates to:
  /// **'In Prüfung'**
  String get communityStatusReviewing;

  /// No description provided for @communityStatusMatched.
  ///
  /// In de, this message translates to:
  /// **'Zugeordnet'**
  String get communityStatusMatched;

  /// No description provided for @communityStatusTaskCreated.
  ///
  /// In de, this message translates to:
  /// **'Aufgabe erstellt'**
  String get communityStatusTaskCreated;

  /// No description provided for @communityStatusActioned.
  ///
  /// In de, this message translates to:
  /// **'Bearbeitet'**
  String get communityStatusActioned;

  /// No description provided for @communityStatusDismissed.
  ///
  /// In de, this message translates to:
  /// **'Verworfen'**
  String get communityStatusDismissed;

  /// No description provided for @communityActionViewOnly.
  ///
  /// In de, this message translates to:
  /// **'Nur ansehen'**
  String get communityActionViewOnly;

  /// No description provided for @communityActionLike.
  ///
  /// In de, this message translates to:
  /// **'Liken'**
  String get communityActionLike;

  /// No description provided for @communityActionShare.
  ///
  /// In de, this message translates to:
  /// **'Teilen'**
  String get communityActionShare;

  /// No description provided for @communityActionRepost.
  ///
  /// In de, this message translates to:
  /// **'Reposten'**
  String get communityActionRepost;

  /// No description provided for @communityActionShortPersonalComment.
  ///
  /// In de, this message translates to:
  /// **'Kurzer eigener Kommentar'**
  String get communityActionShortPersonalComment;

  /// No description provided for @communityActionPersonalExperience.
  ///
  /// In de, this message translates to:
  /// **'Eigene Erfahrung'**
  String get communityActionPersonalExperience;

  /// No description provided for @communityActionFactualAnswer.
  ///
  /// In de, this message translates to:
  /// **'Sachliche Antwort'**
  String get communityActionFactualAnswer;

  /// No description provided for @communityActionAskFollowUpQuestion.
  ///
  /// In de, this message translates to:
  /// **'Nachfrage stellen'**
  String get communityActionAskFollowUpQuestion;

  /// No description provided for @communityActionOpenOriginal.
  ///
  /// In de, this message translates to:
  /// **'Original öffnen'**
  String get communityActionOpenOriginal;

  /// No description provided for @communityActionSkip.
  ///
  /// In de, this message translates to:
  /// **'Überspringen'**
  String get communityActionSkip;

  /// No description provided for @navCommunityMembers.
  ///
  /// In de, this message translates to:
  /// **'Community-Mitglieder'**
  String get navCommunityMembers;

  /// No description provided for @communityNavGroupPlatform.
  ///
  /// In de, this message translates to:
  /// **'Plattform'**
  String get communityNavGroupPlatform;

  /// No description provided for @communityNavGroupCommunity.
  ///
  /// In de, this message translates to:
  /// **'Community'**
  String get communityNavGroupCommunity;

  /// No description provided for @communityMembersTitle.
  ///
  /// In de, this message translates to:
  /// **'Community-Mitglieder'**
  String get communityMembersTitle;

  /// No description provided for @communityMembersSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Ein globaler, firmenunabhängiger Pool echter Menschen. Freiwillige Teilnahme, eigene Entscheidung.'**
  String get communityMembersSubtitle;

  /// No description provided for @communityMembersSearchHint.
  ///
  /// In de, this message translates to:
  /// **'Mitglied suchen …'**
  String get communityMembersSearchHint;

  /// No description provided for @communityMembersEmpty.
  ///
  /// In de, this message translates to:
  /// **'Keine Mitglieder für diese Filter.'**
  String get communityMembersEmpty;

  /// No description provided for @communityFilterTopic.
  ///
  /// In de, this message translates to:
  /// **'Thema'**
  String get communityFilterTopic;

  /// No description provided for @communityFilterDomain.
  ///
  /// In de, this message translates to:
  /// **'Bereich'**
  String get communityFilterDomain;

  /// No description provided for @communityMemberQuality.
  ///
  /// In de, this message translates to:
  /// **'Qualität'**
  String get communityMemberQuality;

  /// No description provided for @communityMemberAuthenticity.
  ///
  /// In de, this message translates to:
  /// **'Authentizitätssignal'**
  String get communityMemberAuthenticity;

  /// No description provided for @communityMemberCompletedTasks.
  ///
  /// In de, this message translates to:
  /// **'Erledigte Aufgaben'**
  String get communityMemberCompletedTasks;

  /// No description provided for @communityMemberVerified.
  ///
  /// In de, this message translates to:
  /// **'Verifiziert'**
  String get communityMemberVerified;

  /// No description provided for @communityMemberNotVerified.
  ///
  /// In de, this message translates to:
  /// **'Nicht verifiziert'**
  String get communityMemberNotVerified;

  /// No description provided for @communityMemberAvailable.
  ///
  /// In de, this message translates to:
  /// **'Verfügbar'**
  String get communityMemberAvailable;

  /// No description provided for @communityMemberUnavailable.
  ///
  /// In de, this message translates to:
  /// **'Zurzeit nicht verfügbar'**
  String get communityMemberUnavailable;

  /// No description provided for @communityMemberConsentGranted.
  ///
  /// In de, this message translates to:
  /// **'Profilanalyse erlaubt'**
  String get communityMemberConsentGranted;

  /// No description provided for @communityMemberConsentMissing.
  ///
  /// In de, this message translates to:
  /// **'Profilanalyse nicht erlaubt'**
  String get communityMemberConsentMissing;

  /// No description provided for @communityMemberLanguages.
  ///
  /// In de, this message translates to:
  /// **'Sprachen'**
  String get communityMemberLanguages;

  /// No description provided for @communityMemberCountry.
  ///
  /// In de, this message translates to:
  /// **'Land'**
  String get communityMemberCountry;

  /// No description provided for @communityMemberInterests.
  ///
  /// In de, this message translates to:
  /// **'Interessen'**
  String get communityMemberInterests;

  /// No description provided for @communityMemberExperience.
  ///
  /// In de, this message translates to:
  /// **'Erfahrungskategorien'**
  String get communityMemberExperience;

  /// No description provided for @communityMemberPlatforms.
  ///
  /// In de, this message translates to:
  /// **'Plattformprofile'**
  String get communityMemberPlatforms;

  /// No description provided for @communityMemberPublicTopics.
  ///
  /// In de, this message translates to:
  /// **'Öffentlich besprochene Themen'**
  String get communityMemberPublicTopics;

  /// No description provided for @communityMemberPreferredActions.
  ///
  /// In de, this message translates to:
  /// **'Bevorzugte Aufgabenarten'**
  String get communityMemberPreferredActions;

  /// No description provided for @communityMemberExcludedTopics.
  ///
  /// In de, this message translates to:
  /// **'Ausgeschlossene Themen'**
  String get communityMemberExcludedTopics;

  /// No description provided for @communityMemberExcludedCompanies.
  ///
  /// In de, this message translates to:
  /// **'Ausgeschlossene Firmen'**
  String get communityMemberExcludedCompanies;

  /// No description provided for @communityMemberConsentStatus.
  ///
  /// In de, this message translates to:
  /// **'Einwilligungsstatus'**
  String get communityMemberConsentStatus;

  /// No description provided for @communityMemberAvailability.
  ///
  /// In de, this message translates to:
  /// **'Verfügbarkeit'**
  String get communityMemberAvailability;

  /// No description provided for @communityMemberDomains.
  ///
  /// In de, this message translates to:
  /// **'Mögliche Bereiche'**
  String get communityMemberDomains;

  /// No description provided for @communityMemberMatchesTitle.
  ///
  /// In de, this message translates to:
  /// **'Passende Beiträge'**
  String get communityMemberMatchesTitle;

  /// No description provided for @communityMemberNone.
  ///
  /// In de, this message translates to:
  /// **'—'**
  String get communityMemberNone;

  /// No description provided for @communityMemberStatusActive.
  ///
  /// In de, this message translates to:
  /// **'Aktiv'**
  String get communityMemberStatusActive;

  /// No description provided for @communityMemberStatusPending.
  ///
  /// In de, this message translates to:
  /// **'Ausstehend'**
  String get communityMemberStatusPending;

  /// No description provided for @communityMemberStatusPaused.
  ///
  /// In de, this message translates to:
  /// **'Pausiert'**
  String get communityMemberStatusPaused;

  /// No description provided for @communityMemberStatusBlocked.
  ///
  /// In de, this message translates to:
  /// **'Gesperrt'**
  String get communityMemberStatusBlocked;

  /// No description provided for @communityDomainCommunityEngagement.
  ///
  /// In de, this message translates to:
  /// **'Community-Beteiligung'**
  String get communityDomainCommunityEngagement;

  /// No description provided for @communityDomainProductTest.
  ///
  /// In de, this message translates to:
  /// **'Produkttest'**
  String get communityDomainProductTest;

  /// No description provided for @communityDomainIdeaResearch.
  ///
  /// In de, this message translates to:
  /// **'Ideenforschung'**
  String get communityDomainIdeaResearch;

  /// No description provided for @communityDomainTranslation.
  ///
  /// In de, this message translates to:
  /// **'Übersetzung'**
  String get communityDomainTranslation;

  /// No description provided for @communityDomainOther.
  ///
  /// In de, this message translates to:
  /// **'Sonstiges'**
  String get communityDomainOther;

  /// No description provided for @communityFactorLanguage.
  ///
  /// In de, this message translates to:
  /// **'Sprache'**
  String get communityFactorLanguage;

  /// No description provided for @communityFactorCountry.
  ///
  /// In de, this message translates to:
  /// **'Land'**
  String get communityFactorCountry;

  /// No description provided for @communityFactorTopic.
  ///
  /// In de, this message translates to:
  /// **'Thema'**
  String get communityFactorTopic;

  /// No description provided for @communityFactorExperience.
  ///
  /// In de, this message translates to:
  /// **'Erfahrung'**
  String get communityFactorExperience;

  /// No description provided for @communityFactorPlatform.
  ///
  /// In de, this message translates to:
  /// **'Plattform'**
  String get communityFactorPlatform;

  /// No description provided for @communityFactorPublicActivity.
  ///
  /// In de, this message translates to:
  /// **'Öffentliche Aktivität'**
  String get communityFactorPublicActivity;

  /// No description provided for @communityFactorPreferredAction.
  ///
  /// In de, this message translates to:
  /// **'Bevorzugte Aktion'**
  String get communityFactorPreferredAction;

  /// No description provided for @communityWarningNoExperience.
  ///
  /// In de, this message translates to:
  /// **'Keine eigene Erfahrung zu diesem Thema angegeben'**
  String get communityWarningNoExperience;

  /// No description provided for @communityWarningNotOnPlatform.
  ///
  /// In de, this message translates to:
  /// **'Nicht auf dieser Plattform aktiv'**
  String get communityWarningNotOnPlatform;

  /// No description provided for @communityWarningLowAuthenticity.
  ///
  /// In de, this message translates to:
  /// **'Niedrigeres Authentizitätssignal'**
  String get communityWarningLowAuthenticity;

  /// No description provided for @communityWarningProfileAnalysisNoConsent.
  ///
  /// In de, this message translates to:
  /// **'Profilanalyse ohne Einwilligung nicht möglich – öffentliche Aktivität wird nicht verwendet'**
  String get communityWarningProfileAnalysisNoConsent;

  /// No description provided for @communityBlockCompanyExcluded.
  ///
  /// In de, this message translates to:
  /// **'Firma ausgeschlossen'**
  String get communityBlockCompanyExcluded;

  /// No description provided for @communityBlockTopicExcluded.
  ///
  /// In de, this message translates to:
  /// **'Thema ausgeschlossen'**
  String get communityBlockTopicExcluded;

  /// No description provided for @communityBlockUnavailable.
  ///
  /// In de, this message translates to:
  /// **'Aktuell nicht verfügbar'**
  String get communityBlockUnavailable;

  /// No description provided for @communityBlockAccountBlocked.
  ///
  /// In de, this message translates to:
  /// **'Konto gesperrt'**
  String get communityBlockAccountBlocked;

  /// No description provided for @communityBlockDomainUnsupported.
  ///
  /// In de, this message translates to:
  /// **'Bereich wird nicht unterstützt'**
  String get communityBlockDomainUnsupported;

  /// No description provided for @communityMatchingTitle.
  ///
  /// In de, this message translates to:
  /// **'Matching-Ansicht'**
  String get communityMatchingTitle;

  /// No description provided for @communityMatchingFromContent.
  ///
  /// In de, this message translates to:
  /// **'Ausgangspunkt: Beitrag'**
  String get communityMatchingFromContent;

  /// No description provided for @communityMatchingFromMember.
  ///
  /// In de, this message translates to:
  /// **'Ausgangspunkt: Mitglied'**
  String get communityMatchingFromMember;

  /// No description provided for @communityMatchComponents.
  ///
  /// In de, this message translates to:
  /// **'Score-Komponenten'**
  String get communityMatchComponents;

  /// No description provided for @communityMatchWarningsTitle.
  ///
  /// In de, this message translates to:
  /// **'Hinweise'**
  String get communityMatchWarningsTitle;

  /// No description provided for @communityMatchBlockedTitle.
  ///
  /// In de, this message translates to:
  /// **'Ausgeschlossen'**
  String get communityMatchBlockedTitle;

  /// No description provided for @communityMatchPossibleActions.
  ///
  /// In de, this message translates to:
  /// **'Mögliche Reaktionsarten'**
  String get communityMatchPossibleActions;

  /// No description provided for @communityMatchNoAssignNote.
  ///
  /// In de, this message translates to:
  /// **'Kein automatisches Zuweisen – ein Mensch entscheidet.'**
  String get communityMatchNoAssignNote;

  /// No description provided for @communityMatchEligible.
  ///
  /// In de, this message translates to:
  /// **'Für Zuweisung geeignet'**
  String get communityMatchEligible;

  /// No description provided for @communityMatchIneligible.
  ///
  /// In de, this message translates to:
  /// **'Nicht für Zuweisung geeignet'**
  String get communityMatchIneligible;

  /// No description provided for @communityViewMatching.
  ///
  /// In de, this message translates to:
  /// **'Matching-Ansicht öffnen'**
  String get communityViewMatching;

  /// No description provided for @communityViewProfile.
  ///
  /// In de, this message translates to:
  /// **'Profil ansehen'**
  String get communityViewProfile;

  /// No description provided for @communityViewContent.
  ///
  /// In de, this message translates to:
  /// **'Beitrag ansehen'**
  String get communityViewContent;

  /// No description provided for @communityMatchingEmpty.
  ///
  /// In de, this message translates to:
  /// **'Keine Bewertung verfügbar.'**
  String get communityMatchingEmpty;

  /// No description provided for @botDemoTitle.
  ///
  /// In de, this message translates to:
  /// **'Wissensbasierte KI-Antwort'**
  String get botDemoTitle;

  /// No description provided for @botDemoIntro.
  ///
  /// In de, this message translates to:
  /// **'Die KI antwortet ausschließlich auf Basis der freigegebenen Unternehmens-Wissensbasis. Quellen bleiben sichtbar; nichts wird veröffentlicht.'**
  String get botDemoIntro;

  /// No description provided for @botDemoRecentImportTitle.
  ///
  /// In de, this message translates to:
  /// **'Dieses Dokument wurde gerade in die Wissensbasis übernommen.'**
  String get botDemoRecentImportTitle;

  /// No description provided for @botDemoRecentImportBody.
  ///
  /// In de, this message translates to:
  /// **'Sie können BusinessBrain jetzt Fragen zu diesem Dokument stellen.'**
  String get botDemoRecentImportBody;

  /// No description provided for @botDemoQuestionHint.
  ///
  /// In de, this message translates to:
  /// **'Ihre Unternehmensfrage'**
  String get botDemoQuestionHint;

  /// No description provided for @botDemoSubmit.
  ///
  /// In de, this message translates to:
  /// **'Antwort erstellen'**
  String get botDemoSubmit;

  /// No description provided for @botDemoLoading.
  ///
  /// In de, this message translates to:
  /// **'Antwort wird erstellt …'**
  String get botDemoLoading;

  /// No description provided for @botDemoAnswerTitle.
  ///
  /// In de, this message translates to:
  /// **'Antwort'**
  String get botDemoAnswerTitle;

  /// No description provided for @botDemoSources.
  ///
  /// In de, this message translates to:
  /// **'Quellen'**
  String get botDemoSources;

  /// No description provided for @botDemoGrounded.
  ///
  /// In de, this message translates to:
  /// **'Wissensbasiert'**
  String get botDemoGrounded;

  /// No description provided for @botDemoNotGrounded.
  ///
  /// In de, this message translates to:
  /// **'Kein Treffer'**
  String get botDemoNotGrounded;

  /// No description provided for @botDemoCoverageFull.
  ///
  /// In de, this message translates to:
  /// **'Vollständig aus bestätigtem Firmenwissen beantwortet'**
  String get botDemoCoverageFull;

  /// No description provided for @botDemoCoveragePartial.
  ///
  /// In de, this message translates to:
  /// **'Teilweise beantwortet – konkrete Angabe fehlt'**
  String get botDemoCoveragePartial;

  /// No description provided for @botDemoCoverageNone.
  ///
  /// In de, this message translates to:
  /// **'Keine bestätigte Information vorhanden'**
  String get botDemoCoverageNone;

  /// No description provided for @botDemoCoverageSensitive.
  ///
  /// In de, this message translates to:
  /// **'Sensible Frage – menschliche Prüfung empfohlen'**
  String get botDemoCoverageSensitive;

  /// No description provided for @botDemoFurtherInfoTitle.
  ///
  /// In de, this message translates to:
  /// **'Weiterführende Informationen'**
  String get botDemoFurtherInfoTitle;

  /// No description provided for @botDemoFurtherInfoBody.
  ///
  /// In de, this message translates to:
  /// **'Weitere Informationen finden Sie hier.'**
  String get botDemoFurtherInfoBody;

  /// No description provided for @botDemoMoreLinks.
  ///
  /// In de, this message translates to:
  /// **'Weitere Informationen'**
  String get botDemoMoreLinks;

  /// No description provided for @kbLinkSectionTitle.
  ///
  /// In de, this message translates to:
  /// **'Website-Verknüpfung (optional)'**
  String get kbLinkSectionTitle;

  /// No description provided for @kbLinkSectionHint.
  ///
  /// In de, this message translates to:
  /// **'Dieser Link wird nur angezeigt, wenn der Wissenseintrag eine Antwort tatsächlich unterstützt.'**
  String get kbLinkSectionHint;

  /// No description provided for @kbLinkWebsite.
  ///
  /// In de, this message translates to:
  /// **'Website'**
  String get kbLinkWebsite;

  /// No description provided for @kbLinkButtonText.
  ///
  /// In de, this message translates to:
  /// **'Button-Text'**
  String get kbLinkButtonText;

  /// No description provided for @kbLinkType.
  ///
  /// In de, this message translates to:
  /// **'Link-Typ'**
  String get kbLinkType;

  /// No description provided for @kbLinkTypeNone.
  ///
  /// In de, this message translates to:
  /// **'Nicht festgelegt'**
  String get kbLinkTypeNone;

  /// No description provided for @knowledgeLinkProduct.
  ///
  /// In de, this message translates to:
  /// **'Produktseite'**
  String get knowledgeLinkProduct;

  /// No description provided for @knowledgeLinkPrices.
  ///
  /// In de, this message translates to:
  /// **'Preise'**
  String get knowledgeLinkPrices;

  /// No description provided for @knowledgeLinkFaq.
  ///
  /// In de, this message translates to:
  /// **'FAQ'**
  String get knowledgeLinkFaq;

  /// No description provided for @knowledgeLinkGuide.
  ///
  /// In de, this message translates to:
  /// **'Bedienungsanleitung'**
  String get knowledgeLinkGuide;

  /// No description provided for @knowledgeLinkDownload.
  ///
  /// In de, this message translates to:
  /// **'Download'**
  String get knowledgeLinkDownload;

  /// No description provided for @knowledgeLinkVideo.
  ///
  /// In de, this message translates to:
  /// **'Video'**
  String get knowledgeLinkVideo;

  /// No description provided for @knowledgeLinkSupport.
  ///
  /// In de, this message translates to:
  /// **'Support'**
  String get knowledgeLinkSupport;

  /// No description provided for @knowledgeLinkContact.
  ///
  /// In de, this message translates to:
  /// **'Kontakt'**
  String get knowledgeLinkContact;

  /// No description provided for @knowledgeLinkBlog.
  ///
  /// In de, this message translates to:
  /// **'Blog'**
  String get knowledgeLinkBlog;

  /// No description provided for @knowledgeLinkShop.
  ///
  /// In de, this message translates to:
  /// **'Shop'**
  String get knowledgeLinkShop;

  /// No description provided for @knowledgeLinkForm.
  ///
  /// In de, this message translates to:
  /// **'Formular'**
  String get knowledgeLinkForm;

  /// No description provided for @knowledgeLinkWebsite.
  ///
  /// In de, this message translates to:
  /// **'Website'**
  String get knowledgeLinkWebsite;

  /// No description provided for @botDemoNoKnowledge.
  ///
  /// In de, this message translates to:
  /// **'Ich habe erkannt, dass zu deiner Frage aktuell noch keine ausreichenden Informationen in der Wissensbasis vorhanden sind.'**
  String get botDemoNoKnowledge;

  /// No description provided for @botDemoBlocked.
  ///
  /// In de, this message translates to:
  /// **'Diese Frage berührt ein sensibles Thema. Sie wird bewusst nicht automatisch beantwortet, sondern an einen Menschen übergeben – es wurde keine KI-Antwort erzeugt.'**
  String get botDemoBlocked;

  /// No description provided for @botDemoGapTitle.
  ///
  /// In de, this message translates to:
  /// **'Wissenslücke erkannt'**
  String get botDemoGapTitle;

  /// No description provided for @botDemoGapRecommendTitle.
  ///
  /// In de, this message translates to:
  /// **'Empfohlene Inhalte zur Ergänzung der Wissensbasis:'**
  String get botDemoGapRecommendTitle;

  /// No description provided for @botDemoGapItemFaq.
  ///
  /// In de, this message translates to:
  /// **'Häufig gestellte Fragen (FAQ)'**
  String get botDemoGapItemFaq;

  /// No description provided for @botDemoGapItemFeatures.
  ///
  /// In de, this message translates to:
  /// **'Funktionsbeschreibung'**
  String get botDemoGapItemFeatures;

  /// No description provided for @botDemoGapItemGuide.
  ///
  /// In de, this message translates to:
  /// **'Bedienungsanleitung'**
  String get botDemoGapItemGuide;

  /// No description provided for @botDemoGapItemSteps.
  ///
  /// In de, this message translates to:
  /// **'Schritt-für-Schritt-Anleitung'**
  String get botDemoGapItemSteps;

  /// No description provided for @botDemoGapItemScreenshots.
  ///
  /// In de, this message translates to:
  /// **'Screenshots'**
  String get botDemoGapItemScreenshots;

  /// No description provided for @botDemoGapItemRequirements.
  ///
  /// In de, this message translates to:
  /// **'Technische Voraussetzungen'**
  String get botDemoGapItemRequirements;

  /// No description provided for @botDemoGapClosing.
  ///
  /// In de, this message translates to:
  /// **'Sobald diese Inhalte ergänzt sind, können zukünftige Kundenfragen deutlich präziser beantwortet werden.'**
  String get botDemoGapClosing;

  /// No description provided for @botDemoGapTermsLabel.
  ///
  /// In de, this message translates to:
  /// **'Betroffene Begriffe aus deiner Frage:'**
  String get botDemoGapTermsLabel;

  /// No description provided for @botDemoHumanReview.
  ///
  /// In de, this message translates to:
  /// **'KI-Vorschlag – vor Veröffentlichung prüfen.'**
  String get botDemoHumanReview;

  /// No description provided for @botDemoProviderLabel.
  ///
  /// In de, this message translates to:
  /// **'Provider'**
  String get botDemoProviderLabel;

  /// No description provided for @botDemoProviderMock.
  ///
  /// In de, this message translates to:
  /// **'Offline-Mock'**
  String get botDemoProviderMock;

  /// No description provided for @botDemoModelLabel.
  ///
  /// In de, this message translates to:
  /// **'Modell'**
  String get botDemoModelLabel;

  /// No description provided for @botDemoError.
  ///
  /// In de, this message translates to:
  /// **'Antwort konnte nicht erstellt werden.'**
  String get botDemoError;

  /// No description provided for @botDemoRetry.
  ///
  /// In de, this message translates to:
  /// **'Erneut versuchen'**
  String get botDemoRetry;

  /// No description provided for @botDemoErrorConfig.
  ///
  /// In de, this message translates to:
  /// **'KI ist nicht konfiguriert. Bitte Server-Konfiguration prüfen.'**
  String get botDemoErrorConfig;

  /// No description provided for @botDemoErrorNetwork.
  ///
  /// In de, this message translates to:
  /// **'KI-Dienst nicht erreichbar. Bitte später erneut versuchen.'**
  String get botDemoErrorNetwork;

  /// No description provided for @botDemoErrorTimeout.
  ///
  /// In de, this message translates to:
  /// **'Zeitüberschreitung beim KI-Dienst. Bitte erneut versuchen.'**
  String get botDemoErrorTimeout;

  /// No description provided for @botDemoErrorRateLimit.
  ///
  /// In de, this message translates to:
  /// **'Zu viele Anfragen. Bitte kurz warten und erneut versuchen.'**
  String get botDemoErrorRateLimit;

  /// No description provided for @botDemoErrorBlocked.
  ///
  /// In de, this message translates to:
  /// **'Die Antwort wurde durch Sicherheitsfilter blockiert.'**
  String get botDemoErrorBlocked;

  /// No description provided for @botDemoErrorServer.
  ///
  /// In de, this message translates to:
  /// **'Der KI-Dienst ist derzeit nicht verfügbar.'**
  String get botDemoErrorServer;

  /// No description provided for @navCompanyEvolution.
  ///
  /// In de, this message translates to:
  /// **'Unternehmens-Evolution'**
  String get navCompanyEvolution;

  /// No description provided for @navGroupResearch.
  ///
  /// In de, this message translates to:
  /// **'Recherche'**
  String get navGroupResearch;

  /// No description provided for @companyEvolutionTitle.
  ///
  /// In de, this message translates to:
  /// **'Unternehmens-Evolution'**
  String get companyEvolutionTitle;

  /// No description provided for @companyEvolutionSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Strukturierte externe Informationen zu einem Unternehmen – aus Demo-Daten, ohne Live-Recherche.'**
  String get companyEvolutionSubtitle;

  /// No description provided for @companyEvolutionSelectCompany.
  ///
  /// In de, this message translates to:
  /// **'Unternehmen'**
  String get companyEvolutionSelectCompany;

  /// No description provided for @companyEvolutionSnapshotTitle.
  ///
  /// In de, this message translates to:
  /// **'Unternehmensprofil'**
  String get companyEvolutionSnapshotTitle;

  /// No description provided for @companyEvolutionTimelineTitle.
  ///
  /// In de, this message translates to:
  /// **'Zeitleiste'**
  String get companyEvolutionTimelineTitle;

  /// No description provided for @companyEvolutionSourcesTitle.
  ///
  /// In de, this message translates to:
  /// **'Recherche-Quellen'**
  String get companyEvolutionSourcesTitle;

  /// No description provided for @companyEvolutionEvidenceForDocument.
  ///
  /// In de, this message translates to:
  /// **'Belege aus diesem Dokument'**
  String get companyEvolutionEvidenceForDocument;

  /// No description provided for @companyEvolutionFieldIndustry.
  ///
  /// In de, this message translates to:
  /// **'Branche'**
  String get companyEvolutionFieldIndustry;

  /// No description provided for @companyEvolutionFieldFounded.
  ///
  /// In de, this message translates to:
  /// **'Gründungsjahr'**
  String get companyEvolutionFieldFounded;

  /// No description provided for @companyEvolutionFieldCountries.
  ///
  /// In de, this message translates to:
  /// **'Länder'**
  String get companyEvolutionFieldCountries;

  /// No description provided for @companyEvolutionFieldProducts.
  ///
  /// In de, this message translates to:
  /// **'Bekannte Produkte'**
  String get companyEvolutionFieldProducts;

  /// No description provided for @companyEvolutionFieldWebsite.
  ///
  /// In de, this message translates to:
  /// **'Website'**
  String get companyEvolutionFieldWebsite;

  /// No description provided for @companyEvolutionFieldSocial.
  ///
  /// In de, this message translates to:
  /// **'Social-Media-Kanäle'**
  String get companyEvolutionFieldSocial;

  /// No description provided for @companyEvolutionFieldSegment.
  ///
  /// In de, this message translates to:
  /// **'Marktsegment'**
  String get companyEvolutionFieldSegment;

  /// No description provided for @companyEvolutionFieldRating.
  ///
  /// In de, this message translates to:
  /// **'Bewertung'**
  String get companyEvolutionFieldRating;

  /// No description provided for @companyEvolutionFieldUpdated.
  ///
  /// In de, this message translates to:
  /// **'Letzter Datenstand'**
  String get companyEvolutionFieldUpdated;

  /// No description provided for @companyEvolutionDocSource.
  ///
  /// In de, this message translates to:
  /// **'Quelle'**
  String get companyEvolutionDocSource;

  /// No description provided for @companyEvolutionDocType.
  ///
  /// In de, this message translates to:
  /// **'Typ'**
  String get companyEvolutionDocType;

  /// No description provided for @companyEvolutionDocPublished.
  ///
  /// In de, this message translates to:
  /// **'Veröffentlicht'**
  String get companyEvolutionDocPublished;

  /// No description provided for @companyEvolutionDocLanguage.
  ///
  /// In de, this message translates to:
  /// **'Sprache'**
  String get companyEvolutionDocLanguage;

  /// No description provided for @companyEvolutionDocCountry.
  ///
  /// In de, this message translates to:
  /// **'Land'**
  String get companyEvolutionDocCountry;

  /// No description provided for @companyEvolutionDocUrl.
  ///
  /// In de, this message translates to:
  /// **'URL'**
  String get companyEvolutionDocUrl;

  /// No description provided for @companyEvolutionEvidenceConfidence.
  ///
  /// In de, this message translates to:
  /// **'Konfidenz'**
  String get companyEvolutionEvidenceConfidence;

  /// No description provided for @companyEvolutionEvidenceExtracted.
  ///
  /// In de, this message translates to:
  /// **'Extrahiert'**
  String get companyEvolutionEvidenceExtracted;

  /// No description provided for @companyEvolutionTrustTitle.
  ///
  /// In de, this message translates to:
  /// **'Transparenzhinweis'**
  String get companyEvolutionTrustTitle;

  /// No description provided for @companyEvolutionTrustBody.
  ///
  /// In de, this message translates to:
  /// **'Demo-Daten – keine Live-Recherche, keine KI-generierten Schlussfolgerungen. Quellen und Aussagen sind getrennt modelliert.'**
  String get companyEvolutionTrustBody;

  /// No description provided for @companyEvolutionEmptyCompanies.
  ///
  /// In de, this message translates to:
  /// **'Keine Unternehmen verfügbar.'**
  String get companyEvolutionEmptyCompanies;

  /// No description provided for @companyEvolutionEmptyTimeline.
  ///
  /// In de, this message translates to:
  /// **'Keine Zeitleisten-Einträge vorhanden.'**
  String get companyEvolutionEmptyTimeline;

  /// No description provided for @companyEvolutionEmptyDocuments.
  ///
  /// In de, this message translates to:
  /// **'Keine Recherche-Dokumente vorhanden.'**
  String get companyEvolutionEmptyDocuments;

  /// No description provided for @companyEvolutionEmptyEvidence.
  ///
  /// In de, this message translates to:
  /// **'Keine Belege zu diesem Dokument.'**
  String get companyEvolutionEmptyEvidence;

  /// No description provided for @timelineCategoryFounding.
  ///
  /// In de, this message translates to:
  /// **'Gründung'**
  String get timelineCategoryFounding;

  /// No description provided for @timelineCategoryProduct.
  ///
  /// In de, this message translates to:
  /// **'Produkt'**
  String get timelineCategoryProduct;

  /// No description provided for @timelineCategoryMarketing.
  ///
  /// In de, this message translates to:
  /// **'Marketing'**
  String get timelineCategoryMarketing;

  /// No description provided for @timelineCategoryPartnership.
  ///
  /// In de, this message translates to:
  /// **'Partnerschaft'**
  String get timelineCategoryPartnership;

  /// No description provided for @timelineCategoryExpansion.
  ///
  /// In de, this message translates to:
  /// **'Expansion'**
  String get timelineCategoryExpansion;

  /// No description provided for @timelineCategoryLegal.
  ///
  /// In de, this message translates to:
  /// **'Recht'**
  String get timelineCategoryLegal;

  /// No description provided for @timelineCategoryFinance.
  ///
  /// In de, this message translates to:
  /// **'Finanzen'**
  String get timelineCategoryFinance;

  /// No description provided for @timelineCategoryHiring.
  ///
  /// In de, this message translates to:
  /// **'Personal'**
  String get timelineCategoryHiring;

  /// No description provided for @timelineCategoryStrategy.
  ///
  /// In de, this message translates to:
  /// **'Strategie'**
  String get timelineCategoryStrategy;

  /// No description provided for @timelineCategoryCrisis.
  ///
  /// In de, this message translates to:
  /// **'Krise'**
  String get timelineCategoryCrisis;

  /// No description provided for @timelineCategoryMilestone.
  ///
  /// In de, this message translates to:
  /// **'Meilenstein'**
  String get timelineCategoryMilestone;

  /// No description provided for @researchDocTypeWebsite.
  ///
  /// In de, this message translates to:
  /// **'Website'**
  String get researchDocTypeWebsite;

  /// No description provided for @researchDocTypeNews.
  ///
  /// In de, this message translates to:
  /// **'News'**
  String get researchDocTypeNews;

  /// No description provided for @researchDocTypeBlog.
  ///
  /// In de, this message translates to:
  /// **'Blog'**
  String get researchDocTypeBlog;

  /// No description provided for @researchDocTypeSocialPost.
  ///
  /// In de, this message translates to:
  /// **'Social Post'**
  String get researchDocTypeSocialPost;

  /// No description provided for @researchDocTypeReview.
  ///
  /// In de, this message translates to:
  /// **'Bewertung'**
  String get researchDocTypeReview;

  /// No description provided for @researchDocTypePressRelease.
  ///
  /// In de, this message translates to:
  /// **'Pressemitteilung'**
  String get researchDocTypePressRelease;

  /// No description provided for @researchDocTypeForum.
  ///
  /// In de, this message translates to:
  /// **'Forum'**
  String get researchDocTypeForum;

  /// No description provided for @researchDocTypeVideo.
  ///
  /// In de, this message translates to:
  /// **'Video'**
  String get researchDocTypeVideo;

  /// No description provided for @researchDocTypeFinancial.
  ///
  /// In de, this message translates to:
  /// **'Finanzbericht'**
  String get researchDocTypeFinancial;

  /// No description provided for @researchDocTypeUnknown.
  ///
  /// In de, this message translates to:
  /// **'Unbekannt'**
  String get researchDocTypeUnknown;

  /// No description provided for @researchEvidenceCategoryProduct.
  ///
  /// In de, this message translates to:
  /// **'Produkt'**
  String get researchEvidenceCategoryProduct;

  /// No description provided for @researchEvidenceCategoryMarketing.
  ///
  /// In de, this message translates to:
  /// **'Marketing'**
  String get researchEvidenceCategoryMarketing;

  /// No description provided for @researchEvidenceCategoryExpansion.
  ///
  /// In de, this message translates to:
  /// **'Expansion'**
  String get researchEvidenceCategoryExpansion;

  /// No description provided for @researchEvidenceCategoryHiring.
  ///
  /// In de, this message translates to:
  /// **'Personal'**
  String get researchEvidenceCategoryHiring;

  /// No description provided for @researchEvidenceCategoryFinance.
  ///
  /// In de, this message translates to:
  /// **'Finanzen'**
  String get researchEvidenceCategoryFinance;

  /// No description provided for @researchEvidenceCategoryPartnership.
  ///
  /// In de, this message translates to:
  /// **'Partnerschaft'**
  String get researchEvidenceCategoryPartnership;

  /// No description provided for @researchEvidenceCategoryReputation.
  ///
  /// In de, this message translates to:
  /// **'Reputation'**
  String get researchEvidenceCategoryReputation;

  /// No description provided for @researchEvidenceCategoryStrategy.
  ///
  /// In de, this message translates to:
  /// **'Strategie'**
  String get researchEvidenceCategoryStrategy;

  /// No description provided for @researchEvidenceCategoryOther.
  ///
  /// In de, this message translates to:
  /// **'Sonstiges'**
  String get researchEvidenceCategoryOther;

  /// No description provided for @navKnowledgeBuilder.
  ///
  /// In de, this message translates to:
  /// **'Wissens-Builder'**
  String get navKnowledgeBuilder;

  /// No description provided for @kbTitle.
  ///
  /// In de, this message translates to:
  /// **'Knowledge Builder'**
  String get kbTitle;

  /// No description provided for @kbIntro.
  ///
  /// In de, this message translates to:
  /// **'Füge einen langen Text ein (z. B. Anleitung, Doku, Notizen). Die Analyse schlägt strukturierte Wissenseinträge vor – ohne etwas zu erfinden oder zu speichern.'**
  String get kbIntro;

  /// No description provided for @kbInputHint.
  ///
  /// In de, this message translates to:
  /// **'Unternehmenswissen hier einfügen …'**
  String get kbInputHint;

  /// No description provided for @kbAnalyze.
  ///
  /// In de, this message translates to:
  /// **'Wissen analysieren'**
  String get kbAnalyze;

  /// No description provided for @kbDemoDocumentsTitle.
  ///
  /// In de, this message translates to:
  /// **'Demo-Dokumente'**
  String get kbDemoDocumentsTitle;

  /// No description provided for @kbDemoDocumentsIntro.
  ///
  /// In de, this message translates to:
  /// **'Sie können ein eigenes Dokument einfügen oder eines der vorbereiteten Beispieldokumente laden.'**
  String get kbDemoDocumentsIntro;

  /// No description provided for @kbLoadExample.
  ///
  /// In de, this message translates to:
  /// **'Beispiel laden'**
  String get kbLoadExample;

  /// No description provided for @kbExampleLoaded.
  ///
  /// In de, this message translates to:
  /// **'Beispieldokument geladen'**
  String get kbExampleLoaded;

  /// No description provided for @kbExampleLanguage.
  ///
  /// In de, this message translates to:
  /// **'Sprache'**
  String get kbExampleLanguage;

  /// No description provided for @kbExampleArea.
  ///
  /// In de, this message translates to:
  /// **'Wissensbereich'**
  String get kbExampleArea;

  /// No description provided for @kbExampleDocumentType.
  ///
  /// In de, this message translates to:
  /// **'Dokumenttyp'**
  String get kbExampleDocumentType;

  /// No description provided for @kbExampleReady.
  ///
  /// In de, this message translates to:
  /// **'Bereit zur Analyse.'**
  String get kbExampleReady;

  /// No description provided for @kbPackageBadge.
  ///
  /// In de, this message translates to:
  /// **'Umfangreiches Hauptbeispiel'**
  String get kbPackageBadge;

  /// No description provided for @kbPackageLoad.
  ///
  /// In de, this message translates to:
  /// **'Gesamtes HB-Cure-Wissen laden'**
  String get kbPackageLoad;

  /// No description provided for @kbPackageLoaded.
  ///
  /// In de, this message translates to:
  /// **'HB-Cure-Wissenspaket geladen'**
  String get kbPackageLoaded;

  /// No description provided for @kbPackageNotAnalyzed.
  ///
  /// In de, this message translates to:
  /// **'Die Quelldokumente wurden nur in den Editor geladen. Es wurde noch nichts analysiert oder gespeichert.'**
  String get kbPackageNotAnalyzed;

  /// No description provided for @kbPackageIncludedAreas.
  ///
  /// In de, this message translates to:
  /// **'Enthaltene Bereiche'**
  String get kbPackageIncludedAreas;

  /// No description provided for @kbPackageDocuments.
  ///
  /// In de, this message translates to:
  /// **'Quelldokumente'**
  String get kbPackageDocuments;

  /// No description provided for @kbPackageLanguage.
  ///
  /// In de, this message translates to:
  /// **'Sprache'**
  String get kbPackageLanguage;

  /// No description provided for @kbPackageAreas.
  ///
  /// In de, this message translates to:
  /// **'Wissensbereiche'**
  String get kbPackageAreas;

  /// No description provided for @kbPackageTimeSensitive.
  ///
  /// In de, this message translates to:
  /// **'Zeitabhängige Inhalte'**
  String get kbPackageTimeSensitive;

  /// No description provided for @kbPackageReviewRequired.
  ///
  /// In de, this message translates to:
  /// **'Prüfpflichtige Aussagen'**
  String get kbPackageReviewRequired;

  /// No description provided for @kbPackageSourcesTitle.
  ///
  /// In de, this message translates to:
  /// **'Inhalte und Quellenherkunft ansehen'**
  String get kbPackageSourcesTitle;

  /// No description provided for @kbPackageSourcesHint.
  ///
  /// In de, this message translates to:
  /// **'Website-Daten und interne Projektdokumentation bleiben klar getrennt.'**
  String get kbPackageSourcesHint;

  /// No description provided for @kbPackageSourceLabel.
  ///
  /// In de, this message translates to:
  /// **'Quelle'**
  String get kbPackageSourceLabel;

  /// No description provided for @kbPackageSourceTypeLabel.
  ///
  /// In de, this message translates to:
  /// **'Quellentyp'**
  String get kbPackageSourceTypeLabel;

  /// No description provided for @kbPackageDataStatusLabel.
  ///
  /// In de, this message translates to:
  /// **'Datenstand'**
  String get kbPackageDataStatusLabel;

  /// No description provided for @kbPackageLastCheckedLabel.
  ///
  /// In de, this message translates to:
  /// **'Zuletzt geprüft'**
  String get kbPackageLastCheckedLabel;

  /// No description provided for @kbPackageRiskReview.
  ///
  /// In de, this message translates to:
  /// **'Rechtliche beziehungsweise fachliche Prüfung erforderlich'**
  String get kbPackageRiskReview;

  /// No description provided for @kbPackageRiskImpact.
  ///
  /// In de, this message translates to:
  /// **'Wirkungsbezogene Aussage – vor Veröffentlichung prüfen'**
  String get kbPackageRiskImpact;

  /// No description provided for @kbPackageRiskTestimonial.
  ///
  /// In de, this message translates to:
  /// **'Erfahrungsbericht – nicht als Tatsachenbehauptung verwenden'**
  String get kbPackageRiskTestimonial;

  /// No description provided for @kbPackageTimeSensitiveBadge.
  ///
  /// In de, this message translates to:
  /// **'Zeitabhängig'**
  String get kbPackageTimeSensitiveBadge;

  /// No description provided for @kbPackageReviewRecommendedLabel.
  ///
  /// In de, this message translates to:
  /// **'Erneute Prüfung'**
  String get kbPackageReviewRecommendedLabel;

  /// No description provided for @kbPackageReviewRecommended.
  ///
  /// In de, this message translates to:
  /// **'Vor Veröffentlichung empfohlen'**
  String get kbPackageReviewRecommended;

  /// No description provided for @kbAnalyzeReady.
  ///
  /// In de, this message translates to:
  /// **'Dokument bereit'**
  String get kbAnalyzeReady;

  /// No description provided for @kbAnalyzeEmptyHint.
  ///
  /// In de, this message translates to:
  /// **'Dokument einfügen oder Beispiel laden'**
  String get kbAnalyzeEmptyHint;

  /// No description provided for @kbCharacters.
  ///
  /// In de, this message translates to:
  /// **'Zeichen'**
  String get kbCharacters;

  /// No description provided for @kbAnalyzing.
  ///
  /// In de, this message translates to:
  /// **'Analysiere …'**
  String get kbAnalyzing;

  /// No description provided for @kbReset.
  ///
  /// In de, this message translates to:
  /// **'Zurücksetzen'**
  String get kbReset;

  /// No description provided for @kbTrustNotice.
  ///
  /// In de, this message translates to:
  /// **'Nichts wird automatisch gespeichert. Die KI erfindet keine Fakten – Inhalte bleiben unverändert, nur Titel, Fragen und Schlagwörter werden erzeugt.'**
  String get kbTrustNotice;

  /// No description provided for @kbNoResults.
  ///
  /// In de, this message translates to:
  /// **'Keine auswertbaren Aussagen gefunden. Bitte mehr Text einfügen.'**
  String get kbNoResults;

  /// No description provided for @kbStatsTitle.
  ///
  /// In de, this message translates to:
  /// **'Analyse-Übersicht'**
  String get kbStatsTitle;

  /// No description provided for @kbStatSentences.
  ///
  /// In de, this message translates to:
  /// **'Analysierte Sätze'**
  String get kbStatSentences;

  /// No description provided for @kbStatTopics.
  ///
  /// In de, this message translates to:
  /// **'Erkannte Themen'**
  String get kbStatTopics;

  /// No description provided for @kbStatNew.
  ///
  /// In de, this message translates to:
  /// **'Neue Wissenseinträge'**
  String get kbStatNew;

  /// No description provided for @kbStatExisting.
  ///
  /// In de, this message translates to:
  /// **'Vorhandene Einträge'**
  String get kbStatExisting;

  /// No description provided for @kbStatDuplicates.
  ///
  /// In de, this message translates to:
  /// **'Mögliche Dubletten'**
  String get kbStatDuplicates;

  /// No description provided for @kbStatUnclear.
  ///
  /// In de, this message translates to:
  /// **'Unklare Aussagen'**
  String get kbStatUnclear;

  /// No description provided for @kbDraftsTitle.
  ///
  /// In de, this message translates to:
  /// **'Vorgeschlagene Einträge'**
  String get kbDraftsTitle;

  /// No description provided for @kbDecisionAccept.
  ///
  /// In de, this message translates to:
  /// **'Übernehmen'**
  String get kbDecisionAccept;

  /// No description provided for @kbDecisionEdit.
  ///
  /// In de, this message translates to:
  /// **'Bearbeiten'**
  String get kbDecisionEdit;

  /// No description provided for @kbDecisionIgnore.
  ///
  /// In de, this message translates to:
  /// **'Ignorieren'**
  String get kbDecisionIgnore;

  /// No description provided for @kbFieldTitle.
  ///
  /// In de, this message translates to:
  /// **'Titel'**
  String get kbFieldTitle;

  /// No description provided for @kbFieldQuestion.
  ///
  /// In de, this message translates to:
  /// **'Frage'**
  String get kbFieldQuestion;

  /// No description provided for @kbFieldContent.
  ///
  /// In de, this message translates to:
  /// **'Inhalt'**
  String get kbFieldContent;

  /// No description provided for @kbFieldKeywords.
  ///
  /// In de, this message translates to:
  /// **'Schlagwörter'**
  String get kbFieldKeywords;

  /// No description provided for @kbFieldArea.
  ///
  /// In de, this message translates to:
  /// **'Bereich'**
  String get kbFieldArea;

  /// No description provided for @kbFieldCategory.
  ///
  /// In de, this message translates to:
  /// **'Kategorie'**
  String get kbFieldCategory;

  /// No description provided for @kbFieldDetectedTopics.
  ///
  /// In de, this message translates to:
  /// **'Erkannte Themen'**
  String get kbFieldDetectedTopics;

  /// No description provided for @kbDuplicateBadge.
  ///
  /// In de, this message translates to:
  /// **'Mögliche Dublette'**
  String get kbDuplicateBadge;

  /// No description provided for @kbExistingTitle.
  ///
  /// In de, this message translates to:
  /// **'Bestehender Eintrag'**
  String get kbExistingTitle;

  /// No description provided for @kbNewInfoTitle.
  ///
  /// In de, this message translates to:
  /// **'Neue Information'**
  String get kbNewInfoTitle;

  /// No description provided for @kbSuggestionTitle.
  ///
  /// In de, this message translates to:
  /// **'Vorschlag'**
  String get kbSuggestionTitle;

  /// No description provided for @kbMergeAugment.
  ///
  /// In de, this message translates to:
  /// **'Ergänzen'**
  String get kbMergeAugment;

  /// No description provided for @kbMergeReplace.
  ///
  /// In de, this message translates to:
  /// **'Ersetzen'**
  String get kbMergeReplace;

  /// No description provided for @kbMergeNew.
  ///
  /// In de, this message translates to:
  /// **'Neuen Eintrag anlegen'**
  String get kbMergeNew;

  /// No description provided for @kbCatFaq.
  ///
  /// In de, this message translates to:
  /// **'FAQ'**
  String get kbCatFaq;

  /// No description provided for @kbCatInstallation.
  ///
  /// In de, this message translates to:
  /// **'Installationsanleitung'**
  String get kbCatInstallation;

  /// No description provided for @kbCatStepByStep.
  ///
  /// In de, this message translates to:
  /// **'Schritt-für-Schritt'**
  String get kbCatStepByStep;

  /// No description provided for @kbCatTechnicalRequirement.
  ///
  /// In de, this message translates to:
  /// **'Technische Voraussetzung'**
  String get kbCatTechnicalRequirement;

  /// No description provided for @kbCatWarning.
  ///
  /// In de, this message translates to:
  /// **'Warnhinweis'**
  String get kbCatWarning;

  /// No description provided for @kbCatTroubleshooting.
  ///
  /// In de, this message translates to:
  /// **'Problemlösung'**
  String get kbCatTroubleshooting;

  /// No description provided for @kbCatProductFeature.
  ///
  /// In de, this message translates to:
  /// **'Produktfunktion'**
  String get kbCatProductFeature;

  /// No description provided for @kbCatTip.
  ///
  /// In de, this message translates to:
  /// **'Tipp'**
  String get kbCatTip;

  /// No description provided for @kbCatDefinition.
  ///
  /// In de, this message translates to:
  /// **'Definition'**
  String get kbCatDefinition;

  /// No description provided for @kbCatContact.
  ///
  /// In de, this message translates to:
  /// **'Kontaktinformation'**
  String get kbCatContact;

  /// No description provided for @kbCatGeneral.
  ///
  /// In de, this message translates to:
  /// **'Allgemein'**
  String get kbCatGeneral;

  /// No description provided for @kbAnalysisTitle.
  ///
  /// In de, this message translates to:
  /// **'BusinessBrain analysiert Ihr Wissen'**
  String get kbAnalysisTitle;

  /// No description provided for @kbAnalysisComplete.
  ///
  /// In de, this message translates to:
  /// **'Analyse abgeschlossen'**
  String get kbAnalysisComplete;

  /// No description provided for @kbAnalysisIntro.
  ///
  /// In de, this message translates to:
  /// **'Jeder Schritt bleibt sichtbar: erkennen, strukturieren und mit der Wissensbasis abgleichen.'**
  String get kbAnalysisIntro;

  /// No description provided for @kbPhaseRecognizeTitle.
  ///
  /// In de, this message translates to:
  /// **'BusinessBrain erkennt den Kontext'**
  String get kbPhaseRecognizeTitle;

  /// No description provided for @kbPhaseStructureTitle.
  ///
  /// In de, this message translates to:
  /// **'BusinessBrain strukturiert das Wissen'**
  String get kbPhaseStructureTitle;

  /// No description provided for @kbPhaseCompareTitle.
  ///
  /// In de, this message translates to:
  /// **'BusinessBrain prüft die vorhandene Wissensbasis'**
  String get kbPhaseCompareTitle;

  /// No description provided for @kbPhasePending.
  ///
  /// In de, this message translates to:
  /// **'Ausstehend'**
  String get kbPhasePending;

  /// No description provided for @kbPhaseActive.
  ///
  /// In de, this message translates to:
  /// **'In Arbeit'**
  String get kbPhaseActive;

  /// No description provided for @kbPhaseComplete.
  ///
  /// In de, this message translates to:
  /// **'Abgeschlossen'**
  String get kbPhaseComplete;

  /// No description provided for @kbDetectedLanguage.
  ///
  /// In de, this message translates to:
  /// **'Sprache'**
  String get kbDetectedLanguage;

  /// No description provided for @kbDetectedDocumentType.
  ///
  /// In de, this message translates to:
  /// **'Dokumenttyp'**
  String get kbDetectedDocumentType;

  /// No description provided for @kbDetectedStatements.
  ///
  /// In de, this message translates to:
  /// **'Erkannte Aussagen'**
  String get kbDetectedStatements;

  /// No description provided for @kbMetricFaq.
  ///
  /// In de, this message translates to:
  /// **'FAQ'**
  String get kbMetricFaq;

  /// No description provided for @kbMetricProductFeatures.
  ///
  /// In de, this message translates to:
  /// **'Produktfunktionen'**
  String get kbMetricProductFeatures;

  /// No description provided for @kbMetricSteps.
  ///
  /// In de, this message translates to:
  /// **'Schritt-für-Schritt-Anleitungen'**
  String get kbMetricSteps;

  /// No description provided for @kbMetricWarnings.
  ///
  /// In de, this message translates to:
  /// **'Warnhinweise'**
  String get kbMetricWarnings;

  /// No description provided for @kbMetricRequirements.
  ///
  /// In de, this message translates to:
  /// **'Technische Voraussetzungen'**
  String get kbMetricRequirements;

  /// No description provided for @kbMetricDefinitions.
  ///
  /// In de, this message translates to:
  /// **'Definitionen'**
  String get kbMetricDefinitions;

  /// No description provided for @kbMetricTips.
  ///
  /// In de, this message translates to:
  /// **'Tipps'**
  String get kbMetricTips;

  /// No description provided for @kbMetricKeywords.
  ///
  /// In de, this message translates to:
  /// **'Schlagwörter'**
  String get kbMetricKeywords;

  /// No description provided for @kbMetricSimilarTopics.
  ///
  /// In de, this message translates to:
  /// **'Ähnliche Themen'**
  String get kbMetricSimilarTopics;

  /// No description provided for @kbMetricProducts.
  ///
  /// In de, this message translates to:
  /// **'Erkannte Produkte'**
  String get kbMetricProducts;

  /// No description provided for @kbMetricDevices.
  ///
  /// In de, this message translates to:
  /// **'Erkannte Geräte'**
  String get kbMetricDevices;

  /// No description provided for @kbMetricFunctions.
  ///
  /// In de, this message translates to:
  /// **'Erkannte Funktionen'**
  String get kbMetricFunctions;

  /// No description provided for @kbSummaryTitle.
  ///
  /// In de, this message translates to:
  /// **'BusinessBrain hat Ihren Text erfolgreich analysiert.'**
  String get kbSummaryTitle;

  /// No description provided for @kbSummaryIntro.
  ///
  /// In de, this message translates to:
  /// **'BusinessBrain hat Ihren Text analysiert und daraus strukturiertes Unternehmenswissen vorgeschlagen. Es wurde noch nichts gespeichert. Erst nach Ihrer Bestätigung wird neues Wissen Teil der Wissensbasis.'**
  String get kbSummaryIntro;

  /// No description provided for @kbPreviewIntro.
  ///
  /// In de, this message translates to:
  /// **'Prüfen Sie jetzt jeden vorgeschlagenen Eintrag und seine Herkunft im Originaltext.'**
  String get kbPreviewIntro;

  /// No description provided for @kbCreatedFrom.
  ///
  /// In de, this message translates to:
  /// **'Erstellt aus:'**
  String get kbCreatedFrom;

  /// No description provided for @kbLanguageGerman.
  ///
  /// In de, this message translates to:
  /// **'Deutsch'**
  String get kbLanguageGerman;

  /// No description provided for @kbLanguageEnglish.
  ///
  /// In de, this message translates to:
  /// **'Englisch'**
  String get kbLanguageEnglish;

  /// No description provided for @kbLanguageUnknown.
  ///
  /// In de, this message translates to:
  /// **'Nicht eindeutig'**
  String get kbLanguageUnknown;

  /// No description provided for @kbDocTypeFaqCollection.
  ///
  /// In de, this message translates to:
  /// **'FAQ-Sammlung'**
  String get kbDocTypeFaqCollection;

  /// No description provided for @kbDocTypeProductDescription.
  ///
  /// In de, this message translates to:
  /// **'Produktbeschreibung'**
  String get kbDocTypeProductDescription;

  /// No description provided for @kbDocTypeInstructions.
  ///
  /// In de, this message translates to:
  /// **'Anleitung'**
  String get kbDocTypeInstructions;

  /// No description provided for @kbDocTypeTechnicalDocumentation.
  ///
  /// In de, this message translates to:
  /// **'Technische Dokumentation'**
  String get kbDocTypeTechnicalDocumentation;

  /// No description provided for @kbDocTypeCompanyKnowledge.
  ///
  /// In de, this message translates to:
  /// **'Unternehmenswissen'**
  String get kbDocTypeCompanyKnowledge;

  /// No description provided for @kbDemoBadge.
  ///
  /// In de, this message translates to:
  /// **'Wissensvorschau'**
  String get kbDemoBadge;

  /// No description provided for @kbDemoNotSaved.
  ///
  /// In de, this message translates to:
  /// **'Noch nicht gespeichert'**
  String get kbDemoNotSaved;

  /// No description provided for @kbDemoSaved.
  ///
  /// In de, this message translates to:
  /// **'Im Workspace bestätigt'**
  String get kbDemoSaved;

  /// No description provided for @kbDemoTitle.
  ///
  /// In de, this message translates to:
  /// **'Dieses Wissen sofort ausprobieren'**
  String get kbDemoTitle;

  /// No description provided for @kbDemoIntro.
  ///
  /// In de, this message translates to:
  /// **'BusinessBrain hat passende Beispielfragen ausschließlich aus dem gerade analysierten Text vorbereitet. Wählen Sie eine Frage und prüfen Sie unmittelbar, wie das vorgeschlagene Wissen verwendet werden kann.'**
  String get kbDemoIntro;

  /// No description provided for @kbDemoQuestionLabel.
  ///
  /// In de, this message translates to:
  /// **'Vorbereitete Beispielfrage'**
  String get kbDemoQuestionLabel;

  /// No description provided for @kbDemoCreateAnswer.
  ///
  /// In de, this message translates to:
  /// **'Antwort erstellen'**
  String get kbDemoCreateAnswer;

  /// No description provided for @kbDemoAnswerTitle.
  ///
  /// In de, this message translates to:
  /// **'Antwort aus dem analysierten Text'**
  String get kbDemoAnswerTitle;

  /// No description provided for @kbDemoSourcesTitle.
  ///
  /// In de, this message translates to:
  /// **'Verwendete Quelle'**
  String get kbDemoSourcesTitle;

  /// No description provided for @kbDemoSourceSentence.
  ///
  /// In de, this message translates to:
  /// **'Originalsatz aus dem Dokument'**
  String get kbDemoSourceSentence;

  /// No description provided for @kbImportReviewTitle.
  ///
  /// In de, this message translates to:
  /// **'Wissen in den Workspace übernehmen'**
  String get kbImportReviewTitle;

  /// No description provided for @kbImportReviewNote.
  ///
  /// In de, this message translates to:
  /// **'Mit diesem Schritt bestätigen Sie alle vorgeschlagenen Einträge gemeinsam. Erst danach werden sie Teil der aktiven Wissensbasis.'**
  String get kbImportReviewNote;

  /// No description provided for @kbImportAll.
  ///
  /// In de, this message translates to:
  /// **'Alle vorgeschlagenen Wissenseinträge übernehmen'**
  String get kbImportAll;

  /// No description provided for @kbImporting.
  ///
  /// In de, this message translates to:
  /// **'Wissenseinträge werden übernommen …'**
  String get kbImporting;

  /// No description provided for @kbImportSuccessTitle.
  ///
  /// In de, this message translates to:
  /// **'{count} Wissenseinträge übernommen'**
  String kbImportSuccessTitle(int count);

  /// No description provided for @kbImportKnowledgeCount.
  ///
  /// In de, this message translates to:
  /// **'Wissensbasis: {before} → {after}'**
  String kbImportKnowledgeCount(int before, int after);

  /// No description provided for @kbImportGroundedReady.
  ///
  /// In de, this message translates to:
  /// **'Grounded AI verwendet jetzt dieses Unternehmenswissen.'**
  String get kbImportGroundedReady;

  /// No description provided for @kbImportError.
  ///
  /// In de, this message translates to:
  /// **'Die Wissenseinträge konnten nicht vollständig übernommen werden. Bitte versuchen Sie es erneut.'**
  String get kbImportError;

  /// No description provided for @kbSuccessDialogTitle.
  ///
  /// In de, this message translates to:
  /// **'Unternehmenswissen erfolgreich erweitert'**
  String get kbSuccessDialogTitle;

  /// No description provided for @kbSuccessDialogBody.
  ///
  /// In de, this message translates to:
  /// **'BusinessBrain hat die vorgeschlagenen Wissenseinträge übernommen.'**
  String get kbSuccessDialogBody;

  /// No description provided for @kbSuccessBefore.
  ///
  /// In de, this message translates to:
  /// **'Vorher'**
  String get kbSuccessBefore;

  /// No description provided for @kbSuccessNow.
  ///
  /// In de, this message translates to:
  /// **'Jetzt'**
  String get kbSuccessNow;

  /// No description provided for @kbSuccessImported.
  ///
  /// In de, this message translates to:
  /// **'Übernommene Einträge'**
  String get kbSuccessImported;

  /// No description provided for @kbSuccessEntryValue.
  ///
  /// In de, this message translates to:
  /// **'{count} Wissenseinträge'**
  String kbSuccessEntryValue(int count);

  /// No description provided for @kbSuccessNewFaq.
  ///
  /// In de, this message translates to:
  /// **'Neue FAQ'**
  String get kbSuccessNewFaq;

  /// No description provided for @kbSuccessNewProductFeatures.
  ///
  /// In de, this message translates to:
  /// **'Neue Produktfunktionen'**
  String get kbSuccessNewProductFeatures;

  /// No description provided for @kbSuccessNewRequirements.
  ///
  /// In de, this message translates to:
  /// **'Neue technische Voraussetzungen'**
  String get kbSuccessNewRequirements;

  /// No description provided for @kbSuccessWorkspaceTitle.
  ///
  /// In de, this message translates to:
  /// **'Unternehmenswissen'**
  String get kbSuccessWorkspaceTitle;

  /// No description provided for @kbSuccessDocuments.
  ///
  /// In de, this message translates to:
  /// **'Dokumente'**
  String get kbSuccessDocuments;

  /// No description provided for @kbSuccessKnowledgeEntries.
  ///
  /// In de, this message translates to:
  /// **'Wissenseinträge'**
  String get kbSuccessKnowledgeEntries;

  /// No description provided for @kbSuccessFaq.
  ///
  /// In de, this message translates to:
  /// **'FAQ'**
  String get kbSuccessFaq;

  /// No description provided for @kbSuccessKeywords.
  ///
  /// In de, this message translates to:
  /// **'Schlagwörter'**
  String get kbSuccessKeywords;

  /// No description provided for @kbSuccessGroundedReady.
  ///
  /// In de, this message translates to:
  /// **'Das neue Wissen steht jetzt für Grounded Answers zur Verfügung.'**
  String get kbSuccessGroundedReady;

  /// No description provided for @kbSuccessAddDocument.
  ///
  /// In de, this message translates to:
  /// **'Weiteres Dokument hinzufügen'**
  String get kbSuccessAddDocument;

  /// No description provided for @kbSuccessAskNow.
  ///
  /// In de, this message translates to:
  /// **'BusinessBrain jetzt befragen'**
  String get kbSuccessAskNow;

  /// No description provided for @kbCycleDocument.
  ///
  /// In de, this message translates to:
  /// **'Dokument'**
  String get kbCycleDocument;

  /// No description provided for @kbCycleStructured.
  ///
  /// In de, this message translates to:
  /// **'Strukturiert'**
  String get kbCycleStructured;

  /// No description provided for @kbCycleAccepted.
  ///
  /// In de, this message translates to:
  /// **'Übernommen'**
  String get kbCycleAccepted;

  /// No description provided for @kbCycleAnswerable.
  ///
  /// In de, this message translates to:
  /// **'Ab jetzt beantwortbar'**
  String get kbCycleAnswerable;

  /// No description provided for @navRolePortals.
  ///
  /// In de, this message translates to:
  /// **'Portale'**
  String get navRolePortals;

  /// No description provided for @roleOverviewTitle.
  ///
  /// In de, this message translates to:
  /// **'Rollen & Portale'**
  String get roleOverviewTitle;

  /// No description provided for @roleOverviewIntro.
  ///
  /// In de, this message translates to:
  /// **'Drei Ebenen, eine Wissensbasis. Vorschau der reduzierten Navigation je Rolle – ohne Login und ohne echte Rechtevergabe.'**
  String get roleOverviewIntro;

  /// No description provided for @roleTrustNotice.
  ///
  /// In de, this message translates to:
  /// **'Demo-Struktur: keine Anmeldung, keine Berechtigungsprüfung, keine Backend-Änderung. Nur zur Veranschaulichung.'**
  String get roleTrustNotice;

  /// No description provided for @roleSharedKnowledgeNote.
  ///
  /// In de, this message translates to:
  /// **'Alle drei Ebenen greifen auf dieselbe Wissensbasis zu – neue Informationen werden ausschließlich im Firmenportal gepflegt.'**
  String get roleSharedKnowledgeNote;

  /// No description provided for @roleSectionsTitle.
  ///
  /// In de, this message translates to:
  /// **'Sichtbare Bereiche'**
  String get roleSectionsTitle;

  /// No description provided for @roleDayTitle.
  ///
  /// In de, this message translates to:
  /// **'Beispiel-Tagesablauf'**
  String get roleDayTitle;

  /// No description provided for @roleSelectTier.
  ///
  /// In de, this message translates to:
  /// **'Ebene'**
  String get roleSelectTier;

  /// No description provided for @roleSelectDepartment.
  ///
  /// In de, this message translates to:
  /// **'Abteilung'**
  String get roleSelectDepartment;

  /// No description provided for @rolePortalCompanyTitle.
  ///
  /// In de, this message translates to:
  /// **'Firmenportal'**
  String get rolePortalCompanyTitle;

  /// No description provided for @rolePortalEmployeeTitle.
  ///
  /// In de, this message translates to:
  /// **'Mitarbeiterportal'**
  String get rolePortalEmployeeTitle;

  /// No description provided for @rolePortalCustomerTitle.
  ///
  /// In de, this message translates to:
  /// **'Kundenportal'**
  String get rolePortalCustomerTitle;

  /// No description provided for @roleTierCompany.
  ///
  /// In de, this message translates to:
  /// **'Firmenadministrator'**
  String get roleTierCompany;

  /// No description provided for @roleTierEmployee.
  ///
  /// In de, this message translates to:
  /// **'Mitarbeiter'**
  String get roleTierEmployee;

  /// No description provided for @roleTierCustomer.
  ///
  /// In de, this message translates to:
  /// **'Kunde'**
  String get roleTierCustomer;

  /// No description provided for @roleDeptSupport.
  ///
  /// In de, this message translates to:
  /// **'Support'**
  String get roleDeptSupport;

  /// No description provided for @roleDeptMarketing.
  ///
  /// In de, this message translates to:
  /// **'Marketing'**
  String get roleDeptMarketing;

  /// No description provided for @roleDeptTechnical.
  ///
  /// In de, this message translates to:
  /// **'Technik'**
  String get roleDeptTechnical;

  /// No description provided for @roleDeptSales.
  ///
  /// In de, this message translates to:
  /// **'Vertrieb'**
  String get roleDeptSales;

  /// No description provided for @roleSecProducts.
  ///
  /// In de, this message translates to:
  /// **'Produkte'**
  String get roleSecProducts;

  /// No description provided for @roleSecResearch.
  ///
  /// In de, this message translates to:
  /// **'Research'**
  String get roleSecResearch;

  /// No description provided for @roleSecCompetitors.
  ///
  /// In de, this message translates to:
  /// **'Wettbewerber'**
  String get roleSecCompetitors;

  /// No description provided for @roleSecEmployees.
  ///
  /// In de, this message translates to:
  /// **'Mitarbeiter'**
  String get roleSecEmployees;

  /// No description provided for @roleSecRoles.
  ///
  /// In de, this message translates to:
  /// **'Rollen'**
  String get roleSecRoles;

  /// No description provided for @roleSecCustomerAssistant.
  ///
  /// In de, this message translates to:
  /// **'Kunden-Assistent'**
  String get roleSecCustomerAssistant;

  /// No description provided for @roleSecContact.
  ///
  /// In de, this message translates to:
  /// **'Kontakt'**
  String get roleSecContact;

  /// No description provided for @roleDayCompany1.
  ///
  /// In de, this message translates to:
  /// **'Dokumente importieren und mit dem Knowledge Builder strukturieren.'**
  String get roleDayCompany1;

  /// No description provided for @roleDayCompany2.
  ///
  /// In de, this message translates to:
  /// **'Rollen vergeben und Analysen im Dashboard prüfen.'**
  String get roleDayCompany2;

  /// No description provided for @roleDayCompany3.
  ///
  /// In de, this message translates to:
  /// **'Company Evolution und Wettbewerber im Blick behalten.'**
  String get roleDayCompany3;

  /// No description provided for @roleDayEmployee1.
  ///
  /// In de, this message translates to:
  /// **'Nur die zugewiesenen Bereiche öffnen (z. B. Support: FAQ & Prüfung).'**
  String get roleDayEmployee1;

  /// No description provided for @roleDayEmployee2.
  ///
  /// In de, this message translates to:
  /// **'Antworten für Kunden vorbereiten und Wissen ergänzen.'**
  String get roleDayEmployee2;

  /// No description provided for @roleDayEmployee3.
  ///
  /// In de, this message translates to:
  /// **'Keine Systemeinstellungen – Fokus auf die tägliche Arbeit.'**
  String get roleDayEmployee3;

  /// No description provided for @roleDayCustomer1.
  ///
  /// In de, this message translates to:
  /// **'Eine Frage im öffentlichen Bereich stellen.'**
  String get roleDayCustomer1;

  /// No description provided for @roleDayCustomer2.
  ///
  /// In de, this message translates to:
  /// **'Antwort mit Quellen lesen und freigegebene Dokumente öffnen.'**
  String get roleDayCustomer2;

  /// No description provided for @roleDayCustomer3.
  ///
  /// In de, this message translates to:
  /// **'Bei Bedarf Kontakt aufnehmen – keine internen Daten sichtbar.'**
  String get roleDayCustomer3;

  /// No description provided for @navKnowledgeImprovement.
  ///
  /// In de, this message translates to:
  /// **'Lernkreislauf'**
  String get navKnowledgeImprovement;

  /// No description provided for @kiTitle.
  ///
  /// In de, this message translates to:
  /// **'Knowledge Improvement'**
  String get kiTitle;

  /// No description provided for @kiIntro.
  ///
  /// In de, this message translates to:
  /// **'So wird BusinessBrain mit jeder Frage besser: der Wissens-Lernkreislauf in sieben Schritten.'**
  String get kiIntro;

  /// No description provided for @kiTrustNotice.
  ///
  /// In de, this message translates to:
  /// **'Illustrative Demo – kein Live-KI-Aufruf, keine Speicherung. Das Prinzip in 30 Sekunden.'**
  String get kiTrustNotice;

  /// No description provided for @kiStart.
  ///
  /// In de, this message translates to:
  /// **'Start'**
  String get kiStart;

  /// No description provided for @kiNext.
  ///
  /// In de, this message translates to:
  /// **'Weiter'**
  String get kiNext;

  /// No description provided for @kiRestart.
  ///
  /// In de, this message translates to:
  /// **'Neu starten'**
  String get kiRestart;

  /// No description provided for @kiStep.
  ///
  /// In de, this message translates to:
  /// **'Schritt'**
  String get kiStep;

  /// No description provided for @kiStage1Title.
  ///
  /// In de, this message translates to:
  /// **'Kundenfrage'**
  String get kiStage1Title;

  /// No description provided for @kiStage1Body.
  ///
  /// In de, this message translates to:
  /// **'Ein Kunde stellt eine konkrete Frage.'**
  String get kiStage1Body;

  /// No description provided for @kiStage2Title.
  ///
  /// In de, this message translates to:
  /// **'KI-Antwort'**
  String get kiStage2Title;

  /// No description provided for @kiStage2Body.
  ///
  /// In de, this message translates to:
  /// **'Die KI antwortet ausschließlich aus der freigegebenen Wissensbasis.'**
  String get kiStage2Body;

  /// No description provided for @kiStage3Title.
  ///
  /// In de, this message translates to:
  /// **'Wissenslücke erkannt'**
  String get kiStage3Title;

  /// No description provided for @kiStage3Body.
  ///
  /// In de, this message translates to:
  /// **'Fehlt Wissen, bleibt die KI ehrlich und markiert die Lücke.'**
  String get kiStage3Body;

  /// No description provided for @kiStage4Title.
  ///
  /// In de, this message translates to:
  /// **'Verbesserungsvorschlag'**
  String get kiStage4Title;

  /// No description provided for @kiStage4Body.
  ///
  /// In de, this message translates to:
  /// **'BusinessBrain schlägt automatisch einen passenden Wissenseintrag vor.'**
  String get kiStage4Body;

  /// No description provided for @kiStage5Title.
  ///
  /// In de, this message translates to:
  /// **'Mitarbeiter übernimmt'**
  String get kiStage5Title;

  /// No description provided for @kiStage5Body.
  ///
  /// In de, this message translates to:
  /// **'Ein Mensch prüft und übernimmt die Ergänzung – nichts wird automatisch gespeichert.'**
  String get kiStage5Body;

  /// No description provided for @kiStage6Title.
  ///
  /// In de, this message translates to:
  /// **'Wissensbasis wächst'**
  String get kiStage6Title;

  /// No description provided for @kiStage6Body.
  ///
  /// In de, this message translates to:
  /// **'Der neue Eintrag wird Teil der einen Wissensbasis.'**
  String get kiStage6Body;

  /// No description provided for @kiStage7Title.
  ///
  /// In de, this message translates to:
  /// **'Alle Antworten profitieren'**
  String get kiStage7Title;

  /// No description provided for @kiStage7Body.
  ///
  /// In de, this message translates to:
  /// **'Dieselbe Frage wird künftig präzise und belegt beantwortet.'**
  String get kiStage7Body;

  /// No description provided for @kiQuestion.
  ///
  /// In de, this message translates to:
  /// **'Wie verbinde ich mein Gerät über Bluetooth?'**
  String get kiQuestion;

  /// No description provided for @kiGapAnswer.
  ///
  /// In de, this message translates to:
  /// **'Dazu liegen aktuell noch nicht genügend Informationen in der Wissensbasis vor.'**
  String get kiGapAnswer;

  /// No description provided for @kiSuggestionTitle.
  ///
  /// In de, this message translates to:
  /// **'Gerät über Bluetooth verbinden'**
  String get kiSuggestionTitle;

  /// No description provided for @kiSuggestionContent.
  ///
  /// In de, this message translates to:
  /// **'Bluetooth aktivieren und das Gerät in der App auswählen, um die Verbindung herzustellen.'**
  String get kiSuggestionContent;

  /// No description provided for @kiImprovedAnswer.
  ///
  /// In de, this message translates to:
  /// **'Aktiviere Bluetooth und wähle dein Gerät in der App aus – anschließend ist die Verbindung hergestellt.'**
  String get kiImprovedAnswer;

  /// No description provided for @kiKbCountLabel.
  ///
  /// In de, this message translates to:
  /// **'Wissenseinträge'**
  String get kiKbCountLabel;

  /// No description provided for @kiBeforeLabel.
  ///
  /// In de, this message translates to:
  /// **'Vorher'**
  String get kiBeforeLabel;

  /// No description provided for @kiAfterLabel.
  ///
  /// In de, this message translates to:
  /// **'Nachher'**
  String get kiAfterLabel;

  /// No description provided for @kiAhaTitle.
  ///
  /// In de, this message translates to:
  /// **'Der Aha-Moment'**
  String get kiAhaTitle;

  /// No description provided for @kiAhaBody.
  ///
  /// In de, this message translates to:
  /// **'Aus einer Wissenslücke wird dauerhaftes Wissen – jede zukünftige Antwort profitiert.'**
  String get kiAhaBody;

  /// No description provided for @kiSourceLabel.
  ///
  /// In de, this message translates to:
  /// **'Quelle'**
  String get kiSourceLabel;

  /// No description provided for @navGuidedDemo.
  ///
  /// In de, this message translates to:
  /// **'Geführte Demo'**
  String get navGuidedDemo;

  /// No description provided for @gdStart.
  ///
  /// In de, this message translates to:
  /// **'Demo starten'**
  String get gdStart;

  /// No description provided for @gdBack.
  ///
  /// In de, this message translates to:
  /// **'Zurück'**
  String get gdBack;

  /// No description provided for @gdNext.
  ///
  /// In de, this message translates to:
  /// **'Weiter'**
  String get gdNext;

  /// No description provided for @gdWelcomeStatement.
  ///
  /// In de, this message translates to:
  /// **'BusinessBrain ist das digitale Wissenszentrum eines Unternehmens.'**
  String get gdWelcomeStatement;

  /// No description provided for @gdWelcomeSubtitle.
  ///
  /// In de, this message translates to:
  /// **'In zwei Minuten durch den gesamten Workflow – vom Firmenwissen bis zur lernenden Antwort.'**
  String get gdWelcomeSubtitle;

  /// No description provided for @gdStep1Title.
  ///
  /// In de, this message translates to:
  /// **'Willkommen'**
  String get gdStep1Title;

  /// No description provided for @gdStep2Title.
  ///
  /// In de, this message translates to:
  /// **'Wissen aufbauen'**
  String get gdStep2Title;

  /// No description provided for @gdStep3Title.
  ///
  /// In de, this message translates to:
  /// **'Grounded Antwort'**
  String get gdStep3Title;

  /// No description provided for @gdStep4Title.
  ///
  /// In de, this message translates to:
  /// **'Wissenslücke'**
  String get gdStep4Title;

  /// No description provided for @gdStep5Title.
  ///
  /// In de, this message translates to:
  /// **'Verbesserung & Kontrolle'**
  String get gdStep5Title;

  /// No description provided for @gdStep6Title.
  ///
  /// In de, this message translates to:
  /// **'Lernkreislauf'**
  String get gdStep6Title;

  /// No description provided for @gdStep7Title.
  ///
  /// In de, this message translates to:
  /// **'Fazit'**
  String get gdStep7Title;

  /// No description provided for @gdNarr2.
  ///
  /// In de, this message translates to:
  /// **'Aus unstrukturiertem Text entsteht automatisch strukturiertes Firmenwissen – nichts wird ohne Prüfung gespeichert.'**
  String get gdNarr2;

  /// No description provided for @gdNarr3.
  ///
  /// In de, this message translates to:
  /// **'BusinessBrain beantwortet Fragen ausschließlich aus dem freigegebenen Firmenwissen und zeigt die Quellen – es erfindet nichts.'**
  String get gdNarr3;

  /// No description provided for @gdNarr4.
  ///
  /// In de, this message translates to:
  /// **'Fehlt Wissen, bleibt BusinessBrain ehrlich und markiert die Lücke, statt zu halluzinieren.'**
  String get gdNarr4;

  /// No description provided for @gdNarr5.
  ///
  /// In de, this message translates to:
  /// **'BusinessBrain schlägt eine Ergänzung vor. Ein Mitarbeiter entscheidet – nichts wird automatisch übernommen.'**
  String get gdNarr5;

  /// No description provided for @gdNarr6.
  ///
  /// In de, this message translates to:
  /// **'Der komplette Kreislauf auf einen Blick: bestätigtes Wissen verbessert alle zukünftigen Antworten.'**
  String get gdNarr6;

  /// No description provided for @gdLoopTitle.
  ///
  /// In de, this message translates to:
  /// **'Der Lernkreislauf'**
  String get gdLoopTitle;

  /// No description provided for @gdLoop1.
  ///
  /// In de, this message translates to:
  /// **'Firmenwissen'**
  String get gdLoop1;

  /// No description provided for @gdLoop2.
  ///
  /// In de, this message translates to:
  /// **'Kundenfragen beantworten'**
  String get gdLoop2;

  /// No description provided for @gdLoop3.
  ///
  /// In de, this message translates to:
  /// **'Neue Fragen entstehen'**
  String get gdLoop3;

  /// No description provided for @gdLoop4.
  ///
  /// In de, this message translates to:
  /// **'Wissenslücken erkannt'**
  String get gdLoop4;

  /// No description provided for @gdLoop5.
  ///
  /// In de, this message translates to:
  /// **'Verbesserungsvorschläge'**
  String get gdLoop5;

  /// No description provided for @gdLoop6.
  ///
  /// In de, this message translates to:
  /// **'Mitarbeiter entscheidet'**
  String get gdLoop6;

  /// No description provided for @gdLoop7.
  ///
  /// In de, this message translates to:
  /// **'Wissensbasis wächst'**
  String get gdLoop7;

  /// No description provided for @gdLoop8.
  ///
  /// In de, this message translates to:
  /// **'Bessere Antworten'**
  String get gdLoop8;

  /// No description provided for @gdClosingTitle.
  ///
  /// In de, this message translates to:
  /// **'BusinessBrain lernt nicht durch Halluzinationen.'**
  String get gdClosingTitle;

  /// No description provided for @gdClosingLine1.
  ///
  /// In de, this message translates to:
  /// **'Das Unternehmen behält jederzeit die Kontrolle.'**
  String get gdClosingLine1;

  /// No description provided for @gdClosingLine2.
  ///
  /// In de, this message translates to:
  /// **'Jede bestätigte Ergänzung verbessert alle zukünftigen Antworten.'**
  String get gdClosingLine2;

  /// No description provided for @navBusinessStory.
  ///
  /// In de, this message translates to:
  /// **'Business Story'**
  String get navBusinessStory;

  /// No description provided for @bsTitle.
  ///
  /// In de, this message translates to:
  /// **'BusinessBrain für Unternehmen'**
  String get bsTitle;

  /// No description provided for @bsSubtitle.
  ///
  /// In de, this message translates to:
  /// **'In zwei Minuten: welches Problem wir lösen, warum das kein gewöhnlicher KI-Chat ist und welcher Nutzen für Unternehmen entsteht.'**
  String get bsSubtitle;

  /// No description provided for @bsProblemTitle.
  ///
  /// In de, this message translates to:
  /// **'Das Problem'**
  String get bsProblemTitle;

  /// No description provided for @bsProblemBody.
  ///
  /// In de, this message translates to:
  /// **'Viele Unternehmen besitzen enormes Wissen – verteilt auf PDFs, E-Mails, Webseiten, Mitarbeiter, Handbücher und Support-Anfragen. Dadurch gehen Zeit, Wissen und Qualität verloren.'**
  String get bsProblemBody;

  /// No description provided for @bsSolutionTitle.
  ///
  /// In de, this message translates to:
  /// **'Die Lösung'**
  String get bsSolutionTitle;

  /// No description provided for @bsSolutionBody.
  ///
  /// In de, this message translates to:
  /// **'BusinessBrain bündelt dieses Wissen in einer zentralen Wissensbasis. Die KI beantwortet Fragen ausschließlich auf Basis dieses Wissens und zeigt ihre Quellen. Fehlendes Wissen wird erkannt und als Verbesserungsvorschlag vorbereitet – Mitarbeiter entscheiden jederzeit selbst, was übernommen wird.'**
  String get bsSolutionBody;

  /// No description provided for @bsCycleTitle.
  ///
  /// In de, this message translates to:
  /// **'Der Kreislauf'**
  String get bsCycleTitle;

  /// No description provided for @bsBenefitsTitle.
  ///
  /// In de, this message translates to:
  /// **'Der Nutzen für Unternehmen'**
  String get bsBenefitsTitle;

  /// No description provided for @bsBenefit1Title.
  ///
  /// In de, this message translates to:
  /// **'Schnellerer Kundensupport'**
  String get bsBenefit1Title;

  /// No description provided for @bsBenefit1Body.
  ///
  /// In de, this message translates to:
  /// **'Antworten kommen direkt aus dem freigegebenen Firmenwissen.'**
  String get bsBenefit1Body;

  /// No description provided for @bsBenefit2Title.
  ///
  /// In de, this message translates to:
  /// **'Einheitliche Antworten'**
  String get bsBenefit2Title;

  /// No description provided for @bsBenefit2Body.
  ///
  /// In de, this message translates to:
  /// **'Alle greifen auf dieselbe Wissensbasis zu.'**
  String get bsBenefit2Body;

  /// No description provided for @bsBenefit3Title.
  ///
  /// In de, this message translates to:
  /// **'Zentrale Wissensbasis'**
  String get bsBenefit3Title;

  /// No description provided for @bsBenefit3Body.
  ///
  /// In de, this message translates to:
  /// **'Eine Quelle der Wahrheit statt verstreuter Dokumente.'**
  String get bsBenefit3Body;

  /// No description provided for @bsBenefit4Title.
  ///
  /// In de, this message translates to:
  /// **'Entlastung der Mitarbeiter'**
  String get bsBenefit4Title;

  /// No description provided for @bsBenefit4Body.
  ///
  /// In de, this message translates to:
  /// **'Wiederkehrende Fragen werden zuverlässig beantwortet.'**
  String get bsBenefit4Body;

  /// No description provided for @bsBenefit5Title.
  ///
  /// In de, this message translates to:
  /// **'Kontinuierliche Verbesserung'**
  String get bsBenefit5Title;

  /// No description provided for @bsBenefit5Body.
  ///
  /// In de, this message translates to:
  /// **'Bestätigtes Wissen verbessert alle zukünftigen Antworten.'**
  String get bsBenefit5Body;

  /// No description provided for @bsBenefit6Title.
  ///
  /// In de, this message translates to:
  /// **'Transparente Quellen'**
  String get bsBenefit6Title;

  /// No description provided for @bsBenefit6Body.
  ///
  /// In de, this message translates to:
  /// **'Jede Antwort zeigt die verwendeten Wissenseinträge.'**
  String get bsBenefit6Body;

  /// No description provided for @bsBenefit7Title.
  ///
  /// In de, this message translates to:
  /// **'Keine Halluzinationen'**
  String get bsBenefit7Title;

  /// No description provided for @bsBenefit7Body.
  ///
  /// In de, this message translates to:
  /// **'Es wird nur belegtes Firmenwissen verwendet.'**
  String get bsBenefit7Body;

  /// No description provided for @bsBenefit8Title.
  ///
  /// In de, this message translates to:
  /// **'Mensch behält die Kontrolle'**
  String get bsBenefit8Title;

  /// No description provided for @bsBenefit8Body.
  ///
  /// In de, this message translates to:
  /// **'Nichts wird automatisch veröffentlicht oder gespeichert.'**
  String get bsBenefit8Body;

  /// No description provided for @bsContrastTitle.
  ///
  /// In de, this message translates to:
  /// **'Bewusst mit Grenzen'**
  String get bsContrastTitle;

  /// No description provided for @bsNotTitle.
  ///
  /// In de, this message translates to:
  /// **'Was BusinessBrain bewusst nicht macht'**
  String get bsNotTitle;

  /// No description provided for @bsDoesTitle.
  ///
  /// In de, this message translates to:
  /// **'Was BusinessBrain tut'**
  String get bsDoesTitle;

  /// No description provided for @bsNot1.
  ///
  /// In de, this message translates to:
  /// **'Erfindet keine Fakten'**
  String get bsNot1;

  /// No description provided for @bsNot2.
  ///
  /// In de, this message translates to:
  /// **'Veröffentlicht nichts automatisch'**
  String get bsNot2;

  /// No description provided for @bsNot3.
  ///
  /// In de, this message translates to:
  /// **'Ersetzt keine Mitarbeiter'**
  String get bsNot3;

  /// No description provided for @bsNot4.
  ///
  /// In de, this message translates to:
  /// **'Entscheidet nichts selbstständig'**
  String get bsNot4;

  /// No description provided for @bsDoes1.
  ///
  /// In de, this message translates to:
  /// **'Unterstützt Mitarbeiter'**
  String get bsDoes1;

  /// No description provided for @bsDoes2.
  ///
  /// In de, this message translates to:
  /// **'Erkennt Wissenslücken'**
  String get bsDoes2;

  /// No description provided for @bsDoes3.
  ///
  /// In de, this message translates to:
  /// **'Erstellt Verbesserungsvorschläge'**
  String get bsDoes3;

  /// No description provided for @bsDoes4.
  ///
  /// In de, this message translates to:
  /// **'Lernt durch bestätigtes Firmenwissen'**
  String get bsDoes4;

  /// No description provided for @bsVisionTitle.
  ///
  /// In de, this message translates to:
  /// **'Vision'**
  String get bsVisionTitle;

  /// No description provided for @bsVisionBadge.
  ///
  /// In de, this message translates to:
  /// **'Zukünftige Entwicklung'**
  String get bsVisionBadge;

  /// No description provided for @bsVision1.
  ///
  /// In de, this message translates to:
  /// **'Autonome Research-Agenten'**
  String get bsVision1;

  /// No description provided for @bsVision2.
  ///
  /// In de, this message translates to:
  /// **'Wettbewerbsanalyse'**
  String get bsVision2;

  /// No description provided for @bsVision3.
  ///
  /// In de, this message translates to:
  /// **'Sichtbarkeitsüberwachung'**
  String get bsVision3;

  /// No description provided for @bsVision4.
  ///
  /// In de, this message translates to:
  /// **'Morning Briefings'**
  String get bsVision4;

  /// No description provided for @bsVision5.
  ///
  /// In de, this message translates to:
  /// **'Trendanalysen'**
  String get bsVision5;

  /// No description provided for @bsVision6.
  ///
  /// In de, this message translates to:
  /// **'Strategische Handlungsempfehlungen'**
  String get bsVision6;

  /// No description provided for @bsVision7.
  ///
  /// In de, this message translates to:
  /// **'Intelligente Aufgabenverteilung'**
  String get bsVision7;

  /// No description provided for @bsVision8.
  ///
  /// In de, this message translates to:
  /// **'Kontinuierliche Unternehmensbeobachtung'**
  String get bsVision8;

  /// No description provided for @bsClosingTitle.
  ///
  /// In de, this message translates to:
  /// **'BusinessBrain entwickelt sich vom Wissenssystem zum digitalen Unternehmensgehirn.'**
  String get bsClosingTitle;

  /// No description provided for @bsClosingBody.
  ///
  /// In de, this message translates to:
  /// **'Heute unterstützt BusinessBrain Unternehmen dabei, ihr Wissen effizient zu organisieren, Kundenfragen zuverlässig zu beantworten und Wissenslücken sichtbar zu machen. Zukünftig soll die Plattform Unternehmen zusätzlich aktiv unterstützen, Entwicklungen beobachten, Chancen erkennen und strategische Empfehlungen liefern.'**
  String get bsClosingBody;

  /// No description provided for @bsStatusTitle.
  ///
  /// In de, this message translates to:
  /// **'Status-Übersicht'**
  String get bsStatusTitle;

  /// No description provided for @bsStatusIntro.
  ///
  /// In de, this message translates to:
  /// **'Transparente Zuordnung: Was ist heute real, was ist in Arbeit, was ist Vision?'**
  String get bsStatusIntro;

  /// No description provided for @bsStatusAvailable.
  ///
  /// In de, this message translates to:
  /// **'Bereits verfügbar'**
  String get bsStatusAvailable;

  /// No description provided for @bsStatusInDev.
  ///
  /// In de, this message translates to:
  /// **'In Entwicklung'**
  String get bsStatusInDev;

  /// No description provided for @bsStatusVision.
  ///
  /// In de, this message translates to:
  /// **'Langfristige Vision'**
  String get bsStatusVision;

  /// No description provided for @bsFeatKnowledgeBase.
  ///
  /// In de, this message translates to:
  /// **'Zentrale Wissensbasis'**
  String get bsFeatKnowledgeBase;

  /// No description provided for @bsFeatGrounded.
  ///
  /// In de, this message translates to:
  /// **'Grounded KI-Assistent mit Quellen'**
  String get bsFeatGrounded;

  /// No description provided for @bsFeatGapDetection.
  ///
  /// In de, this message translates to:
  /// **'Wissenslücken-Erkennung'**
  String get bsFeatGapDetection;

  /// No description provided for @bsFeatBuilder.
  ///
  /// In de, this message translates to:
  /// **'AI Knowledge Builder (Import)'**
  String get bsFeatBuilder;

  /// No description provided for @bsFeatSuggestions.
  ///
  /// In de, this message translates to:
  /// **'Verbesserungsvorschläge (Mensch entscheidet)'**
  String get bsFeatSuggestions;

  /// No description provided for @bsFeatLoop.
  ///
  /// In de, this message translates to:
  /// **'Lernkreislauf-Visualisierung'**
  String get bsFeatLoop;

  /// No description provided for @bsFeatEvolution.
  ///
  /// In de, this message translates to:
  /// **'Company Evolution (Demo-Daten)'**
  String get bsFeatEvolution;

  /// No description provided for @bsFeatPortals.
  ///
  /// In de, this message translates to:
  /// **'Rollen & Portale (Vorschau)'**
  String get bsFeatPortals;

  /// No description provided for @bsFeatI18n.
  ///
  /// In de, this message translates to:
  /// **'Zweisprachig (DE/EN)'**
  String get bsFeatI18n;

  /// No description provided for @bsFeatLiveGemini.
  ///
  /// In de, this message translates to:
  /// **'Live-Gemini in Produktion (in Härtung)'**
  String get bsFeatLiveGemini;

  /// No description provided for @bsFeatRoleEnforcement.
  ///
  /// In de, this message translates to:
  /// **'Rollen-Durchsetzung & Login-Guards'**
  String get bsFeatRoleEnforcement;

  /// No description provided for @bsFeatResearchLive.
  ///
  /// In de, this message translates to:
  /// **'Live-Recherche-Pipeline mit echten Quellen'**
  String get bsFeatResearchLive;

  /// No description provided for @bsFeatCommunity.
  ///
  /// In de, this message translates to:
  /// **'Community-Radar (read-only Demo)'**
  String get bsFeatCommunity;

  /// No description provided for @navOperations.
  ///
  /// In de, this message translates to:
  /// **'Operations'**
  String get navOperations;

  /// No description provided for @opTitle.
  ///
  /// In de, this message translates to:
  /// **'AI Operations Center'**
  String get opTitle;

  /// No description provided for @opSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Auf einen Blick: wie BusinessBrain Wissen nutzbar macht, Lücken sichtbar macht und Mitarbeiter im Tagesgeschäft unterstützt.'**
  String get opSubtitle;

  /// No description provided for @opDemoBadge.
  ///
  /// In de, this message translates to:
  /// **'DEMO'**
  String get opDemoBadge;

  /// No description provided for @opDemoNoticeTitle.
  ///
  /// In de, this message translates to:
  /// **'Transparente Demonstrationsdaten'**
  String get opDemoNoticeTitle;

  /// No description provided for @opDemoNoticeBody.
  ///
  /// In de, this message translates to:
  /// **'Alle Kennzahlen und Verläufe auf dieser Seite sind ein bewusst kleiner, fest definierter Demo-Datensatz. Sie sind keine Live-Messung und kein Leistungsversprechen.'**
  String get opDemoNoticeBody;

  /// No description provided for @opDemoDisabledTitle.
  ///
  /// In de, this message translates to:
  /// **'Demonstrationsdaten sind deaktiviert'**
  String get opDemoDisabledTitle;

  /// No description provided for @opDemoDisabledBody.
  ///
  /// In de, this message translates to:
  /// **'Ohne Demo-Modus zeigt das Operations Center keine Beispielkennzahlen. Dadurch werden Demo-Werte niemals mit echten Unternehmensdaten verwechselt.'**
  String get opDemoDisabledBody;

  /// No description provided for @opActivityTitle.
  ///
  /// In de, this message translates to:
  /// **'Aktivität heute'**
  String get opActivityTitle;

  /// No description provided for @opActivitySubtitle.
  ///
  /// In de, this message translates to:
  /// **'Der aktuelle Arbeitstag im nachvollziehbaren Demo-Betrieb.'**
  String get opActivitySubtitle;

  /// No description provided for @opMetricReviews.
  ///
  /// In de, this message translates to:
  /// **'Human Reviews'**
  String get opMetricReviews;

  /// No description provided for @opMetricRedirects.
  ///
  /// In de, this message translates to:
  /// **'Website-Weiterleitungen'**
  String get opMetricRedirects;

  /// No description provided for @opMetricDocumentsAnalyzed.
  ///
  /// In de, this message translates to:
  /// **'Dokumente analysiert'**
  String get opMetricDocumentsAnalyzed;

  /// No description provided for @opMetricAvgResponseTime.
  ///
  /// In de, this message translates to:
  /// **'Ø Antwortzeit'**
  String get opMetricAvgResponseTime;

  /// No description provided for @opSecondsShort.
  ///
  /// In de, this message translates to:
  /// **'Sek.'**
  String get opSecondsShort;

  /// No description provided for @opHistoryTitle.
  ///
  /// In de, this message translates to:
  /// **'Betriebsverlauf'**
  String get opHistoryTitle;

  /// No description provided for @opHistorySubtitle.
  ///
  /// In de, this message translates to:
  /// **'Zwei ruhige Verläufe aus demselben fest definierten Demo-Datensatz.'**
  String get opHistorySubtitle;

  /// No description provided for @opPeriod7.
  ///
  /// In de, this message translates to:
  /// **'7 Tage'**
  String get opPeriod7;

  /// No description provided for @opPeriod30.
  ///
  /// In de, this message translates to:
  /// **'30 Tage'**
  String get opPeriod30;

  /// No description provided for @opHistoryAnswersTitle.
  ///
  /// In de, this message translates to:
  /// **'Antworten und Wissenslücken'**
  String get opHistoryAnswersTitle;

  /// No description provided for @opHistoryKnowledgeTitle.
  ///
  /// In de, this message translates to:
  /// **'Wissenswachstum und Weiterleitungen'**
  String get opHistoryKnowledgeTitle;

  /// No description provided for @opHistoryAnswered.
  ///
  /// In de, this message translates to:
  /// **'Beantwortet'**
  String get opHistoryAnswered;

  /// No description provided for @opHistoryGaps.
  ///
  /// In de, this message translates to:
  /// **'Lücken'**
  String get opHistoryGaps;

  /// No description provided for @opHistoryEntries.
  ///
  /// In de, this message translates to:
  /// **'Neue Einträge'**
  String get opHistoryEntries;

  /// No description provided for @opHistoryRedirects.
  ///
  /// In de, this message translates to:
  /// **'Weiterleitungen'**
  String get opHistoryRedirects;

  /// No description provided for @opHistoryToday.
  ///
  /// In de, this message translates to:
  /// **'Heute'**
  String get opHistoryToday;

  /// No description provided for @opGrowthTitle.
  ///
  /// In de, this message translates to:
  /// **'Wissenswachstum'**
  String get opGrowthTitle;

  /// No description provided for @opGrowthSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Struktur der bestätigten Demo-Wissensbasis und heutige Ergänzungen.'**
  String get opGrowthSubtitle;

  /// No description provided for @opGrowthConfirmed.
  ///
  /// In de, this message translates to:
  /// **'Bestätigte Wissenseinträge'**
  String get opGrowthConfirmed;

  /// No description provided for @opGrowthFaq.
  ///
  /// In de, this message translates to:
  /// **'Neue FAQ heute'**
  String get opGrowthFaq;

  /// No description provided for @opGrowthProduct.
  ///
  /// In de, this message translates to:
  /// **'Produktwissen'**
  String get opGrowthProduct;

  /// No description provided for @opGrowthSupport.
  ///
  /// In de, this message translates to:
  /// **'Supportwissen'**
  String get opGrowthSupport;

  /// No description provided for @opGrowthDocuments.
  ///
  /// In de, this message translates to:
  /// **'Dokumente'**
  String get opGrowthDocuments;

  /// No description provided for @opGrowthTags.
  ///
  /// In de, this message translates to:
  /// **'Schlagwörter'**
  String get opGrowthTags;

  /// No description provided for @opCustomerTitle.
  ///
  /// In de, this message translates to:
  /// **'Kundenerkenntnisse'**
  String get opCustomerTitle;

  /// No description provided for @opCustomerSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Wiederkehrende Muster aus vorhandenen Demo-Fragen und Supportfällen.'**
  String get opCustomerSubtitle;

  /// No description provided for @opCustomerQuestions.
  ///
  /// In de, this message translates to:
  /// **'Häufigste Fragen'**
  String get opCustomerQuestions;

  /// No description provided for @opCustomerProducts.
  ///
  /// In de, this message translates to:
  /// **'Häufigste Produkte'**
  String get opCustomerProducts;

  /// No description provided for @opCustomerGaps.
  ///
  /// In de, this message translates to:
  /// **'Offene Wissenslücken'**
  String get opCustomerGaps;

  /// No description provided for @opCustomerTopics.
  ///
  /// In de, this message translates to:
  /// **'Meistgesuchte Themen'**
  String get opCustomerTopics;

  /// No description provided for @opCustomerSupport.
  ///
  /// In de, this message translates to:
  /// **'Wiederkehrende Supportprobleme'**
  String get opCustomerSupport;

  /// No description provided for @opItemCurebaseUsage.
  ///
  /// In de, this message translates to:
  /// **'Wie funktioniert CureBase?'**
  String get opItemCurebaseUsage;

  /// No description provided for @opItemAppConnection.
  ///
  /// In de, this message translates to:
  /// **'Wie verbinde ich die App?'**
  String get opItemAppConnection;

  /// No description provided for @opItemPricing.
  ///
  /// In de, this message translates to:
  /// **'Was kostet das System?'**
  String get opItemPricing;

  /// No description provided for @opItemPriceDetails.
  ///
  /// In de, this message translates to:
  /// **'Aktuelle Preisdetails'**
  String get opItemPriceDetails;

  /// No description provided for @opItemFirmwareHelp.
  ///
  /// In de, this message translates to:
  /// **'Firmware-Fehlerbehebung'**
  String get opItemFirmwareHelp;

  /// No description provided for @opItemCompatibility.
  ///
  /// In de, this message translates to:
  /// **'Gerätekompatibilität'**
  String get opItemCompatibility;

  /// No description provided for @opItemPrograms.
  ///
  /// In de, this message translates to:
  /// **'Programme'**
  String get opItemPrograms;

  /// No description provided for @opItemBluetoothConnection.
  ///
  /// In de, this message translates to:
  /// **'Bluetooth-Verbindung'**
  String get opItemBluetoothConnection;

  /// No description provided for @opItemFirmwareUpdate.
  ///
  /// In de, this message translates to:
  /// **'Firmware-Update'**
  String get opItemFirmwareUpdate;

  /// No description provided for @opItemAppPairing.
  ///
  /// In de, this message translates to:
  /// **'App-Kopplung'**
  String get opItemAppPairing;

  /// No description provided for @opImpactTitle.
  ///
  /// In de, this message translates to:
  /// **'Geschäftlicher Nutzen'**
  String get opImpactTitle;

  /// No description provided for @opImpactSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Vorsichtige, transparent berechnete Demo-Indikatoren – keine Umsatz- oder Erfolgsversprechen.'**
  String get opImpactSubtitle;

  /// No description provided for @opImpactTimeSaved.
  ///
  /// In de, this message translates to:
  /// **'Geschätzte Zeitersparnis'**
  String get opImpactTimeSaved;

  /// No description provided for @opImpactAvoidedSupport.
  ///
  /// In de, this message translates to:
  /// **'Potenziell vermiedene Supportanfragen'**
  String get opImpactAvoidedSupport;

  /// No description provided for @opImpactConsistent.
  ///
  /// In de, this message translates to:
  /// **'Konsistente Antworten'**
  String get opImpactConsistent;

  /// No description provided for @opImpactSources.
  ///
  /// In de, this message translates to:
  /// **'Genutzte Quellen'**
  String get opImpactSources;

  /// No description provided for @opImpactReviewRate.
  ///
  /// In de, this message translates to:
  /// **'Abgeschlossene Human-Review-Quote'**
  String get opImpactReviewRate;

  /// No description provided for @opImpactMethodNote.
  ///
  /// In de, this message translates to:
  /// **'Demo-Berechnung: sieben Minuten potenzielle Bearbeitungszeit je beantworteter Frage; vermiedene Supportanfragen werden konservativ mit zwei Dritteln der beantworteten Fragen geschätzt.'**
  String get opImpactMethodNote;

  /// No description provided for @opHoursMinutes.
  ///
  /// In de, this message translates to:
  /// **'{hours} Std. {minutes} Min.'**
  String opHoursMinutes(int hours, int minutes);

  /// No description provided for @opKnowledgeQualityTitle.
  ///
  /// In de, this message translates to:
  /// **'Wissensqualität'**
  String get opKnowledgeQualityTitle;

  /// No description provided for @opKnowledgeQualitySubtitle.
  ///
  /// In de, this message translates to:
  /// **'Wie vollständig die heutigen Demo-Fragen mit bestätigtem Wissen bearbeitbar sind.'**
  String get opKnowledgeQualitySubtitle;

  /// No description provided for @opQualityFull.
  ///
  /// In de, this message translates to:
  /// **'Vollständig beantwortbar'**
  String get opQualityFull;

  /// No description provided for @opQualityPartial.
  ///
  /// In de, this message translates to:
  /// **'Teilweise beantwortbar'**
  String get opQualityPartial;

  /// No description provided for @opQualityMissing.
  ///
  /// In de, this message translates to:
  /// **'Keine Information'**
  String get opQualityMissing;

  /// No description provided for @opQualitySensitive.
  ///
  /// In de, this message translates to:
  /// **'Medizinisch sensible Fragen'**
  String get opQualitySensitive;

  /// No description provided for @opQualityRedirects.
  ///
  /// In de, this message translates to:
  /// **'Weiterleitungen'**
  String get opQualityRedirects;

  /// No description provided for @opInsightsTitle.
  ///
  /// In de, this message translates to:
  /// **'Geschäftliche Erkenntnisse'**
  String get opInsightsTitle;

  /// No description provided for @opInsightsSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Deterministische Hinweise aus den sichtbaren Demo-Zahlen – ohne KI- oder LLM-Auswertung.'**
  String get opInsightsSubtitle;

  /// No description provided for @opInsightsMethodNote.
  ///
  /// In de, this message translates to:
  /// **'Diese Hinweise entstehen aus festen, prüfbaren Regeln über dem Demo-Datensatz. BusinessBrain entscheidet oder veröffentlicht nichts selbst.'**
  String get opInsightsMethodNote;

  /// No description provided for @opInsightLeadingTitle.
  ///
  /// In de, this message translates to:
  /// **'CureBase steht im Mittelpunkt'**
  String get opInsightLeadingTitle;

  /// No description provided for @opInsightLeadingBody.
  ///
  /// In de, this message translates to:
  /// **'CureBase ist mit {count} Nennungen das am häufigsten gefragte Produkt im Demo-Zeitraum.'**
  String opInsightLeadingBody(int count);

  /// No description provided for @opInsightSupportTitle.
  ///
  /// In de, this message translates to:
  /// **'Supportfragen nehmen zu'**
  String get opInsightSupportTitle;

  /// No description provided for @opInsightSupportBody.
  ///
  /// In de, this message translates to:
  /// **'Die letzten sieben Demo-Tage enthalten mehr Supportfragen als die sieben Tage davor. Die Supportdokumentation sollte beobachtet werden.'**
  String get opInsightSupportBody;

  /// No description provided for @opInsightFirmwareTitle.
  ///
  /// In de, this message translates to:
  /// **'Firmware wird häufiger gesucht'**
  String get opInsightFirmwareTitle;

  /// No description provided for @opInsightFirmwareBody.
  ///
  /// In de, this message translates to:
  /// **'Firmware erscheint {count}-mal in den meistgesuchten Demo-Themen. Eine leicht auffindbare Anleitung wäre sinnvoll.'**
  String opInsightFirmwareBody(int count);

  /// No description provided for @opInsightPriceTitle.
  ///
  /// In de, this message translates to:
  /// **'Interesse an Preisen ist sichtbar'**
  String get opInsightPriceTitle;

  /// No description provided for @opInsightPriceBody.
  ///
  /// In de, this message translates to:
  /// **'{count} Demo-Besucher wechselten aus einer Antwort zur Preisübersicht.'**
  String opInsightPriceBody(int count);

  /// No description provided for @opInsightFaqTitle.
  ///
  /// In de, this message translates to:
  /// **'Neue FAQ sind sinnvoll'**
  String get opInsightFaqTitle;

  /// No description provided for @opInsightFaqBody.
  ///
  /// In de, this message translates to:
  /// **'{count} heutige Wissenslücken zeigen konkrete Themen, die nach menschlicher Prüfung als FAQ ergänzt werden könnten.'**
  String opInsightFaqBody(int count);

  /// No description provided for @opTodayTitle.
  ///
  /// In de, this message translates to:
  /// **'BusinessBrain heute'**
  String get opTodayTitle;

  /// No description provided for @opTodayBody.
  ///
  /// In de, this message translates to:
  /// **'Ein Überblick über den heutigen Tag – alle Werte sind Demo-Daten zur Veranschaulichung.'**
  String get opTodayBody;

  /// No description provided for @opMetricQuestions.
  ///
  /// In de, this message translates to:
  /// **'Kundenfragen heute'**
  String get opMetricQuestions;

  /// No description provided for @opMetricAnswered.
  ///
  /// In de, this message translates to:
  /// **'Erfolgreich beantwortet'**
  String get opMetricAnswered;

  /// No description provided for @opMetricGaps.
  ///
  /// In de, this message translates to:
  /// **'Neue Wissenslücken erkannt'**
  String get opMetricGaps;

  /// No description provided for @opMetricSuggestions.
  ///
  /// In de, this message translates to:
  /// **'Verbesserungsvorschläge erstellt'**
  String get opMetricSuggestions;

  /// No description provided for @opMetricSources.
  ///
  /// In de, this message translates to:
  /// **'Quellen genutzt'**
  String get opMetricSources;

  /// No description provided for @opMetricEntriesAdopted.
  ///
  /// In de, this message translates to:
  /// **'Neue Wissenseinträge übernommen'**
  String get opMetricEntriesAdopted;

  /// No description provided for @opTimelineTitle.
  ///
  /// In de, this message translates to:
  /// **'Aktivitäts-Timeline'**
  String get opTimelineTitle;

  /// No description provided for @opTl1.
  ///
  /// In de, this message translates to:
  /// **'Kundenfrage beantwortet'**
  String get opTl1;

  /// No description provided for @opTl2.
  ///
  /// In de, this message translates to:
  /// **'Wissenslücke erkannt'**
  String get opTl2;

  /// No description provided for @opTl3.
  ///
  /// In de, this message translates to:
  /// **'Verbesserungsvorschlag erstellt'**
  String get opTl3;

  /// No description provided for @opTl4.
  ///
  /// In de, this message translates to:
  /// **'Mitarbeiter bestätigt neuen Wissenseintrag'**
  String get opTl4;

  /// No description provided for @opTl5.
  ///
  /// In de, this message translates to:
  /// **'Wissensbasis erweitert'**
  String get opTl5;

  /// No description provided for @opTl6.
  ///
  /// In de, this message translates to:
  /// **'Zukünftige Antworten verbessert'**
  String get opTl6;

  /// No description provided for @opDetectedTitle.
  ///
  /// In de, this message translates to:
  /// **'Heute erkannt'**
  String get opDetectedTitle;

  /// No description provided for @opDetected1.
  ///
  /// In de, this message translates to:
  /// **'Häufig gestellte Frage erkannt'**
  String get opDetected1;

  /// No description provided for @opDetected2.
  ///
  /// In de, this message translates to:
  /// **'Mehrere Kunden fragen nach demselben Thema'**
  String get opDetected2;

  /// No description provided for @opDetected3.
  ///
  /// In de, this message translates to:
  /// **'Neue FAQ empfohlen'**
  String get opDetected3;

  /// No description provided for @opDetected4.
  ///
  /// In de, this message translates to:
  /// **'Bedienungsanleitung empfohlen'**
  String get opDetected4;

  /// No description provided for @opDetected5.
  ///
  /// In de, this message translates to:
  /// **'Technische Voraussetzung fehlt'**
  String get opDetected5;

  /// No description provided for @opDetected6.
  ///
  /// In de, this message translates to:
  /// **'Schritt-für-Schritt-Anleitung empfohlen'**
  String get opDetected6;

  /// No description provided for @opDecisionsTitle.
  ///
  /// In de, this message translates to:
  /// **'Menschliche Entscheidungen'**
  String get opDecisionsTitle;

  /// No description provided for @opDecTotal.
  ///
  /// In de, this message translates to:
  /// **'Vorschläge insgesamt'**
  String get opDecTotal;

  /// No description provided for @opDecAdopted.
  ///
  /// In de, this message translates to:
  /// **'Übernommen'**
  String get opDecAdopted;

  /// No description provided for @opDecInProgress.
  ///
  /// In de, this message translates to:
  /// **'In Bearbeitung'**
  String get opDecInProgress;

  /// No description provided for @opDecRejected.
  ///
  /// In de, this message translates to:
  /// **'Abgelehnt'**
  String get opDecRejected;

  /// No description provided for @opDecisionsNote.
  ///
  /// In de, this message translates to:
  /// **'BusinessBrain trifft keine Entscheidungen selbst – jede Änderung wird von einem Menschen bestätigt.'**
  String get opDecisionsNote;

  /// No description provided for @opQualityTitle.
  ///
  /// In de, this message translates to:
  /// **'Qualität der Wissensbasis'**
  String get opQualityTitle;

  /// No description provided for @opQualEntries.
  ///
  /// In de, this message translates to:
  /// **'Wissenseinträge'**
  String get opQualEntries;

  /// No description provided for @opQualFaq.
  ///
  /// In de, this message translates to:
  /// **'FAQ'**
  String get opQualFaq;

  /// No description provided for @opQualGuides.
  ///
  /// In de, this message translates to:
  /// **'Anleitungen'**
  String get opQualGuides;

  /// No description provided for @opQualTechnical.
  ///
  /// In de, this message translates to:
  /// **'Technische Informationen'**
  String get opQualTechnical;

  /// No description provided for @opQualProblems.
  ///
  /// In de, this message translates to:
  /// **'Problemlösungen'**
  String get opQualProblems;

  /// No description provided for @opQualDefinitions.
  ///
  /// In de, this message translates to:
  /// **'Definitionen'**
  String get opQualDefinitions;

  /// No description provided for @opClosingTitle.
  ///
  /// In de, this message translates to:
  /// **'BusinessBrain macht den Betrieb sichtbar – der Mensch entscheidet.'**
  String get opClosingTitle;

  /// No description provided for @opClosingBody.
  ///
  /// In de, this message translates to:
  /// **'Das Operations Center zeigt Fragen, Wissenslücken, Nutzung und Verbesserungspotenziale. Es trifft keine Unternehmensentscheidungen und verändert kein Wissen automatisch.'**
  String get opClosingBody;

  /// No description provided for @navKnowledgeWorkflow.
  ///
  /// In de, this message translates to:
  /// **'Lern-Workflow'**
  String get navKnowledgeWorkflow;

  /// No description provided for @kwTitle.
  ///
  /// In de, this message translates to:
  /// **'Wissens-Verbesserung – End-to-End'**
  String get kwTitle;

  /// No description provided for @kwIntro.
  ///
  /// In de, this message translates to:
  /// **'Ein echter, reproduzierbarer Lernkreislauf: aus einer Wissenslücke entsteht dauerhaftes Firmenwissen. Verwendet dieselbe Wissensbasis wie der Assistent.'**
  String get kwIntro;

  /// No description provided for @kwQuestion.
  ///
  /// In de, this message translates to:
  /// **'Wie kann ich meine Berichte als CSV-Datei exportieren?'**
  String get kwQuestion;

  /// No description provided for @kwAsk.
  ///
  /// In de, this message translates to:
  /// **'Frage stellen'**
  String get kwAsk;

  /// No description provided for @kwSuggestionTitle.
  ///
  /// In de, this message translates to:
  /// **'Verbesserungsvorschlag (Human Review)'**
  String get kwSuggestionTitle;

  /// No description provided for @kwSuggestedEntryTitle.
  ///
  /// In de, this message translates to:
  /// **'Berichte als CSV exportieren'**
  String get kwSuggestedEntryTitle;

  /// No description provided for @kwSuggestedEntryContent.
  ///
  /// In de, this message translates to:
  /// **'Berichte lassen sich im Menü unter „Export“ als CSV-Datei herunterladen.'**
  String get kwSuggestedEntryContent;

  /// No description provided for @kwAccept.
  ///
  /// In de, this message translates to:
  /// **'Übernehmen'**
  String get kwAccept;

  /// No description provided for @kwReject.
  ///
  /// In de, this message translates to:
  /// **'Ablehnen'**
  String get kwReject;

  /// No description provided for @kwReset.
  ///
  /// In de, this message translates to:
  /// **'Zurücksetzen'**
  String get kwReset;

  /// No description provided for @kwFirstAnswerTitle.
  ///
  /// In de, this message translates to:
  /// **'Erste Antwort'**
  String get kwFirstAnswerTitle;

  /// No description provided for @kwImprovedAnswerTitle.
  ///
  /// In de, this message translates to:
  /// **'Verbesserte Antwort'**
  String get kwImprovedAnswerTitle;

  /// No description provided for @kwImprovedInfo.
  ///
  /// In de, this message translates to:
  /// **'Diese Antwort wurde durch einen neu bestätigten Wissenseintrag verbessert.'**
  String get kwImprovedInfo;

  /// No description provided for @kwRejectedInfo.
  ///
  /// In de, this message translates to:
  /// **'Vorschlag abgelehnt – die Wissensbasis bleibt unverändert, dieselbe Frage liefert weiterhin die ehrliche Wissenslücke.'**
  String get kwRejectedInfo;

  /// No description provided for @kwProcessTitle.
  ///
  /// In de, this message translates to:
  /// **'Prozess'**
  String get kwProcessTitle;

  /// No description provided for @kwStep1.
  ///
  /// In de, this message translates to:
  /// **'Frage gestellt'**
  String get kwStep1;

  /// No description provided for @kwStep2.
  ///
  /// In de, this message translates to:
  /// **'Wissenslücke erkannt'**
  String get kwStep2;

  /// No description provided for @kwStep3.
  ///
  /// In de, this message translates to:
  /// **'Verbesserungsvorschlag erstellt'**
  String get kwStep3;

  /// No description provided for @kwStep4.
  ///
  /// In de, this message translates to:
  /// **'Mitarbeiter bestätigt'**
  String get kwStep4;

  /// No description provided for @kwStep5.
  ///
  /// In de, this message translates to:
  /// **'Wissenseintrag gespeichert'**
  String get kwStep5;

  /// No description provided for @kwStep6.
  ///
  /// In de, this message translates to:
  /// **'Antwort verbessert'**
  String get kwStep6;

  /// No description provided for @kwClosingTitle.
  ///
  /// In de, this message translates to:
  /// **'Der Lernkreislauf wurde erfolgreich abgeschlossen.'**
  String get kwClosingTitle;

  /// No description provided for @kwClosingBody.
  ///
  /// In de, this message translates to:
  /// **'BusinessBrain verbessert seine Antworten ausschließlich durch bestätigtes Unternehmenswissen.'**
  String get kwClosingBody;

  /// No description provided for @navJuryStart.
  ///
  /// In de, this message translates to:
  /// **'Jury-Modus'**
  String get navJuryStart;

  /// No description provided for @navMore.
  ///
  /// In de, this message translates to:
  /// **'Weitere Module'**
  String get navMore;

  /// No description provided for @navReleaseCheck.
  ///
  /// In de, this message translates to:
  /// **'Release-Check'**
  String get navReleaseCheck;

  /// No description provided for @juryNavGroundedAi.
  ///
  /// In de, this message translates to:
  /// **'Grounded AI'**
  String get juryNavGroundedAi;

  /// No description provided for @juryStartTitle.
  ///
  /// In de, this message translates to:
  /// **'Willkommen bei BusinessBrain'**
  String get juryStartTitle;

  /// No description provided for @juryStartIntro.
  ///
  /// In de, this message translates to:
  /// **'Das digitale Wissenszentrum eines Unternehmens. Wählen Sie, wie Sie starten möchten.'**
  String get juryStartIntro;

  /// No description provided for @juryStartGuided.
  ///
  /// In de, this message translates to:
  /// **'Geführte Jury-Demo starten'**
  String get juryStartGuided;

  /// No description provided for @juryStartExplore.
  ///
  /// In de, this message translates to:
  /// **'Plattform frei erkunden'**
  String get juryStartExplore;

  /// No description provided for @juryStartNote.
  ///
  /// In de, this message translates to:
  /// **'Im Jury-Modus zeigt die Navigation nur die wichtigsten Bereiche. Alle weiteren Module bleiben unter „Weitere Module“ erreichbar.'**
  String get juryStartNote;

  /// No description provided for @juryTourTitle.
  ///
  /// In de, this message translates to:
  /// **'Geführte Jury-Demo'**
  String get juryTourTitle;

  /// No description provided for @juryBack.
  ///
  /// In de, this message translates to:
  /// **'Zurück'**
  String get juryBack;

  /// No description provided for @juryNext.
  ///
  /// In de, this message translates to:
  /// **'Weiter'**
  String get juryNext;

  /// No description provided for @juryFinish.
  ///
  /// In de, this message translates to:
  /// **'Jetzt selbst die Plattform erkunden'**
  String get juryFinish;

  /// No description provided for @juryExit.
  ///
  /// In de, this message translates to:
  /// **'Jury-Modus beenden'**
  String get juryExit;

  /// No description provided for @juryStep1Title.
  ///
  /// In de, this message translates to:
  /// **'Business Story'**
  String get juryStep1Title;

  /// No description provided for @juryStep1Intro.
  ///
  /// In de, this message translates to:
  /// **'Zuerst das große Bild: welches Problem BusinessBrain löst und warum es kein gewöhnlicher KI-Chat ist.'**
  String get juryStep1Intro;

  /// No description provided for @juryStep2Title.
  ///
  /// In de, this message translates to:
  /// **'Operations Dashboard'**
  String get juryStep2Title;

  /// No description provided for @juryStep2Intro.
  ///
  /// In de, this message translates to:
  /// **'So arbeitet BusinessBrain heute für ein Unternehmen – auf einen Blick (Demo-Daten).'**
  String get juryStep2Intro;

  /// No description provided for @juryStep3Title.
  ///
  /// In de, this message translates to:
  /// **'Guided Demo'**
  String get juryStep3Title;

  /// No description provided for @juryStep3Intro.
  ///
  /// In de, this message translates to:
  /// **'Der gesamte Workflow in sieben Schritten, verständlich zusammengeführt.'**
  String get juryStep3Intro;

  /// No description provided for @juryStep4Title.
  ///
  /// In de, this message translates to:
  /// **'Grounded Assistant'**
  String get juryStep4Title;

  /// No description provided for @juryStep4Intro.
  ///
  /// In de, this message translates to:
  /// **'Fragen werden ausschließlich aus dem Firmenwissen beantwortet – mit Quellen, ohne Halluzination.'**
  String get juryStep4Intro;

  /// No description provided for @juryStep5Title.
  ///
  /// In de, this message translates to:
  /// **'Knowledge Workflow'**
  String get juryStep5Title;

  /// No description provided for @juryStep5Intro.
  ///
  /// In de, this message translates to:
  /// **'Der reproduzierbare Beweis: aus einer Wissenslücke entsteht dauerhaftes, bestätigtes Firmenwissen.'**
  String get juryStep5Intro;

  /// No description provided for @juryStep6Title.
  ///
  /// In de, this message translates to:
  /// **'Abschluss'**
  String get juryStep6Title;

  /// No description provided for @juryClosingTitle.
  ///
  /// In de, this message translates to:
  /// **'Vielen Dank.'**
  String get juryClosingTitle;

  /// No description provided for @juryClosingBody.
  ///
  /// In de, this message translates to:
  /// **'BusinessBrain organisiert Firmenwissen, beantwortet Kundenfragen zuverlässig und verbessert sich ausschließlich durch bestätigtes Unternehmenswissen – der Mensch behält jederzeit die Kontrolle.'**
  String get juryClosingBody;

  /// No description provided for @moreTitle.
  ///
  /// In de, this message translates to:
  /// **'Weitere Module'**
  String get moreTitle;

  /// No description provided for @moreIntro.
  ///
  /// In de, this message translates to:
  /// **'Alle übrigen Bereiche der Plattform – nichts wurde entfernt.'**
  String get moreIntro;

  /// No description provided for @demoSwitchTitle.
  ///
  /// In de, this message translates to:
  /// **'Demo-Daten'**
  String get demoSwitchTitle;

  /// No description provided for @demoSwitchSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Zentraler Schalter für Demo-Inhalte (z. B. Operations Dashboard).'**
  String get demoSwitchSubtitle;

  /// No description provided for @demoSwitchOn.
  ///
  /// In de, this message translates to:
  /// **'Demo aktiv'**
  String get demoSwitchOn;

  /// No description provided for @demoSwitchOff.
  ///
  /// In de, this message translates to:
  /// **'Live'**
  String get demoSwitchOff;

  /// No description provided for @releaseTitle.
  ///
  /// In de, this message translates to:
  /// **'Release-Checkliste'**
  String get releaseTitle;

  /// No description provided for @releaseIntro.
  ///
  /// In de, this message translates to:
  /// **'Interne Team-Checkliste für die Hackathon-Einreichung – nicht öffentlich.'**
  String get releaseIntro;

  /// No description provided for @rcNotStarted.
  ///
  /// In de, this message translates to:
  /// **'Nicht begonnen'**
  String get rcNotStarted;

  /// No description provided for @rcInProgress.
  ///
  /// In de, this message translates to:
  /// **'In Arbeit'**
  String get rcInProgress;

  /// No description provided for @rcDone.
  ///
  /// In de, this message translates to:
  /// **'Erledigt'**
  String get rcDone;

  /// No description provided for @rcItem1.
  ///
  /// In de, this message translates to:
  /// **'Aktueller Branch veröffentlicht'**
  String get rcItem1;

  /// No description provided for @rcItem2.
  ///
  /// In de, this message translates to:
  /// **'Cloudflare Deployment erfolgreich'**
  String get rcItem2;

  /// No description provided for @rcItem3.
  ///
  /// In de, this message translates to:
  /// **'Live Gemini aktiv'**
  String get rcItem3;

  /// No description provided for @rcItem4.
  ///
  /// In de, this message translates to:
  /// **'AI_PROVIDER korrekt gesetzt'**
  String get rcItem4;

  /// No description provided for @rcItem5.
  ///
  /// In de, this message translates to:
  /// **'Demo-Daten vorhanden'**
  String get rcItem5;

  /// No description provided for @rcItem6.
  ///
  /// In de, this message translates to:
  /// **'Guided Demo vollständig'**
  String get rcItem6;

  /// No description provided for @rcItem7.
  ///
  /// In de, this message translates to:
  /// **'Business Story vollständig'**
  String get rcItem7;

  /// No description provided for @rcItem8.
  ///
  /// In de, this message translates to:
  /// **'Operations Dashboard vollständig'**
  String get rcItem8;

  /// No description provided for @rcItem9.
  ///
  /// In de, this message translates to:
  /// **'Knowledge Workflow vollständig'**
  String get rcItem9;

  /// No description provided for @rcItem10.
  ///
  /// In de, this message translates to:
  /// **'README aktuell'**
  String get rcItem10;

  /// No description provided for @rcItem11.
  ///
  /// In de, this message translates to:
  /// **'Screenshots vorhanden'**
  String get rcItem11;

  /// No description provided for @rcItem12.
  ///
  /// In de, this message translates to:
  /// **'Pitch-Video vorhanden'**
  String get rcItem12;

  /// No description provided for @rcItem13.
  ///
  /// In de, this message translates to:
  /// **'Submission-Dokument aktuell'**
  String get rcItem13;

  /// No description provided for @heroSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Die lernende Unternehmens-KI.'**
  String get heroSubtitle;

  /// No description provided for @heroBody.
  ///
  /// In de, this message translates to:
  /// **'BusinessBrain organisiert Unternehmenswissen, beantwortet Kundenfragen ausschließlich auf Basis bestätigter Informationen und verbessert sich kontinuierlich durch menschlich freigegebene Wissensbausteine.'**
  String get heroBody;

  /// No description provided for @heroStartDemo.
  ///
  /// In de, this message translates to:
  /// **'BusinessBrain in 2 Minuten erleben'**
  String get heroStartDemo;

  /// No description provided for @heroExplore.
  ///
  /// In de, this message translates to:
  /// **'Plattform erkunden'**
  String get heroExplore;

  /// No description provided for @heroFlow1.
  ///
  /// In de, this message translates to:
  /// **'Unternehmenswissen'**
  String get heroFlow1;

  /// No description provided for @heroFlow2.
  ///
  /// In de, this message translates to:
  /// **'Kundenfragen'**
  String get heroFlow2;

  /// No description provided for @heroFlow3.
  ///
  /// In de, this message translates to:
  /// **'Wissenslücken'**
  String get heroFlow3;

  /// No description provided for @heroFlow4.
  ///
  /// In de, this message translates to:
  /// **'Verbesserungen'**
  String get heroFlow4;

  /// No description provided for @heroFlow5.
  ///
  /// In de, this message translates to:
  /// **'Lernkreislauf'**
  String get heroFlow5;

  /// No description provided for @heroFlow6.
  ///
  /// In de, this message translates to:
  /// **'BusinessBrain'**
  String get heroFlow6;

  /// No description provided for @juryOf.
  ///
  /// In de, this message translates to:
  /// **'von'**
  String get juryOf;

  /// No description provided for @juryTrans1.
  ///
  /// In de, this message translates to:
  /// **'BusinessBrain beginnt mit dem Wissen Ihres Unternehmens.'**
  String get juryTrans1;

  /// No description provided for @juryTrans2.
  ///
  /// In de, this message translates to:
  /// **'Jetzt beantwortet die KI eine echte Kundenfrage.'**
  String get juryTrans2;

  /// No description provided for @juryTrans3.
  ///
  /// In de, this message translates to:
  /// **'Fehlendes Wissen wird erkannt.'**
  String get juryTrans3;

  /// No description provided for @juryTrans4.
  ///
  /// In de, this message translates to:
  /// **'Der Mitarbeiter entscheidet.'**
  String get juryTrans4;

  /// No description provided for @juryTrans5.
  ///
  /// In de, this message translates to:
  /// **'Die Wissensbasis wächst.'**
  String get juryTrans5;

  /// No description provided for @juryTrans6.
  ///
  /// In de, this message translates to:
  /// **'Alle zukünftigen Antworten profitieren.'**
  String get juryTrans6;

  /// No description provided for @oxClosingTitle.
  ///
  /// In de, this message translates to:
  /// **'BusinessBrain lernt niemals durch Vermutungen.'**
  String get oxClosingTitle;

  /// No description provided for @oxClosingSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Jede Verbesserung basiert auf bestätigtem Unternehmenswissen.'**
  String get oxClosingSubtitle;

  /// No description provided for @oxSeenTitle.
  ///
  /// In de, this message translates to:
  /// **'Heute gesehen:'**
  String get oxSeenTitle;

  /// No description provided for @oxSeen1.
  ///
  /// In de, this message translates to:
  /// **'Grounded AI'**
  String get oxSeen1;

  /// No description provided for @oxSeen2.
  ///
  /// In de, this message translates to:
  /// **'Wissensbasis'**
  String get oxSeen2;

  /// No description provided for @oxSeen3.
  ///
  /// In de, this message translates to:
  /// **'Human Review'**
  String get oxSeen3;

  /// No description provided for @oxSeen4.
  ///
  /// In de, this message translates to:
  /// **'Knowledge Builder'**
  String get oxSeen4;

  /// No description provided for @oxSeen5.
  ///
  /// In de, this message translates to:
  /// **'Lernkreislauf'**
  String get oxSeen5;

  /// No description provided for @oxSeen6.
  ///
  /// In de, this message translates to:
  /// **'Operations Dashboard'**
  String get oxSeen6;

  /// No description provided for @oxSeen7.
  ///
  /// In de, this message translates to:
  /// **'Business Story'**
  String get oxSeen7;

  /// No description provided for @oxThanks.
  ///
  /// In de, this message translates to:
  /// **'Vielen Dank für Ihr Interesse an BusinessBrain.'**
  String get oxThanks;

  /// No description provided for @oxLinkProject.
  ///
  /// In de, this message translates to:
  /// **'Projektseite'**
  String get oxLinkProject;

  /// No description provided for @oxLinkGithub.
  ///
  /// In de, this message translates to:
  /// **'GitHub'**
  String get oxLinkGithub;

  /// No description provided for @oxLinkVideo.
  ///
  /// In de, this message translates to:
  /// **'Projektvideo'**
  String get oxLinkVideo;

  /// No description provided for @oxLinkDocs.
  ///
  /// In de, this message translates to:
  /// **'Dokumentation'**
  String get oxLinkDocs;

  /// No description provided for @navBusinessBrainVision.
  ///
  /// In de, this message translates to:
  /// **'BusinessBrain Vision'**
  String get navBusinessBrainVision;

  /// No description provided for @visionBadge.
  ///
  /// In de, this message translates to:
  /// **'VISION'**
  String get visionBadge;

  /// No description provided for @visionFutureLabel.
  ///
  /// In de, this message translates to:
  /// **'Zukünftige Entwicklung'**
  String get visionFutureLabel;

  /// No description provided for @visionHeroTitle.
  ///
  /// In de, this message translates to:
  /// **'Vom Wissenssystem zum digitalen Unternehmensgehirn'**
  String get visionHeroTitle;

  /// No description provided for @visionHeroBody.
  ///
  /// In de, this message translates to:
  /// **'BusinessBrain soll Unternehmen eines Tages dabei unterstützen, relevante Signale früh zu erkennen, Zusammenhänge verständlich zu machen und die sinnvollsten nächsten Schritte vorzuschlagen – ohne jemals selbst zu entscheiden oder zu veröffentlichen.'**
  String get visionHeroBody;

  /// No description provided for @visionTodayLabel.
  ///
  /// In de, this message translates to:
  /// **'HEUTE'**
  String get visionTodayLabel;

  /// No description provided for @visionTodayTitle.
  ///
  /// In de, this message translates to:
  /// **'Der Ausgangspunkt ist bestätigt'**
  String get visionTodayTitle;

  /// No description provided for @visionTodayBody.
  ///
  /// In de, this message translates to:
  /// **'BusinessBrain beantwortet Kundenfragen aus bestätigtem Unternehmenswissen, erkennt Lücken und verbessert die Wissensbasis ausschließlich nach menschlicher Freigabe.'**
  String get visionTodayBody;

  /// No description provided for @visionJourneyTitle.
  ///
  /// In de, this message translates to:
  /// **'Eine Entwicklung in drei klaren Phasen'**
  String get visionJourneyTitle;

  /// No description provided for @visionJourneyBody.
  ///
  /// In de, this message translates to:
  /// **'Jede Phase baut auf der vorherigen auf. Die Vision erweitert den bestehenden Wissenskern, ersetzt ihn aber nicht.'**
  String get visionJourneyBody;

  /// No description provided for @visionPhase1Eyebrow.
  ///
  /// In de, this message translates to:
  /// **'Phase 1'**
  String get visionPhase1Eyebrow;

  /// No description provided for @visionPhase1Title.
  ///
  /// In de, this message translates to:
  /// **'Wissenssystem'**
  String get visionPhase1Title;

  /// No description provided for @visionPhase1Body.
  ///
  /// In de, this message translates to:
  /// **'Bestätigtes Unternehmenswissen wird strukturiert, auffindbar und sicher für Kundenfragen nutzbar.'**
  String get visionPhase1Body;

  /// No description provided for @visionPhase2Eyebrow.
  ///
  /// In de, this message translates to:
  /// **'Phase 2'**
  String get visionPhase2Eyebrow;

  /// No description provided for @visionPhase2Title.
  ///
  /// In de, this message translates to:
  /// **'Unternehmensassistent'**
  String get visionPhase2Title;

  /// No description provided for @visionPhase2Body.
  ///
  /// In de, this message translates to:
  /// **'BusinessBrain ordnet neue Signale ein, fasst Entwicklungen zusammen und schlägt prüfbare Maßnahmen vor.'**
  String get visionPhase2Body;

  /// No description provided for @visionPhase3Eyebrow.
  ///
  /// In de, this message translates to:
  /// **'Phase 3'**
  String get visionPhase3Eyebrow;

  /// No description provided for @visionPhase3Title.
  ///
  /// In de, this message translates to:
  /// **'Digitales Unternehmensgehirn'**
  String get visionPhase3Title;

  /// No description provided for @visionPhase3Body.
  ///
  /// In de, this message translates to:
  /// **'Wissen, Marktbeobachtung und bestätigte Erfahrungen verbinden sich zu einem kontinuierlichen Orientierungssystem für das Unternehmen.'**
  String get visionPhase3Body;

  /// No description provided for @visionFlowTitle.
  ///
  /// In de, this message translates to:
  /// **'Von Signalen zu verantwortbaren Vorschlägen'**
  String get visionFlowTitle;

  /// No description provided for @visionFlowBody.
  ///
  /// In de, this message translates to:
  /// **'BusinessBrain beobachtet nicht, um selbst zu handeln. Es verdichtet Informationen, erklärt ihre Bedeutung und legt Entscheidungen in die Hände des Unternehmens.'**
  String get visionFlowBody;

  /// No description provided for @visionFlow1.
  ///
  /// In de, this message translates to:
  /// **'Signale beobachten'**
  String get visionFlow1;

  /// No description provided for @visionFlow2.
  ///
  /// In de, this message translates to:
  /// **'Zusammenhänge erkennen'**
  String get visionFlow2;

  /// No description provided for @visionFlow3.
  ///
  /// In de, this message translates to:
  /// **'Maßnahmen vorschlagen'**
  String get visionFlow3;

  /// No description provided for @visionFlow4.
  ///
  /// In de, this message translates to:
  /// **'Der Mensch entscheidet'**
  String get visionFlow4;

  /// No description provided for @visionPresenceTitle.
  ///
  /// In de, this message translates to:
  /// **'Digitale Präsenz verstehen'**
  String get visionPresenceTitle;

  /// No description provided for @visionPresenceBody.
  ///
  /// In de, this message translates to:
  /// **'Öffentliche Signale könnten in einer gemeinsamen, verständlichen Sicht zusammenlaufen.'**
  String get visionPresenceBody;

  /// No description provided for @visionWebsiteTitle.
  ///
  /// In de, this message translates to:
  /// **'Unternehmenswebsite beobachten'**
  String get visionWebsiteTitle;

  /// No description provided for @visionWebsiteBody.
  ///
  /// In de, this message translates to:
  /// **'Veränderungen, veraltete Inhalte und neue Informationslücken kontinuierlich sichtbar machen.'**
  String get visionWebsiteBody;

  /// No description provided for @visionSeoTitle.
  ///
  /// In de, this message translates to:
  /// **'SEO-Entwicklung analysieren'**
  String get visionSeoTitle;

  /// No description provided for @visionSeoBody.
  ///
  /// In de, this message translates to:
  /// **'Suchthemen, Auffindbarkeit und Optimierungspotenziale verständlich zusammenfassen.'**
  String get visionSeoBody;

  /// No description provided for @visionGoogleTitle.
  ///
  /// In de, this message translates to:
  /// **'Verbesserungen für Google vorschlagen'**
  String get visionGoogleTitle;

  /// No description provided for @visionGoogleBody.
  ///
  /// In de, this message translates to:
  /// **'Konkrete, prüfbare Vorschläge für Inhalte, Suchintentionen und lokale Sichtbarkeit vorbereiten.'**
  String get visionGoogleBody;

  /// No description provided for @visionSocialTitle.
  ///
  /// In de, this message translates to:
  /// **'Relevante Plattformsignale bündeln'**
  String get visionSocialTitle;

  /// No description provided for @visionSocialBody.
  ///
  /// In de, this message translates to:
  /// **'Facebook, Instagram, Reddit, LinkedIn, YouTube und TikTok in einer gemeinsamen Unternehmenssicht einordnen.'**
  String get visionSocialBody;

  /// No description provided for @visionReputationTitle.
  ///
  /// In de, this message translates to:
  /// **'Google Business und Bewertungen verstehen'**
  String get visionReputationTitle;

  /// No description provided for @visionReputationBody.
  ///
  /// In de, this message translates to:
  /// **'Wiederkehrende Rückmeldungen, Chancen und mögliche Reputationsrisiken früh sichtbar machen.'**
  String get visionReputationBody;

  /// No description provided for @visionCustomerTitle.
  ///
  /// In de, this message translates to:
  /// **'Die Stimme der Kunden erkennen'**
  String get visionCustomerTitle;

  /// No description provided for @visionCustomerBody.
  ///
  /// In de, this message translates to:
  /// **'Wiederkehrende Fragen und Probleme sollen zu strukturierten, überprüfbaren Erkenntnissen werden.'**
  String get visionCustomerBody;

  /// No description provided for @visionEmailTitle.
  ///
  /// In de, this message translates to:
  /// **'Support-E-Mails zusammenfassen'**
  String get visionEmailTitle;

  /// No description provided for @visionEmailBody.
  ///
  /// In de, this message translates to:
  /// **'Häufige Anliegen und neue Themen erkennen, ohne Nachrichten selbst zu beantworten oder zu verändern.'**
  String get visionEmailBody;

  /// No description provided for @visionQuestionsTitle.
  ///
  /// In de, this message translates to:
  /// **'Häufige Kundenfragen erkennen'**
  String get visionQuestionsTitle;

  /// No description provided for @visionQuestionsBody.
  ///
  /// In de, this message translates to:
  /// **'Ähnliche Fragen über verschiedene Kontaktpunkte hinweg als gemeinsames Muster sichtbar machen.'**
  String get visionQuestionsBody;

  /// No description provided for @visionProblemsTitle.
  ///
  /// In de, this message translates to:
  /// **'Wiederkehrende Kundenprobleme erkennen'**
  String get visionProblemsTitle;

  /// No description provided for @visionProblemsBody.
  ///
  /// In de, this message translates to:
  /// **'Häufungen, Ursachen und betroffene Produkte verständlich für das Unternehmen aufbereiten.'**
  String get visionProblemsBody;

  /// No description provided for @visionExternalGapsTitle.
  ///
  /// In de, this message translates to:
  /// **'Wissenslücken außerhalb der Wissensbasis erkennen'**
  String get visionExternalGapsTitle;

  /// No description provided for @visionExternalGapsBody.
  ///
  /// In de, this message translates to:
  /// **'Fehlende Informationen aus Kundenkontakten und öffentlichen Signalen als Vorschläge zurückführen.'**
  String get visionExternalGapsBody;

  /// No description provided for @visionMarketTitle.
  ///
  /// In de, this message translates to:
  /// **'Marktbewegungen einordnen'**
  String get visionMarketTitle;

  /// No description provided for @visionMarketBody.
  ///
  /// In de, this message translates to:
  /// **'Die Vision verbindet externe Entwicklungen mit dem bestätigten Wissen und den Zielen des Unternehmens.'**
  String get visionMarketBody;

  /// No description provided for @visionCompetitorsTitle.
  ///
  /// In de, this message translates to:
  /// **'Wettbewerber beobachten'**
  String get visionCompetitorsTitle;

  /// No description provided for @visionCompetitorsBody.
  ///
  /// In de, this message translates to:
  /// **'Relevante Veränderungen sachlich zusammenfassen, ohne automatische Bewertungen oder Entscheidungen.'**
  String get visionCompetitorsBody;

  /// No description provided for @visionTrendsTitle.
  ///
  /// In de, this message translates to:
  /// **'Trends und Marktchancen erkennen'**
  String get visionTrendsTitle;

  /// No description provided for @visionTrendsBody.
  ///
  /// In de, this message translates to:
  /// **'Neue Themen nach Relevanz, möglichem Nutzen und offenen Fragen für das Unternehmen einordnen.'**
  String get visionTrendsBody;

  /// No description provided for @visionProductsTitle.
  ///
  /// In de, this message translates to:
  /// **'Neue Produkte analysieren'**
  String get visionProductsTitle;

  /// No description provided for @visionProductsBody.
  ///
  /// In de, this message translates to:
  /// **'Produktideen und Marktangebote mit vorhandenem Wissen, Kundenproblemen und Chancen vergleichen.'**
  String get visionProductsBody;

  /// No description provided for @visionProposalsTitle.
  ///
  /// In de, this message translates to:
  /// **'Aus Erkenntnissen werden Vorschläge'**
  String get visionProposalsTitle;

  /// No description provided for @visionProposalsBody.
  ///
  /// In de, this message translates to:
  /// **'Jeder Vorschlag bleibt Entwurf. Erst ein Mensch entscheidet, ob daraus eine Maßnahme wird.'**
  String get visionProposalsBody;

  /// No description provided for @visionFaqTitle.
  ///
  /// In de, this message translates to:
  /// **'Neue FAQ vorschlagen'**
  String get visionFaqTitle;

  /// No description provided for @visionFaqBody.
  ///
  /// In de, this message translates to:
  /// **'Wiederkehrende Fragen in konkrete Vorschläge für bestätigtes Kundenwissen überführen.'**
  String get visionFaqBody;

  /// No description provided for @visionDocsTitle.
  ///
  /// In de, this message translates to:
  /// **'Neue Dokumentationen vorschlagen'**
  String get visionDocsTitle;

  /// No description provided for @visionDocsBody.
  ///
  /// In de, this message translates to:
  /// **'Erkannte Erklärungsbedarfe als nachvollziehbare Dokumentationsentwürfe strukturieren.'**
  String get visionDocsBody;

  /// No description provided for @visionLandingTitle.
  ///
  /// In de, this message translates to:
  /// **'Neue Landingpages vorschlagen'**
  String get visionLandingTitle;

  /// No description provided for @visionLandingBody.
  ///
  /// In de, this message translates to:
  /// **'Relevante Kundenbedürfnisse und Suchthemen in begründete Seitenthemen übersetzen.'**
  String get visionLandingBody;

  /// No description provided for @visionCampaignTitle.
  ///
  /// In de, this message translates to:
  /// **'Marketingkampagnen vorschlagen'**
  String get visionCampaignTitle;

  /// No description provided for @visionCampaignBody.
  ///
  /// In de, this message translates to:
  /// **'Chancen in überprüfbare Kampagnenideen mit Begründung und erwartetem Nutzen überführen.'**
  String get visionCampaignBody;

  /// No description provided for @visionTasksTitle.
  ///
  /// In de, this message translates to:
  /// **'Aufgaben für Mitarbeiter vorschlagen'**
  String get visionTasksTitle;

  /// No description provided for @visionTasksBody.
  ///
  /// In de, this message translates to:
  /// **'Aus offenen Themen klare Arbeitsvorschläge ableiten, ohne Aufgaben automatisch zuzuweisen.'**
  String get visionTasksBody;

  /// No description provided for @visionPriorityTitle.
  ///
  /// In de, this message translates to:
  /// **'Offene Themen priorisieren'**
  String get visionPriorityTitle;

  /// No description provided for @visionPriorityBody.
  ///
  /// In de, this message translates to:
  /// **'Dringlichkeit, Nutzen und Wissenslage transparent gegenüberstellen; die Reihenfolge bestätigt der Mensch.'**
  String get visionPriorityBody;

  /// No description provided for @visionBriefingTitle.
  ///
  /// In de, this message translates to:
  /// **'Orientierung für jeden neuen Arbeitstag'**
  String get visionBriefingTitle;

  /// No description provided for @visionBriefingBody.
  ///
  /// In de, this message translates to:
  /// **'Statt weiterer Dashboards könnte BusinessBrain die wichtigsten Veränderungen in einer ruhigen, entscheidungsfähigen Übersicht zusammenführen.'**
  String get visionBriefingBody;

  /// No description provided for @visionMorningTitle.
  ///
  /// In de, this message translates to:
  /// **'Morning Briefing'**
  String get visionMorningTitle;

  /// No description provided for @visionMorningBody.
  ///
  /// In de, this message translates to:
  /// **'Die wichtigsten neuen Signale, offenen Entscheidungen und empfohlenen nächsten Schritte am Morgen.'**
  String get visionMorningBody;

  /// No description provided for @visionDailyTitle.
  ///
  /// In de, this message translates to:
  /// **'Tägliche Zusammenfassung'**
  String get visionDailyTitle;

  /// No description provided for @visionDailyBody.
  ///
  /// In de, this message translates to:
  /// **'Was sich verändert hat, welche Themen zunehmen und wo Aufmerksamkeit erforderlich sein könnte.'**
  String get visionDailyBody;

  /// No description provided for @visionLearningTitle.
  ///
  /// In de, this message translates to:
  /// **'Aus bestätigten Informationen lernen'**
  String get visionLearningTitle;

  /// No description provided for @visionLearningBody.
  ///
  /// In de, this message translates to:
  /// **'Nur bestätigte Erkenntnisse erweitern das Unternehmenswissen und verbessern spätere Vorschläge.'**
  String get visionLearningBody;

  /// No description provided for @visionControlTitle.
  ///
  /// In de, this message translates to:
  /// **'Die Entscheidungsgewalt bleibt beim Unternehmen'**
  String get visionControlTitle;

  /// No description provided for @visionControlBody.
  ///
  /// In de, this message translates to:
  /// **'Auch als digitales Unternehmensgehirn bleibt BusinessBrain ein Vorschlagssystem mit klaren Grenzen.'**
  String get visionControlBody;

  /// No description provided for @visionNeverDecides.
  ///
  /// In de, this message translates to:
  /// **'trifft niemals selbst Unternehmensentscheidungen'**
  String get visionNeverDecides;

  /// No description provided for @visionNeverPublishes.
  ///
  /// In de, this message translates to:
  /// **'veröffentlicht niemals selbst Inhalte'**
  String get visionNeverPublishes;

  /// No description provided for @visionNeverChanges.
  ///
  /// In de, this message translates to:
  /// **'verändert niemals selbst Unternehmenswissen'**
  String get visionNeverChanges;

  /// No description provided for @visionOnlySuggests.
  ///
  /// In de, this message translates to:
  /// **'schlägt ausschließlich nachvollziehbare Maßnahmen vor'**
  String get visionOnlySuggests;

  /// No description provided for @visionHumanAlways.
  ///
  /// In de, this message translates to:
  /// **'Der Mensch entscheidet immer.'**
  String get visionHumanAlways;

  /// No description provided for @visionClosingTitle.
  ///
  /// In de, this message translates to:
  /// **'Schritt für Schritt zu besserer Orientierung'**
  String get visionClosingTitle;

  /// No description provided for @visionClosingBody.
  ///
  /// In de, this message translates to:
  /// **'BusinessBrain wächst nicht durch unkontrollierte Autonomie, sondern durch nachvollziehbare Vorschläge, bestätigtes Wissen und menschliche Entscheidungen. So kann aus einem Wissenssystem langfristig ein glaubwürdiges digitales Unternehmensgehirn entstehen.'**
  String get visionClosingBody;

  /// No description provided for @visionBack.
  ///
  /// In de, this message translates to:
  /// **'Zurück zu BusinessBrain'**
  String get visionBack;
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
