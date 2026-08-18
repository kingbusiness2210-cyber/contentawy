class MarketingMath {
  // ROAS = Revenue / Ad Spend
  static double calculateROAS(double revenue, double adSpend) {
    if (adSpend <= 0) return 0.0;
    return revenue / adSpend;
  }

  // Net ROI (%) = ((Revenue - Ad Spend - COGS) / Total Cost) * 100
  static double calculateROI({
    required double revenue,
    required double adSpend,
    double cogs = 0.0,
  }) {
    final totalCost = adSpend + cogs;
    if (totalCost <= 0) return 0.0;
    return ((revenue - totalCost) / totalCost) * 100;
  }

  // Net Profit = Revenue - Ad Spend - COGS
  static double calculateNetProfit({
    required double revenue,
    required double adSpend,
    double cogs = 0.0,
  }) {
    return revenue - adSpend - cogs;
  }

  // CAC = Total Marketing Cost / Number of New Customers Acquired
  static double calculateCAC(double totalCost, int newCustomers) {
    if (newCustomers <= 0) return 0.0;
    return totalCost / newCustomers;
  }

  // LTV = Average Purchase Value * Purchase Frequency * Customer Lifespan (Months/Years)
  static double calculateLTV({
    required double avgOrderValue,
    required double purchaseFrequencyPerYear,
    required double lifespanYears,
  }) {
    return avgOrderValue * purchaseFrequencyPerYear * lifespanYears;
  }

  // Break-Even ROAS = 1 / (Profit Margin % as decimal)
  // e.g. If profit margin is 40% (0.4), Break-even ROAS is 1 / 0.4 = 2.5x
  static double calculateBreakEvenROAS(double profitMarginPercent) {
    if (profitMarginPercent <= 0) return 0.0;
    final decimal = profitMarginPercent > 1 ? profitMarginPercent / 100 : profitMarginPercent;
    return 1 / decimal;
  }

  // Engagement Rate (%) = (Total Interactions / Total Reach or Followers) * 100
  static double calculateEngagementRate({
    required int likes,
    required int comments,
    required int shares,
    int saves = 0,
    required int reachOrFollowers,
  }) {
    if (reachOrFollowers <= 0) return 0.0;
    final totalInteractions = likes + comments + shares + saves;
    return (totalInteractions / reachOrFollowers) * 100;
  }

  // UTM URL Builder
  static String buildUTMUrl({
    required String baseUrl,
    required String source,
    required String medium,
    required String campaign,
    String term = '',
    String content = '',
  }) {
    var url = baseUrl.trim();
    if (url.isEmpty) return '';

    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    final uri = Uri.tryParse(url);
    if (uri == null) return url;

    final queryParams = Map<String, String>.from(uri.queryParameters);

    if (source.trim().isNotEmpty) queryParams['utm_source'] = source.trim();
    if (medium.trim().isNotEmpty) queryParams['utm_medium'] = medium.trim();
    if (campaign.trim().isNotEmpty) queryParams['utm_campaign'] = campaign.trim();
    if (term.trim().isNotEmpty) queryParams['utm_term'] = term.trim();
    if (content.trim().isNotEmpty) queryParams['utm_content'] = content.trim();

    return uri.replace(queryParameters: queryParams).toString();
  }

  // Copywriting Hooks & Formulas Bank
  static const List<Map<String, String>> hookTemplates = [
    {
      'category': 'خطافات جذب الانتباه (Viral Hooks)',
      'title': 'السر المخفي',
      'hook': 'معظم المسوقين بيغلطوا الغلطة دي في إعلاناتهم...',
      'description': 'بيخلق فضول فوري ويخلي المشاهد يكمل الفيديو أو البوست.',
    },
    {
      'category': 'خطافات جذب الانتباه (Viral Hooks)',
      'title': 'النتيجة قبل الشرح',
      'hook': 'إزاي وصلنا لـ ROAS 5.4x في 14 يوم بس بميزانية صغيرة...',
      'description': 'إثبات اجتماعي قوي وأرقام حقيقية تجذب العملاء المحتملين.',
    },
    {
      'category': 'خطافات جذب الانتباه (Viral Hooks)',
      'title': 'التحذير والتنبيه',
      'hook': 'لو بتعمل [اسم الخدمة/المنتج] بالشكل ده، وقف فوراً!',
      'description': 'بيعتمد على الخوف من إهدار الميزانية أو الوقت.',
    },
    {
      'category': 'خطافات جذب الانتباه (Viral Hooks)',
      'title': 'المقارنة الصادمة',
      'hook': 'الفرق بين الإعلان اللي بيحرق فلوس والإعلان اللي بيبيع...',
      'description': 'بيوضح تباين واضح وسهل الفهم.',
    },
    {
      'category': 'صيغ كتابة الإعلانات (Formulas)',
      'title': 'صيغة AIDA الكلاسيكية',
      'hook': 'Attention (لفت الانتباه) ➔ Interest (إثارة الاهتمام) ➔ Desire (خلق الرغبة) ➔ Action (الدعوة للشراء)',
      'description': 'الصيغة الذهبية لأي صفحة هبوط أو إعلان بيع مباشر.',
    },
    {
      'category': 'صيغ كتابة الإعلانات (Formulas)',
      'title': 'صيغة PAS (المشكلة والعلاج)',
      'hook': 'Problem (حدد المشكلة) ➔ Agitate (وضح خطورتها) ➔ Solution (قدم حلك الذكي)',
      'description': 'أنسب صيغة لإعلانات التيك توك وريلز إنستجرام.',
    },
    {
      'category': 'صيغ كتابة الإعلانات (Formulas)',
      'title': 'صيغة BAB (قبل وبعد)',
      'hook': 'Before (وضعك الحالي) ➔ After (شكل حياتك بعد الحل) ➔ Bridge (الجسر اللي هيوصلك)',
      'description': 'فعالة جداً مع المنتجات والخدمات الاستشارية.',
    },
    {
      'category': 'صيغ كتابة الإعلانات (Formulas)',
      'title': 'صيغة الـ 4Ps',
      'hook': 'Picture (ارسم المشهد) ➔ Promise (قدم وعد قوي) ➔ Prove (اثبت بكلام وتجارب) ➔ Push (ادفع للفعل)',
      'description': 'ممتازة للـ Carousels والبوستات الطويلة والمقالات.',
    },
  ];
}
