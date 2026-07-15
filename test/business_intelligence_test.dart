import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/calculators/business_intelligence_calculator.dart';
import 'package:universalbusiness/data/app_state.dart';
import 'package:universalbusiness/data/mock_data.dart';
import 'package:universalbusiness/models/business_intelligence.dart';

void main() {
  test(
    'business intelligence creates a timeline for the selected workspace',
    () {
      const calculator = BusinessIntelligenceCalculator();
      final workspace = MockData.companyWorkspaces.first;
      final snapshot = calculator.calculate(workspace);

      expect(snapshot.timeline, isNotEmpty);
      expect(
        snapshot.timeline.every(
          (event) => event.workspaceId == workspace.company.id,
        ),
        isTrue,
      );
      expect(
        snapshot.timeline.any(
          (event) => event.type == BusinessTimelineEventType.companyCreated,
        ),
        isTrue,
      );
    },
  );

  test('business intelligence keeps workspace timelines separated', () {
    final state = AppState();

    final hbSnapshot = state.businessIntelligence;
    final hbId = state.company.id;

    state.selectCompany('schnurr-purr');
    final schnurrPurrSnapshot = state.businessIntelligence;
    final schnurrPurrId = state.company.id;

    expect(hbId, isNot(schnurrPurrId));
    expect(
      hbSnapshot.timeline.every((event) => event.workspaceId == hbId),
      isTrue,
    );
    expect(
      schnurrPurrSnapshot.timeline.every(
        (event) => event.workspaceId == schnurrPurrId,
      ),
      isTrue,
    );
  });

  test('business intelligence exposes KPI cards and development signals', () {
    const calculator = BusinessIntelligenceCalculator();
    final snapshot = calculator.calculate(MockData.companyWorkspaces.first);

    expect(snapshot.kpiTrends, hasLength(BusinessKpiType.values.length));
    expect(snapshot.developmentSignals, isNotEmpty);
    expect(
      snapshot.kpiTrends.every((trend) => trend.route.startsWith('/')),
      isTrue,
    );
    expect(
      snapshot.developmentSignals.every(
        (signal) => signal.route.startsWith('/'),
      ),
      isTrue,
    );
  });

  test('business intelligence creates highlights and monthly overview', () {
    const calculator = BusinessIntelligenceCalculator();
    final snapshot = calculator.calculate(MockData.companyWorkspaces.last);

    expect(snapshot.highlights, isNotEmpty);
    expect(snapshot.monthlyOverview.changeCount, greaterThanOrEqualTo(0));
    expect(snapshot.monthlyOverview.newSources, greaterThanOrEqualTo(0));
    expect(
      snapshot.highlights.every((highlight) => highlight.route.startsWith('/')),
      isTrue,
    );
  });
}
