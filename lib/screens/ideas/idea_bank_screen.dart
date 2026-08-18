import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/campaign.dart';
import '../../core/models/marketing_idea.dart';
import '../../core/providers/app_state_provider.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/haptic_helper.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/empty_state_view.dart';
import '../calendar/widgets/add_edit_content_sheet.dart';
import '../campaigns/widgets/add_edit_campaign_sheet.dart';
import 'widgets/add_edit_idea_sheet.dart';

class IdeaBankScreen extends StatefulWidget {
  const IdeaBankScreen({super.key});

  @override
  State<IdeaBankScreen> createState() => _IdeaBankScreenState();
}

class _IdeaBankScreenState extends State<IdeaBankScreen> {
  final TextEditingController _searchController = TextEditingController();
  IdeaPriority? _priorityFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppStateProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final query = _searchController.text.trim().toLowerCase();

    final filteredIdeas = provider.ideas.where((idea) {
      if (_priorityFilter != null && idea.priority != _priorityFilter) {
        return false;
      }
      if (query.isNotEmpty) {
        final matchesTitle = idea.title.toLowerCase().contains(query);
        final matchesDesc = idea.description.toLowerCase().contains(query);
        final matchesTags = idea.tags.toLowerCase().contains(query);
        if (!matchesTitle && !matchesDesc && !matchesTags) return false;
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('بنك الأفكار والإلهام', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'تسجيل فكرة جديدة',
            onPressed: () => AddEditIdeaSheet.show(context),
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
                  hintText: 'ابحث في بنك الأفكار والزوايا الإعلانية...',
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

            // Priority Filter Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  ChoiceChip(
                    label: Text('الكل (${provider.ideas.length})'),
                    selected: _priorityFilter == null,
                    onSelected: (val) {
                      if (val) setState(() => _priorityFilter = null);
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('عالية الأهمية 🔥'),
                    selected: _priorityFilter == IdeaPriority.high,
                    onSelected: (val) {
                      setState(() => _priorityFilter = val ? IdeaPriority.high : null);
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('متوسطة ⚡'),
                    selected: _priorityFilter == IdeaPriority.medium,
                    onSelected: (val) {
                      setState(() => _priorityFilter = val ? IdeaPriority.medium : null);
                    },
                  ),
                ],
              ),
            ),

            // Ideas List
            Expanded(
              child: filteredIdeas.isEmpty
                  ? EmptyStateView(
                      icon: Icons.lightbulb_outline_rounded,
                      title: 'بنك الأفكار فارغ حالياً',
                      description: 'سجل أي فكرة محتوى أو زاوية تسويقية تخطر على بالك فوراً عشان متنساهاش.',
                      actionText: 'تسجيل فكرة جديدة',
                      onAction: () => AddEditIdeaSheet.show(context),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredIdeas.length,
                      itemBuilder: (context, index) {
                        final idea = filteredIdeas[index];
                        return _buildIdeaCard(context, idea, provider, isDark);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AddEditIdeaSheet.show(context),
        backgroundColor: AppColors.accentGrowth,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('فكرة جديدة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildIdeaCard(
    BuildContext context,
    MarketingIdea idea,
    AppStateProvider provider,
    bool isDark,
  ) {
    Color prioColor;
    String prioLabel;
    switch (idea.priority) {
      case IdeaPriority.high:
        prioColor = AppColors.accentError;
        prioLabel = 'عالية 🔥';
        break;
      case IdeaPriority.medium:
        prioColor = AppColors.accentWarning;
        prioLabel = 'متوسطة ⚡';
        break;
      case IdeaPriority.low:
        prioColor = AppColors.primary;
        prioLabel = 'عادية 💡';
        break;
    }

    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      onTap: () => AddEditIdeaSheet.show(context, idea: idea),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  idea.platform.name.toUpperCase(),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: prioColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  prioLabel,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: prioColor),
                ),
              ),
              const Spacer(),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, size: 18),
                onSelected: (val) async {
                  HapticHelper.light();
                  if (val == 'edit') {
                    AddEditIdeaSheet.show(context, idea: idea);
                  } else if (val == 'delete') {
                    final confirmed = await ConfirmDialog.show(
                      context,
                      title: 'حذف الفكرة',
                      content: 'هل أنت متأكد من حذف فكرة "${idea.title}"؟',
                      confirmText: 'حذف',
                      isDestructive: true,
                    );
                    if (confirmed == true) {
                      await provider.deleteIdea(idea.id);
                    }
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(value: 'edit', child: Text('تعديل')),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('حذف', style: TextStyle(color: AppColors.accentError)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            idea.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          if (idea.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              idea.description,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                height: 1.4,
              ),
            ),
          ],
          if (idea.tags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              children: idea.tags.split(',').map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('#${tag.trim()}', style: const TextStyle(fontSize: 11, color: AppColors.lightTextMuted)),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 14),

          // Convert to Content or Campaign Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.post_add_rounded, size: 16),
                label: const Text('تحويل لمحتوى ➔', style: TextStyle(fontSize: 12)),
                onPressed: () {
                  HapticHelper.medium();
                  AddEditContentSheet.show(
                    context,
                    initialTitle: idea.title,
                    initialCaption: idea.description,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
