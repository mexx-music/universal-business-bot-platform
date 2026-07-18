enum IntakeInvitationStatus { invited, started, partial, completed, disabled }

class IntakeInvitation {
  const IntakeInvitation({
    this.id = '',
    required this.token,
    required this.status,
    required this.greeting,
    required this.createdAt,
    required this.updatedAt,
    this.startedAt,
    this.completedAt,
    this.disabledAt,
  });

  final String id;
  final String token;
  final IntakeInvitationStatus status;
  final String greeting;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? disabledAt;

  bool get isActive => status != IntakeInvitationStatus.disabled;

  IntakeInvitation copyWith({
    String? id,
    String? token,
    IntakeInvitationStatus? status,
    String? greeting,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? disabledAt,
  }) {
    return IntakeInvitation(
      id: id ?? this.id,
      token: token ?? this.token,
      status: status ?? this.status,
      greeting: greeting ?? this.greeting,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      disabledAt: disabledAt ?? this.disabledAt,
    );
  }
}
