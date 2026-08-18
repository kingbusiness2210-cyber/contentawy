import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/task_item.dart';
import '../../../core/providers/app_state_provider.dart';
import '../../../core/utils/haptic_helper.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/gradient_button.dart';

class AddTaskSheet extends StatefulWidget {
  final TaskItem? task;

  const AddTaskSheet({super.key, this.task});

  static Future<void> show(BuildContext context, {TaskItem? task}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTaskSheet(task: task),
    );
  }

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descController;
  late String _category;
  late TaskPriority _priority;
  late DateTime _dueDate;

  final List<String> _categories = [
    'عام',
    'ميديا باينج وإعلانات',
    'صناعة محتوى',
    'تصميم ومونتاج',
    'تقارير وتحليلات',
    'متابعة عملاء',
  ];

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _titleController = TextEditingController(text: t?.title ?? '');
    _descController = TextEditingController(text: t?.description ?? '');
    _category = t?.category ?? _categories.first;
    _priority = t?.priority ?? TaskPriority.medium;
    _dueDate = t?.dueDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AppStateProvider>();
    HapticHelper.success();

    if (widget.task == null) {
      final newTask = TaskItem(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        category: _category,
        priority: _priority,
        dueDate: _dueDate,
      );
      await provider.addTask(newTask);
    } else {
      final updated = widget.task!.copyWith(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        category: _category,
        priority: _priority,
        dueDate: _dueDate,
      );
      await provider.updateTask(updated);
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.task == null ? 'إضافة مهمة تسويقية جديدة' : 'تعديل المهمة',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'عنوان المهمة',
                hint: 'مثال: مراجعة الكرييتف ومعدل الـ CTR في إعلانات تيك توك',
                controller: _titleController,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'برجاء كتابة عنوان المهمة' : null,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'تفاصيل إضافية (اختياري)',
                hint: 'أي روابط أو أرقام مستهدفة لإتمام المهمة',
                controller: _descController,
                maxLines: 2,
              ),
              const SizedBox(height: 14),
              const Text('التصنيف', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _category,
                    isExpanded: true,
                    items: _categories.map((c) {
                      return DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _category = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text('الأولوية', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Row(
                children: [
                  _buildPriorityChip(TaskPriority.high, 'عاجلة 🔥', AppColors.accentError),
                  const SizedBox(width: 8),
                  _buildPriorityChip(TaskPriority.medium, 'متوسطة ⚡', AppColors.accentWarning),
                  const SizedBox(width: 8),
                  _buildPriorityChip(TaskPriority.low, 'عادية ⏳', AppColors.primary),
                ],
              ),
              const SizedBox(height: 24),
              GradientButton(
                text: widget.task == null ? 'حفظ المهمة' : 'حفظ التعديل',
                icon: Icons.check_rounded,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(TaskPriority priority, String label, Color color) {
    final isSelected = _priority == priority;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: color.withOpacity(0.2),
      onSelected: (val) {
        if (val) setState(() => _priority = priority);
      },
    );
  }
}
