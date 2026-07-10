import 'business_audit.dart';
import 'knowledge_entry.dart';
import 'product_or_service.dart';
import 'source_material.dart';

enum IntakeMappingTargetArea {
  companyProfile,
  products,
  businessRules,
  sources,
  knowledgeBase,
  audit,
  botSettings,
  internalNotes,
}

enum IntakeMappingAction {
  updateCompanyField,
  addProduct,
  appendInternalNote,
  addBusinessRuleDoNotSay,
  addBusinessRuleAllowedTopic,
  appendEscalationNotes,
  addSourceMaterial,
  addKnowledgeEntry,
  updateAuditArea,
  addBotBlockedTopic,
  setBotEscalateRedFlags,
  setBotHandoverMessage,
}

class IntakeMappingSuggestion {
  final String id;
  final IntakeMappingTargetArea targetArea;
  final IntakeMappingAction action;
  final String label;
  final String proposedValue;
  final String? currentValue;
  final bool conflict;
  final bool selected;
  final String? fieldKey;
  final ProductType? productType;
  final SourceMaterialType? sourceType;
  final RiskLevel? riskLevel;
  final AuditArea? auditArea;
  final AuditItemStatus? auditStatus;

  const IntakeMappingSuggestion({
    required this.id,
    required this.targetArea,
    required this.action,
    required this.label,
    required this.proposedValue,
    this.currentValue,
    required this.conflict,
    required this.selected,
    this.fieldKey,
    this.productType,
    this.sourceType,
    this.riskLevel,
    this.auditArea,
    this.auditStatus,
  });

  IntakeMappingSuggestion copyWith({bool? selected}) {
    return IntakeMappingSuggestion(
      id: id,
      targetArea: targetArea,
      action: action,
      label: label,
      proposedValue: proposedValue,
      currentValue: currentValue,
      conflict: conflict,
      selected: selected ?? this.selected,
      fieldKey: fieldKey,
      productType: productType,
      sourceType: sourceType,
      riskLevel: riskLevel,
      auditArea: auditArea,
      auditStatus: auditStatus,
    );
  }
}

class IntakeMappingPreview {
  final List<IntakeMappingSuggestion> suggestions;
  final List<String> warnings;
  final DateTime generatedAt;

  const IntakeMappingPreview({
    required this.suggestions,
    required this.warnings,
    required this.generatedAt,
  });

  List<IntakeMappingSuggestion> suggestionsFor(
    IntakeMappingTargetArea targetArea,
  ) {
    return suggestions
        .where((suggestion) => suggestion.targetArea == targetArea)
        .toList();
  }

  IntakeMappingPreview copyWithSuggestionSelected(String id, bool selected) {
    return IntakeMappingPreview(
      suggestions: [
        for (final suggestion in suggestions)
          if (suggestion.id == id)
            suggestion.copyWith(selected: selected)
          else
            suggestion,
      ],
      warnings: warnings,
      generatedAt: generatedAt,
    );
  }
}
