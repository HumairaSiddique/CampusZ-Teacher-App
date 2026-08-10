import 'package:flutter/material.dart';

/// Centralized theme-aware colors for the CampusZ app.
///
/// Brand accent colors (the purple/indigo gradient, and status colors like
/// green/red/orange) stay the same in both Light and Dark mode — that's
/// normal practice for a brand palette. Only backgrounds, card surfaces,
/// and text colors adapt to the current Brightness.
///
/// Usage: replace hardcoded `darkText` / `bgColor` / `Colors.white` (for
/// card backgrounds) in a screen with `AppColors.text(context)`,
/// `AppColors.bg(context)`, and `AppColors.surface(context)`.
class AppColors {
  AppColors._();

  static bool isDark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;

  /// Page/scaffold background.
  static Color bg(BuildContext context) =>
      isDark(context) ? const Color(0xFF121212) : const Color(0xFFF7F8FC);

  /// Card / container surface color (was hardcoded `Colors.white`).
  static Color surface(BuildContext context) =>
      isDark(context) ? const Color(0xFF1E1E1E) : Colors.white;

  /// Primary text/icon color (was hardcoded `darkText` = 0xFF1E1B3A).
  static Color text(BuildContext context) =>
      isDark(context) ? const Color(0xFFF1F1F5) : const Color(0xFF1E1B3A);

  /// Muted/secondary text — same idea as `darkText.withOpacity(x)` before.
  static Color textMuted(BuildContext context, [double opacity = 0.5]) =>
      text(context).withOpacity(opacity);

  /// Subtle divider/border color.
  static Color divider(BuildContext context) =>
      isDark(context) ? Colors.white.withOpacity(0.08) : const Color(0xFF1E1B3A).withOpacity(0.06);

  // Brand colors — intentionally identical in both themes.
  static const Color primaryIndigo = Color(0xFF4A5AE8);
  static const Color gradientStart = Color(0xFF6C4CE0);
  static const Color gradientEnd = Color(0xFF3D5AE0);
}