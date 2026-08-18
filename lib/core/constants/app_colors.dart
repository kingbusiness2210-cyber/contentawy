import 'package:flutter/material.dart';

class AppColors {
  // Brand Primary & Gradient
  static const Color primary = Color(0xFF2563EB); // Electric Royal Blue
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryContainer = Color(0xFFDBEAFE);

  // Secondary & Accents
  static const Color secondary = Color(0xFF0D9488); // Teal
  static const Color accentGrowth = Color(0xFF10B981); // Emerald Growth/Profit
  static const Color accentGrowthDark = Color(0xFF059669);
  static const Color accentWarning = Color(0xFFF59E0B); // Amber
  static const Color accentError = Color(0xFFEF4444); // Coral Crimson
  static const Color accentPurple = Color(0xFF8B5CF6);

  // Dark Theme Palette
  static const Color darkBg = Color(0xFF0B1120); // Deep Midnight Slate
  static const Color darkSurface = Color(0xFF1E293B); // Slate Surface
  static const Color darkSurfaceVariant = Color(0xFF334155); // Elevated
  static const Color darkBorder = Color(0xFF2E3D52);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);

  // Light Theme Palette
  static const Color lightBg = Color(0xFFF8FAFC); // Clean Snow
  static const Color lightSurface = Color(0xFFFFFFFF); // Pure White
  static const Color lightSurfaceVariant = Color(0xFFF1F5F9); // Light Gray
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);

  // Social Platforms Colors
  static const Color facebook = Color(0xFF1877F2);
  static const Color instagram = Color(0xFFE1306C);
  static const Color tiktok = Color(0xFF000000);
  static const Color google = Color(0xFF4285F4);
  static const Color snapchat = Color(0xFFFFFC00);
  static const Color linkedin = Color(0xFF0A66C2);
  static const Color twitter = Color(0xFF1DA1F2);
  static const Color youtube = Color(0xFFFF0000);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient growthGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF172033)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
