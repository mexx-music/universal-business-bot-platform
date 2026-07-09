enum SourceMaterialType { website, pdf, faq, review, social, note, other }

enum SourceMaterialStatus { newItem, reviewed, converted, ignored }

class SourceMaterial {
  final String id;
  final String title;
  final SourceMaterialType type;
  final String? url;
  final String? contentSnippet;
  final SourceMaterialStatus status;
  final List<String> relatedKnowledgeEntryIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? notes;

  const SourceMaterial({
    required this.id,
    required this.title,
    required this.type,
    this.url,
    this.contentSnippet,
    required this.status,
    this.relatedKnowledgeEntryIds = const [],
    required this.createdAt,
    required this.updatedAt,
    this.notes,
  });

  SourceMaterial copyWith({
    String? title,
    SourceMaterialType? type,
    Object? url = _keep,
    Object? contentSnippet = _keep,
    SourceMaterialStatus? status,
    List<String>? relatedKnowledgeEntryIds,
    DateTime? updatedAt,
    Object? notes = _keep,
  }) {
    return SourceMaterial(
      id: id,
      title: title ?? this.title,
      type: type ?? this.type,
      url: identical(url, _keep) ? this.url : url as String?,
      contentSnippet: identical(contentSnippet, _keep)
          ? this.contentSnippet
          : contentSnippet as String?,
      status: status ?? this.status,
      relatedKnowledgeEntryIds:
          relatedKnowledgeEntryIds ?? this.relatedKnowledgeEntryIds,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: identical(notes, _keep) ? this.notes : notes as String?,
    );
  }
}

const Object _keep = Object();
