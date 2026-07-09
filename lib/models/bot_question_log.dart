import 'package:flutter/material.dart';

enum ReviewStatus { open, reviewed, closed }

enum ReviewReason { noMatch, redFlag, yellowRisk, lowConfidence }

extension ReviewStatusX on ReviewStatus {
  Color get color => switch (this) {
    ReviewStatus.open => Colors.orange,
    ReviewStatus.reviewed => Colors.blue,
    ReviewStatus.closed => Colors.green,
  };

  IconData get icon => switch (this) {
    ReviewStatus.open => Icons.pending_outlined,
    ReviewStatus.reviewed => Icons.rate_review_outlined,
    ReviewStatus.closed => Icons.check_circle_outline,
  };
}

extension ReviewReasonX on ReviewReason {
  Color get color => switch (this) {
    ReviewReason.noMatch => Colors.blueGrey,
    ReviewReason.redFlag => Colors.red,
    ReviewReason.yellowRisk => Colors.orange,
    ReviewReason.lowConfidence => Colors.grey,
  };

  IconData get icon => switch (this) {
    ReviewReason.noMatch => Icons.search_off,
    ReviewReason.redFlag => Icons.block,
    ReviewReason.yellowRisk => Icons.warning_amber_outlined,
    ReviewReason.lowConfidence => Icons.low_priority,
  };
}

class BotQuestionLog {
  final String id;
  final String question;
  final String? answer;
  final bool matched;
  // true = blocked by red risk level, content withheld
  final bool redirected;
  final DateTime timestamp;
  final ReviewStatus reviewStatus;
  final ReviewReason? reviewReason;
  final String? humanNote;
  // Set when status transitions to reviewed or closed
  final DateTime? reviewedAt;

  BotQuestionLog({
    required this.id,
    required this.question,
    this.answer,
    required this.matched,
    this.redirected = false,
    required this.timestamp,
    this.reviewStatus = ReviewStatus.closed,
    this.reviewReason,
    this.humanNote,
    this.reviewedAt,
  });

  BotQuestionLog copyWith({
    String? id,
    String? question,
    String? answer,
    bool? matched,
    bool? redirected,
    DateTime? timestamp,
    ReviewStatus? reviewStatus,
    ReviewReason? reviewReason,
    // Sentinel pattern: pass _keep to leave unchanged, or pass explicit null/String
    Object? humanNote = _keep,
    Object? reviewedAt = _keep,
  }) => BotQuestionLog(
    id: id ?? this.id,
    question: question ?? this.question,
    answer: answer ?? this.answer,
    matched: matched ?? this.matched,
    redirected: redirected ?? this.redirected,
    timestamp: timestamp ?? this.timestamp,
    reviewStatus: reviewStatus ?? this.reviewStatus,
    reviewReason: reviewReason ?? this.reviewReason,
    humanNote: identical(humanNote, _keep)
        ? this.humanNote
        : humanNote as String?,
    reviewedAt: identical(reviewedAt, _keep)
        ? this.reviewedAt
        : reviewedAt as DateTime?,
  );
}

// Sentinel so copyWith can explicitly pass null for nullable fields
const Object _keep = Object();
