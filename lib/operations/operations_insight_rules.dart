import 'operations_demo.dart';

/// Fixed, transparent rules over [OperationsDemo]. This is deliberately not an
/// AI or LLM service: the same demo input always produces the same insights.
enum OperationsInsightKind {
  leadingProduct,
  risingSupport,
  firmwareDemand,
  priceInterest,
  faqOpportunity,
}

class OperationsInsightRules {
  const OperationsInsightRules._();

  static List<OperationsInsightKind> evaluate() {
    final insights = <OperationsInsightKind>[];

    final products = OperationsDemo.frequentProducts;
    if (products.length > 1 &&
        products.first.key == 'curebase' &&
        products.first.count > products[1].count) {
      insights.add(OperationsInsightKind.leadingProduct);
    }

    final recent = OperationsDemo.historyForDays(7);
    final previous = OperationsDemo.history
        .skip(OperationsDemo.history.length - 14)
        .take(7);
    final recentSupport = recent.fold<int>(
      0,
      (sum, day) => sum + day.supportQuestions,
    );
    final previousSupport = previous.fold<int>(
      0,
      (sum, day) => sum + day.supportQuestions,
    );
    if (recentSupport > previousSupport) {
      insights.add(OperationsInsightKind.risingSupport);
    }

    if (OperationsDemo.searchedTopics.any(
      (item) => item.key == 'firmware' && item.count >= 5,
    )) {
      insights.add(OperationsInsightKind.firmwareDemand);
    }

    if (OperationsDemo.priceRedirects >= 5) {
      insights.add(OperationsInsightKind.priceInterest);
    }

    if (OperationsDemo.today.knowledgeGaps >= 4) {
      insights.add(OperationsInsightKind.faqOpportunity);
    }

    return List.unmodifiable(insights);
  }
}
