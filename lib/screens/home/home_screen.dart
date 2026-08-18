import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/task_item.dart';
import '../../core/providers/app_state_provider.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/haptic_helper.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/stat_badge.dart';
import '../campaigns/widgets/add_edit_campaign_sheet.dart';
import '../calendar/widgets/add_edit_content_sheet.dart';
import '../ideas/widgets/add_edit_idea_sheet.dart';
import '../tasks/tasks_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppStateProvider>();
    final profile = provider.profile;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currency = profile.currency;

    final greeting = DateFormatter.getDayGreeting();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.trending_up_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text('كونتنتاوي', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline_rounded),
            tooltip: 'قائمة المهام اليومية',
            onPressed: () {
              HapticHelper.light();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TasksScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'الإعدادات والنسخ الاحتياطي',
            onPressed: () {
              HapticHelper.light();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            HapticHelper.light();
            await Future.delayed(const Duration(milliseconds: 300));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: isDark
                        ? const LinearGradient(
                            colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : const LinearGradient(
                            colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : const Color(0xFFBFDBFE),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            greeting,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.primaryDark,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              profile.role.split('(').first.trim(),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        profile.name,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'جاهز لتحقيق نتائج وأرقام أعلى النهاردة؟',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Quick Action Bar
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildQuickAction(
                        context,
                        icon: Icons.add_circle_outline_rounded,
                        label: 'حملة جديدة',
                        color: AppColors.primary,
                        onTap: () => AddEditCampaignSheet.show(context),
                      ),
                      const SizedBox(width: 8),
                      _buildQuickAction(
                        context,
                        icon: Icons.post_add_rounded,
                        label: 'محتوى جديد',
                        color: AppColors.secondary,
                        onTap: () => AddEditContentSheet.show(context),
                      ),
                      const SizedBox(width: 8),
                      _buildQuickAction(
                        context,
                        icon: Icons.lightbulb_outline_rounded,
                        label: 'فكرة سريعة',
                        color: AppColors.accentGrowth,
                        onTap: () => AddEditIdeaSheet.show(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Marketing Stats Bar (Spend / Revenue / ROAS)
                Row(
                  children: [
                    Expanded(
                      child: StatBadge(
                        title: 'الإنفاق الإعلاني',
                        value: CurrencyFormatter.format(provider.totalSpent, currency: currency, compact: true),
                        icon: Icons.account_balance_wallet_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatBadge(
                        title: 'إجمالي العائد',
                        value: CurrencyFormatter.format(provider.totalRevenue, currency: currency, compact: true),
                        icon: Icons.trending_up_rounded,
                        color: AppColors.accentGrowth,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatBadge(
                        title: 'متوسط ROAS',
                        value: '${provider.overallROAS.toStringAsFixed(2)}x',
                        icon: Icons.auto_graph_rounded,
                        color: provider.overallROAS >= 2.0 ? AppColors.accentGrowth : AppColors.accentWarning,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Today's Planned Content Section
                SectionHeader(
                  title: 'محتوى اليوم 🎬',
                  subtitle: '${provider.todayContent.length} منشورات مجدولة',
                  actionTitle: 'عرض الكل',
                  onAction: () {
                    // Switch tab or direct view
                  },
                ),
                if (provider.todayContent.isEmpty)
                  CustomCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_circle_outline_rounded, color: AppColors.secondary, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'مفيش منشورات مجدولة للنهاردة',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'تقدر تضيف ريلز أو بوست في جدول المحتوى.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () => AddEditContentSheet.show(context),
                          child: const Text('+ إضافة'),
                        ),
                      ],
                    ),
                  )
                else
                  ...provider.todayContent.map((content) {
                    return CustomCard(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.video_library_rounded, color: AppColors.secondary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  content.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${content.platform.name.toUpperCase()} • ${content.format.name}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              content.status.name,
                              style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                const SizedBox(height: 20),

                // Urgent & Today Tasks Section
                SectionHeader(
                  title: 'أهم مهام اليوم ✅',
                  subtitle: '${provider.todayTasks.where((t) => !t.isDone).length} متبقية',
                  actionTitle: 'كل المهام',
                  onAction: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const TasksScreen()),
                    );
                  },
                ),
                if (provider.tasks.isEmpty)
                  CustomCard(
                    padding: const EdgeInsets.all(16),
                    child: const Center(
                      child: Text('لا توجد مهام حالياً. استغل الوقت في التخطيط!'),
                    ),
                  )
                else
                  ...provider.tasks.take(3).map((task) {
                    return CustomCard(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Checkbox(
                            value: task.isDone,
                            activeColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            onChanged: (_) {
                              HapticHelper.medium();
                              provider.toggleTaskDone(task.id);
                            },
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task.title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    decoration: task.isDone ? TextDecoration.lineThrough : null,
                                    color: task.isDone
                                        ? (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)
                                        : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                                  ),
                                ),
                                if (task.description.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    task.description,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (task.priority == TaskPriority.high && !task.isDone)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.accentError.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'عاجل',
                                style: TextStyle(fontSize: 10, color: AppColors.accentError, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        HapticHelper.light();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(isDark ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
