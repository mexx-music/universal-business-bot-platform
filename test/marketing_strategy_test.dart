import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/data/app_state.dart';
import 'package:universalbusiness/models/marketing_strategy.dart';
import 'package:universalbusiness/models/project_status.dart';

void main() {
  test('marketing strategy score and actions are derived per workspace', () {
    final state = AppState();

    final hbStrategy = state.marketingStrategy;
    expect(hbStrategy.score, inInclusiveRange(0, 100));
    expect(hbStrategy.actions, hasLength(MarketingActionType.values.length));
    expect(hbStrategy.recommendedActions, isNotEmpty);

    state.selectCompany('schnurr-purr');
    final schnurrPurrStrategy = state.marketingStrategy;
    expect(schnurrPurrStrategy.score, inInclusiveRange(0, 100));
    expect(
      schnurrPurrStrategy.actions,
      hasLength(MarketingActionType.values.length),
    );
  });

  test('marketing action updates only affect the selected workspace', () {
    final state = AppState();
    final hbAction = state.marketingStrategy.actions.first.copyWith(
      status: MarketingActionStatus.completed,
      notes: 'Ready for demo',
      plannedBudget: 250,
    );

    state.updateMarketingAction(hbAction);
    expect(
      state.marketingStrategy.actions
          .firstWhere((action) => action.id == hbAction.id)
          .status,
      MarketingActionStatus.completed,
    );

    state.selectCompany('schnurr-purr');
    expect(
      state.marketingStrategy.actions
          .firstWhere((action) => action.id == hbAction.id)
          .status,
      MarketingActionStatus.notStarted,
    );
  });

  test('completed marketing actions improve the project marketing status', () {
    final state = AppState();
    state.selectCompany('schnurr-purr');

    final before = state.projectStatus.items.firstWhere(
      (item) => item.type == ProjectTaskType.marketing,
    );

    for (final action in state.marketingStrategy.actions.take(3)) {
      state.updateMarketingAction(
        action.copyWith(status: MarketingActionStatus.completed),
      );
    }

    final after = state.projectStatus.items.firstWhere(
      (item) => item.type == ProjectTaskType.marketing,
    );
    expect(before.completion, isNot(ProjectCompletionState.complete));
    expect(after.completion, ProjectCompletionState.complete);
  });
}
