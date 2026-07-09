class BusinessRules {
  final String brandVoice;
  final List<String> doNotSay;
  final List<String> allowedSupportTopics;
  final String escalationNotes;
  final String? disclaimerText;

  const BusinessRules({
    required this.brandVoice,
    required this.doNotSay,
    required this.allowedSupportTopics,
    required this.escalationNotes,
    this.disclaimerText,
  });

  BusinessRules copyWith({
    String? brandVoice,
    List<String>? doNotSay,
    List<String>? allowedSupportTopics,
    String? escalationNotes,
    Object? disclaimerText = _keep,
  }) {
    return BusinessRules(
      brandVoice: brandVoice ?? this.brandVoice,
      doNotSay: doNotSay ?? this.doNotSay,
      allowedSupportTopics: allowedSupportTopics ?? this.allowedSupportTopics,
      escalationNotes: escalationNotes ?? this.escalationNotes,
      disclaimerText: identical(disclaimerText, _keep)
          ? this.disclaimerText
          : disclaimerText as String?,
    );
  }
}

const Object _keep = Object();
