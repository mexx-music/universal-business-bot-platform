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

  test('yes/no answer skips website URL follow-up when website is absent', () {
    final state = AppState();
    state.updateIntakeBasics(const IntakeBasics());

    final hasWebsite = IntakeChatFlow.questions.firstWhere(
      (question) => question.questionKey == 'hasWebsite',
    );
    final website = IntakeChatFlow.questions.firstWhere(
      (question) => question.questionKey == 'website',
    );

    IntakeChatFlow.saveAnswer(state, hasWebsite, 'no');

    expect(state.intakeSession!.basics.hasWebsite, isFalse);
    expect(website.shouldAsk(state.intakeSession!), isFalse);
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
}
