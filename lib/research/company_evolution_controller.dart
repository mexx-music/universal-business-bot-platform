import 'package:flutter/widgets.dart';

import 'models/company_research.dart';
import 'models/company_snapshot.dart';
import 'models/company_timeline_event.dart';
import 'models/research_document.dart';
import 'models/research_evidence.dart';
import 'research_runtime.dart';

/// View-model for the Company Evolution screen.
///
/// The UI talks only to this controller; the controller talks only to
/// [ResearchRuntime]. No widget touches the repository or the demo data
/// directly, and no research/sorting logic lives in the UI — timelines are
/// sorted by the model/runtime and evidence is always resolved via document id.
class CompanyEvolutionController extends ChangeNotifier {
  CompanyEvolutionController(this._runtime) : _companies = _runtime.companies {
    _selectedId = _companies.isEmpty ? null : _companies.first.companyId;
  }

  final ResearchRuntime _runtime;
  final List<CompanyResearch> _companies;
  String? _selectedId;

  /// All researched companies, in stable order.
  List<CompanyResearch> get companies => _companies;

  bool get hasCompanies => _companies.isNotEmpty;

  String? get selectedCompanyId => _selectedId;

  /// The currently selected company bundle, or null when there are none.
  CompanyResearch? get selectedCompany {
    final id = _selectedId;
    if (id == null) return null;
    return _runtime.company(id);
  }

  CompanySnapshot? get snapshot => selectedCompany?.snapshot;

  /// Timeline of the selected company, oldest → newest (sorted by the runtime).
  List<CompanyTimelineEvent> get timeline {
    final id = _selectedId;
    if (id == null) return const [];
    return _runtime.timeline(id);
  }

  List<ResearchDocument> get documents =>
      selectedCompany?.documents ?? const [];

  /// Evidence belonging to a document of the selected company. Always resolved
  /// through the runtime by [documentId] — evidence can never leak across
  /// documents.
  List<ResearchEvidence> evidenceForDocument(String documentId) {
    final id = _selectedId;
    if (id == null) return const [];
    return _runtime.evidenceForDocument(id, documentId);
  }

  /// Switches the selected company. No-op for the current or an unknown id.
  void selectCompany(String companyId) {
    if (companyId == _selectedId) return;
    if (_runtime.company(companyId) == null) return;
    _selectedId = companyId;
    notifyListeners();
  }

  static CompanyEvolutionController of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<CompanyEvolutionScope>()!
        .notifier!;
  }
}

class CompanyEvolutionScope
    extends InheritedNotifier<CompanyEvolutionController> {
  const CompanyEvolutionScope({
    super.key,
    required super.notifier,
    required super.child,
  });
}
