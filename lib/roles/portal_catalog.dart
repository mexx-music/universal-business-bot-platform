import 'models/portal_role.dart';

/// Single place that defines the *reduced navigation* per portal tier and
/// employee department. Pure data — no enforcement, no login, no backend.
///
/// Invariants (verified by tests):
/// - The company (admin) portal is the superset of all internal sections.
/// - Employee portals are a subset of the company portal and never contain a
///   system-setting section.
/// - The customer portal contains only public sections.
/// - Every tier resolves to the same [RolePortal.knowledgeSource].
class PortalCatalog {
  const PortalCatalog._();

  /// Full internal navigation for the firm administrator.
  static const List<PortalSection> _companySections = [
    PortalSection.dashboard,
    PortalSection.knowledge,
    PortalSection.knowledgeBuilder,
    PortalSection.products,
    PortalSection.aiAssistant,
    PortalSection.reviewAnswers,
    PortalSection.community,
    PortalSection.analytics,
    PortalSection.companyEvolution,
    PortalSection.research,
    PortalSection.competitors,
    PortalSection.marketing,
    PortalSection.sources,
    PortalSection.employees,
    PortalSection.roles,
    PortalSection.aiSettings,
  ];

  /// Public-only navigation for customers.
  static const List<PortalSection> _customerSections = [
    PortalSection.customerAssistant,
    PortalSection.contact,
  ];

  static List<PortalSection> _employeeSections(EmployeeRole role) {
    return switch (role) {
      EmployeeRole.support => const [
        PortalSection.knowledge,
        PortalSection.knowledgeBuilder,
        PortalSection.reviewAnswers,
        PortalSection.aiAssistant,
      ],
      EmployeeRole.marketing => const [
        PortalSection.marketing,
        PortalSection.community,
        PortalSection.aiAssistant,
      ],
      EmployeeRole.technical => const [
        PortalSection.knowledge,
        PortalSection.knowledgeBuilder,
        PortalSection.sources,
        PortalSection.aiAssistant,
      ],
      EmployeeRole.sales => const [
        PortalSection.products,
        PortalSection.knowledge,
        PortalSection.aiAssistant,
      ],
    };
  }

  static RolePortal company() =>
      const RolePortal(tier: PortalTier.company, sections: _companySections);

  static RolePortal employee(EmployeeRole role) => RolePortal(
    tier: PortalTier.employee,
    employeeRole: role,
    sections: _employeeSections(role),
  );

  static RolePortal customer() =>
      const RolePortal(tier: PortalTier.customer, sections: _customerSections);

  /// Resolves any persona. [role] is honoured only for the employee tier.
  static RolePortal forPersona(PortalTier tier, {EmployeeRole? role}) {
    return switch (tier) {
      PortalTier.company => company(),
      PortalTier.employee => employee(role ?? EmployeeRole.support),
      PortalTier.customer => customer(),
    };
  }
}
