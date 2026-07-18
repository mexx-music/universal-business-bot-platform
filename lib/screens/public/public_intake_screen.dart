import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/app_state.dart';
import '../../l10n/app_localizations.dart';
import '../../public_intake/public_intake_service.dart';
import '../../public_intake/public_intake_workspace_repository.dart';
import '../intake/intake_chat_screen.dart';

class PublicIntakeScreen extends StatefulWidget {
  const PublicIntakeScreen({
    super.key,
    required this.token,
    required this.publicIntakeService,
  });

  final String token;
  final PublicIntakeService publicIntakeService;

  @override
  State<PublicIntakeScreen> createState() => _PublicIntakeScreenState();
}

class _PublicIntakeScreenState extends State<PublicIntakeScreen> {
  PublicIntakeOpenResult? _result;
  Future<PublicIntakeOpenResult>? _openFuture;
  AppState? _publicAppState;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _openFuture ??= _openInvitation();
  }

  Future<PublicIntakeOpenResult> _openInvitation() async {
    if (!widget.publicIntakeService.isSupported) {
      final state = AppState.of(context);
      final result = state.openPublicIntakeInvitation(widget.token);
      _result = result;
      return result;
    }

    final response = await widget.publicIntakeService.open(widget.token);
    final workspace = response.workspace;
    final result = switch (response.status) {
      PublicIntakeRemoteStatus.opened when workspace != null =>
        PublicIntakeOpenResult.opened,
      PublicIntakeRemoteStatus.disabled => PublicIntakeOpenResult.disabled,
      _ => PublicIntakeOpenResult.notFound,
    };
    if (result == PublicIntakeOpenResult.opened && workspace != null) {
      _publicAppState?.dispose();
      _publicAppState = AppState(
        workspaceRepository: PublicIntakeWorkspaceRepository(
          token: widget.token,
          service: widget.publicIntakeService,
          workspace: workspace,
        ),
      );
    }
    _result = result;
    return result;
  }

  @override
  void dispose() {
    _publicAppState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final future = _openFuture;
    if (future == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return FutureBuilder<PublicIntakeOpenResult>(
      future: future,
      builder: (context, snapshot) {
        final result = snapshot.data ?? _result;
        if (snapshot.connectionState != ConnectionState.done ||
            result == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final remoteState = _publicAppState;
        if (result == PublicIntakeOpenResult.opened && remoteState != null) {
          final invitation = remoteState.selectedIntakeInvitation;
          return AppStateScope(
            notifier: remoteState,
            child: IntakeChatScreen(
              publicMode: true,
              publicCompanyName: remoteState.selectedCompany.name,
              publicGreeting: invitation?.greeting,
            ),
          );
        }

        if (result == PublicIntakeOpenResult.opened) {
          final state = AppState.of(context);
          if (state.hasWorkspaces) {
            final invitation = state.selectedIntakeInvitation;
            return IntakeChatScreen(
              publicMode: true,
              publicCompanyName: state.selectedCompany.name,
              publicGreeting: invitation?.greeting,
            );
          }
        }

        return _ErrorView(result: result);
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.result});

  final PublicIntakeOpenResult result;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    final disabled = result == PublicIntakeOpenResult.disabled;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.appName),
        actions: [
          TextButton(onPressed: () => context.go('/'), child: Text(l.navHome)),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      disabled
                          ? Icons.link_off_outlined
                          : Icons.search_off_outlined,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      disabled
                          ? l.publicIntakeDisabledTitle
                          : l.publicIntakeNotFoundTitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      disabled
                          ? l.publicIntakeDisabledMessage
                          : l.publicIntakeNotFoundMessage,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: () => context.go('/'),
                      icon: const Icon(Icons.home_outlined),
                      label: Text(l.navHome),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
