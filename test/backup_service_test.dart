import 'package:flutter_test/flutter_test.dart';
import 'package:contentawy/core/models/campaign.dart';
import 'package:contentawy/core/models/content_item.dart';
import 'package:contentawy/core/models/marketing_idea.dart';
import 'package:contentawy/core/models/task_item.dart';
import 'package:contentawy/core/models/user_profile.dart';
import 'package:contentawy/core/services/backup_service.dart';

void main() {
  group('BackupService Tests', () {
    test('createBackupJson creates valid JSON and restoreFromJson recovers data', () {
      final profile = UserProfile(name: 'أحمد ماركتينج', role: 'Media Buying', currency: 'EGP');
      final campaigns = [
        Campaign(name: 'حملة التيست', platform: MarketingPlatform.facebook, budget: 1000, spent: 500, revenue: 2000),
      ];
      final content = [
        ContentItem(title: 'ريلز تجريبي', platform: MarketingPlatform.instagram),
      ];
      final ideas = [
        MarketingIdea(title: 'فكرة ريلز جديدة', platform: MarketingPlatform.tiktok),
      ];
      final tasks = [
        TaskItem(title: 'مراجعة الإعلانات'),
      ];

      final json = BackupService.createBackupJson(
        profile: profile,
        campaigns: campaigns,
        contentItems: content,
        ideas: ideas,
        tasks: tasks,
      );

      expect(json, contains('Contentawy'));
      expect(json, contains('حملة التيست'));

      final restoreResult = BackupService.restoreFromJson(json);
      expect(restoreResult.success, isTrue);
      expect(restoreResult.payload, isNotNull);
      expect(restoreResult.payload!.profile.name, equals('أحمد ماركتينج'));
      expect(restoreResult.payload!.campaigns.length, equals(1));
      expect(restoreResult.payload!.campaigns.first.name, equals('حملة التيست'));
      expect(restoreResult.payload!.contentItems.length, equals(1));
      expect(restoreResult.payload!.ideas.length, equals(1));
      expect(restoreResult.payload!.tasks.length, equals(1));
    });

    test('restoreFromJson fails on invalid or corrupted JSON', () {
      final emptyResult = BackupService.restoreFromJson('');
      expect(emptyResult.success, isFalse);

      final invalidJsonResult = BackupService.restoreFromJson('not valid json');
      expect(invalidJsonResult.success, isFalse);

      final foreignAppResult = BackupService.restoreFromJson('{"app": "AnotherApp"}');
      expect(foreignAppResult.success, isFalse);
    });
  });
}
