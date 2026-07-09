enum BotStatus { draft, testReady, active }

enum BotAnswerStyle { short, balanced, detailed }

class BotConfiguration {
  final BotStatus status;
  final BotAnswerStyle answerStyle;
  final String defaultLanguage;
  final bool useDisclaimer;
  final String disclaimerText;
  final bool alwaysEscalateRedFlags;
  final bool escalateNoMatch;
  final bool escalateYellowRisk;
  final List<String> allowedTopics;
  final List<String> blockedTopics;
  final String handoverMessage;

  const BotConfiguration({
    required this.status,
    required this.answerStyle,
    required this.defaultLanguage,
    required this.useDisclaimer,
    required this.disclaimerText,
    required this.alwaysEscalateRedFlags,
    required this.escalateNoMatch,
    required this.escalateYellowRisk,
    required this.allowedTopics,
    required this.blockedTopics,
    required this.handoverMessage,
  });

  BotConfiguration copyWith({
    BotStatus? status,
    BotAnswerStyle? answerStyle,
    String? defaultLanguage,
    bool? useDisclaimer,
    String? disclaimerText,
    bool? alwaysEscalateRedFlags,
    bool? escalateNoMatch,
    bool? escalateYellowRisk,
    List<String>? allowedTopics,
    List<String>? blockedTopics,
    String? handoverMessage,
  }) {
    return BotConfiguration(
      status: status ?? this.status,
      answerStyle: answerStyle ?? this.answerStyle,
      defaultLanguage: defaultLanguage ?? this.defaultLanguage,
      useDisclaimer: useDisclaimer ?? this.useDisclaimer,
      disclaimerText: disclaimerText ?? this.disclaimerText,
      alwaysEscalateRedFlags:
          alwaysEscalateRedFlags ?? this.alwaysEscalateRedFlags,
      escalateNoMatch: escalateNoMatch ?? this.escalateNoMatch,
      escalateYellowRisk: escalateYellowRisk ?? this.escalateYellowRisk,
      allowedTopics: allowedTopics ?? this.allowedTopics,
      blockedTopics: blockedTopics ?? this.blockedTopics,
      handoverMessage: handoverMessage ?? this.handoverMessage,
    );
  }
}
