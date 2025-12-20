import 'package:flutter/material.dart';

import 'app_colors.dart';

ThemeData createLightThemeData() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.brandPrimary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.brandPrimary.withValues(alpha: 0.1),
      onPrimaryContainer: AppColors.brandPrimary,
      secondary: AppColors.brandSecondary,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.brandSecondary.withValues(alpha: 0.1),
      onSecondaryContainer: AppColors.brandSecondary,
      tertiary: GameColors.wordsyPrimary,
      onTertiary: Colors.white,
      error: AppColors.error,
      onError: Colors.white,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightOnSurface,
      surfaceContainerHighest: AppColors.lightSurfaceVariant,
      outline: AppColors.lightDivider,
      shadow: Colors.black26,
    ),
    scaffoldBackgroundColor: AppColors.lightBackground,
    cardTheme: CardThemeData(
      color: AppColors.lightCard,
      elevation: DesignConstants.elevationLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignConstants.borderRadiusLarge),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.lightSurface,
      foregroundColor: AppColors.lightOnSurface,
      elevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.lightOnSurface,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.lightSurface,
      selectedItemColor: AppColors.brandPrimary,
      unselectedItemColor: AppColors.lightOnSurfaceMuted,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.brandPrimary,
        foregroundColor: Colors.white,
        elevation: DesignConstants.elevationLow,
        padding: const EdgeInsets.symmetric(
          horizontal: DesignConstants.spacingLarge,
          vertical: DesignConstants.spacingMedium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(DesignConstants.borderRadiusMedium),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.brandPrimary,
        side: const BorderSide(color: AppColors.brandPrimary),
        padding: const EdgeInsets.symmetric(
          horizontal: DesignConstants.spacingLarge,
          vertical: DesignConstants.spacingMedium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(DesignConstants.borderRadiusMedium),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.brandPrimary,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: AppColors.lightOnSurface,
      ),
    ),
    iconTheme: const IconThemeData(
      color: AppColors.lightOnSurface,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.brandPrimary,
      foregroundColor: Colors.white,
      elevation: DesignConstants.elevationMedium,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.lightSurfaceVariant,
      labelStyle: const TextStyle(color: AppColors.lightOnSurface),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignConstants.borderRadiusSmall),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.lightDivider,
      thickness: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightSurfaceVariant,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: DesignConstants.spacingMedium,
        vertical: DesignConstants.spacingMedium,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignConstants.borderRadiusMedium),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignConstants.borderRadiusMedium),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignConstants.borderRadiusMedium),
        borderSide: const BorderSide(color: AppColors.brandPrimary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignConstants.borderRadiusMedium),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.lightOnSurface,
      contentTextStyle: const TextStyle(color: AppColors.lightSurface),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignConstants.borderRadiusMedium),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.brandPrimary,
      linearTrackColor: AppColors.lightDivider,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignConstants.borderRadiusXLarge),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(DesignConstants.borderRadiusXLarge),
        ),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        color: AppColors.lightOnBackground,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        color: AppColors.lightOnBackground,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: AppColors.lightOnBackground,
      ),
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: AppColors.lightOnBackground,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: AppColors.lightOnBackground,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.lightOnBackground,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: AppColors.lightOnBackground,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.lightOnBackground,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.lightOnBackground,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.lightOnBackground,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.lightOnBackground,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.lightOnSurfaceMuted,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.lightOnBackground,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.lightOnBackground,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.lightOnSurfaceMuted,
      ),
    ),
  );
}
