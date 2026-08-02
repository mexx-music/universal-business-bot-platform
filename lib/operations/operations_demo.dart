// Operations Dashboard demo data (BLOCK 7). Static, illustrative numbers only —
// no live data, no backend, no AI, no background processes. Every value is
// clearly labelled DEMO in the UI. Text labels are localized in the screen;
// this holds only the structural figures and fixed timeline times.

class OperationsDemo {
  const OperationsDemo._();

  // --- Today's metrics ---
  static const int customerQuestions = 24;
  static const int answered = 21;
  static const int gapsDetected = 4;
  static const int suggestionsCreated = 3;
  static const int sourcesUsed = 57;
  static const int entriesAdopted = 2;

  // --- Activity timeline (fixed demo times, paired with l10n by index) ---
  static const List<String> timelineTimes = [
    '09:12',
    '09:18',
    '09:20',
    '09:45',
    '10:02',
    '10:03',
  ];

  // --- Human decisions (BusinessBrain never decides on its own) ---
  static const int decisionsTotal = 6;
  static const int decisionsAdopted = 3;
  static const int decisionsInProgress = 2;
  static const int decisionsRejected = 1;

  // --- Knowledge-base quality distribution (faq, guides, technical,
  //     problems, definitions) ---
  static const List<int> qualityCounts = [9, 6, 5, 4, 3];

  static int get qualityTotal => qualityCounts.fold(0, (sum, v) => sum + v);

  static int get qualityMax => qualityCounts.reduce((a, b) => a > b ? a : b);
}
