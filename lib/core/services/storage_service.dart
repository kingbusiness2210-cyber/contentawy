import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../models/campaign.dart';
import '../models/content_item.dart';
import '../models/marketing_idea.dart';
import '../models/task_item.dart';

class StorageService {
  static const String keyProfile = 'contentawy_profile_v1';
  static const String keyCampaigns = 'contentawy_campaigns_v1';
  static const String keyContent = 'contentawy_content_v1';
  static const String keyIdeas = 'contentawy_ideas_v1';
  static const String keyTasks = 'contentawy_tasks_v1';
  static const String keyInitialized = 'contentawy_initialized_v1';

  final SharedPreferences prefs;

  StorageService(this.prefs);

  static Future<StorageService> init() async {
    final preferences = await SharedPreferences.getInstance();
    final service = StorageService(preferences);
    await service._ensureInitialData();
    return service;
  }

  Future<void> _ensureInitialData() async {
    final isInitialized = prefs.getBool(keyInitialized) ?? false;
    if (!isInitialized) {
      // Seed high quality initial marketing data
      final defaultCampaigns = [
        Campaign(
          name: 'حملة إطلاق كورس الماركتينج الصيفي',
          platform: MarketingPlatform.facebook,
          budget: 5000.0,
          spent: 3200.0,
          revenue: 14500.0,
          objective: 'مبيعات (Sales / Purchases)',
          status: CampaignStatus.active,
          targetAudience: 'المسوقين والمهتمين بالفريلانسينج في مصر والخليج (22-40 سنة)',
          notes: 'الإعلان شغال بنتيجة ممتازة، الـ CBO عامل أداء عالي.',
        ),
        Campaign(
          name: 'حملة تيك توك لزيادة المتابعين والتفاعل',
          platform: MarketingPlatform.tiktok,
          budget: 2000.0,
          spent: 1850.0,
          revenue: 4200.0,
          objective: 'تفاعل ومشاهدات فيديو',
          status: CampaignStatus.active,
          targetAudience: 'الشباب وصناع المحتوى (18-30 سنة)',
          notes: 'فيديو الهوك بتاع (سر زيادة المبيعات) جايب أعلى تفاعل.',
        ),
        Campaign(
          name: 'إعلانات جوجل سيرش للمنتج الأساسي',
          platform: MarketingPlatform.google,
          budget: 3500.0,
          spent: 3500.0,
          revenue: 11200.0,
          objective: 'تحويلات مباشرة (Direct Conversions)',
          status: CampaignStatus.completed,
          targetAudience: 'الباحثين عن أفضل أدوات التسويق وصناعة المحتوى',
          notes: 'الحملة حققت أعلى ROAS 3.2x.',
        ),
      ];

      final defaultContent = [
        ContentItem(
          title: 'فيديو ريل: 3 أسرار لمضاعفة مبيعات متجرك',
          platform: MarketingPlatform.instagram,
          format: ContentFormat.reel,
          status: ContentStatus.scheduled,
          scheduledDate: DateTime.now().add(const Duration(hours: 3)),
          caption: 'لو بتعاني إن الإعلانات بتصرف بدون مبيعات.. شوف الـ 3 خطوات دول وطبقهم فوراً! 🔥👇\n\n1. ركز على الهوك الأول في أول 3 ثواني.\n2. خلي العرض لا يقاوم (Irresistible Offer).\n3. قلل خطوات الشراء في صفحة الدفع.',
          hashtags: '#تسويق #ماركتينج #ريلز #مبيعات #صناعة_محتوى #كونتنتاوي',
          targetGoal: 'تفاعل ومشاركات',
        ),
        ContentItem(
          title: 'كاروسيل: الدليل الشامل لحساب الـ ROAS والـ CAC',
          platform: MarketingPlatform.linkedin,
          format: ContentFormat.carousel,
          status: ContentStatus.editing,
          scheduledDate: DateTime.now().add(const Duration(days: 1)),
          caption: 'إزاي تعرف هل حملتك الإعلانية كسبانة بجد ولا بتخسر في صمت؟ تفاصيل ومعادلات الحساب خطوة بخطوة 📊.',
          hashtags: '#ميديا_باينج #أرقام_التسويق #B2B #إعلانات',
          targetGoal: 'بناء مصداقية وخبرة',
        ),
        ContentItem(
          title: 'فيديو تيك توك: خطأ كارثي بيضيع ميزانية إعلاناتك',
          platform: MarketingPlatform.tiktok,
          format: ContentFormat.reel,
          status: ContentStatus.scripting,
          scheduledDate: DateTime.now().add(const Duration(days: 2)),
          caption: 'ليه أغلب الناس بتفتكر المشكلة في الاستهداف مع إن المشكلة في الكرييتف نفسه؟',
          hashtags: '#tiktokads #digitalmarketing #egypt',
          targetGoal: 'انتشار سريع (Virality)',
        ),
      ];

      final defaultIdeas = [
        MarketingIdea(
          title: 'سلسلة يوميات ميديا باير ومشاكل الـ Ad Account',
          description: 'فيديوهات قصيرة كوميدية واقعية بتعبر عن معاناتنا مع قفل الحسابات الإعلانية ومراجعة الفيسبوك.',
          platform: MarketingPlatform.tiktok,
          tags: 'ريلز, كوميدي, ميديا باير',
          priority: IdeaPriority.high,
        ),
        MarketingIdea(
          title: 'إنفوجرافيك مقارنة بين تكلفة الإعلان على المنصات في مصر',
          description: 'مقارنة دقيقة لمتوسط الـ CPM والـ CPC بين فيسبوك وتيك توك وجوجل في السوق المصري.',
          platform: MarketingPlatform.linkedin,
          tags: 'بيانات, سوشيال ميديا, إحصائيات',
          priority: IdeaPriority.medium,
        ),
      ];

      final defaultTasks = [
        TaskItem(
          title: 'مراجعة أداء حملة الفيسبوك وإيقاف الـ Ad Sets الضعيفة',
          description: 'التشيك على الـ ROAS والـ Frequency والتأكد من عدم وصولها لأكثر من 3.5.',
          category: 'ميديا باينج',
          priority: TaskPriority.high,
          dueDate: DateTime.now(),
        ),
        TaskItem(
          title: 'تصوير وتعديل ريلز الأسبوع القادم (3 فيديوهات)',
          description: 'تجهيز السكريبت والإضاءة والمايك.',
          category: 'محتوى',
          priority: TaskPriority.high,
          dueDate: DateTime.now(),
        ),
        TaskItem(
          title: 'تجهيز تقرير نهاية الشهر للعميل',
          description: 'جمع أرقام الإنفاق، العائد، وعدد الليدز وتكلفة العميل.',
          category: 'تقارير',
          priority: TaskPriority.medium,
          dueDate: DateTime.now().add(const Duration(days: 2)),
        ),
      ];

      await saveProfile(UserProfile.defaultProfile());
      await saveCampaigns(defaultCampaigns);
      await saveContent(defaultContent);
      await saveIdeas(defaultIdeas);
      await saveTasks(defaultTasks);
      await prefs.setBool(keyInitialized, true);
    }
  }

  // Profile
  Future<bool> saveProfile(UserProfile profile) async {
    return await prefs.setString(keyProfile, jsonEncode(profile.toJson()));
  }

  UserProfile loadProfile() {
    final str = prefs.getString(keyProfile);
    if (str == null) return UserProfile.defaultProfile();
    try {
      return UserProfile.fromJson(jsonDecode(str) as Map<String, dynamic>);
    } catch (_) {
      return UserProfile.defaultProfile();
    }
  }

  // Campaigns
  Future<bool> saveCampaigns(List<Campaign> campaigns) async {
    final list = campaigns.map((c) => c.toJson()).toList();
    return await prefs.setString(keyCampaigns, jsonEncode(list));
  }

  List<Campaign> loadCampaigns() {
    final str = prefs.getString(keyCampaigns);
    if (str == null) return [];
    try {
      final list = jsonDecode(str) as List<dynamic>;
      return list.map((item) => Campaign.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  // Content
  Future<bool> saveContent(List<ContentItem> content) async {
    final list = content.map((c) => c.toJson()).toList();
    return await prefs.setString(keyContent, jsonEncode(list));
  }

  List<ContentItem> loadContent() {
    final str = prefs.getString(keyContent);
    if (str == null) return [];
    try {
      final list = jsonDecode(str) as List<dynamic>;
      return list.map((item) => ContentItem.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  // Ideas
  Future<bool> saveIdeas(List<MarketingIdea> ideas) async {
    final list = ideas.map((i) => i.toJson()).toList();
    return await prefs.setString(keyIdeas, jsonEncode(list));
  }

  List<MarketingIdea> loadIdeas() {
    final str = prefs.getString(keyIdeas);
    if (str == null) return [];
    try {
      final list = jsonDecode(str) as List<dynamic>;
      return list.map((item) => MarketingIdea.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  // Tasks
  Future<bool> saveTasks(List<TaskItem> tasks) async {
    final list = tasks.map((t) => t.toJson()).toList();
    return await prefs.setString(keyTasks, jsonEncode(list));
  }

  List<TaskItem> loadTasks() {
    final str = prefs.getString(keyTasks);
    if (str == null) return [];
    try {
      final list = jsonDecode(str) as List<dynamic>;
      return list.map((item) => TaskItem.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> clearAll() async {
    await prefs.clear();
  }
}
