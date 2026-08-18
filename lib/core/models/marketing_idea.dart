import 'package:uuid/uuid.dart';
import 'campaign.dart';

enum IdeaPriority { high, medium, low }

class MarketingIdea {
  final String id;
  final String title;
  final String description;
  final MarketingPlatform platform;
  final String tags;
  final IdeaPriority priority;
  final bool isConverted;
  final DateTime createdAt;

  MarketingIdea({
    String? id,
    required this.title,
    this.description = '',
    this.platform = MarketingPlatform.tiktok,
    this.tags = '',
    this.priority = IdeaPriority.medium,
    this.isConverted = false,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  MarketingIdea copyWith({
    String? id,
    String? title,
    String? description,
    MarketingPlatform? platform,
    String? tags,
    IdeaPriority? priority,
    bool? isConverted,
    DateTime? createdAt,
  }) {
    return MarketingIdea(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      platform: platform ?? this.platform,
      tags: tags ?? this.tags,
      priority: priority ?? this.priority,
      isConverted: isConverted ?? this.isConverted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'platform': platform.name,
      'tags': tags,
      'priority': priority.name,
      'isConverted': isConverted,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MarketingIdea.fromJson(Map<String, dynamic> json) {
    MarketingPlatform plat;
    try {
      plat = MarketingPlatform.values
          .byName(json['platform'] as String? ?? 'tiktok');
    } catch (_) {
      plat = MarketingPlatform.tiktok;
    }

    IdeaPriority prio;
    try {
      prio = IdeaPriority.values
          .byName(json['priority'] as String? ?? 'medium');
    } catch (_) {
      prio = IdeaPriority.medium;
    }

    return MarketingIdea(
      id: json['id'] as String?,
      title: json['title'] as String? ?? 'فكرة تسويقية جديدة',
      description: json['description'] as String? ?? '',
      platform: plat,
      tags: json['tags'] as String? ?? '',
      priority: prio,
      isConverted: json['isConverted'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
