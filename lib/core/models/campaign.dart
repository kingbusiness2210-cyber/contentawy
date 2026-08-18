import 'package:uuid/uuid.dart';

enum CampaignStatus { active, paused, completed, draft }

enum MarketingPlatform {
  facebook,
  instagram,
  tiktok,
  google,
  snapchat,
  linkedin,
  twitter,
  youtube,
  other
}

class Campaign {
  final String id;
  final String name;
  final MarketingPlatform platform;
  final double budget;
  final double spent;
  final double revenue;
  final String objective;
  final CampaignStatus status;
  final String targetAudience;
  final String notes;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime createdAt;

  Campaign({
    String? id,
    required this.name,
    required this.platform,
    required this.budget,
    this.spent = 0.0,
    this.revenue = 0.0,
    this.objective = 'مبيعات (Sales / Purchases)',
    this.status = CampaignStatus.active,
    this.targetAudience = '',
    this.notes = '',
    DateTime? startDate,
    this.endDate,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        startDate = startDate ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  double get roas => spent > 0 ? (revenue / spent) : (revenue > 0 ? 99.0 : 0.0);
  double get profit => revenue - spent;
  double get roiPercentage => spent > 0 ? ((revenue - spent) / spent) * 100 : 0.0;
  double get budgetProgress => budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;

  Campaign copyWith({
    String? id,
    String? name,
    MarketingPlatform? platform,
    double? budget,
    double? spent,
    double? revenue,
    String? objective,
    CampaignStatus? status,
    String? targetAudience,
    String? notes,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
  }) {
    return Campaign(
      id: id ?? this.id,
      name: name ?? this.name,
      platform: platform ?? this.platform,
      budget: budget ?? this.budget,
      spent: spent ?? this.spent,
      revenue: revenue ?? this.revenue,
      objective: objective ?? this.objective,
      status: status ?? this.status,
      targetAudience: targetAudience ?? this.targetAudience,
      notes: notes ?? this.notes,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'platform': platform.name,
      'budget': budget,
      'spent': spent,
      'revenue': revenue,
      'objective': objective,
      'status': status.name,
      'targetAudience': targetAudience,
      'notes': notes,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Campaign.fromJson(Map<String, dynamic> json) {
    MarketingPlatform plat;
    try {
      plat = MarketingPlatform.values.byName(json['platform'] as String? ?? 'facebook');
    } catch (_) {
      plat = MarketingPlatform.facebook;
    }

    CampaignStatus stat;
    try {
      stat = CampaignStatus.values.byName(json['status'] as String? ?? 'active');
    } catch (_) {
      stat = CampaignStatus.active;
    }

    return Campaign(
      id: json['id'] as String?,
      name: json['name'] as String? ?? 'حملة بدون عنوان',
      platform: plat,
      budget: (json['budget'] as num?)?.toDouble() ?? 0.0,
      spent: (json['spent'] as num?)?.toDouble() ?? 0.0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
      objective: json['objective'] as String? ?? 'مبيعات (Sales / Purchases)',
      status: stat,
      targetAudience: json['targetAudience'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'] as String) ?? DateTime.now()
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
