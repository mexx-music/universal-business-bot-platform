enum AuditArea {
  companyProfile,
  website,
  products,
  supportKnowledge,
  trustMaterial,
  socialPresence,
  sources,
  riskRules,
  botReadiness,
}

enum AuditItemStatus { missing, partial, complete }

enum AuditPriority { low, medium, high }

class BusinessAuditItem {
  final String id;
  final AuditArea area;
  final String title;
  final String description;
  final AuditItemStatus status;
  final AuditPriority priority;
  final String? note;
  final String? recommendation;

  const BusinessAuditItem({
    required this.id,
    required this.area,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    this.note,
    this.recommendation,
  });

  BusinessAuditItem copyWith({
    AuditItemStatus? status,
    AuditPriority? priority,
    Object? note = _keep,
  }) {
    return BusinessAuditItem(
      id: id,
      area: area,
      title: title,
      description: description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      note: identical(note, _keep) ? this.note : note as String?,
      recommendation: recommendation,
    );
  }
}

const Object _keep = Object();
