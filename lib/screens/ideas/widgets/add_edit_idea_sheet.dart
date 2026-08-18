import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/campaign.dart';
import '../../../core/models/marketing_idea.dart';
import '../../../core/providers/app_state_provider.dart';
import '../../../core/utils/haptic_helper.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/gradient_button.dart';

class AddEditIdeaSheet extends StatefulWidget {
  final MarketingIdea? idea;

  const AddEditIdeaSheet({super.key, this.idea});

  static Future<void> show(BuildContext context, {MarketingIdea? idea}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddEditIdeaSheet(idea: idea),
    );
  }

  @override
  State<AddEditIdeaSheet> createState() => _AddEditIdeaSheetState();
}

class _AddEditIdeaSheetState extends State<AddEditIdeaSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _tagsController;

  late MarketingPlatform _selectedPlatform;
  late IdeaPriority _selectedPriority;

  @override
  void initState() {
    super.initState();
    final it = widget.idea;

    _titleController = TextEditingController(text: it?.title ?? '');
    _descController = TextEditingController(text: it?.description ?? '');
    _tagsController = TextEditingController(text: it?.tags ?? '');

    _selectedPlatform = it?.platform ?? MarketingPlatform.tiktok;
    _selectedPriority = it?.priority ?? IdeaPriority.medium;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AppStateProvider>();
    HapticHelper.success();

    if (widget.idea == null) {
      final newIdea = MarketingIdea(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        platform: _selectedPlatform,
        tags: _tagsController.text.trim(),
        priority: _selectedPriority,
      );
      await provider.addIdea(newIdea);
    } else {
      final updated = widget.idea!.copyWith(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        platform: _selectedPlatform,
        tags: _tagsController.text.trim(),
        priority: _selectedPriority,
      );
      await provider.updateIdea(updated);
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
                    widget.idea == null ? 'تسجيل فكرة تسويقية سريعة' : 'تعديل الفكرة',
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
                label: 'عنوان الفكرة / زاوية الطرح (Hook Angle)',
                hint: 'مثال: فكرة فيديو كوميدي عن مقارنة التكلفة',
                controller: _titleController,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'برجاء كتابة عنوان الفكرة' : null,
              ),
              const SizedBox(height: 14),
              const Text('المنصة المقترحة', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: MarketingPlatform.values.map((plat) {
                    final isSelected = _selectedPlatform == plat;
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: ChoiceChip(
                        label: Text(plat.name.toUpperCase()),
                        selected: isSelected,
                        onSelected: (val) {
                          if (val) setState(() => _selectedPlatform = plat);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 14),
              const Text('الأولوية', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Row(
                children: [
                  _buildPriorityChip(IdeaPriority.high, 'عالية 🔥', AppColors.accentError),
                  const SizedBox(width: 8),
                  _buildPriorityChip(IdeaPriority.medium, 'متوسطة ⚡', AppColors.accentWarning),
                  const SizedBox(width: 8),
                  _buildPriorityChip(IdeaPriority.low, 'عادية 💡', AppColors.primary),
                ],
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'تفاصيل الفكرة وملاحظات التنفيذ',
                hint: 'اشرح الزاوية التسويقية، العرض، أو المحفز النفسي للجمهور...',
                controller: _descController,
                maxLines: 3,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'التاجات والتصنيف (Tags)',
                hint: 'ريلز, مبيعات, B2B, UGC',
                controller: _tagsController,
              ),
              const SizedBox(height: 24),
              GradientButton(
                text: widget.idea == null ? 'حفظ الفكرة في البنك' : 'حفظ التعديلات',
                icon: Icons.lightbulb_rounded,
                gradient: AppColors.growthGradient,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(IdeaPriority priority, String label, Color color) {
    final isSelected = _selectedPriority == priority;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: color.withOpacity(0.2),
      onSelected: (val) {
        if (val) setState(() => _selectedPriority = priority);
      },
    );
  }
}
