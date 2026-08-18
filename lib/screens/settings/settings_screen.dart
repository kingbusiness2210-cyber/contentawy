import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/providers/app_state_provider.dart';
import '../../core/utils/haptic_helper.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/gradient_button.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  final List<Map<String, String>> _currencies = const [
    {'code': 'EGP', 'name': 'ج.م (الجنيه المصري)'},
    {'code': 'USD', 'name': '\$ (الدولار الأمريكي)'},
    {'code': 'SAR', 'name': 'ر.س (الريال السعودي)'},
    {'code': 'AED', 'name': 'د.إ (الدرهم الإماراتي)'},
    {'code': 'EUR', 'name': '€ (اليورو)'},
  ];

  final List<String> _roles = const [
    'صناعة المحتوى (Content Creation)',
    'إدارة الإعلانات (Media Buying)',
    'سوشيال ميديا (Social Media Management)',
    'تسويق الأداء (Performance Marketing)',
    'فريلانسر شامل (Freelancing)',
    'كل ما يخص الماركتينج (Everything)',
  ];

  void _exportBackup(BuildContext context) {
    HapticHelper.light();
    final provider = context.read<AppStateProvider>();
    final json = provider.exportBackupJson();

    Clipboard.setData(ClipboardData(text: json));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ بيانات النسخ الاحتياطي (JSON) إلى الحافظة! 📦'),
        duration: Duration(seconds: 3),
      ),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تم تجهيز النسخة الاحتياطية 💾'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'تم نسخ كامل بيانات التطبيق بصيغة JSON. يمكنك حفظ هذا النص في الملاحظات أو إرساله لنفسك عبر الواتساب أو درايف لاستعادته في أي وقت.',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 12),
            Container(
              height: 100,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  json,
                  style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
                ),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('تمام'),
          ),
        ],
      ),
    );
  }

  void _importBackup(BuildContext context) {
    HapticHelper.light();
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('استرجاع نسخة احتياطية 📥'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'الصق كود الـ JSON الخاص بالنسخة الاحتياطية هنا لاستعادة كافة حملاتك وجدول محتواك وأفكارك:',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: '{\n  "app": "Contentawy",\n  ...\n}',
                contentPadding: EdgeInsets.all(10),
              ),
              style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isEmpty) return;

              Navigator.of(ctx).pop();
              final provider = context.read<AppStateProvider>();
              final result = await provider.restoreFromBackupJson(text);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result.message),
                    backgroundColor: result.success ? AppColors.accentGrowth : AppColors.accentError,
                  ),
                );
              }
            },
            child: const Text('استرجاع البيانات'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppStateProvider>();
    final profile = provider.profile;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات والنسخ الاحتياطي', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Profile Card
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person_rounded, color: Colors.white, size: 26),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.name,
                                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                profile.role,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),

                    // Role Picker Dropdown
                    const Text('تغيير التخصص الأساسي', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: profile.role,
                          isExpanded: true,
                          items: _roles.map((r) {
                            return DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 13)));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              HapticHelper.selection();
                              provider.updateProfile(role: val);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Currency Picker Dropdown
                    const Text('عملة الحسابات الإعلانية', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: profile.currency,
                          isExpanded: true,
                          items: _currencies.map((c) {
                            return DropdownMenuItem(value: c['code'], child: Text(c['name']!, style: const TextStyle(fontSize: 13)));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              HapticHelper.selection();
                              provider.setCurrency(val);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Appearance (Dark Mode)
              CustomCard(
                child: SwitchListTile(
                  title: const Text('الوضع المظلم (Dark Mode)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  subtitle: Text(
                    isDark ? 'الوضع المظلم مفعّل' : 'الوضع الفاتح مفعّل',
                    style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                  ),
                  value: profile.isDarkMode,
                  activeColor: AppColors.primary,
                  onChanged: (_) {
                    HapticHelper.selection();
                    provider.toggleDarkMode();
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Backup & Restore Section
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.backup_rounded, color: AppColors.primary, size: 20),
                        SizedBox(width: 8),
                        Text('النسخ الاحتياطي ونقل البيانات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'بياناتك محفوظة على جهازك محلياً 100% (Offline First). يمكنك نسخ البيانات ونقلها لأي هاتف آخر بسهولة.',
                      style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.download_rounded, size: 18),
                            label: const Text('تصدير نسخة 💾'),
                            onPressed: () => _exportBackup(context),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.upload_rounded, size: 18),
                            label: const Text('استرجاع نسخة 📥'),
                            onPressed: () => _importBackup(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Privacy & Data Security Notice
              CustomCard(
                backgroundColor: AppColors.accentGrowth.withOpacity(isDark ? 0.12 : 0.06),
                borderSide: BorderSide(color: AppColors.accentGrowth.withOpacity(0.3)),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.security_rounded, color: AppColors.accentGrowth, size: 22),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'خصوصية بياناتك مضمونة 100% 🔒',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.accentGrowth),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'جميع حملاتك وأرقامك ومحتواك مخزنة فقط على هذا الجهاز دون أي خوادم أو تتبع خارجي.',
                            style: TextStyle(fontSize: 12, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Reset Data Button
              CustomCard(
                child: ListTile(
                  leading: const Icon(Icons.delete_forever_rounded, color: AppColors.accentError),
                  title: const Text('إعادة تعيين البيانات (Reset)', style: TextStyle(color: AppColors.accentError, fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('حذف جميع البيانات والبدء من جديد', style: TextStyle(fontSize: 12)),
                  onTap: () async {
                    final confirmed = await ConfirmDialog.show(
                      context,
                      title: 'إعادة ضبط التطبيق',
                      content: 'هل أنت متأكد من مسح جميع البيانات؟ لن تتمكن من التراجع إلا إذا كنت تملك نسخة احتياطية.',
                      confirmText: 'مسح الكل',
                      isDestructive: true,
                    );
                    if (confirmed == true) {
                      HapticHelper.heavy();
                      await provider.resetAllData();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تمت إعادة ضبط البيانات بنجاح.')),
                        );
                      }
                    }
                  },
                ),
              ),
              const SizedBox(height: 24),

              // App Version & Brand Footer
              Center(
                child: Column(
                  children: [
                    Text(
                      '${AppStrings.appNameAr} v1.0.0',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.lightTextMuted),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'صُمم بأعلى معايير الإنتاجية للمسوقين وصناع المحتوى',
                      style: TextStyle(fontSize: 11, color: AppColors.lightTextMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
