import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/campaign.dart';
import '../../../core/models/content_item.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/haptic_helper.dart';
import '../../../widgets/custom_card.dart';

class ContentCard extends StatelessWidget {
  final ContentItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<ContentStatus> onStatusChanged;

  const ContentCard({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
    required this.onStatusChanged,
  });

  Color _getPlatformColor(MarketingPlatform platform) {
    switch (platform) {
      case MarketingPlatform.facebook:
        return AppColors.facebook;
      case MarketingPlatform.instagram:
        return AppColors.instagram;
      case MarketingPlatform.tiktok:
        return Colors.black87;
      case MarketingPlatform.google:
        return AppColors.google;
      case MarketingPlatform.linkedin:
        return AppColors.linkedin;
      case MarketingPlatform.twitter:
        return AppColors.twitter;
      default:
        return AppColors.primary;
    }
  }

  Color _getStatusColor(ContentStatus status) {
    switch (status) {
      case ContentStatus.published:
        return AppColors.accentGrowth;
      case ContentStatus.scheduled:
        return AppColors.primary;
      case ContentStatus.editing:
        return AppColors.accentPurple;
      case ContentStatus.production:
        return AppColors.accentWarning;
      case ContentStatus.scripting:
        return Colors.teal;
      case ContentStatus.idea:
        return Colors.grey;
    }
  }

  String _getStatusLabel(ContentStatus status) {
    switch (status) {
      case ContentStatus.published:
        return 'تم النشر ✅';
      case ContentStatus.scheduled:
        return 'مجدول ⏰';
      case ContentStatus.editing:
        return 'مونتاج وتصميم 🎨';
      case ContentStatus.production:
        return 'تصوير وتسجيل 🎥';
      case ContentStatus.scripting:
        return 'كتابة سكريبت ✍️';
      case ContentStatus.idea:
        return 'فكرة 💡';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final platColor = _getPlatformColor(item.platform);
    final statusColor = _getStatusColor(item.status);

    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      onTap: onEdit,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Platform, Format, Status, Menu
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: platColor.withOpacity(isDark ? 0.25 : 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.platform.name.toUpperCase(),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: platColor),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.format.name.toUpperCase(),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondary),
                ),
              ),
              const Spacer(),
              PopupMenuButton<ContentStatus>(
                initialValue: item.status,
                onSelected: (st) {
                  HapticHelper.light();
                  onStatusChanged(st);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getStatusLabel(item.status),
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_drop_down_rounded, size: 16, color: statusColor),
                    ],
                  ),
                ),
                itemBuilder: (ctx) => ContentStatus.values.map((st) {
                  return PopupMenuItem(
                    value: st,
                    child: Text(_getStatusLabel(st), style: TextStyle(color: _getStatusColor(st))),
                  );
                }).toList(),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, size: 18),
                onSelected: (val) {
                  HapticHelper.light();
                  if (val == 'edit') onEdit();
                  if (val == 'delete') onDelete();
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(value: 'edit', child: Text('تعديل')),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('حذف', style: TextStyle(color: AppColors.accentError)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Title
          Text(
            item.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),

          // Schedule Date/Time
          Row(
            children: [
              Icon(Icons.access_time_rounded, size: 14, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
              const SizedBox(width: 4),
              Text(
                '${DateFormatter.formatShort(item.scheduledDate)} الساعة ${DateFormatter.formatTime(item.scheduledDate)}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Caption Snippet if exists
          if (item.caption.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceVariant.withOpacity(0.4) : AppColors.lightSurfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item.caption,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Action Buttons: Copy Caption & Copy Hashtags
          Row(
            children: [
              if (item.caption.isNotEmpty)
                TextButton.icon(
                  icon: const Icon(Icons.copy_rounded, size: 14),
                  label: const Text('نسخ الكابشن', style: TextStyle(fontSize: 12)),
                  onPressed: () {
                    HapticHelper.light();
                    Clipboard.setData(ClipboardData(text: item.caption));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم نسخ نص المنشور (Caption)! 📋')),
                    );
                  },
                ),
              if (item.hashtags.isNotEmpty) ...[
                const SizedBox(width: 8),
                TextButton.icon(
                  icon: const Icon(Icons.tag_rounded, size: 14),
                  label: const Text('نسخ الهاشتاجات', style: TextStyle(fontSize: 12)),
                  onPressed: () {
                    HapticHelper.light();
                    Clipboard.setData(ClipboardData(text: item.hashtags));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم نسخ الهاشتاجات! #️⃣')),
                    );
                  },
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
