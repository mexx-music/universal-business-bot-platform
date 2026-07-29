import 'models/company_research.dart';
import 'models/company_snapshot.dart';
import 'models/company_timeline_event.dart';
import 'models/research_document.dart';
import 'models/research_enums.dart';
import 'models/research_evidence.dart';

/// Fictional, brand-neutral demo companies for the Research Engine foundation.
///
/// None of this is fetched from the web — it is hand-authored sample data so
/// the later intelligence modules have something realistic to render while the
/// real research pipeline does not yet exist. Timeline events are intentionally
/// stored out of chronological order; the runtime is responsible for sorting.
class ResearchDemoData {
  const ResearchDemoData._();

  static List<CompanyResearch> companies() => [
    _nordlicht(),
    _auroraRobotics(),
    _verdanoFoods(),
  ];

  static CompanyResearch _nordlicht() {
    const companyId = 'co-nordlicht';
    const companyName = 'Nordlicht Kaffeerösterei';
    final documents = [
      ResearchDocument(
        id: 'doc-nordlicht-1',
        companyId: companyId,
        title: 'Nordlicht eröffnet zweite Rösterei in Hamburg',
        sourceName: 'Handelsblatt Nord',
        sourceUrl: 'https://example.com/nordlicht-hamburg',
        publishedAt: DateTime(2025, 9, 12),
        language: 'de',
        country: 'DE',
        companyName: companyName,
        documentType: ResearchDocumentType.news,
      ),
      ResearchDocument(
        id: 'doc-nordlicht-2',
        companyId: companyId,
        title: 'Neue Cold-Brew-Linie im Sortiment',
        sourceName: 'Nordlicht Blog',
        sourceUrl: 'https://example.com/nordlicht-coldbrew',
        publishedAt: DateTime(2026, 3, 4),
        language: 'de',
        country: 'DE',
        companyName: companyName,
        documentType: ResearchDocumentType.blog,
      ),
    ];
    final evidence = [
      ResearchEvidence(
        id: 'ev-nordlicht-1',
        documentId: 'doc-nordlicht-1',
        category: ResearchEvidenceCategory.expansion,
        summary: 'Zweiter Röstereistandort in Hamburg eröffnet.',
        confidence: 88,
        extractedAt: DateTime(2025, 9, 13),
      ),
      ResearchEvidence(
        id: 'ev-nordlicht-2',
        documentId: 'doc-nordlicht-1',
        category: ResearchEvidenceCategory.hiring,
        summary: 'Rund 15 neue Stellen im Produktionsbereich geschaffen.',
        confidence: 62,
        extractedAt: DateTime(2025, 9, 13),
      ),
      ResearchEvidence(
        id: 'ev-nordlicht-3',
        documentId: 'doc-nordlicht-2',
        category: ResearchEvidenceCategory.product,
        summary: 'Neue Cold-Brew-Produktlinie veröffentlicht.',
        confidence: 91,
        extractedAt: DateTime(2026, 3, 5),
      ),
    ];
    return CompanyResearch(
      companyId: companyId,
      companyName: companyName,
      snapshot: CompanySnapshot(
        companyId: companyId,
        companyName: companyName,
        capturedAt: DateTime(2026, 3, 10),
        knownProducts: const ['Filterkaffee', 'Espresso-Blends', 'Cold Brew'],
        countries: const ['DE', 'AT'],
        website: 'https://example.com/nordlicht',
        socialMedia: const {
          'instagram': 'https://example.com/ig/nordlicht',
          'linkedin': 'https://example.com/li/nordlicht',
        },
        rating: 4.5,
        marketSegment: 'Spezialitätenkaffee',
      ),
      // Deliberately unsorted.
      timeline: [
        CompanyTimelineEvent(
          id: 'tl-nordlicht-2',
          companyId: companyId,
          date: DateTime(2025, 9, 12),
          title: 'Zweite Rösterei in Hamburg',
          description: 'Ausbau der Produktionskapazität.',
          category: TimelineCategory.expansion,
        ),
        CompanyTimelineEvent(
          id: 'tl-nordlicht-1',
          companyId: companyId,
          date: DateTime(2016, 5, 1),
          title: 'Gründung in Kiel',
          description: 'Start als kleine Manufakturrösterei.',
          category: TimelineCategory.founding,
        ),
        CompanyTimelineEvent(
          id: 'tl-nordlicht-3',
          companyId: companyId,
          date: DateTime(2026, 3, 4),
          title: 'Launch Cold-Brew-Linie',
          description: 'Neues Produktsegment für den Sommer.',
          category: TimelineCategory.product,
        ),
      ],
      documents: documents,
      evidence: evidence,
    );
  }

  static CompanyResearch _auroraRobotics() {
    const companyId = 'co-aurora';
    const companyName = 'Aurora Robotics';
    final documents = [
      ResearchDocument(
        id: 'doc-aurora-1',
        companyId: companyId,
        title: 'Aurora Robotics raises Series B',
        sourceName: 'TechWire',
        sourceUrl: 'https://example.com/aurora-seriesb',
        publishedAt: DateTime(2025, 11, 20),
        language: 'en',
        country: 'US',
        companyName: companyName,
        documentType: ResearchDocumentType.pressRelease,
      ),
      ResearchDocument(
        id: 'doc-aurora-2',
        companyId: companyId,
        title: 'Aurora opens European office in Munich',
        sourceName: 'EU Startups',
        sourceUrl: 'https://example.com/aurora-munich',
        publishedAt: DateTime(2026, 1, 15),
        language: 'en',
        country: 'DE',
        companyName: companyName,
        documentType: ResearchDocumentType.news,
      ),
    ];
    final evidence = [
      ResearchEvidence(
        id: 'ev-aurora-1',
        documentId: 'doc-aurora-1',
        category: ResearchEvidenceCategory.finance,
        summary: 'Series-B-Finanzierung über 40 Mio. USD abgeschlossen.',
        confidence: 84,
        extractedAt: DateTime(2025, 11, 21),
      ),
      ResearchEvidence(
        id: 'ev-aurora-2',
        documentId: 'doc-aurora-2',
        category: ResearchEvidenceCategory.expansion,
        summary: 'Expansion nach Europa mit Büro in München.',
        confidence: 79,
        extractedAt: DateTime(2026, 1, 16),
      ),
    ];
    return CompanyResearch(
      companyId: companyId,
      companyName: companyName,
      snapshot: CompanySnapshot(
        companyId: companyId,
        companyName: companyName,
        capturedAt: DateTime(2026, 1, 20),
        knownProducts: const ['Lagerroboter AX-1', 'Flottensoftware Aurora OS'],
        countries: const ['US', 'DE'],
        website: 'https://example.com/aurora',
        socialMedia: const {'linkedin': 'https://example.com/li/aurora'},
        rating: 4.1,
        marketSegment: 'Industrierobotik',
      ),
      timeline: [
        CompanyTimelineEvent(
          id: 'tl-aurora-3',
          companyId: companyId,
          date: DateTime(2026, 1, 15),
          title: 'Europäisches Büro in München',
          description: 'Markteintritt in der EU.',
          category: TimelineCategory.expansion,
        ),
        CompanyTimelineEvent(
          id: 'tl-aurora-1',
          companyId: companyId,
          date: DateTime(2020, 2, 10),
          title: 'Gründung in Austin',
          description: 'Spin-off aus einem Universitätslabor.',
          category: TimelineCategory.founding,
        ),
        CompanyTimelineEvent(
          id: 'tl-aurora-2',
          companyId: companyId,
          date: DateTime(2025, 11, 20),
          title: 'Series B abgeschlossen',
          description: 'Wachstumsfinanzierung für die Skalierung.',
          category: TimelineCategory.finance,
        ),
      ],
      documents: documents,
      evidence: evidence,
    );
  }

  static CompanyResearch _verdanoFoods() {
    const companyId = 'co-verdano';
    const companyName = 'Verdano Foods';
    final documents = [
      ResearchDocument(
        id: 'doc-verdano-1',
        companyId: companyId,
        title: 'Verdano startet Kooperation mit Bio-Supermarktkette',
        sourceName: 'Lebensmittel Zeitung',
        sourceUrl: 'https://example.com/verdano-partnership',
        publishedAt: DateTime(2025, 6, 8),
        language: 'de',
        country: 'AT',
        companyName: companyName,
        documentType: ResearchDocumentType.news,
      ),
      ResearchDocument(
        id: 'doc-verdano-2',
        companyId: companyId,
        title: 'Kundenbewertung: „Toller Geschmack, faire Preise"',
        sourceName: 'ShopReviews',
        sourceUrl: 'https://example.com/verdano-review',
        publishedAt: DateTime(2026, 2, 2),
        language: 'de',
        country: 'AT',
        companyName: companyName,
        documentType: ResearchDocumentType.review,
      ),
    ];
    final evidence = [
      ResearchEvidence(
        id: 'ev-verdano-1',
        documentId: 'doc-verdano-1',
        category: ResearchEvidenceCategory.partnership,
        summary: 'Vertriebspartnerschaft mit einer Bio-Supermarktkette.',
        confidence: 76,
        extractedAt: DateTime(2025, 6, 9),
      ),
      ResearchEvidence(
        id: 'ev-verdano-2',
        documentId: 'doc-verdano-2',
        category: ResearchEvidenceCategory.reputation,
        summary: 'Durchweg positive Kundenbewertungen zu Geschmack und Preis.',
        confidence: 58,
        extractedAt: DateTime(2026, 2, 3),
      ),
    ];
    return CompanyResearch(
      companyId: companyId,
      companyName: companyName,
      snapshot: CompanySnapshot(
        companyId: companyId,
        companyName: companyName,
        capturedAt: DateTime(2026, 2, 5),
        knownProducts: const ['Pflanzendrinks', 'Vegane Aufstriche'],
        countries: const ['AT', 'DE', 'CH'],
        website: 'https://example.com/verdano',
        socialMedia: const {'instagram': 'https://example.com/ig/verdano'},
        rating: 4.7,
        marketSegment: 'Pflanzenbasierte Lebensmittel',
      ),
      timeline: [
        CompanyTimelineEvent(
          id: 'tl-verdano-2',
          companyId: companyId,
          date: DateTime(2025, 6, 8),
          title: 'Partnerschaft mit Bio-Handelskette',
          description: 'Breitere Verfügbarkeit im Einzelhandel.',
          category: TimelineCategory.partnership,
        ),
        CompanyTimelineEvent(
          id: 'tl-verdano-1',
          companyId: companyId,
          date: DateTime(2019, 9, 15),
          title: 'Gründung in Graz',
          description: 'Start mit einem einzelnen Pflanzendrink.',
          category: TimelineCategory.founding,
        ),
      ],
      documents: documents,
      evidence: evidence,
    );
  }
}
