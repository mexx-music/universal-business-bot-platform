import '../calculators/business_strategy_calculator.dart';
import '../calculators/marketing_strategy_calculator.dart';
import '../calculators/project_status_calculator.dart';
import '../models/action_record.dart';
import '../models/bot_configuration.dart';
import '../models/bot_question_log.dart';
import '../models/business_audit.dart';
import '../models/business_strategy.dart';
import '../models/company_workspace.dart';
import '../models/intake_session.dart';
import '../models/knowledge_entry.dart';
import '../models/source_material.dart';
import 'next_best_action.dart';

/// Computes the 3–5 most important actions for a workspace right now.
///
/// Pure business logic over data the platform already has (audit, knowledge,
/// human review, marketing/strategy/project-status calculators, bot
/// configuration, company profile, sources). No AI, no network, no side
/// effects: the workspace is only read, and the same workspace state always
/// produces the same recommendations in the same order (`now` is injectable
/// for the time-based signals).
///
/// Ranking: every candidate gets a deterministic score —
///   priority (critical 400 / high 300 / medium 200 / low 100)
/// + impact   (high 30 / medium 20 / low 10)
/// + quick-win bonus for low effort (low 15 / medium 8 / high 0)
/// + situation-specific urgency (0–25, e.g. number of open reviews)
/// — sorted descending, ties broken by action type for stable order.
class NextBestActionEngine {
  const NextBestActionEngine({
    this.projectStatusCalculator = const ProjectStatusCalculator(),
    this.marketingStrategyCalculator = const MarketingStrategyCalculator(),
    this.businessStrategyCalculator = const BusinessStrategyCalculator(),
    this.maxActions = 5,
    this.staleKnowledgeWindow = const Duration(days: 365),
  });

  final ProjectStatusCalculator projectStatusCalculator;
  final MarketingStrategyCalculator marketingStrategyCalculator;
  final BusinessStrategyCalculator businessStrategyCalculator;

  /// Hard cap — the companion recommends focus, not a backlog.
  final int maxActions;

  final Duration staleKnowledgeWindow;

  /// How long after completion an action is not re-recommended.
  final Duration repeatCooldown = const Duration(days: 90);

  List<NextBestAction> recommend(CompanyWorkspace workspace, {DateTime? now}) {
    return recommendPlan(workspace, now: now).actions;
  }

  /// Recommends the top actions and reports every candidate the action
  /// history suppressed — nothing disappears silently.
  NextBestActionPlan recommendPlan(
    CompanyWorkspace workspace, {
    DateTime? now,
  }) {
    final timestamp = now ?? DateTime.now();
    final actions = <NextBestAction>[];
    final suppressed = <SuppressedAction>[];

    for (final candidate in _candidates(workspace, timestamp)) {
      final record = _latestRecordFor(workspace, candidate.type);
      final (action, suppression) = _applyHistory(candidate, record, timestamp);
      if (action != null) actions.add(action);
      if (suppression != null) suppressed.add(suppression);
    }

    actions.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      return byScore != 0 ? byScore : a.type.name.compareTo(b.type.name);
    });
    return NextBestActionPlan(
      actions: actions.take(maxActions).toList(),
      suppressed: suppressed,
    );
  }

  List<NextBestAction> _candidates(
    CompanyWorkspace workspace,
    DateTime timestamp,
  ) {
    final candidates = <NextBestAction?>[
      _completeIntake(workspace),
      _completeCompanyProfile(workspace),
      _workOffHumanReview(workspace),
      _reviewSources(workspace),
      _expandFaq(workspace),
      _addKnowledge(workspace, timestamp),
      _activateBot(workspace),
      _auditAreaAction(
        workspace,
        area: AuditArea.website,
        type: NextBestActionType.improveWebsite,
        title: 'Website verbessern',
        description:
            'Die Audit-Prüfung zeigt offene Punkte an der Website. Eine '
            'gepflegte Website ist die Basis für Bot, Marketing und '
            'Sichtbarkeit.',
        areas: const [BusinessGoalArea.marketing, BusinessGoalArea.audit],
      ),
      _auditAreaAction(
        workspace,
        area: AuditArea.socialPresence,
        type: NextBestActionType.prepareSocialMedia,
        title: 'Social Media & Google Business vorbereiten',
        description:
            'Die Online-Präsenz außerhalb der Website hat offene '
            'Audit-Punkte (z. B. Google Business Profil, Social-Kanäle).',
        areas: const [BusinessGoalArea.marketing, BusinessGoalArea.audit],
      ),
      _auditAreaAction(
        workspace,
        area: AuditArea.trustMaterial,
        type: NextBestActionType.collectAndAnswerReviews,
        title: 'Bewertungen sammeln und beantworten',
        description:
            'Vertrauensmaterial (Bewertungen, Referenzen) ist laut Audit '
            'unvollständig. Sichtbare, beantwortete Bewertungen sind einer '
            'der stärksten Kaufauslöser.',
        areas: const [BusinessGoalArea.marketing, BusinessGoalArea.audit],
      ),
      _startMarketing(workspace),
      _focusMarketing(workspace),
      _defineBusinessGoals(workspace),
    ];
    return candidates.whereType<NextBestAction>().toList();
  }

  // --- action history (company memory) ---

  ActionRecord? _latestRecordFor(
    CompanyWorkspace workspace,
    NextBestActionType type,
  ) {
    ActionRecord? latest;
    for (final record in workspace.actionRecords) {
      if (record.actionType != type.name) continue;
      if (latest == null || record.createdAt.isAfter(latest.createdAt)) {
        latest = record;
      }
    }
    return latest;
  }

  /// Applies the user's history to a computed candidate. Returns either the
  /// (possibly annotated) action or an explained suppression — never both,
  /// never neither.
  (NextBestAction?, SuppressedAction?) _applyHistory(
    NextBestAction action,
    ActionRecord? record,
    DateTime now,
  ) {
    if (record == null || record.status == ActionRecordStatus.suggested) {
      return (action, null);
    }

    SuppressedAction suppress(String reason) => SuppressedAction(
      type: action.type,
      title: action.title,
      reason: reason,
      evidence: 'actionRecord ${record.id}: status=${record.status.name}',
    );

    NextBestAction annotate(String message) => action.copyWith(
      reasons: [
        ...action.reasons,
        ActionReason(
          message: message,
          evidence: 'actionRecord ${record.id}: status=${record.status.name}',
        ),
      ],
    );

    switch (record.status) {
      case ActionRecordStatus.suggested:
        return (action, null);
      case ActionRecordStatus.accepted:
        return (
          null,
          suppress(
            'Bereits am ${_date(record.acceptedAt)} angenommen – wartet auf '
            'Umsetzung.',
          ),
        );
      case ActionRecordStatus.inProgress:
        return (
          null,
          suppress('Läuft bereits seit ${_date(record.startedAt)}.'),
        );
      case ActionRecordStatus.deferred:
        final until = record.deferredUntil;
        if (until != null && now.isBefore(until)) {
          return (null, suppress('Zurückgestellt bis ${_date(until)}.'));
        }
        return (
          annotate(
            'Die Zurückstellung (bis ${_date(until)}) ist abgelaufen – '
            'Empfehlung wieder aktiv.',
          ),
          null,
        );
      case ActionRecordStatus.declined:
        if (_evidenceChanged(record, action)) {
          return (
            annotate(
              'Am ${_date(record.declinedAt)} abgelehnt, aber die Datenlage '
              'hat sich seitdem wesentlich verändert.',
            ),
            null,
          );
        }
        final reason = record.declineReason;
        return (
          null,
          suppress(
            'Am ${_date(record.declinedAt)} abgelehnt'
            '${reason == null || reason.isEmpty ? '' : ' („$reason")'} – '
            'Datenlage unverändert.',
          ),
        );
      case ActionRecordStatus.completed:
        final completedAt = record.completedAt ?? record.createdAt;
        final unsuccessful =
            record.resultRating == ActionResultRating.noEffect ||
            record.resultRating == ActionResultRating.negative;
        if (unsuccessful) {
          if (_evidenceChanged(record, action)) {
            return (
              annotate(
                'Frühere Umsetzung (${_date(completedAt)}) blieb ohne '
                'Erfolg, aber die Datenlage hat sich wesentlich verändert.',
              ),
              null,
            );
          }
          return (
            null,
            suppress(
              'Am ${_date(completedAt)} ohne erkennbaren Erfolg '
              'abgeschlossen – keine neue Begründung vorhanden.',
            ),
          );
        }
        if (record.repeatRequested == false) {
          return (
            null,
            suppress(
              'Am ${_date(completedAt)} abgeschlossen – Wiederholung wurde '
              'nicht gewünscht.',
            ),
          );
        }
        if (now.difference(completedAt) < repeatCooldown) {
          return (
            null,
            suppress(
              'Am ${_date(completedAt)} abgeschlossen – frühestens nach '
              '${repeatCooldown.inDays} Tagen wieder relevant.',
            ),
          );
        }
        return (
          annotate(
            'Wiederholung: wurde am ${_date(completedAt)} abgeschlossen'
            '${record.resultRating == null ? '' : ' (${_ratingLabel(record.resultRating!)})'} '
            'und die Bedingungen treffen wieder zu.',
          ),
          null,
        );
    }
  }

  /// "Materially changed" = the current evidence behind the recommendation
  /// differs from the evidence snapshotted when the user decided. Evidence
  /// strings carry the concrete counts, so any relevant data change shows
  /// up here. Records without a snapshot respect the user's decision
  /// (treated as unchanged).
  bool _evidenceChanged(ActionRecord record, NextBestAction action) {
    final recorded = record.sourceReasonKeys.toSet();
    if (recorded.isEmpty) return false;
    final current = action.reasons.map((reason) => reason.evidence).toSet();
    return current.length != recorded.length || !current.containsAll(recorded);
  }

  String _ratingLabel(ActionResultRating rating) {
    return switch (rating) {
      ActionResultRating.helpedALot => 'hat deutlich geholfen',
      ActionResultRating.helpedSomewhat => 'hat etwas geholfen',
      ActionResultRating.noEffect => 'kein erkennbarer Effekt',
      ActionResultRating.negative => 'negativer Effekt',
      ActionResultRating.notYetRatable => 'noch nicht bewertet',
    };
  }

  String _date(DateTime? date) {
    if (date == null) return 'unbekanntem Datum';
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  // --- candidate builders (each returns null when not applicable) ---

  NextBestAction? _completeIntake(CompanyWorkspace workspace) {
    final session = workspace.intakeSession;
    if (session != null && session.status == IntakeStatus.completed) {
      return null;
    }
    final progress = projectStatusCalculator.calculate(workspace).progress;
    return _action(
      type: NextBestActionType.completeIntake,
      title: 'Firmenaufnahme abschließen',
      description:
          'Die strukturierte Aufnahme ist die Grundlage für alle Analysen '
          'und Empfehlungen. Ohne sie arbeitet die Plattform mit '
          'unvollständigem Bild.',
      reasons: [
        ActionReason(
          message: session == null
              ? 'Die Firmenaufnahme wurde noch nicht gestartet.'
              : 'Die Firmenaufnahme ist noch nicht abgeschlossen '
                    '(Status: ${session.status.name}).',
          evidence: 'intakeSession: ${session?.status.name ?? 'null'}',
        ),
        ActionReason(
          message:
              'Der Projektfortschritt liegt bei '
              '${(progress * 100).round()} %.',
          evidence:
              'projectStatus.progress = '
              '${(progress * 100).round()} %',
        ),
      ],
      priority: ActionPriority.high,
      effort: ActionEffort.medium,
      impact: ActionImpact.high,
      areas: const [
        BusinessGoalArea.companyProfile,
        BusinessGoalArea.knowledgeBase,
      ],
      urgency: session == null ? 25 : 15,
    );
  }

  NextBestAction? _completeCompanyProfile(CompanyWorkspace workspace) {
    final company = workspace.company;
    final rules = workspace.businessRules;
    // Same completeness signals the dashboard uses (AppState profile status).
    final checks = <String, bool>{
      'Name': company.name.isNotEmpty,
      'Beschreibung': company.description.isNotEmpty,
      'Branche': company.industry.isNotEmpty,
      'Land': company.country.isNotEmpty,
      'Sprache': company.primaryLanguage.isNotEmpty,
      'Website': company.website.isNotEmpty,
      'E-Mail': company.email.isNotEmpty,
      'Social Links': company.socialLinks.values.any(
        (value) => value.trim().isNotEmpty,
      ),
      'Markenstimme': rules.brandVoice.isNotEmpty,
      'Erlaubte Support-Themen': rules.allowedSupportTopics.isNotEmpty,
    };
    final filled = checks.values.where((ok) => ok).length;
    if (filled >= 8) return null;
    final missing = [
      for (final entry in checks.entries)
        if (!entry.value) entry.key,
    ];
    return _action(
      type: NextBestActionType.completeCompanyProfile,
      title: 'Firmenprofil vervollständigen',
      description:
          'Ein vollständiges Profil verbessert jede weitere Empfehlung, den '
          'Bot und die Außendarstellung.',
      reasons: [
        ActionReason(
          message:
              'Es fehlen ${missing.length} von ${checks.length} '
              'Profilangaben: ${missing.join(', ')}.',
          evidence: 'companyProfile: $filled/${checks.length} Feldern gefüllt',
        ),
      ],
      priority: filled < 4 ? ActionPriority.high : ActionPriority.medium,
      effort: ActionEffort.low,
      impact: ActionImpact.medium,
      areas: const [BusinessGoalArea.companyProfile],
      urgency: (checks.length - filled) * 2,
    );
  }

  NextBestAction? _workOffHumanReview(CompanyWorkspace workspace) {
    final open = workspace.botLogs
        .where((log) => log.reviewStatus == ReviewStatus.open)
        .toList();
    if (open.isEmpty) return null;
    final redFlags = open
        .where((log) => log.reviewReason == ReviewReason.redFlag)
        .length;
    return _action(
      type: NextBestActionType.workOffHumanReview,
      title: 'Human Review bearbeiten',
      description:
          'Offene Review-Anfragen sind unbeantwortete Kundenfragen — jede '
          'beantwortete Anfrage verbessert außerdem die Wissensbasis.',
      reasons: [
        ActionReason(
          message: 'Es liegen ${open.length} offene Review-Anfragen vor.',
          evidence: 'botLogs: ${open.length}× reviewStatus=open',
        ),
        if (redFlags > 0)
          ActionReason(
            message: '$redFlags davon betreffen gesperrte Themen (Red Flag).',
            evidence: 'botLogs: $redFlags× reviewReason=redFlag',
          ),
      ],
      priority: redFlags > 0 || open.length >= 5
          ? ActionPriority.critical
          : ActionPriority.high,
      effort: ActionEffort.low,
      impact: ActionImpact.high,
      areas: const [BusinessGoalArea.humanReview, BusinessGoalArea.bot],
      urgency: (open.length * 4).clamp(0, 20),
    );
  }

  NextBestAction? _reviewSources(CompanyWorkspace workspace) {
    final fresh = workspace.sourceMaterials
        .where((source) => source.status == SourceMaterialStatus.newItem)
        .length;
    if (fresh == 0) return null;
    return _action(
      type: NextBestActionType.reviewSources,
      title: 'Neue Quellen prüfen',
      description:
          'Ungeprüfte Quellen enthalten potenzielles Wissen, das dem Bot und '
          'den Analysen noch fehlt.',
      reasons: [
        ActionReason(
          message: '$fresh Quelle(n) wurden noch nicht gesichtet.',
          evidence: 'sourceMaterials: $fresh× status=newItem',
        ),
      ],
      priority: fresh >= 3 ? ActionPriority.high : ActionPriority.medium,
      effort: ActionEffort.low,
      impact: ActionImpact.medium,
      areas: const [BusinessGoalArea.sources, BusinessGoalArea.knowledgeBase],
      urgency: (fresh * 3).clamp(0, 12),
    );
  }

  NextBestAction? _expandFaq(CompanyWorkspace workspace) {
    final faqCount = workspace.knowledgeEntries
        .where((entry) => entry.category == KnowledgeCategory.faq)
        .length;
    if (faqCount >= 8) return null;
    return _action(
      type: NextBestActionType.expandFaq,
      title: 'FAQ erweitern',
      description:
          'Häufige Kundenfragen als FAQ zu erfassen ist der schnellste Weg '
          'zu einem nützlichen Bot und entlastet den Support sofort.',
      reasons: [
        ActionReason(
          message:
              'Die Wissensbasis enthält erst $faqCount FAQ-Einträge '
              '(Richtwert: mindestens 8).',
          evidence: 'knowledgeEntries: $faqCount× category=faq',
        ),
        ActionReason(
          message:
              'Der Bot ist im Status '
              '„${workspace.botConfiguration.status.name}" und braucht '
              'FAQ-Breite, um Fragen sicher zu beantworten.',
          evidence:
              'botConfiguration.status = '
              '${workspace.botConfiguration.status.name}',
        ),
      ],
      priority: faqCount < 3 ? ActionPriority.high : ActionPriority.medium,
      effort: ActionEffort.medium,
      impact: ActionImpact.high,
      areas: const [BusinessGoalArea.knowledgeBase, BusinessGoalArea.bot],
      urgency: ((8 - faqCount) * 2).clamp(0, 16),
    );
  }

  NextBestAction? _addKnowledge(CompanyWorkspace workspace, DateTime now) {
    final entries = workspace.knowledgeEntries;
    final stale = entries
        .where(
          (entry) => now.difference(entry.createdAt) > staleKnowledgeWindow,
        )
        .length;
    final tooFew = entries.length < 12;
    final mostlyStale = entries.isNotEmpty && stale > entries.length / 2;
    if (!tooFew && !mostlyStale) return null;
    return _action(
      type: NextBestActionType.addKnowledge,
      title: 'Wissensbasis ergänzen',
      description:
          'Mehr geprüftes Wissen verbessert Bot-Antworten, Audit-Ergebnis '
          'und jede weitere Empfehlung.',
      reasons: [
        if (tooFew)
          ActionReason(
            message:
                'Die Wissensbasis enthält erst ${entries.length} '
                'Einträge (Richtwert: mindestens 12).',
            evidence: 'knowledgeEntries.length = ${entries.length}',
          ),
        if (mostlyStale)
          ActionReason(
            message:
                '$stale von ${entries.length} Einträgen sind älter als '
                '12 Monate und sollten geprüft werden.',
            evidence:
                'knowledgeEntries: $stale× älter als '
                '${staleKnowledgeWindow.inDays} Tage',
          ),
      ],
      priority: entries.length < 5
          ? ActionPriority.high
          : ActionPriority.medium,
      effort: ActionEffort.medium,
      impact: ActionImpact.medium,
      areas: const [BusinessGoalArea.knowledgeBase],
      urgency: tooFew ? ((12 - entries.length)).clamp(0, 12) : 6,
    );
  }

  NextBestAction? _activateBot(CompanyWorkspace workspace) {
    if (workspace.botConfiguration.status == BotStatus.active) return null;
    final knowledgeCount = workspace.knowledgeEntries.length;
    final auditScore = projectStatusCalculator.auditScoreFor(workspace);
    final openReviews = workspace.botLogs
        .where((log) => log.reviewStatus == ReviewStatus.open)
        .length;
    final ready = knowledgeCount >= 10 && auditScore >= 0.6 && openReviews <= 2;
    if (!ready) return null;
    return _action(
      type: NextBestActionType.activateBot,
      title: 'Bot aktivieren',
      description:
          'Wissensbasis und Audit sind reif genug — der Bot kann live '
          'gehen und ab sofort Kundenfragen aus geprüftem Wissen '
          'beantworten.',
      reasons: [
        ActionReason(
          message:
              'Die Wissensbasis enthält $knowledgeCount geprüfte '
              'Einträge.',
          evidence: 'knowledgeEntries.length = $knowledgeCount',
        ),
        ActionReason(
          message:
              'Der Audit-Score liegt bei '
              '${(auditScore * 100).round()} %.',
          evidence: 'auditScore = ${(auditScore * 100).round()} %',
        ),
        ActionReason(
          message:
              'Nur $openReviews offene Review-Anfragen — der '
              'Review-Prozess funktioniert.',
          evidence: 'botLogs: $openReviews× reviewStatus=open',
        ),
      ],
      priority: ActionPriority.high,
      effort: ActionEffort.low,
      impact: ActionImpact.high,
      areas: const [BusinessGoalArea.bot, BusinessGoalArea.marketing],
      urgency: 10,
    );
  }

  NextBestAction? _auditAreaAction(
    CompanyWorkspace workspace, {
    required AuditArea area,
    required NextBestActionType type,
    required String title,
    required String description,
    required List<BusinessGoalArea> areas,
  }) {
    final openItems = workspace.auditItems
        .where((item) => item.area == area)
        .where((item) => item.status != AuditItemStatus.complete)
        .toList();
    if (openItems.isEmpty) return null;
    final highPriority = openItems
        .where((item) => item.priority == AuditPriority.high)
        .length;
    final missing = openItems
        .where((item) => item.status == AuditItemStatus.missing)
        .length;
    return _action(
      type: type,
      title: title,
      description: description,
      reasons: [
        ActionReason(
          message:
              '${openItems.length} offene Audit-Punkte in diesem '
              'Bereich: '
              '${openItems.map((item) => item.title).join('; ')}.',
          evidence:
              'auditItems[${area.name}]: ${openItems.length}× nicht '
              'complete ($missing× missing, $highPriority× hohe Priorität)',
        ),
      ],
      priority: highPriority > 0 ? ActionPriority.high : ActionPriority.medium,
      effort: ActionEffort.medium,
      impact: missing > 0 ? ActionImpact.high : ActionImpact.medium,
      areas: areas,
      urgency: (openItems.length * 3 + highPriority * 4).clamp(0, 18),
    );
  }

  NextBestAction? _startMarketing(CompanyWorkspace workspace) {
    final strategy = marketingStrategyCalculator.calculate(workspace);
    final started =
        strategy.inProgressActionCount + strategy.completedActionCount;
    if (started > 0 || strategy.recommendedActions.isEmpty) return null;
    final top = strategy.recommendedActions.take(3).toList();
    return _action(
      type: NextBestActionType.startMarketing,
      title: 'Marketing starten',
      description:
          'Es läuft noch keine einzige Marketing-Maßnahme. Mit den '
          'empfohlenen ersten Schritten wird das Unternehmen sichtbar.',
      reasons: [
        ActionReason(
          message:
              'Keine Marketing-Maßnahme ist gestartet oder '
              'abgeschlossen.',
          evidence: 'marketing: 0× inProgress, 0× completed',
        ),
        ActionReason(
          message:
              'Der Marketing-Score liegt bei ${strategy.score}/100; '
              'empfohlener Einstieg: '
              '${top.map((action) => action.type.name).join(', ')}.',
          evidence:
              'marketingStrategy.score = ${strategy.score}; '
              'recommendedActions = ${strategy.recommendedActions.length}',
        ),
      ],
      priority: ActionPriority.medium,
      effort: ActionEffort.medium,
      impact: ActionImpact.high,
      areas: const [BusinessGoalArea.marketing],
      urgency: strategy.score < 40 ? 10 : 5,
    );
  }

  NextBestAction? _focusMarketing(CompanyWorkspace workspace) {
    final strategy = marketingStrategyCalculator.calculate(workspace);
    if (strategy.inProgressActionCount < 4) return null;
    return _action(
      type: NextBestActionType.focusMarketing,
      title: 'Marketing fokussieren',
      description:
          'Zu viele parallele Maßnahmen verwässern Budget und '
          'Aufmerksamkeit. Besser: wenige Maßnahmen konsequent zu Ende '
          'führen, den Rest bewusst pausieren.',
      reasons: [
        ActionReason(
          message:
              '${strategy.inProgressActionCount} Marketing-Maßnahmen '
              'laufen gleichzeitig (Richtwert: höchstens 3).',
          evidence: 'marketing: ${strategy.inProgressActionCount}× inProgress',
        ),
      ],
      priority: ActionPriority.medium,
      effort: ActionEffort.low,
      impact: ActionImpact.medium,
      areas: const [BusinessGoalArea.marketing, BusinessGoalArea.controlling],
      urgency: (strategy.inProgressActionCount * 2).clamp(0, 12),
    );
  }

  NextBestAction? _defineBusinessGoals(CompanyWorkspace workspace) {
    if (workspace.businessGoals.isNotEmpty) return null;
    final strategy = businessStrategyCalculator.calculate(workspace);
    final progress = projectStatusCalculator.calculate(workspace).progress;
    return _action(
      type: NextBestActionType.defineBusinessGoals,
      title: 'Unternehmensziele festlegen',
      description:
          'Ohne definierte Ziele kann kein Fortschritt gemessen und keine '
          'Strategie angepasst werden.',
      reasons: [
        ActionReason(
          message: 'Es sind keine Unternehmensziele hinterlegt.',
          evidence:
              'businessGoals.length = 0; '
              'strategyGoals = ${strategy.goals.length}',
        ),
        ActionReason(
          message:
              'Der Projektfortschritt (${(progress * 100).round()} %) '
              'hat damit keinen Bezugspunkt.',
          evidence: 'projectStatus.progress = ${(progress * 100).round()} %',
        ),
      ],
      priority: ActionPriority.medium,
      effort: ActionEffort.low,
      impact: ActionImpact.medium,
      areas: const [
        BusinessGoalArea.controlling,
        BusinessGoalArea.projectStatus,
      ],
      urgency: 5,
    );
  }

  // --- scoring ---

  static const Map<ActionPriority, int> _priorityWeights = {
    ActionPriority.critical: 400,
    ActionPriority.high: 300,
    ActionPriority.medium: 200,
    ActionPriority.low: 100,
  };

  static const Map<ActionImpact, int> _impactWeights = {
    ActionImpact.high: 30,
    ActionImpact.medium: 20,
    ActionImpact.low: 10,
  };

  static const Map<ActionEffort, int> _effortBonus = {
    ActionEffort.low: 15,
    ActionEffort.medium: 8,
    ActionEffort.high: 0,
  };

  NextBestAction _action({
    required NextBestActionType type,
    required String title,
    required String description,
    required List<ActionReason> reasons,
    required ActionPriority priority,
    required ActionEffort effort,
    required ActionImpact impact,
    required List<BusinessGoalArea> areas,
    required int urgency,
  }) {
    assert(reasons.isNotEmpty, 'Every recommendation must be explainable');
    return NextBestAction(
      type: type,
      title: title,
      description: description,
      reasons: reasons,
      priority: priority,
      effort: effort,
      impact: impact,
      areas: areas,
      score:
          _priorityWeights[priority]! +
          _impactWeights[impact]! +
          _effortBonus[effort]! +
          urgency.clamp(0, 25),
    );
  }
}
