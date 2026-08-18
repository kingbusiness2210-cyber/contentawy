import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/campaign.dart';
import '../models/content_item.dart';
import '../models/marketing_idea.dart';
import '../models/task_item.dart';
import '../models/backup_payload.dart';
import '../services/storage_service.dart';
import '../services/backup_service.dart';

class AppStateProvider extends ChangeNotifier {
  final StorageService _storage;

  late UserProfile _profile;
  List<Campaign> _campaigns = [];
  List<ContentItem> _contentItems = [];
  List<MarketingIdea> _ideas = [];
  List<TaskItem> _tasks = [];
  bool _isLoading = true;

  AppStateProvider(this._storage) {
    _loadAll();
  }

  bool get isLoading => _isLoading;
  UserProfile get profile => _profile;
  List<Campaign> get campaigns => List.unmodifiable(_campaigns);
  List<ContentItem> get contentItems => List.unmodifiable(_contentItems);
  List<MarketingIdea> get ideas => List.unmodifiable(_ideas);
  List<TaskItem> get tasks => List.unmodifiable(_tasks);

  // Computed properties
  double get totalBudget => _campaigns.fold(0.0, (sum, c) => sum + c.budget);
  double get totalSpent => _campaigns.fold(0.0, (sum, c) => sum + c.spent);
  double get totalRevenue => _campaigns.fold(0.0, (sum, c) => sum + c.revenue);
  double get totalProfit => totalRevenue - totalSpent;
  double get overallROAS => totalSpent > 0 ? (totalRevenue / totalSpent) : 0.0;

  List<Campaign> get activeCampaigns =>
      _campaigns.where((c) => c.status == CampaignStatus.active).toList();

  List<ContentItem> get todayContent =>
      _contentItems.where((c) => c.isScheduledForToday).toList();

  List<TaskItem> get todayTasks =>
      _tasks.where((t) => t.isDueToday).toList();

  List<TaskItem> get urgentPendingTasks =>
      _tasks.where((t) => !t.isDone && t.priority == TaskPriority.high).toList();

  void _loadAll() {
    _profile = _storage.loadProfile();
    _campaigns = _storage.loadCampaigns();
    _contentItems = _storage.loadContent();
    _ideas = _storage.loadIdeas();
    _tasks = _storage.loadTasks();
    _isLoading = false;
    notifyListeners();
  }

  // --- Profile Methods ---
  Future<void> updateProfile({
    String? name,
    String? role,
    String? currency,
    bool? isDarkMode,
    bool? hasCompletedOnboarding,
  }) async {
    _profile = _profile.copyWith(
      name: name,
      role: role,
      currency: currency,
      isDarkMode: isDarkMode,
      hasCompletedOnboarding: hasCompletedOnboarding,
    );
    await _storage.saveProfile(_profile);
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    await updateProfile(isDarkMode: !_profile.isDarkMode);
  }

  Future<void> setCurrency(String newCurrency) async {
    await updateProfile(currency: newCurrency);
  }

  Future<void> completeOnboarding(String name, String role, String currency) async {
    await updateProfile(
      name: name.trim().isEmpty ? 'المسوق الذكي' : name.trim(),
      role: role,
      currency: currency,
      hasCompletedOnboarding: true,
    );
  }

  // --- Campaign Methods ---
  Future<void> addCampaign(Campaign campaign) async {
    _campaigns.insert(0, campaign);
    await _storage.saveCampaigns(_campaigns);
    notifyListeners();
  }

  Future<void> updateCampaign(Campaign updated) async {
    final index = _campaigns.indexWhere((c) => c.id == updated.id);
    if (index != -1) {
      _campaigns[index] = updated;
      await _storage.saveCampaigns(_campaigns);
      notifyListeners();
    }
  }

  Future<void> deleteCampaign(String id) async {
    _campaigns.removeWhere((c) => c.id == id);
    await _storage.saveCampaigns(_campaigns);
    notifyListeners();
  }

  Future<void> toggleCampaignStatus(String id) async {
    final index = _campaigns.indexWhere((c) => c.id == id);
    if (index != -1) {
      final current = _campaigns[index];
      final newStatus = current.status == CampaignStatus.active
          ? CampaignStatus.paused
          : CampaignStatus.active;
      _campaigns[index] = current.copyWith(status: newStatus);
      await _storage.saveCampaigns(_campaigns);
      notifyListeners();
    }
  }

  // --- Content Methods ---
  Future<void> addContent(ContentItem item) async {
    _contentItems.insert(0, item);
    await _storage.saveContent(_contentItems);
    notifyListeners();
  }

  Future<void> updateContent(ContentItem updated) async {
    final index = _contentItems.indexWhere((c) => c.id == updated.id);
    if (index != -1) {
      _contentItems[index] = updated;
      await _storage.saveContent(_contentItems);
      notifyListeners();
    }
  }

  Future<void> deleteContent(String id) async {
    _contentItems.removeWhere((c) => c.id == id);
    await _storage.saveContent(_contentItems);
    notifyListeners();
  }

  Future<void> updateContentStatus(String id, ContentStatus status) async {
    final index = _contentItems.indexWhere((c) => c.id == id);
    if (index != -1) {
      _contentItems[index] = _contentItems[index].copyWith(status: status);
      await _storage.saveContent(_contentItems);
      notifyListeners();
    }
  }

  // --- Ideas Methods ---
  Future<void> addIdea(MarketingIdea idea) async {
    _ideas.insert(0, idea);
    await _storage.saveIdeas(_ideas);
    notifyListeners();
  }

  Future<void> updateIdea(MarketingIdea updated) async {
    final index = _ideas.indexWhere((i) => i.id == updated.id);
    if (index != -1) {
      _ideas[index] = updated;
      await _storage.saveIdeas(_ideas);
      notifyListeners();
    }
  }

  Future<void> deleteIdea(String id) async {
    _ideas.removeWhere((i) => i.id == id);
    await _storage.saveIdeas(_ideas);
    notifyListeners();
  }

  Future<void> markIdeaConverted(String id) async {
    final index = _ideas.indexWhere((i) => i.id == id);
    if (index != -1) {
      _ideas[index] = _ideas[index].copyWith(isConverted: true);
      await _storage.saveIdeas(_ideas);
      notifyListeners();
    }
  }

  // --- Task Methods ---
  Future<void> addTask(TaskItem task) async {
    _tasks.insert(0, task);
    await _storage.saveTasks(_tasks);
    notifyListeners();
  }

  Future<void> updateTask(TaskItem updated) async {
    final index = _tasks.indexWhere((t) => t.id == updated.id);
    if (index != -1) {
      _tasks[index] = updated;
      await _storage.saveTasks(_tasks);
      notifyListeners();
    }
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    await _storage.saveTasks(_tasks);
    notifyListeners();
  }

  Future<void> toggleTaskDone(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final current = _tasks[index];
      _tasks[index] = current.copyWith(isDone: !current.isDone);
      await _storage.saveTasks(_tasks);
      notifyListeners();
    }
  }

  // --- Backup & Restore ---
  String exportBackupJson() {
    return BackupService.createBackupJson(
      profile: _profile,
      campaigns: _campaigns,
      contentItems: _contentItems,
      ideas: _ideas,
      tasks: _tasks,
    );
  }

  Future<BackupResult> restoreFromBackupJson(String jsonString) async {
    final result = BackupService.restoreFromJson(jsonString);
    if (result.success && result.payload != null) {
      final payload = result.payload!;
      _profile = payload.profile;
      _campaigns = payload.campaigns;
      _contentItems = payload.contentItems;
      _ideas = payload.ideas;
      _tasks = payload.tasks;

      await _storage.saveProfile(_profile);
      await _storage.saveCampaigns(_campaigns);
      await _storage.saveContent(_contentItems);
      await _storage.saveIdeas(_ideas);
      await _storage.saveTasks(_tasks);

      notifyListeners();
    }
    return result;
  }

  Future<void> resetAllData() async {
    await _storage.clearAll();
    _profile = UserProfile.defaultProfile();
    _campaigns = [];
    _contentItems = [];
    _ideas = [];
    _tasks = [];
    notifyListeners();
  }
}
