import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/data/app_state.dart';
import 'package:universalbusiness/models/business_strategy.dart';

void main() {
  test(
    'business strategy progress is calculated from linked workspace areas',
    () {
      final state = AppState();
      final strategy = state.businessStrategy;

      expect(strategy.goals, isNotEmpty);
      expect(strategy.mainGoal, isNotNull);
      expect(strategy.averageProgress, inInclusiveRange(0, 1));
      expect(strategy.goals.first.moduleContributions, isNotEmpty);
    },
  );

  test('business goal updates only affect the selected workspace', () {
    final state = AppState();
    final goal = state.businessGoals.first;

    state.updateBusinessGoal(
      goal.copyWith(status: BusinessGoalStatus.achieved, comment: 'Done'),
    );
    expect(state.businessGoals.first.status, BusinessGoalStatus.achieved);

    state.selectCompany('schnurr-purr');
    expect(
      state.businessGoals.any((otherGoal) => otherGoal.id == goal.id),
      isFalse,
    );
  });

  test('business recommendations point to existing module routes', () {
    final state = AppState();
    final recommendation = state.businessStrategy.nextRecommendation;

    expect(recommendation, isNotNull);
    expect(recommendation!.route, startsWith('/'));
    expect(recommendation.goal.title, isNotEmpty);
  });
}
