import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../models/business_rules.dart';
import '../models/bot_configuration.dart';
import '../models/company.dart';
import '../models/company_workspace.dart';
import '../models/intake_session.dart';
import '../repositories/persistence/workspace_codec.dart';
import '../repositories/remote_workspace_mapper.dart';

enum PublicIntakeRemoteStatus { opened, notFound, disabled }

class PublicIntakeOpenResponse {
  const PublicIntakeOpenResponse({required this.status, this.workspace});

  final PublicIntakeRemoteStatus status;
  final CompanyWorkspace? workspace;
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

  @override
  bool get isSupported => true;

  @override
  Future<PublicIntakeOpenResponse> open(String token) async {
    final result = await _client.rpc(
      'public_open_intake_invitation',
      params: {'raw_token': token.trim()},
    );
    return _responseFromRpc(result);
  }

  @override
  Future<PublicIntakeOpenResponse> save({
    required String token,
    required IntakeSession session,
  }) async {
    final result = await _client.rpc(
      'public_save_intake_session',
      params: {
        'raw_token': token.trim(),
        'session_payload': WorkspaceCodec.encodeIntakeSession(session),
      },
    );
    return _responseFromRpc(result);
  }

  PublicIntakeOpenResponse _responseFromRpc(Object? result) {
    final json = _map(result);
    final status = switch (_string(json, 'status')) {
      'opened' => PublicIntakeRemoteStatus.opened,
      'disabled' => PublicIntakeRemoteStatus.disabled,
      _ => PublicIntakeRemoteStatus.notFound,
    };
    if (status != PublicIntakeRemoteStatus.opened) {
      return PublicIntakeOpenResponse(status: status);
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
