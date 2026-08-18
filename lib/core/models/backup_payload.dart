import 'user_profile.dart';
import 'campaign.dart';
import 'content_item.dart';
import 'marketing_idea.dart';
import 'task_item.dart';

class BackupPayload {
  final int version;
  final String app;
  final DateTime exportedAt;
  final UserProfile profile;
  final List<Campaign> campaigns;
  final List<ContentItem> contentItems;
  final List<MarketingIdea> ideas;
  final List<TaskItem> tasks;

  BackupPayload({
    this.version = 1,
    this.app = 'Contentawy',
    DateTime? exportedAt,
    required this.profile,
    required this.campaigns,
    required this.contentItems,
    required this.ideas,
    required this.tasks,
  }) : exportedAt = exportedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'app': app,
      'exportedAt': exportedAt.toIso8601String(),
      'profile': profile.toJson(),
      'campaigns': campaigns.map((c) => c.toJson()).toList(),
      'contentItems': contentItems.map((c) => c.toJson()).toList(),
      'ideas': ideas.map((i) => i.toJson()).toList(),
      'tasks': tasks.map((t) => t.toJson()).toList(),
    };
  }

  factory BackupPayload.fromJson(Map<String, dynamic> json) {
    if (json['app'] != 'Contentawy' && json['app'] != 'contentawy') {
      throw const FormatException('ملف النسخ الاحتياطي غير متوافق مع تطبيق كونتنتاوي');
    }

    final profile = json['profile'] != null
        ? UserProfile.fromJson(Map<String, dynamic>.from(json['profile'] as Map))
        : UserProfile.defaultProfile();

    final campaigns = (json['campaigns'] as List<dynamic>?)
            ?.map((c) => Campaign.fromJson(Map<String, dynamic>.from(c as Map)))
            .toList() ??
        [];

    final contentItems = (json['contentItems'] as List<dynamic>?)
            ?.map((c) => ContentItem.fromJson(Map<String, dynamic>.from(c as Map)))
            .toList() ??
        [];

    final ideas = (json['ideas'] as List<dynamic>?)
            ?.map((i) => MarketingIdea.fromJson(Map<String, dynamic>.from(i as Map)))
            .toList() ??
        [];

    final tasks = (json['tasks'] as List<dynamic>?)
            ?.map((t) => TaskItem.fromJson(Map<String, dynamic>.from(t as Map)))
            .toList() ??
        [];

    return BackupPayload(
      version: json['version'] as int? ?? 1,
      app: json['app'] as String? ?? 'Contentawy',
      exportedAt: json['exportedAt'] != null
          ? DateTime.tryParse(json['exportedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      profile: profile,
      campaigns: campaigns,
      contentItems: contentItems,
      ideas: ideas,
      tasks: tasks,
    );
  }
}
