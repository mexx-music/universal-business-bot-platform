import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/data/mock_data.dart';
import 'package:universalbusiness/l10n/app_localizations.dart';
import 'package:universalbusiness/models/bot_question_log.dart';
import 'package:universalbusiness/models/business_audit.dart';
import 'package:universalbusiness/models/business_strategy.dart';
import 'package:universalbusiness/models/knowledge_entry.dart';
import 'package:universalbusiness/models/source_material.dart';

void main() {
  test('HB Cure workspace contains Klaus company profile data', () {
    final workspace = MockData.companyWorkspaces.firstWhere(
      (workspace) => workspace.company.id == 'hb-cure',
    );

    expect(workspace.company.name, 'Healing und Balance GmbH');
    expect(workspace.company.website, 'https://www.healing-balance.com');
    expect(workspace.company.supportEmail, 'semper@healing-balance.com');
    expect(workspace.company.supportPhone, '+43 660 6506900');
    expect(workspace.company.industry, 'Health / frequency technology');
    expect(workspace.company.primaryLanguage, 'en');
    expect(workspace.company.description, contains('complementary use'));
    expect(workspace.company.description, contains('do not replace'));
    expect(
      workspace.company.internalNotes,
      contains('Managing Director Klaus Semper'),
    );
  });

  test(
    'confirmed and missing priorities are represented without invention',
    () {
      final session = MockData.companyWorkspaces
          .firstWhere((workspace) => workspace.company.id == 'hb-cure')
          .intakeSession!;

      expect(
        session.goalsAndRisks.shortTermPriorities,
        contains('Customer service: 5 out of 5'),
      );
      expect(
        session.goalsAndRisks.shortTermPriorities,
        contains('Knowledge base: 5 out of 5'),
      );
      expect(
        session.goalsAndRisks.shortTermPriorities,
        contains('Marketing: not rated yet'),
      );
      expect(
        session.goalsAndRisks.shortTermPriorities,
        contains('Website: not rated yet'),
      );
      expect(session.products.importantProducts, isEmpty);
      expect(session.products.priorityProducts, isEmpty);
    },
  );

  test('open Klaus intake details are visible as workspace gaps', () {
    final workspace = MockData.companyWorkspaces.firstWhere(
      (workspace) => workspace.company.id == 'hb-cure',
    );

    expect(
      workspace.auditItems.any(
        (item) =>
            item.title == 'Open company details' &&
            item.status == AuditItemStatus.missing &&
            item.priority == AuditPriority.high,
      ),
      isTrue,
    );
    expect(
      workspace.sourceMaterials.any(
        (source) =>
            source.title == 'Open company details' &&
            source.status == SourceMaterialStatus.newItem,
      ),
      isTrue,
    );
    expect(workspace.company.internalNotes, contains('exact inquiry channels'));
  });

  test('HB Cure keeps Human Review active for sensitive content', () {
    final workspace = MockData.companyWorkspaces.firstWhere(
      (workspace) => workspace.company.id == 'hb-cure',
    );

    expect(workspace.botConfiguration.alwaysEscalateRedFlags, isTrue);
    expect(workspace.botConfiguration.escalateNoMatch, isTrue);
    expect(workspace.botConfiguration.escalateYellowRisk, isTrue);
    expect(
      workspace.botConfiguration.handoverMessage,
      contains('human review'),
    );
  });

  test('medical and legal questions are not automatically approved', () {
    final workspace = MockData.companyWorkspaces.firstWhere(
      (workspace) => workspace.company.id == 'hb-cure',
    );

    expect(
      workspace.knowledgeEntries
          .where((entry) => entry.riskLevel == RiskLevel.red)
          .expand((entry) => entry.keywords)
          .toSet(),
      containsAll(['heilung', 'diagnose', 'therapie']),
    );
    expect(
      workspace.botLogs.where(
        (log) =>
            log.reviewStatus != ReviewStatus.closed &&
            (log.reviewReason == ReviewReason.redFlag ||
                log.reviewReason == ReviewReason.yellowRisk),
      ),
      isNotEmpty,
    );
  });

  test('SchnurrPurr demo data stays unchanged', () {
    final workspace = MockData.companyWorkspaces.firstWhere(
      (workspace) => workspace.company.id == 'schnurr-purr',
    );

    expect(workspace.company.name, 'SchnurrPurr');
    expect(workspace.company.website, 'https://www.schnurrpurr.example');
    expect(
      workspace.knowledgeEntries.map((entry) => entry.id),
      contains('sp-k1'),
    );
  });

  test('German and English localizations are still configured', () {
    expect(
      AppLocalizations.supportedLocales.map((locale) => locale.languageCode),
      containsAll(['de', 'en']),
    );
  });

  test('Klaus marketing direction is available in planned actions', () {
    final workspace = MockData.companyWorkspaces.firstWhere(
      (workspace) => workspace.company.id == 'hb-cure',
    );

    expect(
      workspace.marketingActions.map((action) => action.notes).join('\n'),
      contains('No automatic publishing'),
    );
    expect(
      workspace.businessGoals.where(
        (goal) =>
            goal.priority == BusinessGoalPriority.high &&
            goal.description.contains('5 out of 5'),
      ),
      hasLength(2),
    );
  });
}
