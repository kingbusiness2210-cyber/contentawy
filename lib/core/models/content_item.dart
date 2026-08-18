import 'package:uuid/uuid.dart';
import 'campaign.dart';

enum ContentFormat { reel, carousel, post, story, thread, newsletter }

enum ContentStatus {
  idea,
  scripting,
  production,
  editing,
  scheduled,
  published,
}

class ContentItem {
  final String id;
  final String title;
  final MarketingPlatform platform;
  final ContentFormat format;
  final ContentStatus status;
  final DateTime scheduledDate;
  final String caption;
  final String hashtags;
  final String targetGoal;
  final String notes;
  final DateTime createdAt;

  ContentItem({
    String? id,
    required this.title,
    required this.platform,
    this.format = ContentFormat.reel,
    this.status = ContentStatus.idea,
    DateTime? scheduledDate,
    this.caption = '',
    this.hashtags = '',
    this.targetGoal = 'تفاعل (Engagement)',
    this.notes = '',
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        scheduledDate = scheduledDate ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  bool get isScheduledForToday {
    final now = DateTime.now();
    return scheduledDate.year == now.year &&
        scheduledDate.month == now.month &&
        scheduledDate.day == now.day;
  }

  ContentItem copyWith({
    String? id,
    String? title,
    MarketingPlatform? platform,
    ContentFormat? format,
    ContentStatus? status,
    DateTime? scheduledDate,
    String? caption,
    String? hashtags,
    String? targetGoal,
    String? notes,
    DateTime? createdAt,
  }) {
    return ContentItem(
      id: id ?? this.id,
      title: title ?? this.title,
      platform: platform ?? this.platform,
      format: format ?? this.format,
      status: status ?? this.status,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      caption: caption ?? this.caption,
      hashtags: hashtags ?? this.hashtags,
      targetGoal: targetGoal ?? this.targetGoal,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'platform': platform.name,
      'format': format.name,
      'status': status.name,
      'scheduledDate': scheduledDate.toIso8601String(),
      'caption': caption,
      'hashtags': hashtags,
      'targetGoal': targetGoal,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    MarketingPlatform plat;
    try {
      plat = MarketingPlatform.values
          .byName(json['platform'] as String? ?? 'instagram');
    } catch (_) {
      plat = MarketingPlatform.instagram;
    }

    ContentFormat form;
    try {
      form = ContentFormat.values
          .byName(json['format'] as String? ?? 'reel');
    } catch (_) {
      form = ContentFormat.reel;
    }

    ContentStatus stat;
    try {
      stat = ContentStatus.values
          .byName(json['status'] as String? ?? 'idea');
    } catch (_) {
      stat = ContentStatus.idea;
    }

    return ContentItem(
      id: json['id'] as String?,
      title: json['title'] as String? ?? 'منشور بدون عنوان',
      platform: plat,
      format: form,
      status: stat,
      scheduledDate: json['scheduledDate'] != null
          ? DateTime.tryParse(json['scheduledDate'] as String) ?? DateTime.now()
          : DateTime.now(),
      caption: json['caption'] as String? ?? '',
      hashtags: json['hashtags'] as String? ?? '',
      targetGoal: json['targetGoal'] as String? ?? 'تفاعل (Engagement)',
      notes: json['notes'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
