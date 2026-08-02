import 'package:flutter/material.dart';

// Role & portal model (BLOCK 3). Structure only: this describes which areas
// each portal *shows*; it enforces nothing. There is no login, no permission
// check and no backend here — enforcement is deliberately out of scope. All
// three tiers read from the same knowledge base (one source of truth); new
// knowledge is only maintained in the company portal.

/// The three portal tiers that share one knowledge base.
enum PortalTier { company, employee, customer }

/// Department a company employee belongs to (drives their reduced navigation).
enum EmployeeRole { support, marketing, technical, sales }

/// A navigable area of the platform. Some map to an existing route; a few are
/// conceptual placeholders for areas that live in other blocks.
enum PortalSection {
  dashboard,
  knowledge,
  knowledgeBuilder,
  products,
  aiAssistant,
  reviewAnswers,
  community,
  analytics,
  companyEvolution,
  research,
  competitors,
  marketing,
  sources,
  employees,
  roles,
  aiSettings,
  customerAssistant,
  contact,
}

/// Static metadata for a [PortalSection].
class PortalSectionInfo {
  const PortalSectionInfo({
    required this.icon,
    this.route,
    this.isPublic = false,
    this.isSystemSetting = false,
  });

  final IconData icon;

  /// Existing app route, or null for conceptual sections.
  final String? route;

  /// Visible to customers (public bereich).
  final bool isPublic;

  /// System/administration area an employee must never access.
  final bool isSystemSetting;
}

extension PortalSectionX on PortalSection {
  PortalSectionInfo get info => switch (this) {
    PortalSection.dashboard => const PortalSectionInfo(
      icon: Icons.dashboard_outlined,
      route: '/dashboard',
    ),
    PortalSection.knowledge => const PortalSectionInfo(
      icon: Icons.library_books_outlined,
      route: '/knowledge',
    ),
    PortalSection.knowledgeBuilder => const PortalSectionInfo(
      icon: Icons.auto_stories_outlined,
      route: '/knowledge-builder',
    ),
    PortalSection.products => const PortalSectionInfo(
      icon: Icons.inventory_2_outlined,
      route: '/company',
    ),
    PortalSection.aiAssistant => const PortalSectionInfo(
      icon: Icons.smart_toy_outlined,
      route: '/bot-test',
    ),
    PortalSection.reviewAnswers => const PortalSectionInfo(
      icon: Icons.rate_review_outlined,
      route: '/review',
    ),
    PortalSection.community => const PortalSectionInfo(
      icon: Icons.radar_outlined,
      route: '/community',
    ),
    PortalSection.analytics => const PortalSectionInfo(
      icon: Icons.insights_outlined,
      route: '/business-intelligence',
    ),
    PortalSection.companyEvolution => const PortalSectionInfo(
      icon: Icons.timeline_outlined,
      route: '/company-evolution',
    ),
    PortalSection.research => const PortalSectionInfo(
      icon: Icons.travel_explore_outlined,
    ),
    PortalSection.competitors => const PortalSectionInfo(
      icon: Icons.groups_2_outlined,
    ),
    PortalSection.marketing => const PortalSectionInfo(
      icon: Icons.campaign_outlined,
      route: '/marketing-strategy',
    ),
    PortalSection.sources => const PortalSectionInfo(
      icon: Icons.source_outlined,
      route: '/sources',
    ),
    PortalSection.employees => const PortalSectionInfo(
      icon: Icons.badge_outlined,
      isSystemSetting: true,
    ),
    PortalSection.roles => const PortalSectionInfo(
      icon: Icons.admin_panel_settings_outlined,
      isSystemSetting: true,
    ),
    PortalSection.aiSettings => const PortalSectionInfo(
      icon: Icons.tune_outlined,
      route: '/bot-settings',
      isSystemSetting: true,
    ),
    PortalSection.customerAssistant => const PortalSectionInfo(
      icon: Icons.support_agent_outlined,
      isPublic: true,
    ),
    PortalSection.contact => const PortalSectionInfo(
      icon: Icons.mail_outline,
      isPublic: true,
    ),
  };

  IconData get icon => info.icon;
  String? get route => info.route;
  bool get isPublic => info.isPublic;
  bool get isSystemSetting => info.isSystemSetting;
}

/// A resolved portal for one persona: the reduced set of visible sections plus
/// the shared knowledge source. Immutable, descriptive — no behaviour.
class RolePortal {
  const RolePortal({
    required this.tier,
    required this.sections,
    this.employeeRole,
  });

  final PortalTier tier;
  final EmployeeRole? employeeRole;
  final List<PortalSection> sections;

  /// The one source of truth every tier reads from.
  String get knowledgeSource => 'company-knowledge-base';

  bool canAccess(PortalSection section) => sections.contains(section);
}
