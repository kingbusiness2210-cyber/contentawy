import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/campaign.dart';
import '../../core/models/content_item.dart';
import '../../core/providers/app_state_provider.dart';
import '../../core/utils/haptic_helper.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state_view.dart';
import 'widgets/add_edit_content_sheet.dart';
import 'widgets/content_card.dart';

class ContentCalendarScreen extends StatefulWidget {
  const ContentCalendarScreen({super.key});

  @override
  State<ContentCalendarScreen> createState() => _ContentCalendarScreenState();
}

class _ContentCalendarScreenState extends State<ContentCalendarScreen> {
  String _filter = 'all';
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
    final query = _searchController.text.trim().toLowerCase();

    final filteredItems = provider.contentItems.where((item) {
      if (_filter == 'today' && !item.isScheduledForToday) return false;
      if (_filter == 'scheduled' && item.status != ContentStatus.scheduled) return false;
      if (_filter == 'published' && item.status != ContentStatus.published) return false;
      if (_filter == 'reel' && item.format != ContentFormat.reel) return false;
      if (_filter == 'carousel' && item.format != ContentFormat.carousel) return false;

      if (_platformFilter != null && item.platform != _platformFilter) {
        return false;
      }

      if (query.isNotEmpty) {
        final matchesTitle = item.title.toLowerCase().contains(query);
        final matchesCaption = item.caption.toLowerCase().contains(query);
        final matchesTags = item.hashtags.toLowerCase().contains(query);
        if (!matchesTitle && !matchesCaption && !matchesTags) return false;
      }

      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('جدول وخطة المحتوى', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'إضافة منشور للجدول',
            onPressed: () => AddEditContentSheet.show(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'ابحث في العناوين، السكريبتات، الهاشتاجات...',
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

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  _buildFilterChip('all', 'الكل (${provider.contentItems.length})'),
                  const SizedBox(width: 8),
                  _buildFilterChip('today', 'اليوم (${provider.todayContent.length})'),
                  const SizedBox(width: 8),
                  _buildFilterChip('scheduled', 'المجدول'),
                  const SizedBox(width: 8),
                  _buildFilterChip('reel', 'ريلز وفيديو'),
                  const SizedBox(width: 8),
                  _buildFilterChip('carousel', 'كاروسيل'),
                  const SizedBox(width: 8),
                  _buildFilterChip('published', 'تم النشر'),
                ],
              ),
            ),

            // Content List View
            Expanded(
              child: filteredItems.isEmpty
                  ? EmptyStateView(
                      icon: Icons.calendar_month_outlined,
                      title: 'لا يوجد محتوى في هذا القسم',
                      description: 'اضغط على زر الإضافة لتسجيل أفكار الريلز والبوستات وتجهيز جدول النشر.',
                      actionText: 'إضافة محتوى جديد',
                      onAction: () => AddEditContentSheet.show(context),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        return ContentCard(
                          item: item,
                          onEdit: () => AddEditContentSheet.show(context, item: item),
                          onStatusChanged: (st) => provider.updateContentStatus(item.id, st),
                          onDelete: () async {
                            final confirmed = await ConfirmDialog.show(
                              context,
                              title: 'حذف المنشور',
                              content: 'هل أنت متأكد من حذف منشور "${item.title}" من الجدول؟',
                              confirmText: 'حذف',
                              isDestructive: true,
                            );
                            if (confirmed == true) {
                              HapticHelper.medium();
                              await provider.deleteContent(item.id);
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
        onPressed: () => AddEditContentSheet.show(context),
        backgroundColor: AppColors.secondary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('محتوى جديد', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
