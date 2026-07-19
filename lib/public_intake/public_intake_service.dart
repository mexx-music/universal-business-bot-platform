import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:flutter/foundation.dart';

import '../models/business_rules.dart';
import '../models/bot_configuration.dart';
import '../models/company.dart';
import '../models/company_workspace.dart';
import '../models/intake_session.dart';
import '../repositories/persistence/workspace_codec.dart';
import '../repositories/remote_workspace_mapper.dart';

enum PublicIntakeRemoteStatus {
  opened,
  notFound,
  disabled,
  expired,
  notConfigured,
  remoteError,
}

class PublicIntakeOpenResponse {
  const PublicIntakeOpenResponse({
    required this.status,
    this.workspace,
    this.debugReason,
  });

  final PublicIntakeRemoteStatus status;
  final CompanyWorkspace? workspace;
  final String? debugReason;
}

abstract class PublicIntakeService {
  bool get isSupported;

  Future<PublicIntakeOpenResponse> open(String token);

  Future<PublicIntakeOpenResponse> save({
    required String token,
    required IntakeSession session,
  });
}

class UnsupportedPublicIntakeService implements PublicIntakeService {
  const UnsupportedPublicIntakeService();

  @override
  bool get isSupported => false;

  @override
  Future<PublicIntakeOpenResponse> open(String token) {
    throw UnsupportedError('Remote public intake is not configured.');
  }

  @override
  Future<PublicIntakeOpenResponse> save({
    required String token,
    required IntakeSession session,
  }) {
    throw UnsupportedError('Remote public intake is not configured.');
  }
}

class SupabasePublicIntakeService implements PublicIntakeService {
  const SupabasePublicIntakeService(this._client);

  final sb.SupabaseClient _client;
  static const _mapper = RemoteWorkspaceMapper();
  static const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  @override
  bool get isSupported => true;

  @override
  Future<PublicIntakeOpenResponse> open(String token) async {
    const rpcName = 'public_open_intake_invitation';
    _debugRpcStart(rpcName, token);
    try {
      final result = await _client.rpc(
        rpcName,
        params: {'raw_token': token.trim()},
      );
      final response = _responseFromRpc(result);
      _debugRpcResult(rpcName, response);
      return response;
    } catch (error) {
      _debugRpcError(rpcName, error);
      return PublicIntakeOpenResponse(
        status: PublicIntakeRemoteStatus.remoteError,
        debugReason: _safeErrorCode(error),
      );
    }
  }

  @override
  Future<PublicIntakeOpenResponse> save({
    required String token,
    required IntakeSession session,
  }) async {
    const rpcName = 'public_save_intake_session';
    _debugRpcStart(rpcName, token);
    try {
      final result = await _client.rpc(
        rpcName,
        params: {
          'raw_token': token.trim(),
          'session_payload': WorkspaceCodec.encodeIntakeSession(session),
        },
      );
      final response = _responseFromRpc(result);
      _debugRpcResult(rpcName, response);
      return response;
    } catch (error) {
      _debugRpcError(rpcName, error);
      return PublicIntakeOpenResponse(
        status: PublicIntakeRemoteStatus.remoteError,
        debugReason: _safeErrorCode(error),
      );
    }
  }

  PublicIntakeOpenResponse _responseFromRpc(Object? result) {
    final json = _map(result);
    final status = switch (_string(json, 'status')) {
      'opened' => PublicIntakeRemoteStatus.opened,
      'disabled' => PublicIntakeRemoteStatus.disabled,
      'expired' => PublicIntakeRemoteStatus.expired,
      _ => PublicIntakeRemoteStatus.notFound,
    };
    if (status != PublicIntakeRemoteStatus.opened) {
      return PublicIntakeOpenResponse(
        status: status,
        debugReason: _string(json, 'reason'),
      );
    }
    return PublicIntakeOpenResponse(
      status: status,
      workspace: CompanyWorkspace(
        company: _company(_map(json['company'])),
        products: const [],
        knowledgeEntries: const [],
        botLogs: const [],
        auditItems: const [],
        businessRules: const BusinessRules(
          brandVoice: '',
          doNotSay: [],
          allowedSupportTopics: [],
          escalationNotes: '',
        ),
        botConfiguration: const BotConfiguration(
          status: BotStatus.draft,
          answerStyle: BotAnswerStyle.balanced,
          defaultLanguage: 'de',
          useDisclaimer: false,
          disclaimerText: '',
          alwaysEscalateRedFlags: true,
          escalateNoMatch: true,
          escalateYellowRisk: false,
          allowedTopics: [],
          blockedTopics: [],
          handoverMessage: '',
        ),
        sourceMaterials: const [],
        intakeSession: WorkspaceCodec.decodeIntakeSession(
          _map(json['intakeSession']),
        ),
        intakeInvitation: _mapper.intakeInvitationFromRow(
          _map(json['invitation']),
        ),
      ),
    );
  }

  void _debugRpcStart(String rpcName, String token) {
    debugPrint(
      '[public-intake] rpc=$rpcName project=${_projectIdentifier()} '
      'tokenLength=${token.trim().length}',
    );
  }

  void _debugRpcResult(String rpcName, PublicIntakeOpenResponse response) {
    debugPrint(
      '[public-intake] rpc=$rpcName status=${response.status.name} '
      'reason=${response.debugReason ?? '-'} '
      'workspaceLoaded=${response.workspace != null}',
    );
  }

  void _debugRpcError(String rpcName, Object error) {
    debugPrint(
      '[public-intake] rpc=$rpcName status=remoteError '
      'project=${_projectIdentifier()} error=${_safeErrorCode(error)}',
    );
  }

  String _projectIdentifier() {
    final parsed = Uri.tryParse(_supabaseUrl.trim());
    final host = parsed?.host ?? '';
    if (host.isEmpty) return 'unknown';
    return host;
  }

  String _safeErrorCode(Object error) {
    if (error is sb.PostgrestException) {
      return error.code ?? 'postgrest';
    }
    return error.runtimeType.toString();
  }

  Company _company(Map<String, Object?> json) {
    return Company(
      id: _string(json, 'id'),
      name: _string(json, 'name'),
      industry: _string(json, 'industry'),
      description: _string(json, 'shortDescription'),
      country: _string(json, 'country'),
      primaryLanguage: _string(json, 'primaryLanguage', 'de'),
      website: _string(json, 'website'),
      email: '',
      phone: null,
      address: '',
      socialLinks: const {},
      internalNotes: '',
    );
  }

  Map<String, Object?> _map(Object? value) {
    if (value is Map) return value.cast<String, Object?>();
    return const {};
  }

  String _string(
    Map<String, Object?> json,
    String key, [
    String fallback = '',
  ]) {
    final value = json[key];
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }
}
