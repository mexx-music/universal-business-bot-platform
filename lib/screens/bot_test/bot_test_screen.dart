import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../../l10n/app_localizations.dart';
import '../../models/bot_question_log.dart';
import '../../models/knowledge_entry.dart';

class BotTestScreen extends StatefulWidget {
  const BotTestScreen({super.key});

  @override
  State<BotTestScreen> createState() => _BotTestScreenState();
}

class _BotTestScreenState extends State<BotTestScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _greetingAdded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_greetingAdded) {
      _greetingAdded = true;
      _messages.add(
        _ChatMessage(
          text: AppLocalizations.of(context)!.botTestGreeting,
          isBot: true,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Row(
              children: [
                Text(
                  l.botTestTitle,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () => _clearChat(l.botTestResetMessage),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(l.btnReset),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              l.botTestSubtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (context, i) => _ChatBubble(message: _messages[i]),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: l.botTestInputHint,
                      filled: true,
                      fillColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                    onSubmitted: (_) => _send(context, l),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: () => _send(context, l),
                  style: FilledButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(14),
                  ),
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _send(BuildContext context, AppLocalizations l) {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final state = AppState.of(context);

    setState(() => _messages.add(_ChatMessage(text: text, isBot: false)));
    _controller.clear();

    // Red-flag check has priority — never show content for red keywords
    if (_hasRedFlag(text, state.knowledgeEntries)) {
      state.addBotLog(
        BotQuestionLog(
          id: 'b_${DateTime.now().millisecondsSinceEpoch}',
          question: text,
          matched: false,
          redirected: true,
          timestamp: DateTime.now(),
          reviewStatus: ReviewStatus.open,
          reviewReason: ReviewReason.redFlag,
        ),
      );
      Future.delayed(const Duration(milliseconds: 400), () {
        if (!mounted) return;
        setState(
          () => _messages.add(
            _ChatMessage(
              text: l.botTestRedirectMessage(state.company.email),
              isBot: true,
              riskLevel: RiskLevel.red,
            ),
          ),
        );
        _scrollToBottom();
      });
      return;
    }

    // Normal matching — only among non-red entries
    final safeEntries = state.knowledgeEntries
        .where((e) => e.riskLevel != RiskLevel.red)
        .toList();
    final match = _findBestMatch(text, safeEntries);
    final answer = match?.content ?? l.botTestNoMatch;

    final isYellowMatch = match != null && match.riskLevel == RiskLevel.yellow;
    final reviewStatus = match == null
        ? ReviewStatus.open
        : isYellowMatch
        ? ReviewStatus.reviewed
        : ReviewStatus.closed;
    final reviewReason = match == null
        ? ReviewReason.noMatch
        : isYellowMatch
        ? ReviewReason.yellowRisk
        : null;

    state.addBotLog(
      BotQuestionLog(
        id: 'b_${DateTime.now().millisecondsSinceEpoch}',
        question: text,
        answer: match != null ? answer : null,
        matched: match != null,
        redirected: false,
        timestamp: DateTime.now(),
        reviewStatus: reviewStatus,
        reviewReason: reviewReason,
      ),
    );

    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      setState(
        () => _messages.add(
          _ChatMessage(
            text: answer,
            isBot: true,
            matchedTitle: match?.title,
            riskLevel: match?.riskLevel,
          ),
        ),
      );
      _scrollToBottom();
    });
  }

  /// Returns true if the question contains any keyword from a red-level entry.
  bool _hasRedFlag(String question, List<KnowledgeEntry> entries) {
    final lower = question.toLowerCase();
    for (final entry in entries.where((e) => e.riskLevel == RiskLevel.red)) {
      for (final kw in entry.keywords) {
        if (lower.contains(kw)) return true;
      }
    }
    return false;
  }

  KnowledgeEntry? _findBestMatch(
    String question,
    List<KnowledgeEntry> entries,
  ) {
    final words = question.toLowerCase().split(RegExp(r'\s+'));
    KnowledgeEntry? best;
    int bestScore = 0;

    for (final entry in entries) {
      int score = 0;
      for (final kw in entry.keywords) {
        if (words.any(
          (w) => w.isNotEmpty && (kw.contains(w) || w.contains(kw)),
        )) {
          score += 2;
        }
      }
      for (final tw in entry.title.toLowerCase().split(RegExp(r'\s+'))) {
        if (tw.length > 3 &&
            words.any(
              (w) => w.isNotEmpty && (tw.contains(w) || w.contains(tw)),
            )) {
          score += 1;
        }
      }
      if (score > bestScore) {
        bestScore = score;
        best = entry;
      }
    }
    return bestScore >= 2 ? best : null;
  }

  void _clearChat(String resetMessage) {
    setState(() {
      _messages
        ..clear()
        ..add(_ChatMessage(text: resetMessage, isBot: true));
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}

class _ChatMessage {
  final String text;
  final bool isBot;
  final String? matchedTitle;
  final RiskLevel? riskLevel;

  const _ChatMessage({
    required this.text,
    required this.isBot,
    this.matchedTitle,
    this.riskLevel,
  });

  bool get isRedirect => riskLevel == RiskLevel.red;
  bool get isYellow => riskLevel == RiskLevel.yellow;
}

class _ChatBubble extends StatelessWidget {
  final _ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isBot = message.isBot;

    if (isBot && message.isRedirect) {
      return _RedirectBubble(message: message, l: l);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isBot
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isBot) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                Icons.smart_toy,
                size: 16,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isBot
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isBot
                        ? theme.colorScheme.surfaceContainerHighest
                        : theme.colorScheme.primary,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isBot ? 4 : 16),
                      bottomRight: Radius.circular(isBot ? 16 : 4),
                    ),
                  ),
                  child: Text(
                    message.text,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isBot ? null : theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
                if (isBot && message.isYellow)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 12,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            l.botTestYellowDisclaimer,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (isBot && message.matchedTitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.library_books_outlined,
                          size: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          message.matchedTitle!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (!isBot) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _RedirectBubble extends StatelessWidget {
  final _ChatMessage message;
  final AppLocalizations l;

  const _RedirectBubble({required this.message, required this.l});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.red.withAlpha(30),
            child: const Icon(Icons.block, size: 16, color: Colors.red),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(15),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border.all(color: Colors.red.withAlpha(60)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        size: 16,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l.riskRed,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(message.text, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
