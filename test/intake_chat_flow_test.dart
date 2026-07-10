import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/data/app_state.dart';
import 'package:universalbusiness/data/intake_chat_flow.dart';
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
    state.updateIntakeBasics(const IntakeBasics());
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
      IntakeChatFlow.relevantQuestions(
        state.intakeSession!,
      ).map((question) => question.questionKey),
      containsAll(['website', 'hasShop', 'importantPages', 'hasFaqArea']),
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
}
