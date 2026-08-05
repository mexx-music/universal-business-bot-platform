import 'research_enums.dart';

/// One dated event in a company's history.
///
/// The [ResearchRuntime] returns these already sorted; the model itself is a
/// plain value object.
class CompanyTimelineEvent {
  const CompanyTimelineEvent({
    required this.id,
    required this.companyId,
    required this.date,
    required this.title,
    required this.description,
    required this.category,
  });

  final String id;
  final String companyId;
  final DateTime date;
  final String title;
  final String description;
  final TimelineCategory category;
}
