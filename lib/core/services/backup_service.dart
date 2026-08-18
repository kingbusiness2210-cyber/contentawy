import 'dart:convert';
import '../models/backup_payload.dart';
import '../models/user_profile.dart';
import '../models/campaign.dart';
import '../models/content_item.dart';
import '../models/marketing_idea.dart';
import '../models/task_item.dart';

class BackupResult {
  final bool success;
  final String message;
  final BackupPayload? payload;

  BackupResult({
    required this.success,
    required this.message,
    this.payload,
  });
}

class BackupService {
  static String createBackupJson({
    required UserProfile profile,
    required List<Campaign> campaigns,
    required List<ContentItem> contentItems,
    required List<MarketingIdea> ideas,
    required List<TaskItem> tasks,
  }) {
    final payload = BackupPayload(
      profile: profile,
      campaigns: campaigns,
      contentItems: contentItems,
      ideas: ideas,
      tasks: tasks,
    );

    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(payload.toJson());
  }

  static BackupResult restoreFromJson(String jsonString) {
    if (jsonString.trim().isEmpty) {
      return BackupResult(
        success: false,
        message: 'النص أو الملف فارغ تماماً.',
      );
    }

    try {
      final dynamic decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic>) {
        return BackupResult(
          success: false,
          message: 'صيغة الملف غير صحيحة (ليست JSON صالح).',
        );
      }

      final payload = BackupPayload.fromJson(decoded);
      return BackupResult(
        success: true,
        message: 'تم استرجاع البيانات بنجاح (${payload.campaigns.length} حملة، ${payload.contentItems.length} منشور، ${payload.ideas.length} فكرة، ${payload.tasks.length} مهمة).',
        payload: payload,
      );
    } catch (e) {
      return BackupResult(
        success: false,
        message: 'فشل في قراءة ملف النسخ الاحتياطي: ${e.toString()}',
      );
    }
  }
}
