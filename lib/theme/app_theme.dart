import 'package:flutter/material.dart';

// ─────────────────────────────────────────
//  APP THEME COLORS EXTENSION
// ─────────────────────────────────────────
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  final Color bgDeep;
  final Color bgSurface;
  final Color bgCard;
  final Color bgCardSolid;
  final Color accentPurple;
  final Color accentBlue;
  final Color accentCyan;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color success;
  final Color error;
  final Color warning;
  final Color glassBorder;
  final Color glassFill;
  final Color glassBlur;
  final Gradient accentGradient;
  final Gradient accentGradientH;
  final Gradient bgGradient;
  final Gradient cardGradient;

  const AppThemeColors({
    required this.bgDeep,
    required this.bgSurface,
    required this.bgCard,
    required this.bgCardSolid,
    required this.accentPurple,
    required this.accentBlue,
    required this.accentCyan,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.success,
    required this.error,
    required this.warning,
    required this.glassBorder,
    required this.glassFill,
    required this.glassBlur,
    required this.accentGradient,
    required this.accentGradientH,
    required this.bgGradient,
    required this.cardGradient,
  });

  @override
  ThemeExtension<AppThemeColors> copyWith({
    Color? bgDeep,
    Color? bgSurface,
    Color? bgCard,
    Color? bgCardSolid,
    Color? accentPurple,
    Color? accentBlue,
    Color? accentCyan,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? success,
    Color? error,
    Color? warning,
    Color? glassBorder,
    Color? glassFill,
    Color? glassBlur,
    Gradient? accentGradient,
    Gradient? accentGradientH,
    Gradient? bgGradient,
    Gradient? cardGradient,
  }) {
    return AppThemeColors(
      bgDeep: bgDeep ?? this.bgDeep,
      bgSurface: bgSurface ?? this.bgSurface,
      bgCard: bgCard ?? this.bgCard,
      bgCardSolid: bgCardSolid ?? this.bgCardSolid,
      accentPurple: accentPurple ?? this.accentPurple,
      accentBlue: accentBlue ?? this.accentBlue,
      accentCyan: accentCyan ?? this.accentCyan,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      success: success ?? this.success,
      error: error ?? this.error,
      warning: warning ?? this.warning,
      glassBorder: glassBorder ?? this.glassBorder,
      glassFill: glassFill ?? this.glassFill,
      glassBlur: glassBlur ?? this.glassBlur,
      accentGradient: accentGradient ?? this.accentGradient,
      accentGradientH: accentGradientH ?? this.accentGradientH,
      bgGradient: bgGradient ?? this.bgGradient,
      cardGradient: cardGradient ?? this.cardGradient,
    );
  }

  @override
  ThemeExtension<AppThemeColors> lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) return this;
    return AppThemeColors(
      bgDeep: Color.lerp(bgDeep, other.bgDeep, t)!,
      bgSurface: Color.lerp(bgSurface, other.bgSurface, t)!,
      bgCard: Color.lerp(bgCard, other.bgCard, t)!,
      bgCardSolid: Color.lerp(bgCardSolid, other.bgCardSolid, t)!,
      accentPurple: Color.lerp(accentPurple, other.accentPurple, t)!,
      accentBlue: Color.lerp(accentBlue, other.accentBlue, t)!,
      accentCyan: Color.lerp(accentCyan, other.accentCyan, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      success: Color.lerp(success, other.success, t)!,
      error: Color.lerp(error, other.error, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      glassFill: Color.lerp(glassFill, other.glassFill, t)!,
      glassBlur: Color.lerp(glassBlur, other.glassBlur, t)!,
      accentGradient: Gradient.lerp(accentGradient, other.accentGradient, t)!,
      accentGradientH: Gradient.lerp(accentGradientH, other.accentGradientH, t)!,
      bgGradient: Gradient.lerp(bgGradient, other.bgGradient, t)!,
      cardGradient: Gradient.lerp(cardGradient, other.cardGradient, t)!,
    );
  }

  static const dark = AppThemeColors(
    bgDeep: Color(0xFF08080F),
    bgSurface: Color(0xFF111118),
    bgCard: Color(0xFF181822),
    bgCardSolid: Color(0xFF181822),
    accentPurple: Color(0xFF7C5CFC),
    accentBlue: Color(0xFF3D8EF1),
    accentCyan: Color(0xFF00D4FF),
    textPrimary: Color(0xFFEEEEFF),
    textSecondary: Color(0xFF9898B8),
    textMuted: Color(0xFF55556A),
    success: Color(0xFF4ADE80),
    error: Color(0xFFFC5C7D),
    warning: Color(0xFFFFB347),
    glassBorder: Color(0x226C5CFC),
    glassFill: Color(0x0DFFFFFF),
    glassBlur: Color(0x1AFFFFFF),
    accentGradient: LinearGradient(colors: [Color(0xFF7C5CFC), Color(0xFF3D8EF1)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    accentGradientH: LinearGradient(colors: [Color(0xFF7C5CFC), Color(0xFF00D4FF)], begin: Alignment.centerLeft, end: Alignment.centerRight),
    bgGradient: LinearGradient(colors: [Color(0xFF0D0D1A), Color(0xFF08080F)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
    cardGradient: LinearGradient(colors: [Color(0xFF1E1E2E), Color(0xFF141420)], begin: Alignment.topLeft, end: Alignment.bottomRight),
  );

  static const light = AppThemeColors(
    bgDeep: Color(0xFFF0F0F5),
    bgSurface: Color(0xFFFAFAFC),
    bgCard: Color(0xFFFFFFFF),
    bgCardSolid: Color(0xFFFFFFFF),
    accentPurple: Color(0xFF6B4CE6),
    accentBlue: Color(0xFF2B7CE0),
    accentCyan: Color(0xFF00B4D8),
    textPrimary: Color(0xFF1A1A24),
    textSecondary: Color(0xFF6E6E80),
    textMuted: Color(0xFF9898B0),
    success: Color(0xFF34C759),
    error: Color(0xFFFF3B30),
    warning: Color(0xFFFF9500),
    glassBorder: Color(0x1A000000),
    glassFill: Color(0x4DFFFFFF),
    glassBlur: Color(0x66FFFFFF),
    accentGradient: LinearGradient(colors: [Color(0xFF6B4CE6), Color(0xFF2B7CE0)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    accentGradientH: LinearGradient(colors: [Color(0xFF6B4CE6), Color(0xFF00B4D8)], begin: Alignment.centerLeft, end: Alignment.centerRight),
    bgGradient: LinearGradient(colors: [Color(0xFFE5E5EA), Color(0xFFF0F0F5)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
    cardGradient: LinearGradient(colors: [Color(0xFFFFFFFF), Color(0xFFF9F9FB)], begin: Alignment.topLeft, end: Alignment.bottomRight),
  );
}

// ─────────────────────────────────────────
//  CONTEXT EXTENSION
// ─────────────────────────────────────────
extension BuildContextThemeX on BuildContext {
  AppThemeColors get colors => Theme.of(this).extension<AppThemeColors>()!;
}

// ─────────────────────────────────────────
//  APP TEXT STYLES (No hardcoded colors)
// ─────────────────────────────────────────
class AppTextStyles {
  AppTextStyles._();

  static const displayLarge = TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.5);
  static const titleLarge = TextStyle(fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.3);
  static const titleMedium = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0);
  static const bodyLarge = TextStyle(fontSize: 15, fontWeight: FontWeight.w400, height: 1.5);
  static const bodyMedium = TextStyle(fontSize: 13, fontWeight: FontWeight.w400, height: 1.4);
  static const labelSmall = TextStyle(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5);
  static const accentText = TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.2);
}

// ─────────────────────────────────────────
//  APP THEME
// ─────────────────────────────────────────
class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final colors = AppThemeColors.dark;
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: colors.bgDeep,
      primaryColor: colors.accentPurple,
      colorScheme: ColorScheme.dark(
        primary: colors.accentPurple,
        secondary: colors.accentBlue,
        surface: colors.bgSurface,
        error: colors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: colors.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.titleLarge.copyWith(color: colors.textPrimary),
        iconTheme: IconThemeData(color: colors.textPrimary),
      ),
      iconTheme: IconThemeData(color: colors.textSecondary),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge.copyWith(color: colors.textPrimary),
        titleLarge: AppTextStyles.titleLarge.copyWith(color: colors.textPrimary),
        titleMedium: AppTextStyles.titleMedium.copyWith(color: colors.textPrimary),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: colors.textPrimary),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: colors.textSecondary),
        labelSmall: AppTextStyles.labelSmall.copyWith(color: colors.textMuted),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return colors.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return colors.accentPurple;
          return colors.bgCardSolid;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.accentPurple,
        foregroundColor: Colors.white,
        elevation: 8,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.bgCardSolid,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: colors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.bgCardSolid,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: AppTextStyles.titleMedium.copyWith(color: colors.textPrimary),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: colors.textSecondary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.bgCardSolid,
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: colors.textSecondary),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: colors.textSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.glassBorder, width: 1.5)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.glassBorder, width: 1.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.accentPurple, width: 2)),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: colors.bgCardSolid, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
      ),
      extensions: const [AppThemeColors.dark],
    );
  }

  static ThemeData get light {
    final colors = AppThemeColors.light;
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: colors.bgDeep,
      primaryColor: colors.accentPurple,
      colorScheme: ColorScheme.light(
        primary: colors.accentPurple,
        secondary: colors.accentBlue,
        surface: colors.bgSurface,
        error: colors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: colors.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.titleLarge.copyWith(color: colors.textPrimary),
        iconTheme: IconThemeData(color: colors.textPrimary),
      ),
      iconTheme: IconThemeData(color: colors.textSecondary),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge.copyWith(color: colors.textPrimary),
        titleLarge: AppTextStyles.titleLarge.copyWith(color: colors.textPrimary),
        titleMedium: AppTextStyles.titleMedium.copyWith(color: colors.textPrimary),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: colors.textPrimary),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: colors.textSecondary),
        labelSmall: AppTextStyles.labelSmall.copyWith(color: colors.textMuted),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return colors.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return colors.accentPurple;
          return colors.bgCardSolid;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.accentPurple,
        foregroundColor: Colors.white,
        elevation: 8,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.bgCardSolid,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: colors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.bgCardSolid,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: AppTextStyles.titleMedium.copyWith(color: colors.textPrimary),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: colors.textSecondary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.bgCardSolid,
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: colors.textSecondary),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: colors.textSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.glassBorder, width: 1.5)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.glassBorder, width: 1.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.accentPurple, width: 2)),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: colors.bgCardSolid, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
      ),
      extensions: const [AppThemeColors.light],
    );
  }
}

// ─────────────────────────────────────────
//  HELPER EXTENSIONS
// ─────────────────────────────────────────
extension GradientBox on BoxDecoration {
  static BoxDecoration accentCard(BuildContext context, {double radius = 16}) => BoxDecoration(
        gradient: context.colors.cardGradient,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: context.colors.glassBorder, width: 1),
      );

  static BoxDecoration glassCard(BuildContext context, {double radius = 16}) => BoxDecoration(
        color: context.colors.glassFill,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: context.colors.glassBorder, width: 1),
      );
}
