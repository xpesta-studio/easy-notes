import 'package:flutter/material.dart';

class AppColors {
  // Primary brand colors (Material 3 Deep Coral / Violet-Indigo)
  static const Color primaryLight = Color(0xFF6750A4);
  static const Color primaryContainerLight = Color(0xFFEADDFF);
  static const Color onPrimaryLight = Color(0xFFFFFFFF);
  
  static const Color primaryDark = Color(0xFFD0BCFF);
  static const Color primaryContainerDark = Color(0xFF4F378B);
  static const Color onPrimaryDark = Color(0xFF381E72);

  // Backgrounds & Surfaces
  static const Color backgroundLight = Color(0xFFFBF8FD);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF3EDF7);
  static const Color outlineLight = Color(0xFF79747E);

  static const Color backgroundDark = Color(0xFF141218);
  static const Color surfaceDark = Color(0xFF1D1B20);
  static const Color surfaceVariantDark = Color(0xFF2B2930);
  static const Color outlineDark = Color(0xFF938F99);

  /// Note card background colors in Light Mode
  static const List<Color> noteColorsLight = [
    Color(0xFFFFFFFF), // 0: Default white
    Color(0xFFF2F5FD), // 1: Soft Periwinkle / Blue
    Color(0xFFE8F8F5), // 2: Soft Mint / Turquoise
    Color(0xFFFEF7E6), // 3: Soft Amber / Sun
    Color(0xFFFDECEE), // 4: Soft Coral / Rose
    Color(0xFFF5EEF8), // 5: Soft Lavender / Purple
    Color(0xFFEAF5EA), // 6: Soft Sage / Green
    Color(0xFFFDF0E6), // 7: Soft Peach / Orange
  ];

  /// Note card background colors in Dark Mode (OLED-friendly tones)
  static const List<Color> noteColorsDark = [
    Color(0xFF1D1B20), // 0: Default dark surface
    Color(0xFF1C2738), // 1: Night Navy
    Color(0xFF162D29), // 2: Night Forest / Teal
    Color(0xFF332617), // 3: Night Bronze
    Color(0xFF331D24), // 4: Night Crimson
    Color(0xFF281C38), // 5: Night Violet
    Color(0xFF192F1F), // 6: Night Emerald
    Color(0xFF342318), // 7: Night Amber
  ];

  /// Note card border / stroke accent colors
  static const List<Color> noteBorderColorsLight = [
    Color(0xFFE0E0E0),
    Color(0xFFBFD2F8),
    Color(0xFFA6E3D8),
    Color(0xFFFBD788),
    Color(0xFFF8B4BD),
    Color(0xFFDAC0EE),
    Color(0xFFBCE0BC),
    Color(0xFFF8CAA3),
  ];

  static const List<Color> noteBorderColorsDark = [
    Color(0xFF36343B),
    Color(0xFF2C4368),
    Color(0xFF25524A),
    Color(0xFF5D4528),
    Color(0xFF5C3340),
    Color(0xFF4A3469),
    Color(0xFF2B5737),
    Color(0xFF5E3F2A),
  ];
}