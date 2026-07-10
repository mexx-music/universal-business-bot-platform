import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/data/app_state.dart';
import 'package:universalbusiness/data/intake_chat_flow.dart';
import 'package:universalbusiness/l10n/app_localizations.dart';
import 'package:universalbusiness/models/intake_session.dart';

void main() {
  test('chat answer is saved into the selected workspace intake session', () {
    final state = AppState();
    final otherWorkspaceName = state.companies
        .firstWhere((workspace) => workspace.company.id == 'schnurr-purr')
        .intakeSession!
        .basics
        .companyName;

    state.updateIntakeBasics(const IntakeBasics());
    final question = IntakeChatFlow.questions.firstWhere(
      (question) => question.questionKey == 'companyName',
    );

    IntakeChatFlow.saveAnswer(state, question, 'Neue Demo Firma');

    expect(state.intakeSession!.basics.companyName, 'Neue Demo Firma');
    expect(
      state.companies
          .firstWhere((workspace) => workspace.company.id == 'schnurr-purr')
          .intakeSession!
          .basics
          .companyName,
      otherWorkspaceName,
    );
  });

  test('website yes asks URL and website detail questions', () {
    final state = AppState();
    state.updateIntakeBasics(
      const IntakeBasics(website: 'https://prefilled.example'),
    );
    state.updateIntakeWebsiteAndSupport(const IntakeWebsiteAndSupport());

    final hasWebsite = IntakeChatFlow.questions.firstWhere(
      (question) => question.questionKey == 'hasWebsite',
    );

    IntakeChatFlow.saveAnswer(state, hasWebsite, 'yes');

    expect(state.intakeSession!.basics.hasWebsite, isTrue);
    expect(
      IntakeChatFlow.nextQuestion(state.intakeSession!)!.questionKey,
      'website',
    );
    expect(
      IntakeChatFlow.questionByKey('website').value(state.intakeSession!),
      isEmpty,
    );
    expect(
      IntakeChatFlow.questionByKey('website').defaultValue!(
        state.intakeSession!,
      ),
      'https://prefilled.example',
    );
    expect(
      IntakeChatFlow.nextQuestion(state.intakeSession!)!.type,
      IntakeChatQuestionType.url,
    );
    expect(
      IntakeChatFlow.relevantQuestions(
        state.intakeSession!,
      ).map((question) => question.questionKey),
      containsAll(['website', 'hasShop', 'importantPages', 'hasFaqArea']),
    );
  });

  test('website URL empty keeps shop question closed', () {
    final state = AppState();
    state.updateIntakeBasics(
      const IntakeBasics(
        companyName: 'Demo',
        shortDescription: 'Demo description',
        industry: 'Software',
        country: 'AT',
        primaryLanguage: 'de',
        additionalLanguages: 'English',
        hasWebsite: true,
      ),
    );
    state.updateIntakeWebsiteAndSupport(const IntakeWebsiteAndSupport());

    expect(
      IntakeChatFlow.nextQuestion(state.intakeSession!)!.questionKey,
      'website',
    );
    expect(
      IntakeChatFlow.nextQuestion(state.intakeSession!)!.questionKey,
      isNot('hasShop'),
    );
  });

  test('https scheme alone is not accepted as a URL', () {
    final l = lookupAppLocalizations(const Locale('en'));
    final question = IntakeChatFlow.questionByKey('website');

    final error = IntakeChatFlow.validateAnswer(question, 'https://', l);

    expect(error, l.intakeChatUrlWarning);
  });

  test('valid domain URL is normalized and saved', () {
    final state = AppState();
    state.updateIntakeBasics(
      const IntakeBasics(
        companyName: 'Demo',
        shortDescription: 'Demo description',
        industry: 'Software',
        country: 'AT',
        primaryLanguage: 'de',
        additionalLanguages: 'English',
        hasWebsite: true,
      ),
    );
    state.updateIntakeWebsiteAndSupport(const IntakeWebsiteAndSupport());
    final question = IntakeChatFlow.questionByKey('website');

    IntakeChatFlow.saveAnswer(state, question, 'example.com');

    expect(state.intakeSession!.basics.website, 'https://example.com');
    expect(
      state.intakeSession!.websiteAndSupport.websiteUrl,
      'https://example.com',
    );
    expect(
      IntakeChatFlow.nextQuestion(state.intakeSession!)!.questionKey,
      'hasShop',
    );
  });

  test('website URL cancelled remains current question', () {
    final state = AppState();
    state.updateIntakeBasics(
      const IntakeBasics(
        companyName: 'Demo',
        shortDescription: 'Demo description',
        industry: 'Software',
        country: 'AT',
        primaryLanguage: 'de',
        additionalLanguages: 'English',
        hasWebsite: true,
      ),
    );
    state.updateIntakeWebsiteAndSupport(const IntakeWebsiteAndSupport());

    expect(
      IntakeChatFlow.nextQuestion(state.intakeSession!)!.questionKey,
      'website',
    );
    expect(
      IntakeChatFlow.nextQuestion(state.intakeSession!)!.questionKey,
      'website',
    );
  });

  test('website URL answer later allows shop question but keeps gap open', () {
    final state = AppState();
    state.updateIntakeBasics(
      const IntakeBasics(
        companyName: 'Demo',
        shortDescription: 'Demo description',
        industry: 'Software',
        country: 'AT',
        primaryLanguage: 'de',
        additionalLanguages: 'English',
        hasWebsite: true,
      ),
    );
    state.updateIntakeWebsiteAndSupport(const IntakeWebsiteAndSupport());
    final question = IntakeChatFlow.questionByKey('website');
    final before = IntakeChatFlow.answeredRelevantCount(state.intakeSession!);
    final currentIndex = IntakeChatFlow.questions.indexOf(question);

    state.deferIntakeChatQuestion(question.questionKey, currentIndex + 1);

    expect(state.intakeSession!.deferredQuestionKeys, contains('website'));
    expect(
      IntakeChatFlow.nextQuestion(state.intakeSession!)!.questionKey,
      'hasShop',
    );
    expect(
      IntakeChatFlow.answeredRelevantCount(state.intakeSession!),
      greaterThanOrEqualTo(before),
    );
  });

  test('required empty answer is rejected', () {
    final l = lookupAppLocalizations(const Locale('en'));
    final question = IntakeChatFlow.questionByKey('companyName');

    final error = IntakeChatFlow.validateAnswer(question, '   ', l);

    expect(error, l.intakeChatRequiredAnswer);
  });

  test('shop yes asks shop URL next', () {
    final state = AppState();
    state.updateIntakeBasics(const IntakeBasics(hasWebsite: true));
    state.updateIntakeWebsiteAndSupport(
      const IntakeWebsiteAndSupport(websiteUrl: 'https://example.com'),
    );
    final hasShop = IntakeChatFlow.questionByKey('hasShop');

    IntakeChatFlow.saveAnswer(state, hasShop, 'yes');

    final next = IntakeChatFlow.nextQuestion(state.intakeSession!);
    expect(next!.questionKey, 'shopUrl');
    expect(next.type, IntakeChatQuestionType.url);
  });

  test('faq yes asks faq URL next', () {
    final state = AppState();
    state.updateIntakeBasics(const IntakeBasics(hasWebsite: true));
    state.updateIntakeWebsiteAndSupport(
      const IntakeWebsiteAndSupport(
        websiteUrl: 'https://example.com',
        hasShop: false,
        importantPages: 'Home',
      ),
    );
    final hasFaqArea = IntakeChatFlow.questionByKey('hasFaqArea');

    IntakeChatFlow.saveAnswer(state, hasFaqArea, 'yes');

    final next = IntakeChatFlow.nextQuestion(state.intakeSession!);
    expect(next!.questionKey, 'faqUrl');
    expect(next.type, IntakeChatQuestionType.url);
  });

  test('resume inside website detail path starts at missing URL', () {
    final state = AppState();
    state.updateIntakeBasics(
      const IntakeBasics(
        companyName: 'Demo',
        shortDescription: 'Demo description',
        industry: 'Software',
        country: 'AT',
        primaryLanguage: 'de',
        additionalLanguages: 'English',
        hasWebsite: true,
      ),
    );
    state.updateIntakeWebsiteAndSupport(const IntakeWebsiteAndSupport());
    state.setIntakeChatQuestionIndex(
      IntakeChatFlow.questions.indexOf(IntakeChatFlow.questionByKey('website')),
    );

    expect(
      IntakeChatFlow.nextQuestion(state.intakeSession!)!.questionKey,
      'website',
    );
  });

  test('https scheme alone does not count as answered', () {
    final state = AppState();
    state.updateIntakeBasics(
      const IntakeBasics(
        companyName: 'Demo',
        shortDescription: 'Demo description',
        industry: 'Software',
        country: 'AT',
        primaryLanguage: 'de',
        additionalLanguages: 'English',
        hasWebsite: true,
      ),
    );
    state.updateIntakeWebsiteAndSupport(
      const IntakeWebsiteAndSupport(websiteUrl: 'https://'),
    );

    expect(
      IntakeChatFlow.nextQuestion(state.intakeSession!)!.questionKey,
      'website',
    );
  });

  test('website no skips website details and asks planned website', () {
    final state = AppState();
    state.updateIntakeBasics(const IntakeBasics());
    state.updateIntakeWebsiteAndSupport(const IntakeWebsiteAndSupport());

    final hasWebsite = IntakeChatFlow.questions.firstWhere(
      (question) => question.questionKey == 'hasWebsite',
    );

    IntakeChatFlow.saveAnswer(state, hasWebsite, 'no');

    final relevantKeys = IntakeChatFlow.relevantQuestions(
      state.intakeSession!,
    ).map((question) => question.questionKey);

    expect(state.intakeSession!.basics.hasWebsite, isFalse);
    expect(relevantKeys, isNot(contains('website')));
    expect(relevantKeys, contains('websitePlanned'));
  });

  test('resume finds the next unanswered question', () {
    final state = AppState();
    state.updateIntakeBasics(
      const IntakeBasics(
        companyName: 'Resume GmbH',
        shortDescription: 'Kurze Beschreibung',
        industry: 'Software',
        country: 'Österreich',
        primaryLanguage: 'de',
        additionalLanguages: 'Englisch',
        hasWebsite: false,
      ),
    );
    state.updateIntakeWebsiteAndSupport(
      const IntakeWebsiteAndSupport(websitePlanned: 'Noch offen'),
    );

    final next = IntakeChatFlow.nextQuestion(state.intakeSession!);

    expect(next, isNotNull);
    expect(next!.questionKey, 'supportEmail');
  });

  test('chat and wizard share the same intake data', () {
    final state = AppState();
    final question = IntakeChatFlow.questions.firstWhere(
      (question) => question.questionKey == 'targetGroup',
    );

    IntakeChatFlow.saveAnswer(state, question, 'Kleine lokale Unternehmen');

    expect(
      state.intakeSession!.targetGroups.targetGroup,
      'Kleine lokale Unternehmen',
    );
  });

  test('multi-line answers append without duplicates', () {
    final state = AppState();
    state.updateIntakeProducts(
      const IntakeProducts(importantProducts: 'App\nSupport'),
    );
    final question = IntakeChatFlow.questions.firstWhere(
      (question) => question.questionKey == 'importantProducts',
    );

    IntakeChatFlow.saveAnswer(state, question, 'Support\nKissen');

    expect(
      state.intakeSession!.products.importantProducts,
      'App\nSupport\nKissen',
    );
  });

  test('reviews yes walks through review detail path', () {
    final state = AppState();
    state.updateIntakeSourcesAndReviews(const IntakeSourcesAndReviews());
    final hasReviews = IntakeChatFlow.questions.firstWhere(
      (question) => question.questionKey == 'hasReviews',
    );

    IntakeChatFlow.saveAnswer(state, hasReviews, 'yes');

    expect(
      IntakeChatFlow.nextQuestion(state.intakeSession!)!.questionKey,
      'reviewPlatforms',
    );
    expect(
      IntakeChatFlow.relevantQuestions(
        state.intakeSession!,
      ).map((question) => question.questionKey),
      containsAll([
        'reviewPlatforms',
        'reviewCountEstimate',
        'reviewLinksOrFiles',
        'reviewTypes',
        'reviewsPubliclyUsable',
        'reviewsEmbeddedOnWebsite',
      ]),
    );
  });

  test('sensitive topics yes shows dependent detail questions', () {
    final state = AppState();
    state.updateIntakeGoalsAndRisks(const IntakeGoalsAndRisks());
    state.updateIntakeWebsiteAndSupport(const IntakeWebsiteAndSupport());
    final hasSensitiveTopics = IntakeChatFlow.questions.firstWhere(
      (question) => question.questionKey == 'hasSensitiveTopics',
    );

    IntakeChatFlow.saveAnswer(state, hasSensitiveTopics, 'yes');

    expect(
      IntakeChatFlow.nextQuestion(state.intakeSession!)!.questionKey,
      'sensitiveTopics',
    );
    expect(
      IntakeChatFlow.relevantQuestions(
        state.intakeSession!,
      ).map((question) => question.questionKey),
      containsAll([
        'sensitiveTopics',
        'prohibitedStatements',
        'botRestrictedTopics',
        'alwaysEscalateTopics',
        'legalRestrictions',
      ]),
    );
  });

  test('social no skips social detail questions', () {
    final state = AppState();
    state.updateIntakeMarketingAndChannels(const IntakeMarketingAndChannels());
    final hasSocialChannels = IntakeChatFlow.questions.firstWhere(
      (question) => question.questionKey == 'hasSocialChannels',
    );

    IntakeChatFlow.saveAnswer(state, hasSocialChannels, 'no');

    final relevantKeys = IntakeChatFlow.relevantQuestions(
      state.intakeSession!,
    ).map((question) => question.questionKey);
    expect(relevantKeys, isNot(contains('socialPlatforms')));
    expect(relevantKeys, contains('futureSocialPlatforms'));
  });

  test('resume works inside a website detail path', () {
    final state = AppState();
    state.updateIntakeBasics(const IntakeBasics(hasWebsite: true));
    state.updateIntakeWebsiteAndSupport(const IntakeWebsiteAndSupport());
    final website = IntakeChatFlow.questions.firstWhere(
      (question) => question.questionKey == 'website',
    );

    IntakeChatFlow.saveAnswer(state, website, 'https://example.com');

    expect(
      IntakeChatFlow.nextQuestion(state.intakeSession!)!.questionKey,
      'hasShop',
    );
  });

  test('detail answers are saved only into the selected workspace', () {
    final state = AppState();
    final otherBefore = state.companies
        .firstWhere((workspace) => workspace.company.id == 'schnurr-purr')
        .intakeSession!
        .sourcesAndReviews
        .reviewPlatforms;
    state.updateIntakeSourcesAndReviews(
      const IntakeSourcesAndReviews(hasReviews: true),
    );
    final reviewPlatforms = IntakeChatFlow.questions.firstWhere(
      (question) => question.questionKey == 'reviewPlatforms',
    );

    IntakeChatFlow.saveAnswer(state, reviewPlatforms, 'Google\nApp Store');

    expect(
      state.intakeSession!.sourcesAndReviews.reviewPlatforms,
      'Google\nApp Store',
    );
    expect(
      state.companies
          .firstWhere((workspace) => workspace.company.id == 'schnurr-purr')
          .intakeSession!
          .sourcesAndReviews
          .reviewPlatforms,
      otherBefore,
    );
  });

  test('mapping preview can process new detail fields', () {
    final state = AppState();
    state.updateIntakeWebsiteAndSupport(
      const IntakeWebsiteAndSupport(
        websiteUrl: 'https://new.example',
        preSalesQuestions: 'Was kostet das Produkt?',
      ),
    );
    state.updateIntakeSourcesAndReviews(
      const IntakeSourcesAndReviews(
        hasMaterials: true,
        materialDetails: 'Produkt-PDF',
        reviewPlatforms: 'Google Reviews',
      ),
    );
    state.updateIntakeGoalsAndRisks(
      const IntakeGoalsAndRisks(
        hasSensitiveTopics: true,
        alwaysEscalateTopics: 'Rechtliche Beschwerden',
      ),
    );

    final preview = state.generateIntakeMappingPreview();
    final labels = preview.suggestions.map((suggestion) => suggestion.label);

    expect(labels, contains('https://new.example'));
    expect(labels, contains('Produkt-PDF'));
    expect(labels, contains('Google Reviews'));
    expect(labels, contains('Was kostet das Produkt?'));
    expect(labels, contains('Rechtliche Beschwerden'));
  });

  test('multiChoice stores multiple values without duplicates', () {
    final state = AppState();
    state.updateIntakeMarketingAndChannels(
      const IntakeMarketingAndChannels(hasSocialChannels: true),
    );
    final question = IntakeChatFlow.questionByKey('socialPlatforms');

    IntakeChatFlow.saveAnswer(state, question, 'Facebook\nInstagram\nFacebook');

    expect(
      state.intakeSession!.marketingAndChannels.socialPlatforms,
      'Facebook\nInstagram',
    );
  });

  test('none selection removes other selected values', () {
    final state = AppState();
    state.updateIntakeMarketingAndChannels(
      const IntakeMarketingAndChannels(hasSocialChannels: true),
    );
    final question = IntakeChatFlow.questionByKey('socialPlatforms');

    IntakeChatFlow.saveAnswer(state, question, 'Facebook\nkeine\nInstagram');

    expect(state.intakeSession!.marketingAndChannels.socialPlatforms, 'keine');
  });

  test('other choice text is stored with the selected values', () {
    final state = AppState();
    state.updateIntakeMarketingAndChannels(
      const IntakeMarketingAndChannels(hasSocialChannels: true),
    );
    final question = IntakeChatFlow.questionByKey('socialPlatforms');

    IntakeChatFlow.saveAnswer(state, question, 'Instagram\nMastodon');

    expect(
      state.intakeSession!.marketingAndChannels.socialPlatforms,
      'Instagram\nMastodon',
    );
  });

  test('existing choice values remain available for editing', () {
    final state = AppState();
    state.updateIntakeMarketingAndChannels(
      const IntakeMarketingAndChannels(
        hasSocialChannels: true,
        socialPlatforms: 'Facebook\nInstagram',
      ),
    );
    final question = IntakeChatFlow.questionByKey('socialPlatforms');

    expect(question.value(state.intakeSession!), 'Facebook\nInstagram');
  });

  test('social follow-up choices only use selected platforms', () {
    final state = AppState();
    final l = lookupAppLocalizations(const Locale('en'));
    state.updateIntakeMarketingAndChannels(
      const IntakeMarketingAndChannels(
        hasSocialChannels: true,
        socialPlatforms: 'Facebook\nInstagram',
      ),
    );
    final question = IntakeChatFlow.questionByKey('activeChannels');

    expect(question.choiceOptions!(state.intakeSession!, l), [
      'Facebook',
      'Instagram',
    ]);
  });

  test('choice data stays in the selected workspace only', () {
    final state = AppState();
    final otherBefore = state.companies
        .firstWhere((workspace) => workspace.company.id == 'schnurr-purr')
        .intakeSession!
        .marketingAndChannels
        .socialPlatforms;
    state.updateIntakeMarketingAndChannels(
      const IntakeMarketingAndChannels(hasSocialChannels: true),
    );
    final question = IntakeChatFlow.questionByKey('socialPlatforms');

    IntakeChatFlow.saveAnswer(state, question, 'LinkedIn\nNewsletter');

    expect(
      state.intakeSession!.marketingAndChannels.socialPlatforms,
      'LinkedIn\nNewsletter',
    );
    expect(
      state.companies
          .firstWhere((workspace) => workspace.company.id == 'schnurr-purr')
          .intakeSession!
          .marketingAndChannels
          .socialPlatforms,
      otherBefore,
    );
  });

  test('wizard and chat share selected choice values', () {
    final state = AppState();
    final question = IntakeChatFlow.questionByKey('targetGroup');

    IntakeChatFlow.saveAnswer(state, question, 'private customers\nbusinesses');

    expect(
      state.intakeSession!.targetGroups.targetGroup,
      'private customers\nbusinesses',
    );
  });

  test('mapping preview processes selected choice values', () {
    final state = AppState();
    state.updateIntakeMarketingAndChannels(
      const IntakeMarketingAndChannels(
        socialPlatforms: 'Instagram\nNewsletter',
        advertisingChannels: 'Google Ads\nSEO',
        reachProblems: 'too few inquiries',
      ),
    );
    state.updateIntakeSourcesAndReviews(
      const IntakeSourcesAndReviews(
        reviewPlatforms: 'Google\nTrustpilot',
        materialDetails: 'PDF\nFAQ list',
      ),
    );
    state.updateIntakeGoalsAndRisks(
      const IntakeGoalsAndRisks(
        companyGoals: 'more inquiries\nbetter website',
        sensitiveTopics: 'data protection',
      ),
    );

    final labels = state.generateIntakeMappingPreview().suggestions.map(
      (suggestion) => suggestion.label,
    );

    expect(labels, contains('Google'));
    expect(labels, contains('Trustpilot'));
    expect(labels, contains('PDF'));
    expect(labels, contains('FAQ list'));
    expect(labels, contains('data protection'));
  });
}
