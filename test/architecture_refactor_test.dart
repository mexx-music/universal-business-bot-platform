import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/calculators/business_strategy_calculator.dart';
import 'package:universalbusiness/calculators/marketing_strategy_calculator.dart';
import 'package:universalbusiness/calculators/project_status_calculator.dart';
import 'package:universalbusiness/data/mock_data.dart';
import 'package:universalbusiness/data/workspace_store.dart';
import 'package:universalbusiness/models/business_audit.dart';
import 'package:universalbusiness/models/knowledge_entry.dart';
import 'package:universalbusiness/models/marketing_strategy.dart';
import 'package:universalbusiness/services/intake_mapping_service.dart';

void main() {
  test('WorkspaceStore selects and updates one workspace safely', () {
    final store = WorkspaceStore();

    expect(store.selectedWorkspace.company.id, 'hb-cure');
    expect(store.selectCompany('unknown'), isFalse);
    expect(store.selectedWorkspace.company.id, 'hb-cure');

    expect(store.selectCompany('schnurr-purr'), isTrue);
    final beforeOther = store.findWorkspace('hb-cure')!.knowledgeEntries.length;

    store.updateWorkspace(
      'schnurr-purr',
      (workspace) => workspace.copyWith(knowledgeEntries: const []),
    );

    expect(store.selectedWorkspace.knowledgeEntries, isEmpty);
    expect(
      store.findWorkspace('hb-cure')!.knowledgeEntries.length,
      beforeOther,
    );
  });

  test(
    'ProjectStatusCalculator keeps workspaces separate and reacts to data',
    () {
      const calculator = ProjectStatusCalculator();
      final hb = MockData.companyWorkspaces.first;
      final sp = MockData.companyWorkspaces.last;

      final hbStatus = calculator.calculate(hb);
      final spStatus = calculator.calculate(sp);

      expect(hbStatus.items, hasLength(10));
      expect(spStatus.items, hasLength(10));
      expect(hb.company.id, isNot(sp.company.id));

      final hardened = sp.copyWith(
        auditItems: [
          for (final item in sp.auditItems)
            item.copyWith(status: AuditItemStatus.complete),
        ],
        knowledgeEntries: [
          ...sp.knowledgeEntries,
          for (var i = 0; i < 12; i++)
            KnowledgeEntry(
              id: 'extra-$i',
              title: 'Extra FAQ $i',
              content: 'Antwort $i',
              category: KnowledgeCategory.faq,
              riskLevel: RiskLevel.green,
              keywords: const ['extra'],
              source: 'Test',
              createdAt: DateTime(2026, 1, 1),
            ),
        ],
        marketingActions: [
          for (final action
              in const MarketingStrategyCalculator().actionsFor(sp).take(3))
            action.copyWith(status: MarketingActionStatus.completed),
        ],
      );

      expect(
        calculator.calculate(hardened).progress,
        greaterThan(spStatus.progress),
      );
      expect(
        sp.knowledgeEntries.length,
        MockData.companyWorkspaces.last.knowledgeEntries.length,
      );
    },
  );

  test(
    'MarketingStrategyCalculator returns bounded score and recommendations',
    () {
      const calculator = MarketingStrategyCalculator();
      final workspace = MockData.companyWorkspaces.last;
      final strategy = calculator.calculate(workspace);

      expect(strategy.score, inInclusiveRange(0, 100));
      expect(strategy.actions, hasLength(MarketingActionType.values.length));
      expect(strategy.recommendedActions, isNotEmpty);
      expect(workspace.marketingActions, isEmpty);
    },
  );

  test('BusinessStrategyCalculator derives goal progress without mutation', () {
    const calculator = BusinessStrategyCalculator();
    final workspace = MockData.companyWorkspaces.last;
    final beforeGoals = workspace.businessGoals;
    final strategy = calculator.calculate(workspace);

    expect(strategy.goals, isNotEmpty);
    expect(strategy.mainGoal, isNotNull);
    expect(strategy.averageProgress, inInclusiveRange(0, 1));
    expect(identical(workspace.businessGoals, beforeGoals), isTrue);
  });

  test(
    'IntakeMappingService creates preview and imports without mutating input',
    () {
      const service = IntakeMappingService();
      final workspace = MockData.companyWorkspaces.last;
      final preview = service.createPreview(workspace);
      final updated = service.importSelectedMapping(workspace, preview);

      expect(preview.suggestions, isNotEmpty);
      expect(updated.company.id, workspace.company.id);
      expect(identical(updated, workspace), isFalse);
      expect(workspace.intakeSession?.importedAt, isNull);
    },
  );
}
