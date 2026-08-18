class UserProfile {
  final String name;
  final String role; // Content Creation, Media Buying, etc.
  final String currency; // EGP, USD, SAR, AED, EUR
  final bool isDarkMode;
  final bool hasCompletedOnboarding;
  final DateTime createdAt;

  UserProfile({
    required this.name,
    required this.role,
    this.currency = 'EGP',
    this.isDarkMode = false,
    this.hasCompletedOnboarding = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  UserProfile copyWith({
    String? name,
    String? role,
    String? currency,
    bool? isDarkMode,
    bool? hasCompletedOnboarding,
    DateTime? createdAt,
  }) {
    return UserProfile(
      name: name ?? this.name,
      role: role ?? this.role,
      currency: currency ?? this.currency,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'role': role,
      'currency': currency,
      'isDarkMode': isDarkMode,
      'hasCompletedOnboarding': hasCompletedOnboarding,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String? ?? 'المسوق الشاطر',
      role: json['role'] as String? ?? 'صناعة المحتوى (Content Creation)',
      currency: json['currency'] as String? ?? 'EGP',
      isDarkMode: json['isDarkMode'] as bool? ?? false,
      hasCompletedOnboarding: json['hasCompletedOnboarding'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  static UserProfile defaultProfile() {
    return UserProfile(
      name: 'المسوق الذكي',
      role: 'صناعة المحتوى (Content Creation)',
      currency: 'EGP',
      isDarkMode: false,
      hasCompletedOnboarding: false,
    );
  }
}
