import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/app_state_provider.dart';
import '../../core/utils/haptic_helper.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/custom_text_field.dart';
import '../main_navigation_screen.dart';

class RoleSetupScreen extends StatefulWidget {
  const RoleSetupScreen({super.key});

  @override
  State<RoleSetupScreen> createState() => _RoleSetupScreenState();
}

class _RoleSetupScreenState extends State<RoleSetupScreen> {
  final TextEditingController _nameController =
      TextEditingController(text: 'مسوق شاطر');
  String _selectedRole = 'صناعة المحتوى (Content Creation)';
  String _selectedCurrency = 'EGP';

  final List<Map<String, dynamic>> _roles = [
    {
      'title': 'صناعة المحتوى (Content Creation)',
      'desc': 'كتابة سكريبتات، ريلز، كاروسيل، وإدارة خطة النشر اليومية.',
      'icon': Icons.video_camera_front_rounded,
      'color': AppColors.primary,
    },
    {
      'title': 'إدارة الإعلانات (Media Buying)',
      'desc': 'إطلاق حملات فيسبوك، تيك توك، جوجل ومتابعة الـ ROAS والإنفاق.',
      'icon': Icons.ads_click_rounded,
      'color': AppColors.secondary,
    },
    {
      'title': 'سوشيال ميديا (Social Media)',
      'desc': 'إدارة الصفحات، جداول المحتوى، والتفاعل مع المتابعين.',
      'icon': Icons.share_rounded,
      'color': AppColors.accentGrowth,
    },
    {
      'title': 'تسويق الأداء (Performance Marketing)',
      'desc': 'التركيز على التحويلات والمبيعات والـ CAC والـ LTV.',
      'icon': Icons.trending_up_rounded,
      'color': AppColors.accentWarning,
    },
    {
      'title': 'فريلانسر شامل (Freelancing)',
      'desc': 'إدارة مشاريع تسويقية متعددة لعملاء مختلفين في مكان واحد.',
      'icon': Icons.laptop_chromebook_rounded,
      'color': AppColors.accentPurple,
    },
    {
      'title': 'كل ما يخص الماركتينج (Everything)',
      'desc': 'كل الأدوات والحملات والمحتوى والأفكار معاً.',
      'icon': Icons.auto_awesome_rounded,
      'color': AppColors.primaryLight,
    },
  ];

  final List<Map<String, String>> _currencies = [
    {'code': 'EGP', 'name': 'ج.م (الجنيه المصري)'},
    {'code': 'USD', 'name': '\$ (الدولار الأمريكي)'},
    {'code': 'SAR', 'name': 'ر.س (الريال السعودي)'},
    {'code': 'AED', 'name': 'د.إ (الدرهم الإماراتي)'},
    {'code': 'EUR', 'name': '€ (اليورو)'},
  ];

  void _submit() async {
    HapticHelper.success();
    final provider = context.read<AppStateProvider>();
    await provider.completeOnboarding(
      _nameController.text,
      _selectedRole,
      _selectedCurrency,
    );

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تخصيص حسابك'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'أهلاً بيك في كونتنتاوي 👋',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'اختر مجالك الأساسي وعملتك لتخصيص لوحة التحكم والتقارير.',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Name Field
              CustomTextField(
                label: 'اسمك أو اسم البراند / الأكونت',
                hint: 'مثال: أحمد صقر أو Growth Agency',
                controller: _nameController,
                prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
              ),
              const SizedBox(height: 20),

              // Role Picker
              const Text(
                'إيه تخصصك الأساسي؟ (What do you mainly do?)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _roles.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final role = _roles[index];
                  final isSelected = _selectedRole == role['title'];
                  final color = role['color'] as Color;

                  return InkWell(
                    onTap: () {
                      HapticHelper.selection();
                      setState(() => _selectedRole = role['title'] as String);
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withOpacity(isDark ? 0.2 : 0.1)
                            : (isDark
                                ? AppColors.darkSurface
                                : AppColors.lightSurface),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? color
                              : (isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              role['icon'] as IconData,
                              color: color,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  role['title'] as String,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? color
                                        : (isDark
                                            ? AppColors.darkTextPrimary
                                            : AppColors.lightTextPrimary),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  role['desc'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(Icons.check_circle_rounded, color: color),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Currency Picker
              const Text(
                'العملة الأساسية لحسابات الإعلانات والأرباح',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
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
                    value: _selectedCurrency,
                    isExpanded: true,
                    items: _currencies.map((c) {
                      return DropdownMenuItem<String>(
                        value: c['code'],
                        child: Text(
                          c['name']!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedCurrency = val);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Done button
              GradientButton(
                text: 'دخول للتطبيق',
                icon: Icons.check_circle_outline_rounded,
                onPressed: _submit,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
