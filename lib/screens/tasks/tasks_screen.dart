import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/task_item.dart';
import '../../core/providers/app_state_provider.dart';
import '../../core/utils/haptic_helper.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/stat_badge.dart';
import 'widgets/add_task_sheet.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppStateProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final allTasks = provider.tasks;
    final pendingTasks = allTasks.where((t) => !t.isDone).toList();
    final completedTasks = allTasks.where((t) => t.isDone).toList();
    final urgentTasks = allTasks.where((t) => t.priority == TaskPriority.high && !t.isDone).toList();

    List<TaskItem> displayedTasks;
    switch (_filter) {
      case 'pending':
        displayedTasks = pendingTasks;
        break;
      case 'completed':
        displayedTasks = completedTasks;
        break;
      case 'urgent':
        displayedTasks = urgentTasks;
        break;
      default:
        displayedTasks = allTasks;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('قائمة المهام اليومية', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'إضافة مهمة جديدة',
            onPressed: () => AddTaskSheet.show(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Stats Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: StatBadge(
                      title: 'المتبقي',
                      value: '${pendingTasks.length}',
                      icon: Icons.pending_actions_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatBadge(
                      title: 'المكتمل',
                      value: '${completedTasks.length}',
                      icon: Icons.check_circle_rounded,
                      color: AppColors.accentGrowth,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatBadge(
                      title: 'العاجل',
                      value: '${urgentTasks.length}',
                      icon: Icons.local_fire_department_rounded,
                      color: AppColors.accentError,
                    ),
                  ),
                ],
              ),
            ),

            // Filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  _buildFilterChip('all', 'الكل (${allTasks.length})'),
                  const SizedBox(width: 8),
                  _buildFilterChip('pending', 'قيد التنفيذ (${pendingTasks.length})'),
                  const SizedBox(width: 8),
                  _buildFilterChip('urgent', 'عاجلة 🔥 (${urgentTasks.length})'),
                  const SizedBox(width: 8),
                  _buildFilterChip('completed', 'المكتملة (${completedTasks.length})'),
                ],
              ),
            ),

            // Tasks List
            Expanded(
              child: displayedTasks.isEmpty
                  ? EmptyStateView(
                      icon: Icons.task_alt_rounded,
                      title: 'لا توجد مهام في هذه القائمة',
                      description: 'اضغط على زر الإضافة لتسجيل مهامك اليومية ومتابعتها بكل سهولة.',
                      actionText: 'إضافة مهمة جديدة',
                      onAction: () => AddTaskSheet.show(context),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: displayedTasks.length,
                      itemBuilder: (context, index) {
                        final task = displayedTasks[index];
                        return CustomCard(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          onTap: () => AddTaskSheet.show(context, task: task),
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
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        decoration: task.isDone ? TextDecoration.lineThrough : null,
                                        color: task.isDone
                                            ? (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)
                                            : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                                      ),
                                    ),
                                    if (task.description.isNotEmpty) ...[
                                      const SizedBox(height: 3),
                                      Text(
                                        task.description,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        task.category,
                                        style: const TextStyle(fontSize: 10, color: AppColors.lightTextMuted),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.accentError),
                                onPressed: () async {
                                  final confirmed = await ConfirmDialog.show(
                                    context,
                                    title: 'حذف المهمة',
                                    content: 'هل أنت متأكد من حذف هذه المهمة؟',
                                    confirmText: 'حذف',
                                    isDestructive: true,
                                  );
                                  if (confirmed == true) {
                                    HapticHelper.light();
                                    await provider.deleteTask(task.id);
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AddTaskSheet.show(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('مهمة جديدة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _filter == key;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) {
          HapticHelper.selection();
          setState(() => _filter = key);
        }
      },
    );
  }
}
