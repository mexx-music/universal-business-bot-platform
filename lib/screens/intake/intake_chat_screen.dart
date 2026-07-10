import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/app_state.dart';
import '../../data/intake_chat_flow.dart';
import '../../l10n/app_localizations.dart';
import '../../models/intake_chat_message.dart';

class IntakeChatScreen extends StatefulWidget {
  const IntakeChatScreen({super.key});

  @override
  State<IntakeChatScreen> createState() => _IntakeChatScreenState();
}

class _IntakeChatScreenState extends State<IntakeChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<IntakeChatMessage> _messages = [];
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = AppState.of(context);
      state.startOrResumeIntake();
      state.markIntakeChatStarted();
      _startConversation();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);
    final l = AppLocalizations.of(context)!;
    final session = state.intakeSession;
    final question = session == null
        ? null
        : IntakeChatFlow.nextQuestion(session);
    final index = question == null
        ? IntakeChatFlow.questions.length
        : IntakeChatFlow.questions.indexOf(question);
    final blockLabel = question == null
        ? l.intakeSummaryTitle
        : IntakeChatFlow.blockLabel(l, question.blockKey);

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l.intakeChatTitle,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => context.go('/intake'),
                      icon: const Icon(Icons.assignment_outlined, size: 18),
                      label: Text(l.intakeChatOpenWizard),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  l.intakeChatSubtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: IntakeChatFlow.questions.isEmpty
                            ? 0
                            : index / IntakeChatFlow.questions.length,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      question == null
                          ? l.intakeChatCompletedProgress
                          : l.intakeChatQuestionProgress(
                              index + 1,
                              IntakeChatFlow.questions.length,
                            ),
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Chip(
                  avatar: const Icon(Icons.folder_outlined, size: 16),
                  label: Text(blockLabel),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(18),
              itemCount: _messages.length,
              itemBuilder: (context, index) =>
                  _ChatBubble(message: _messages[index]),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                if (question?.type == IntakeChatQuestionType.yesNo)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: FilledButton.tonal(
                            onPressed: () => _submitQuickAnswer(true),
                            child: Text(l.intakeChatYes),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton.tonal(
                            onPressed: () => _submitQuickAnswer(false),
                            child: Text(l.intakeChatNo),
                          ),
                        ),
                      ],
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        minLines: 1,
                        maxLines: 4,
                        enabled: question != null,
                        decoration: InputDecoration(
                          hintText: question == null
                              ? l.intakeChatDoneInputHint
                              : l.intakeChatInputHint,
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                        onSubmitted: (_) => _submitTextAnswer(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: question == null ? null : _submitTextAnswer,
                      child: const Icon(Icons.send),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: question == null ? null : _skipQuestion,
                      icon: const Icon(Icons.skip_next_outlined, size: 18),
                      label: Text(l.intakeChatSkip),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => context.go('/intake'),
                      icon: const Icon(Icons.pause_circle_outline, size: 18),
                      label: Text(l.intakeChatPause),
                    ),
                    if (question == null)
                      FilledButton.icon(
                        onPressed: () => context.go('/intake'),
                        icon: const Icon(Icons.summarize_outlined, size: 18),
                        label: Text(l.intakeChatGoToSummary),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _startConversation() {
    final l = AppLocalizations.of(context)!;
    final state = AppState.of(context);
    final question = IntakeChatFlow.nextQuestion(state.intakeSession!);
    setState(() {
      _messages
        ..add(_bot(l.intakeChatGreeting))
        ..add(_bot(l.intakeChatExplanation));
      if (question == null) {
        _messages.add(_bot(l.intakeChatAllDone));
      } else {
        _messages.add(_questionMessage(question, l));
      }
    });
    _scrollToBottom();
  }

  void _submitQuickAnswer(bool yes) {
    final l = AppLocalizations.of(context)!;
    _submitAnswer(
      yes ? 'yes' : 'no',
      userText: yes ? l.intakeChatYes : l.intakeChatNo,
    );
  }

  void _submitTextAnswer() {
    _submitAnswer(_controller.text.trim());
  }

  void _submitAnswer(String answer, {String? userText}) {
    final l = AppLocalizations.of(context)!;
    final state = AppState.of(context);
    final session = state.intakeSession;
    if (session == null) return;
    final question = IntakeChatFlow.nextQuestion(session);
    if (question == null) return;
    if (answer.trim().isEmpty) {
      setState(() => _messages.add(_bot(l.intakeChatEmptyAnswer)));
      _scrollToBottom();
      return;
    }

    _controller.clear();
    setState(() {
      _messages.add(_user(userText ?? answer, question));
    });

    IntakeChatFlow.saveAnswer(state, question, answer);
    final nextQuestion = IntakeChatFlow.nextQuestion(state.intakeSession!);
    setState(() {
      if (nextQuestion == null) {
        _messages.add(_bot(l.intakeChatAllDone));
      } else {
        _messages.add(_questionMessage(nextQuestion, l));
      }
    });
    _scrollToBottom();
  }

  void _skipQuestion() {
    final l = AppLocalizations.of(context)!;
    final state = AppState.of(context);
    final session = state.intakeSession;
    if (session == null) return;
    final question = IntakeChatFlow.nextQuestion(session);
    if (question == null) return;
    final currentIndex = IntakeChatFlow.questions.indexOf(question);
    state.skipIntakeChatQuestion(question.questionKey, currentIndex + 1);
    final nextQuestion = IntakeChatFlow.nextQuestion(state.intakeSession!);
    setState(() {
      _messages.add(_system(l.intakeChatSkipped));
      if (nextQuestion == null) {
        state.markIntakeChatCompleted();
        _messages.add(_bot(l.intakeChatAllDone));
      } else {
        _messages.add(_questionMessage(nextQuestion, l));
      }
    });
    _scrollToBottom();
  }

  IntakeChatMessage _questionMessage(
    IntakeChatQuestion question,
    AppLocalizations l,
  ) {
    return IntakeChatMessage(
      id: 'm_${DateTime.now().microsecondsSinceEpoch}',
      role: IntakeChatRole.bot,
      text: question.text(l),
      timestamp: DateTime.now(),
      questionKey: question.questionKey,
      blockKey: question.blockKey,
    );
  }

  IntakeChatMessage _bot(String text) {
    return IntakeChatMessage(
      id: 'm_${DateTime.now().microsecondsSinceEpoch}',
      role: IntakeChatRole.bot,
      text: text,
      timestamp: DateTime.now(),
    );
  }

  IntakeChatMessage _user(String text, IntakeChatQuestion question) {
    return IntakeChatMessage(
      id: 'm_${DateTime.now().microsecondsSinceEpoch}',
      role: IntakeChatRole.user,
      text: text,
      timestamp: DateTime.now(),
      questionKey: question.questionKey,
      blockKey: question.blockKey,
    );
  }

  IntakeChatMessage _system(String text) {
    return IntakeChatMessage(
      id: 'm_${DateTime.now().microsecondsSinceEpoch}',
      role: IntakeChatRole.system,
      text: text,
      timestamp: DateTime.now(),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }
}

class _ChatBubble extends StatelessWidget {
  final IntakeChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.role == IntakeChatRole.user;
    final isSystem = message.role == IntakeChatRole.system;
    final bgColor = isSystem
        ? theme.colorScheme.surfaceContainerHighest
        : isUser
        ? theme.colorScheme.primary
        : theme.colorScheme.secondaryContainer;
    final textColor = isUser
        ? theme.colorScheme.onPrimary
        : isSystem
        ? theme.colorScheme.onSurfaceVariant
        : theme.colorScheme.onSecondaryContainer;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                message.text,
                style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
