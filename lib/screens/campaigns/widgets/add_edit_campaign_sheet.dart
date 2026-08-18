import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/campaign.dart';
import '../../../core/providers/app_state_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/haptic_helper.dart';
import '../../../core/utils/marketing_math.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/gradient_button.dart';

class AddEditCampaignSheet extends StatefulWidget {
  final Campaign? campaign;

  const AddEditCampaignSheet({super.key, this.campaign});

  static Future<void> show(BuildContext context, {Campaign? campaign}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddEditCampaignSheet(campaign: campaign),
    );
  }

  @override
  State<AddEditCampaignSheet> createState() => _AddEditCampaignSheetState();
}

class _AddEditCampaignSheetState extends State<AddEditCampaignSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _budgetController;
  late TextEditingController _spentController;
  late TextEditingController _revenueController;
  late TextEditingController _audienceController;
  late TextEditingController _notesController;

  late MarketingPlatform _selectedPlatform;
  late CampaignStatus _selectedStatus;
  late String _selectedObjective;

  final List<String> _objectives = [
    'مبيعات وتحويلات (Sales / Purchases)',
    'ليدز واستمارات (Lead Generation)',
    'رسائل واتساب وماسنجر (Messages)',
    'تفاعل ومشاهدات فيديو (Engagement)',
    'زيارات لموقع الويب (Traffic)',
    'وعي بالبراند والانتشار (Brand Awareness)',
  ];

  @override
  void initState() {
    super.initState();
    final c = widget.campaign;

    _nameController = TextEditingController(text: c?.name ?? '');
    _budgetController = TextEditingController(
        text: c != null && c.budget > 0 ? c.budget.toStringAsFixed(0) : '');
    _spentController = TextEditingController(
        text: c != null && c.spent > 0 ? c.spent.toStringAsFixed(0) : '');
    _revenueController = TextEditingController(
        text: c != null && c.revenue > 0 ? c.revenue.toStringAsFixed(0) : '');
    _audienceController =
        TextEditingController(text: c?.targetAudience ?? '');
    _notesController = TextEditingController(text: c?.notes ?? '');

    _selectedPlatform = c?.platform ?? MarketingPlatform.facebook;
    _selectedStatus = c?.status ?? CampaignStatus.active;
    _selectedObjective = c?.objective ?? _objectives.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _budgetController.dispose();
    _spentController.dispose();
    _revenueController.dispose();
    _audienceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final budget = double.tryParse(_budgetController.text.trim()) ?? 0.0;
    final spent = double.tryParse(_spentController.text.trim()) ?? 0.0;
    final revenue = double.tryParse(_revenueController.text.trim()) ?? 0.0;

    final provider = context.read<AppStateProvider>();
    HapticHelper.success();

    if (widget.campaign == null) {
      final newCampaign = Campaign(
        name: _nameController.text.trim(),
        platform: _selectedPlatform,
        budget: budget,
        spent: spent,
        revenue: revenue,
        objective: _selectedObjective,
        status: _selectedStatus,
        targetAudience: _audienceController.text.trim(),
        notes: _notesController.text.trim(),
      );
      await provider.addCampaign(newCampaign);
    } else {
      final updated = widget.campaign!.copyWith(
        name: _nameController.text.trim(),
        platform: _selectedPlatform,
        budget: budget,
        spent: spent,
        revenue: revenue,
        objective: _selectedObjective,
        status: _selectedStatus,
        targetAudience: _audienceController.text.trim(),
        notes: _notesController.text.trim(),
      );
      await provider.updateCampaign(updated);
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AppStateProvider>();
    final currency = provider.profile.currency;

    final spentVal = double.tryParse(_spentController.text) ?? 0.0;
    final revVal = double.tryParse(_revenueController.text) ?? 0.0;
    final liveRoas = MarketingMath.calculateROAS(revVal, spentVal);
    final liveProfit = revVal - spentVal;

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
              // Handle bar
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

              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.campaign == null
                        ? 'إضافة حملة إعلانية جديدة'
                        : 'تعديل بيانات الحملة',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Platform Selector
              const Text(
                'المنصة الإعلانية',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
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
              const SizedBox(height: 16),

              // Campaign Name
              CustomTextField(
                label: 'اسم الحملة الإعلانية',
                hint: 'مثال: عروض الصيف - كورس الماركتينج',
                controller: _nameController,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'برجاء كتابة اسم الحملة' : null,
              ),
              const SizedBox(height: 14),

              // Budget, Spent, Revenue Row
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'الميزانية ($currency)',
                      hint: '5000',
                      controller: _budgetController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      label: 'المنصرف ($currency)',
                      hint: '3200',
                      controller: _spentController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      label: 'العائد/المبيعات',
                      hint: '12000',
                      controller: _revenueController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Live ROAS & Profit Preview Box
              if (spentVal > 0 || revVal > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(isDark ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        'ROAS المتوقع: ${liveRoas.toStringAsFixed(2)}x',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: liveRoas >= 2.0
                              ? AppColors.accentGrowth
                              : AppColors.accentWarning,
                        ),
                      ),
                      Text(
                        'صافي الأرباح: ${CurrencyFormatter.format(liveProfit, currency: currency)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: liveProfit >= 0
                              ? AppColors.accentGrowth
                              : AppColors.accentError,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 14),

              // Objective Dropdown
              const Text(
                'الهدف التسويقي (Objective)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceVariant
                      : AppColors.lightSurfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedObjective,
                    isExpanded: true,
                    items: _objectives.map((obj) {
                      return DropdownMenuItem<String>(
                        value: obj,
                        child: Text(obj, style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedObjective = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Status Dropdown
              const Text(
                'حالة الحملة',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceVariant
                      : AppColors.lightSurfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<CampaignStatus>(
                    value: _selectedStatus,
                    isExpanded: true,
                    items: CampaignStatus.values.map((st) {
                      return DropdownMenuItem<CampaignStatus>(
                        value: st,
                        child: Text(st.name.toUpperCase(),
                            style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedStatus = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Target Audience
              CustomTextField(
                label: 'الجمهور المستهدف (Target Audience)',
                hint: 'مثال: المسوقين وأصحاب المتاجر الإلكترونية في مصر',
                controller: _audienceController,
              ),
              const SizedBox(height: 14),

              // Notes
              CustomTextField(
                label: 'ملاحظات وتجارب الكرييتف',
                hint: 'سجل الزوايا الإعلانية الناجحة أو نتائج A/B Testing',
                controller: _notesController,
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              // Submit Button
              GradientButton(
                text: widget.campaign == null ? 'حفظ الحملة' : 'تحديث البيانات',
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
