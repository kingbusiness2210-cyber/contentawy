import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/campaign.dart';
import '../../core/providers/app_state_provider.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/haptic_helper.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/stat_badge.dart';
import 'widgets/add_edit_campaign_sheet.dart';
import 'widgets/campaign_card.dart';

class CampaignsScreen extends StatefulWidget {
  const CampaignsScreen({super.key});

  @override
  State<CampaignsScreen> createState() => _CampaignsScreenState();
}

class _CampaignsScreenState extends State<CampaignsScreen> {
  String _statusFilter = 'all';
  MarketingPlatform? _platformFilter;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppStateProvider>();
    final currency = provider.profile.currency;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final query = _searchController.text.trim().toLowerCase();

    final filteredCampaigns = provider.campaigns.where((c) {
      if (_statusFilter != 'all' && c.status.name != _statusFilter) {
        return false;
      }
      if (_platformFilter != null && c.platform != _platformFilter) {
        return false;
      }
      if (query.isNotEmpty) {
        final matchesName = c.name.toLowerCase().contains(query);
        final matchesAudience = c.targetAudience.toLowerCase().contains(query);
        final matchesNotes = c.notes.toLowerCase().contains(query);
        if (!matchesName && !matchesAudience && !matchesNotes) return false;
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('الحملات والإعلانات', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'إضافة حملة جديدة',
            onPressed: () => AddEditCampaignSheet.show(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Summary Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: StatBadge(
                      title: 'المنصرف',
                      value: CurrencyFormatter.format(provider.totalSpent, currency: currency, compact: true),
                      icon: Icons.money_off_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatBadge(
                      title: 'العائد',
                      value: CurrencyFormatter.format(provider.totalRevenue, currency: currency, compact: true),
                      icon: Icons.attach_money_rounded,
                      color: AppColors.accentGrowth,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatBadge(
                      title: 'متوسط ROAS',
                      value: '${provider.overallROAS.toStringAsFixed(2)}x',
                      icon: Icons.speed_rounded,
                      color: provider.overallROAS >= 2.0 ? AppColors.accentGrowth : AppColors.accentWarning,
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar & Filter Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'ابحث باسم الحملة أو الجمهور المستهدف...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
            ),

            // Status Filter Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  _buildFilterChip('all', 'الكل (${provider.campaigns.length})'),
                  const SizedBox(width: 8),
                  _buildFilterChip('active', 'النشطة (${provider.campaigns.where((c) => c.status == CampaignStatus.active).length})'),
                  const SizedBox(width: 8),
                  _buildFilterChip('paused', 'المتوقفة'),
                  const SizedBox(width: 8),
                  _buildFilterChip('completed', 'المكتملة'),
                  const SizedBox(width: 8),
                  _buildFilterChip('draft', 'المسودات'),
                ],
              ),
            ),

            // Campaign List View
            Expanded(
              child: filteredCampaigns.isEmpty
                  ? EmptyStateView(
                      icon: Icons.campaign_outlined,
                      title: 'لا توجد حملات إعلانية مطابقة',
                      description: 'اضغط على زر الإضافة لتسجيل أول حملة ومتابعة أرقام الـ ROAS والإنفاق.',
                      actionText: 'إضافة حملة جديدة',
                      onAction: () => AddEditCampaignSheet.show(context),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredCampaigns.length,
                      itemBuilder: (context, index) {
                        final campaign = filteredCampaigns[index];
                        return CampaignCard(
                          campaign: campaign,
                          currency: currency,
                          onEdit: () => AddEditCampaignSheet.show(context, campaign: campaign),
                          onToggleStatus: () => provider.toggleCampaignStatus(campaign.id),
                          onDelete: () async {
                            final confirmed = await ConfirmDialog.show(
                              context,
                              title: 'حذف الحملة',
                              content: 'هل أنت متأكد من حذف حملة "${campaign.name}" نهائياً؟',
                              confirmText: 'حذف',
                              isDestructive: true,
                            );
                            if (confirmed == true) {
                              HapticHelper.medium();
                              await provider.deleteCampaign(campaign.id);
                            }
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AddEditCampaignSheet.show(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('حملة جديدة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _statusFilter == key;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) {
          HapticHelper.selection();
          setState(() => _statusFilter = key);
        }
      },
    );
  }
}
