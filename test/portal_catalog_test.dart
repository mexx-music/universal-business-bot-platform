import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/roles/models/portal_role.dart';
import 'package:universalbusiness/roles/portal_catalog.dart';

void main() {
  group('PortalCatalog', () {
    final company = PortalCatalog.company();
    final customer = PortalCatalog.customer();
    final employees = [
      for (final r in EmployeeRole.values) PortalCatalog.employee(r),
    ];

    test('company (admin) portal has full access incl. system settings', () {
      expect(company.tier, PortalTier.company);
      expect(company.canAccess(PortalSection.aiSettings), isTrue);
      expect(company.canAccess(PortalSection.roles), isTrue);
      expect(company.canAccess(PortalSection.employees), isTrue);
      expect(company.canAccess(PortalSection.knowledgeBuilder), isTrue);
    });

    test('every employee portal is a subset of the company portal', () {
      for (final e in employees) {
        for (final s in e.sections) {
          expect(
            company.sections.contains(s),
            isTrue,
            reason: '${e.employeeRole} section $s not in company portal',
          );
        }
      }
    });

    test('employees never see system settings', () {
      for (final e in employees) {
        expect(e.canAccess(PortalSection.aiSettings), isFalse);
        expect(e.canAccess(PortalSection.roles), isFalse);
        expect(e.canAccess(PortalSection.employees), isFalse);
        expect(e.sections.any((s) => s.isSystemSetting), isFalse);
      }
    });

    test('employees see internal (non-public) areas only', () {
      for (final e in employees) {
        expect(e.sections, isNotEmpty);
        expect(e.sections.any((s) => s.isPublic), isFalse);
      }
    });

    test('customer portal is public-only, no internal data', () {
      expect(customer.sections.every((s) => s.isPublic), isTrue);
      expect(customer.canAccess(PortalSection.customerAssistant), isTrue);
      expect(customer.canAccess(PortalSection.contact), isTrue);
      // No internal / research / community / employee / settings areas.
      for (final s in const [
        PortalSection.knowledge,
        PortalSection.research,
        PortalSection.competitors,
        PortalSection.community,
        PortalSection.employees,
        PortalSection.aiSettings,
        PortalSection.analytics,
      ]) {
        expect(customer.canAccess(s), isFalse, reason: '$s must be internal');
      }
    });

    test('support employee reduced navigation', () {
      final support = PortalCatalog.employee(EmployeeRole.support);
      expect(support.canAccess(PortalSection.reviewAnswers), isTrue);
      expect(support.canAccess(PortalSection.knowledge), isTrue);
      expect(support.canAccess(PortalSection.marketing), isFalse);
      expect(support.canAccess(PortalSection.products), isFalse);
    });

    test('all tiers share one knowledge base (single source of truth)', () {
      final sources = {
        company.knowledgeSource,
        customer.knowledgeSource,
        for (final e in employees) e.knowledgeSource,
      };
      expect(sources.length, 1);
    });

    test('forPersona resolves each tier', () {
      expect(
        PortalCatalog.forPersona(PortalTier.company).tier,
        PortalTier.company,
      );
      expect(
        PortalCatalog.forPersona(
          PortalTier.employee,
          role: EmployeeRole.sales,
        ).employeeRole,
        EmployeeRole.sales,
      );
      expect(
        PortalCatalog.forPersona(PortalTier.customer).tier,
        PortalTier.customer,
      );
    });
  });
}
