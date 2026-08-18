import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/app_state_provider.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/haptic_helper.dart';
import '../../core/utils/marketing_math.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/gradient_button.dart';

class MarketingToolsScreen extends StatefulWidget {
  const MarketingToolsScreen({super.key});

  @override
  State<MarketingToolsScreen> createState() => _MarketingToolsScreenState();
}

class _MarketingToolsScreenState extends State<MarketingToolsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // --- Calculator Controllers ---
  // ROAS & ROI
  final _roasSpendController = TextEditingController(text: '3000');
  final _roasRevenueController = TextEditingController(text: '9500');
  final _roasCogsController = TextEditingController(text: '2000');

  // CAC & LTV
  final _cacSpendController = TextEditingController(text: '5000');
  final _cacCustomersController = TextEditingController(text: '50');
  final _ltvAovController = TextEditingController(text: '400');
  final _ltvFreqController = TextEditingController(text: '3');
  final _ltvLifeController = TextEditingController(text: '2');

  // Break-even
  final _marginController = TextEditingController(text: '40');

  // Engagement Rate
  final _engLikesController = TextEditingController(text: '450');
  final _engCommentsController = TextEditingController(text: '65');
  final _engSharesController = TextEditingController(text: '80');
  final _engSavesController = TextEditingController(text: '120');
  final _engReachController = TextEditingController(text: '15000');

  // UTM Builder
  final _utmUrlController = TextEditingController(text: 'https://myshop.com');
  final _utmSourceController = TextEditingController(text: 'facebook');
  final _utmMediumController = TextEditingController(text: 'cpc');
  final _utmCampaignController = TextEditingController(text: 'summer_sale_2026');
  final _utmContentController = TextEditingController(text: 'video_hook_1');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _roasSpendController.dispose();
    _roasRevenueController.dispose();
    _roasCogsController.dispose();
    _cacSpendController.dispose();
    _cacCustomersController.dispose();
    _ltvAovController.dispose();
    _ltvFreqController.dispose();
    _ltvLifeController.dispose();
    _marginController.dispose();
    _engLikesController.dispose();
    _engCommentsController.dispose();
    _engSharesController.dispose();
    _engSavesController.dispose();
    _engReachController.dispose();
    _utmUrlController.dispose();
    _utmSourceController.dispose();
    _utmMediumController.dispose();
    _utmCampaignController.dispose();
    _utmContentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('أدوات وحاسبات التسويق', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          tabs: const [
            Tab(text: 'الحاسبات الذكية', icon: Icon(Icons.calculate_rounded, size: 20)),
            Tab(text: 'روابط UTM', icon: Icon(Icons.link_rounded, size: 20)),
            Tab(text: 'بنك الهوكس', icon: Icon(Icons.auto_awesome_rounded, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCalculatorsTab(),
          _buildUtmBuilderTab(),
          _buildHooksBankTab(),
        ],
      ),
    );
  }

  // 1. CALCULATORS TAB
  Widget _buildCalculatorsTab() {
    final provider = context.watch<AppStateProvider>();
    final currency = provider.profile.currency;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculations
    final roasSpend = double.tryParse(_roasSpendController.text) ?? 0.0;
    final roasRev = double.tryParse(_roasRevenueController.text) ?? 0.0;
    final roasCogs = double.tryParse(_roasCogsController.text) ?? 0.0;
    final calculatedRoas = MarketingMath.calculateROAS(roasRev, roasSpend);
    final calculatedNetProfit = MarketingMath.calculateNetProfit(revenue: roasRev, adSpend: roasSpend, cogs: roasCogs);
    final calculatedRoi = MarketingMath.calculateROI(revenue: roasRev, adSpend: roasSpend, cogs: roasCogs);

    // CAC & LTV
    final cacSpend = double.tryParse(_cacSpendController.text) ?? 0.0;
    final cacCust = int.tryParse(_cacCustomersController.text) ?? 0;
    final calculatedCac = MarketingMath.calculateCAC(cacSpend, cacCust);

    final ltvAov = double.tryParse(_ltvAovController.text) ?? 0.0;
    final ltvFreq = double.tryParse(_ltvFreqController.text) ?? 0.0;
    final ltvLife = double.tryParse(_ltvLifeController.text) ?? 0.0;
    final calculatedLtv = MarketingMath.calculateLTV(avgOrderValue: ltvAov, purchaseFrequencyPerYear: ltvFreq, lifespanYears: ltvLife);
    final ltvCacRatio = calculatedCac > 0 ? (calculatedLtv / calculatedCac) : 0.0;

    // Break-even
    final margin = double.tryParse(_marginController.text) ?? 0.0;
    final breakEvenRoas = MarketingMath.calculateBreakEvenROAS(margin);

    // Engagement
    final engLikes = int.tryParse(_engLikesController.text) ?? 0;
    final engComments = int.tryParse(_engCommentsController.text) ?? 0;
    final engShares = int.tryParse(_engSharesController.text) ?? 0;
    final engSaves = int.tryParse(_engSavesController.text) ?? 0;
    final engReach = int.tryParse(_engReachController.text) ?? 0;
    final calculatedEngRate = MarketingMath.calculateEngagementRate(
      likes: engLikes,
      comments: engComments,
      shares: engShares,
      saves: engSaves,
      reachOrFollowers: engReach,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. ROAS & ROI Calculator Card
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.trending_up_rounded, color: AppColors.primary, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'حاسبة الـ ROAS وصافي الأرباح (ROI)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'الإنفاق الإعلاني',
                        hint: '3000',
                        controller: _roasSpendController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomTextField(
                        label: 'إجمالي المبيعات',
                        hint: '9500',
                        controller: _roasRevenueController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomTextField(
                        label: 'تكلفة البضاعة (COGS)',
                        hint: '2000',
                        controller: _roasCogsController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(isDark ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildCalcResult('ROAS', '${calculatedRoas.toStringAsFixed(2)}x',
                          calculatedRoas >= 2.0 ? AppColors.accentGrowth : AppColors.accentWarning),
                      Container(width: 1, height: 28, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      _buildCalcResult('صافي الربح', CurrencyFormatter.format(calculatedNetProfit, currency: currency),
                          calculatedNetProfit >= 0 ? AppColors.accentGrowth : AppColors.accentError),
                      Container(width: 1, height: 28, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      _buildCalcResult('عائد الاستثمار ROI', '${calculatedRoi.toStringAsFixed(1)}%',
                          calculatedRoi >= 0 ? AppColors.accentGrowth : AppColors.accentError),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. CAC & LTV Calculator Card
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.people_alt_rounded, color: AppColors.secondary, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'حاسبة تكلفة العميل (CAC) والقيمة الدائمة (LTV)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'ميزانية التسويق',
                        hint: '5000',
                        controller: _cacSpendController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomTextField(
                        label: 'العملاء الجدد',
                        hint: '50',
                        controller: _cacCustomersController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomTextField(
                        label: 'متوسط الأوردر AOV',
                        hint: '400',
                        controller: _ltvAovController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(isDark ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildCalcResult('تكلفة العميل CAC', CurrencyFormatter.format(calculatedCac, currency: currency), AppColors.secondary),
                      Container(width: 1, height: 28, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      _buildCalcResult('قيمة العميل LTV', CurrencyFormatter.format(calculatedLtv, currency: currency), AppColors.accentGrowth),
                      Container(width: 1, height: 28, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      _buildCalcResult('نسبة LTV : CAC', '${ltvCacRatio.toStringAsFixed(1)}:1',
                          ltvCacRatio >= 3.0 ? AppColors.accentGrowth : AppColors.accentWarning),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. Break-Even ROAS & Engagement Rate Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('نقطة التعادل (Break-Even)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 10),
                      CustomTextField(
                        label: 'هامش الربح (%)',
                        hint: '40',
                        controller: _marginController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.accentGrowth.withOpacity(isDark ? 0.15 : 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            const Text('أقل ROAS لعدم الخسارة', style: TextStyle(fontSize: 11, color: AppColors.lightTextMuted)),
                            const SizedBox(height: 2),
                            Text('${breakEvenRoas.toStringAsFixed(2)}x', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.accentGrowth)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('معدل التفاعل (%)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 10),
                      CustomTextField(
                        label: 'الوصول / المتابعين',
                        hint: '15000',
                        controller: _engReachController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(isDark ? 0.15 : 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            const Text('نسبة التفاعل', style: TextStyle(fontSize: 11, color: AppColors.lightTextMuted)),
                            const SizedBox(height: 2),
                            Text('${calculatedEngRate.toStringAsFixed(2)}%', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCalcResult(String title, String value, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 11, color: AppColors.lightTextMuted)),
        const SizedBox(height: 3),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  // 2. UTM BUILDER TAB
  Widget _buildUtmBuilderTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final utmUrl = MarketingMath.buildUTMUrl(
      baseUrl: _utmUrlController.text,
      source: _utmSourceController.text,
      medium: _utmMediumController.text,
      campaign: _utmCampaignController.text,
      content: _utmContentController.text,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.link_rounded, color: AppColors.primary, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'منشئ روابط التتبع (Campaign UTM Builder)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'أنشئ روابط تتبع دقيقة لتتبع مبيعاتك ونقراتك داخل Google Analytics وMeta Ads.',
                  style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'رابط الموقع أو صفحة الهبوط (Website URL)',
                  hint: 'https://myshop.com/product-1',
                  controller: _utmUrlController,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'المصدر (utm_source)',
                        hint: 'facebook / tiktok',
                        controller: _utmSourceController,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomTextField(
                        label: 'الوسيط (utm_medium)',
                        hint: 'cpc / story / bio',
                        controller: _utmMediumController,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'اسم الحملة (utm_campaign)',
                        hint: 'summer_offers',
                        controller: _utmCampaignController,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomTextField(
                        label: 'المحتوى (utm_content)',
                        hint: 'video_angle_1',
                        controller: _utmContentController,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Generated Output Link Box
                const Text('الرابط الجاهز للتتبع:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  child: SelectableText(
                    utmUrl.isEmpty ? 'اكتب رابط الموقع أولاً...' : utmUrl,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Copy Button
                GradientButton(
                  text: 'نسخ الرابط بالكامل 📋',
                  onPressed: utmUrl.isEmpty
                      ? null
                      : () {
                          HapticHelper.light();
                          Clipboard.setData(ClipboardData(text: utmUrl));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تم نسخ رابط التتبع (UTM) بنجاح! 🚀')),
                          );
                        },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3. HOOKS BANK TAB
  Widget _buildHooksBankTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: MarketingMath.hookTemplates.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = MarketingMath.hookTemplates[index];
        return CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item['category']!,
                      style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceVariant.withOpacity(0.5) : AppColors.lightSurfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  item['hook']!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.primaryDark,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item['description']!,
                style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: const Text('نسخ الصيغة'),
                  onPressed: () {
                    HapticHelper.light();
                    Clipboard.setData(ClipboardData(text: item['hook']!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم نسخ الصيغة التسويقية! 📋')),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
