import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/campaign.dart';
import '../../../core/models/content_item.dart';
import '../../../core/providers/app_state_provider.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/haptic_helper.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/gradient_button.dart';
import 'copywriting_template_sheet.dart';

class AddEditContentSheet extends StatefulWidget {
  final ContentItem? item;
  final String? initialTitle;
  final String? initialCaption;

  const AddEditContentSheet({
    super.key,
    this.item,
    this.initialTitle,
    this.initialCaption,
  });

  static Future<void> show(
    BuildContext context, {
    ContentItem? item,
    String? initialTitle,
    String? initialCaption,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddEditContentSheet(
        item: item,
        initialTitle: initialTitle,
        initialCaption: initialCaption,
      ),
    );
  }

  @override
  State<AddEditContentSheet> createState() => _AddEditContentSheetState();
}

class _AddEditContentSheetState extends State<AddEditContentSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _captionController;
  late TextEditingController _hashtagsController;
  late TextEditingController _notesController;

  late MarketingPlatform _selectedPlatform;
  late ContentFormat _selectedFormat;
  late ContentStatus _selectedStatus;
  late DateTime _scheduledDate;
  late String _targetGoal;

  final List<String> _goals = [
    'تفاعل ومشاركات (Engagement & Shares)',
    'مشاهدات فيديو وانتشار (Views & Virality)',
    'زيادة المتابعين (Followers Growth)',
    'عملاء محتملين واستفسارات (Leads & Inquiries)',
    'مبيعات مباشرة (Direct Sales)',
    'بناء مصداقية وخبرة (Brand Authority)',
  ];

  @override
  void initState() {
    super.initState();
    final it = widget.item;

    _titleController = TextEditingController(
        text: it?.title ?? widget.initialTitle ?? '');
    _captionController = TextEditingController(
        text: it?.caption ?? widget.initialCaption ?? '');
    _hashtagsController = TextEditingController(text: it?.hashtags ?? '');
    _notesController = TextEditingController(text: it?.notes ?? '');

    _selectedPlatform = it?.platform ?? MarketingPlatform.instagram;
    _selectedFormat = it?.format ?? ContentFormat.reel;
    _selectedStatus = it?.status ?? ContentStatus.idea;
    _scheduledDate = it?.scheduledDate ?? DateTime.now();
    _targetGoal = it?.targetGoal ?? _goals.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _captionController.dispose();
    _hashtagsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _pickDateTime() async {
    HapticHelper.light();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _scheduledDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_scheduledDate),
      );

      if (pickedTime != null) {
        setState(() {
          _scheduledDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AppStateProvider>();
    HapticHelper.success();

    if (widget.item == null) {
      final newItem = ContentItem(
        title: _titleController.text.trim(),
        platform: _selectedPlatform,
        format: _selectedFormat,
        status: _selectedStatus,
        scheduledDate: _scheduledDate,
        caption: _captionController.text.trim(),
        hashtags: _hashtagsController.text.trim(),
        targetGoal: _targetGoal,
        notes: _notesController.text.trim(),
      );
      await provider.addContent(newItem);
    } else {
      final updated = widget.item!.copyWith(
        title: _titleController.text.trim(),
        platform: _selectedPlatform,
        format: _selectedFormat,
        status: _selectedStatus,
        scheduledDate: _scheduledDate,
        caption: _captionController.text.trim(),
        hashtags: _hashtagsController.text.trim(),
        targetGoal: _targetGoal,
        notes: _notesController.text.trim(),
      );
      await provider.updateContent(updated);
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
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
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
                    color: isDark
                        ? AppColors.darkSurfaceVariant
                        : AppColors.lightBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.item == null ? 'إضافة محتوى للجدول' : 'تعديل بيانات المحتوى',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Title
              CustomTextField(
                label: 'عنوان المنشور / فكرة المحتوى',
                hint: 'مثال: 5 أسرار لزيادة تفاعل ستوريهات إنستجرام',
                controller: _titleController,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'برجاء كتابة عنوان المنشور' : null,
              ),
              const SizedBox(height: 14),

              // Platform Selector
              const Text('المنصة المستهدفة', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    MarketingPlatform.instagram,
                    MarketingPlatform.tiktok,
                    MarketingPlatform.facebook,
                    MarketingPlatform.linkedin,
                    MarketingPlatform.youtube,
                    MarketingPlatform.twitter,
                  ].map((plat) {
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

              // Format Selector
              const Text('صيغة المحتوى (Format)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ContentFormat.values.map((fmt) {
                    final isSelected = _selectedFormat == fmt;
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: ChoiceChip(
                        label: Text(fmt.name.toUpperCase()),
                        selected: isSelected,
                        onSelected: (val) {
                          if (val) setState(() => _selectedFormat = fmt);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 14),

              // Scheduled Date Picker Box
              const Text('تاريخ ووقت النشر', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              InkWell(
                onTap: _pickDateTime,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Text(
                        '${DateFormatter.formatShort(_scheduledDate)} - ${DateFormatter.formatTime(_scheduledDate)}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      const Text('تغيير 📅', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Status Dropdown
              const Text('مرحلة الإنتاج / الحالة', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<ContentStatus>(
                    value: _selectedStatus,
                    isExpanded: true,
                    items: ContentStatus.values.map((st) {
                      return DropdownMenuItem<ContentStatus>(
                        value: st,
                        child: Text(st.name.toUpperCase(), style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedStatus = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Caption with Copywriting Templates Helper
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('نص المنشور / السكريبت (Caption)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                    label: const Text('قوالب الكوبي رايتينج 💡', style: TextStyle(fontSize: 12)),
                    onPressed: () {
                      HapticHelper.light();
                      CopywritingTemplateSheet.show(
                        context,
                        onSelectTemplate: (templateText) {
                          setState(() {
                            if (_captionController.text.isEmpty) {
                              _captionController.text = templateText;
                            } else {
                              _captionController.text = '${_captionController.text}\n\n$templateText';
                            }
                          });
                        },
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 6),
              CustomTextField(
                label: '',
                hint: 'اكتب نص الإعلان، الهوك، السكريبت، أو العرض هنا...',
                controller: _captionController,
                maxLines: 4,
              ),
              const SizedBox(height: 14),

              // Hashtags
              CustomTextField(
                label: 'الهاشتاجات (Hashtags)',
                hint: '#تسويق #مبيعات #ريلز #كونتنتاوي',
                controller: _hashtagsController,
              ),
              const SizedBox(height: 24),

              // Submit Button
              GradientButton(
                text: widget.item == null ? 'إضافة إلى الجدول' : 'حفظ التعديلات',
                icon: Icons.save_rounded,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
