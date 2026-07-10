import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/app_state.dart';
import '../../data/intake_chat_flow.dart';
import '../../l10n/app_localizations.dart';
import '../../models/intake_chat_message.dart';
import '../../widgets/intake_answer_dialog.dart';
import '../../widgets/intake_choice_dialog.dart';

class IntakeChatScreen extends StatefulWidget {
  const IntakeChatScreen({super.key});

  @override
  State<IntakeChatScreen> createState() => _IntakeChatScreenState();
}

class _IntakeChatScreenState extends State<IntakeChatScreen> {
  final _scrollController = ScrollController();
  final List<IntakeChatMessage> _messages = [];
  bool _initialized = false;
  bool _isBusy = false;
  bool _dialogOpen = false;

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
    final relevant = session == null
        ? const <IntakeChatQuestion>[]
        : IntakeChatFlow.relevantQuestions(session);
    final answered = session == null
        ? 0
        : IntakeChatFlow.answeredRelevantCount(session);
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
                            : answered /
                                  (relevant.isEmpty ? 1 : relevant.length),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      question == null
                          ? l.intakeChatCompletedProgress
                          : l.intakeChatQuestionProgress(
                              answered + 1,
                              relevant.length,
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
                if (question != null)
                  _CurrentQuestionPanel(
                    question: question,
                    blockLabel: blockLabel,
                  ),
                if (question != null) const SizedBox(height: 10),
                if (question?.type == IntakeChatQuestionType.yesNo)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: FilledButton.tonal(
                            onPressed: _isBusy
                                ? null
                                : () => _submitQuickAnswer(true),
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(0, 52),
                            ),
                            child: Text(l.intakeChatYes),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton.tonal(
                            onPressed: _isBusy
                                ? null
                                : () => _submitQuickAnswer(false),
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(0, 52),
                            ),
                            child: Text(l.intakeChatNo),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (question != null &&
                    question.type != IntakeChatQuestionType.yesNo)
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _isBusy
                              ? null
                              : () => _openInputForQuestion(question),
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                          ),
                          label: Text(l.intakeChatEnterAnswer),
                        ),
                      ),
                    ],
                  )
                else if (question == null)
                  TextField(
                    enabled: false,
                    decoration: InputDecoration(
                      hintText: l.intakeChatDoneInputHint,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed:
                          question == null || !question.skippable || _isBusy
                          ? null
                          : () => _deferQuestion(question),
                      icon: const Icon(Icons.skip_next_outlined, size: 18),
                      label: Text(l.intakeChatDialogDefer),
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
    _maybeOpenDialog(question);
  }

  void _submitQuickAnswer(bool yes) {
    final l = AppLocalizations.of(context)!;
    _submitAnswer(
      yes ? 'yes' : 'no',
      userText: yes ? l.intakeChatYes : l.intakeChatNo,
    );
  }

  void _submitAnswer(String answer, {String? userText}) {
    final state = AppState.of(context);
    final session = state.intakeSession;
    if (session == null) return;
    final question = IntakeChatFlow.nextQuestion(session);
    if (question == null) return;
    if (_isBusy) return;
    setState(() => _isBusy = true);
    setState(() {
      _messages.add(_user(userText ?? answer, question));
    });

    IntakeChatFlow.saveAnswer(state, question, answer);
    _advanceAfterQuestion(question);
  }

  Future<void> _openAnswerDialog(IntakeChatQuestion question) async {
    if (_dialogOpen || _isBusy || !mounted) return;
    final state = AppState.of(context);
    final session = state.intakeSession;
    if (session == null) return;
    final currentQuestion = IntakeChatFlow.nextQuestion(session);
    if (currentQuestion?.questionKey != question.questionKey) return;

    setState(() {
      _dialogOpen = true;
      _isBusy = true;
    });
    final result = await showDialog<IntakeAnswerDialogResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => IntakeAnswerDialog(
        question: question,
        initialValue: question.value(session),
        defaultValue: question.defaultValue?.call(session) ?? '',
      ),
    );
    if (!mounted) return;
    setState(() {
      _dialogOpen = false;
      _isBusy = false;
    });
    if (result == null || result.action == IntakeAnswerDialogAction.cancel) {
      return;
    }
    if (result.action == IntakeAnswerDialogAction.defer) {
      _deferQuestion(question);
      return;
    }
    _submitAnswer(result.answer);
  }

  void _maybeOpenDialog(IntakeChatQuestion? question) {
    if (question == null || question.type == IntakeChatQuestionType.yesNo) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _openInputForQuestion(question);
    });
  }

  Future<void> _openInputForQuestion(IntakeChatQuestion question) {
    if (question.isChoiceQuestion) {
      return _openChoiceDialog(question);
    }
    return _openAnswerDialog(question);
  }

  Future<void> _openChoiceDialog(IntakeChatQuestion question) async {
    if (_dialogOpen || _isBusy || !mounted) return;
    final state = AppState.of(context);
    final session = state.intakeSession;
    if (session == null) return;
    final currentQuestion = IntakeChatFlow.nextQuestion(session);
    if (currentQuestion?.questionKey != question.questionKey) return;

    setState(() {
      _dialogOpen = true;
      _isBusy = true;
    });
    final result = await showDialog<IntakeChoiceDialogResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => IntakeChoiceDialog(question: question, session: session),
    );
    if (!mounted) return;
    setState(() {
      _dialogOpen = false;
      _isBusy = false;
    });
    if (result == null || result.action == IntakeChoiceDialogAction.cancel) {
      return;
    }
    if (result.action == IntakeChoiceDialogAction.defer) {
      _deferQuestion(question);
      return;
    }
    _submitAnswer(result.answer);
  }

  void _advanceAfterQuestion(IntakeChatQuestion question) {
    final l = AppLocalizations.of(context)!;
    final state = AppState.of(context);
    final nextQuestion = IntakeChatFlow.nextQuestion(state.intakeSession!);
    setState(() {
      _isBusy = false;
      if (nextQuestion == null) {
        _messages.add(_system(l.intakeChatAnswerSaved));
        _messages.add(_bot(l.intakeChatAllDone));
      } else {
        _messages.add(_system(l.intakeChatAnswerSaved));
        final intro = nextQuestion.parentQuestionKey == question.questionKey
            ? IntakeChatFlow.detailIntro(l, nextQuestion)
            : null;
        if (intro != null) {
          _messages.add(_bot(intro));
        }
        _messages.add(_questionMessage(nextQuestion, l));
      }
    });
    _scrollToBottom();
    _maybeOpenDialog(nextQuestion);
  }

  void _deferQuestion(IntakeChatQuestion question) {
    final l = AppLocalizations.of(context)!;
    final state = AppState.of(context);
    final session = state.intakeSession;
    if (session == null) return;
    if (_isBusy) return;
    setState(() => _isBusy = true);
    final currentIndex = IntakeChatFlow.questions.indexOf(question);
    state.deferIntakeChatQuestion(question.questionKey, currentIndex + 1);
    final nextQuestion = IntakeChatFlow.nextQuestion(state.intakeSession!);
    setState(() {
      _isBusy = false;
      _messages.add(_system(l.intakeChatDeferred));
      if (nextQuestion == null) {
        state.markIntakeChatCompleted();
        _messages.add(_bot(l.intakeChatAllDone));
      } else {
        final intro = nextQuestion.parentQuestionKey == question.questionKey
            ? IntakeChatFlow.detailIntro(l, nextQuestion)
            : null;
        if (intro != null) {
          _messages.add(_bot(intro));
        }
        _messages.add(_questionMessage(nextQuestion, l));
      }
    });
    _scrollToBottom();
    _maybeOpenDialog(nextQuestion);
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

class _CurrentQuestionPanel extends StatelessWidget {
  final IntakeChatQuestion question;
  final String blockLabel;

  const _CurrentQuestionPanel({
    required this.question,
    required this.blockLabel,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            blockLabel,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            question.text(l),
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _answerModeLabel(l, question),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

String _answerModeLabel(AppLocalizations l, IntakeChatQuestion question) {
  return switch (question.type) {
    IntakeChatQuestionType.yesNo => l.intakeChatAnswerModeYesNo,
    IntakeChatQuestionType.singleChoice ||
    IntakeChatQuestionType.choiceWithOther ||
    IntakeChatQuestionType.ratingChoice => l.intakeChatAnswerModeChoice,
    IntakeChatQuestionType.multiChoice ||
    IntakeChatQuestionType.multiChoiceWithOther =>
      l.intakeChatAnswerModeMultiChoice,
    IntakeChatQuestionType.url => l.intakeChatAnswerModeUrl,
    IntakeChatQuestionType.email => l.intakeChatAnswerModeEmail,
    IntakeChatQuestionType.multiLineList => l.intakeChatAnswerModeList,
    IntakeChatQuestionType.approximateNumber =>
      l.intakeChatAnswerModeApproximateNumber,
    IntakeChatQuestionType.longText => l.intakeChatAnswerModeLongText,
    _ => l.intakeChatAnswerModeShortText,
  };
}
