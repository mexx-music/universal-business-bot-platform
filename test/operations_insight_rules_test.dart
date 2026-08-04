import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/operations/operations_demo.dart';
import 'package:universalbusiness/operations/operations_insight_rules.dart';

void main() {
  test('history is a coherent fixed 30-day demo dataset', () {
    expect(OperationsDemo.history, hasLength(30));
    expect(OperationsDemo.history.last, same(OperationsDemo.today));
    expect(OperationsDemo.historyForDays(7), hasLength(7));
    expect(OperationsDemo.historyForDays(30), hasLength(30));
    expect(OperationsDemo.today.questions, 24);
    expect(OperationsDemo.today.answered, lessThanOrEqualTo(24));
    expect(
      OperationsDemo.knowledgeQuality.answerabilityTotal,
      OperationsDemo.today.questions,
    );
  });

  test(
    'business impact values are conservative deterministic calculations',
    () {
      expect(OperationsDemo.estimatedMinutesSaved, 147);
      expect(OperationsDemo.avoidedSupportRequests, 14);
      expect(OperationsDemo.consistentAnswers, OperationsDemo.today.answered);
      expect(OperationsDemo.humanReviewRate, 67);
    },
  );

  test('transparent rules produce all five expected demo insights', () {
    expect(OperationsInsightRules.evaluate(), [
      OperationsInsightKind.leadingProduct,
      OperationsInsightKind.risingSupport,
      OperationsInsightKind.firmwareDemand,
      OperationsInsightKind.priceInterest,
      OperationsInsightKind.faqOpportunity,
    ]);
  });
}
