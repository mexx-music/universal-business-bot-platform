enum IntakeChatRole { bot, user, system }

class IntakeChatMessage {
  final String id;
  final IntakeChatRole role;
  final String text;
  final DateTime timestamp;
  final String? questionKey;
  final String? blockKey;

  const IntakeChatMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.timestamp,
    this.questionKey,
    this.blockKey,
  });
}
