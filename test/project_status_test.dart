import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/data/app_state.dart';
import 'package:universalbusiness/models/project_status.dart';

void main() {
  test('project status is calculated for the selected workspace', () {
    final state = AppState();

    final hbStatus = state.projectStatus;
    expect(hbStatus.items, hasLength(10));
    expect(hbStatus.progress, greaterThanOrEqualTo(0));
    expect(hbStatus.progress, lessThanOrEqualTo(1));

    state.selectCompany('schnurr-purr');
    final schnurrPurrStatus = state.projectStatus;

    expect(state.company.name, 'SchnurrPurr');
    expect(schnurrPurrStatus.items, hasLength(10));
    expect(
      schnurrPurrStatus.items.any(
        (item) => item.type == ProjectTaskType.companyProfile,
      ),
      isTrue,
    );
  });

  test('project recommendations expose a direct navigation target', () {
    final state = AppState();
    final recommendation = state.projectStatus.nextRecommendation;

    expect(recommendation, isNotNull);
    expect(recommendation!.route, startsWith('/'));
    expect(recommendation.priority, isA<ProjectTaskPriority>());
  });
}
