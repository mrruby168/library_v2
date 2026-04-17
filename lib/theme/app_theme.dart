import 'package:flutter/material.dart';

// ── Màu sắc ──────────────────────────────────────────────────────────────────
class AppColors {
  // Backgrounds
  static const Color sidebarBg   = Color(0xFF111318);
  static const Color mainBg      = Color(0xFF181B22);
  static const Color cardBg      = Color(0xFF1E2230);
  static const Color cardHover   = Color(0xFF252A3A);
  static const Color surface     = Color(0xFF242838);

  // Reader
  static const Color readerPaper = Color(0xFFF7F3E9);
  static const Color readerSepia = Color(0xFFEDE3C7);
  static const Color readerDark  = Color(0xFF111318);

  // Accent
  static const Color gold        = Color(0xFFFFD166);
  static const Color goldDim     = Color(0xFFB8942F);
  static const Color accent      = Color(0xFF5B8DEF);
  static const Color accentDim   = Color(0xFF3A6BD4);
  static const Color success     = Color(0xFF4CAF7D);
  static const Color danger      = Color(0xFFEF5350);

  // Text
  static const Color textPrimary   = Color(0xFFE8EAF0);
  static const Color textSecondary = Color(0xFF8B92A8);
  static const Color textMuted     = Color(0xFF555E78);
  static const Color textOnLight   = Color(0xFF1A1A2E);

  // Borders
  static const Color border      = Color(0xFF2A2F42);
  static const Color borderLight = Color(0xFF353D55);
}

// ── Kiểu chữ PC (font lớn hơn, đọc dễ hơn) ─────────────────────────────────
class AppTextStyles {
  static const String _sansFont = 'Inter';

  static const TextStyle appTitle = TextStyle(
    fontFamily: _sansFont,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  static const TextStyle sectionHeader = TextStyle(
    fontFamily: _sansFont,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
    letterSpacing: 1.2,
  );

  static const TextStyle categoryTitle = TextStyle(
    fontFamily: _sansFont,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle subTitle = TextStyle(
    fontFamily: _sansFont,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: _sansFont,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  static const TextStyle button = TextStyle(
    fontFamily: _sansFont,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // Reader text - Georgia cho cảm giác đọc sách
  static const TextStyle readerBody = TextStyle(
    fontFamily: 'Georgia',
    fontSize: 18,
    height: 1.85,
    color: AppColors.textOnLight,
    letterSpacing: 0.1,
  );
}

// ── Theme tổng ───────────────────────────────────────────────────────────────
class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.mainBg,
      fontFamily: 'Inter',

      colorScheme: ColorScheme.dark(
        surface: AppColors.surface,
        primary: AppColors.gold,
        secondary: AppColors.accent,
        onPrimary: AppColors.textOnLight,
        onSurface: AppColors.textPrimary,
        outline: AppColors.border,
      ),

      dividerColor: AppColors.border,
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),

      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(AppColors.borderLight),
        trackColor: WidgetStateProperty.all(Colors.transparent),
        thickness: WidgetStateProperty.all(6),
        radius: const Radius.circular(3),
      ),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.border),
        ),
        textStyle: AppTextStyles.caption.copyWith(color: AppColors.textPrimary),
        waitDuration: const Duration(milliseconds: 600),
      ),
    );
  }
}
