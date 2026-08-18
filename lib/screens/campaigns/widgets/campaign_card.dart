import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/campaign.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/haptic_helper.dart';
import '../../../widgets/custom_card.dart';

class CampaignCard extends StatelessWidget {
  final Campaign campaign;
  final String currency;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleStatus;

  const CampaignCard({
    super.key,
    required this.campaign,
    required this.currency,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
  });

  Color _getPlatformColor(MarketingPlatform platform) {
    switch (platform) {
      case MarketingPlatform.facebook:
        return AppColors.facebook;
      case MarketingPlatform.instagram:
        return AppColors.instagram;
      case MarketingPlatform.tiktok:
        return AppColors.tiktok;
      case MarketingPlatform.google:
        return AppColors.google;
      case MarketingPlatform.linkedin:
        return AppColors.linkedin;
      case MarketingPlatform.twitter:
        return AppColors.twitter;
      case MarketingPlatform.snapchat:
        return const Color(0xFFEAB308);
      default:
        return AppColors.primary;
    }
  }

  IconData _getPlatformIcon(MarketingPlatform platform) {
    switch (platform) {
      case MarketingPlatform.facebook:
        return Icons.facebook_rounded;
      case MarketingPlatform.google:
        return Icons.search_rounded;
      case MarketingPlatform.linkedin:
        return Icons.work_rounded;
      case MarketingPlatform.tiktok:
      case MarketingPlatform.instagram:
      default:
        return Icons.campaign_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final platColor = _getPlatformColor(campaign.platform);

    final isProfit = campaign.profit >= 0;
    final progress = campaign.budgetProgress;

    return CustomCard(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      onTap: onEdit,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Platform & Status & Menu
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: platColor.withOpacity(isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: platColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_getPlatformIcon(campaign.platform), size: 14, color: platColor),
                    const SizedBox(width: 5),
                    Text(
                      campaign.platform.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: platColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildStatusBadge(campaign.status),
              const Spacer(),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, size: 20),
                onSelected: (val) {
                  HapticHelper.light();
                  if (val == 'edit') onEdit();
                  if (val == 'delete') onDelete();
                  if (val == 'toggle') onToggleStatus();
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: 'toggle',
                    child: Row(
                      children: [
                        Icon(
                          campaign.status == CampaignStatus.active
                              ? Icons.pause_circle_outline_rounded
                              : Icons.play_circle_outline_rounded,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(campaign.status == CampaignStatus.active
                            ? 'إيقاف مؤقت'
                            : 'تفعيل الحملة'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18),
                        const SizedBox(width: 8),
                        Text('تعديل البيانات'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.accentError),
                        const SizedBox(width: 8),
                        Text('حذف الحملة', style: TextStyle(color: AppColors.accentError)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Campaign Name & Objective
          Text(
            campaign.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'الهدف: ${campaign.objective} • بدأت ${DateFormatter.formatShort(campaign.startDate)}',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 14),

          // Budget Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'المنصرف من الميزانية',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}% (${CurrencyFormatter.format(campaign.spent, currency: currency)} / ${CurrencyFormatter.format(campaign.budget, currency: currency)})',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightBorder,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress >= 0.95 ? AppColors.accentWarning : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Metrics Summary Row (ROAS, Revenue, Net Profit)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceVariant.withOpacity(0.5) : AppColors.lightSurfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricCol(
                  'العائد الإعلاني ROAS',
                  '${campaign.roas.toStringAsFixed(2)}x',
                  campaign.roas >= 2.0 ? AppColors.accentGrowth : AppColors.accentWarning,
                ),
                Container(width: 1, height: 26, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                _buildMetricCol(
                  'إجمالي المبيعات',
                  CurrencyFormatter.format(campaign.revenue, currency: currency),
                  isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
                Container(width: 1, height: 26, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                _buildMetricCol(
                  'صافي الربح',
                  CurrencyFormatter.format(campaign.profit, currency: currency),
                  isProfit ? AppColors.accentGrowth : AppColors.accentError,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCol(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.lightTextMuted),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(CampaignStatus status) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case CampaignStatus.active:
        bg = AppColors.accentGrowth.withOpacity(0.15);
        fg = AppColors.accentGrowth;
        label = 'نشطة 🟢';
        break;
      case CampaignStatus.paused:
        bg = AppColors.accentWarning.withOpacity(0.15);
        fg = AppColors.accentWarning;
        label = 'متوقفة ⏸️';
        break;
      case CampaignStatus.completed:
        bg = Colors.blueGrey.withOpacity(0.15);
        fg = Colors.blueGrey;
        label = 'مكتملة 🏁';
        break;
      case CampaignStatus.draft:
        bg = Colors.grey.withOpacity(0.15);
        fg = Colors.grey;
        label = 'مسودة 📝';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }
}
