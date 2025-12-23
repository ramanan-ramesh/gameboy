import 'package:flutter/material.dart';
import 'package:gameboy/data/app/constants.dart';

/// Game-specific color schemes
class GameColors {
  // Wordsy - Green theme (word guessing game)
  static const wordsyPrimary = Color(0xFF4CAF50);
  static const wordsySecondary = Color(0xFF81C784);
  static const wordsyAccent = Color(0xFF2E7D32);

  // BeeWise - Amber/Yellow theme (spelling bee)
  static const beeWisePrimary = Color(0xFFFFC107);
  static const beeWiseSecondary = Color(0xFFFFD54F);
  static const beeWiseAccent = Color(0xFFFF8F00);

  // AlphaBound - Blue theme (alphabet game)
  static const alphaBoundPrimary = Color(0xFF2196F3);
  static const alphaBoundSecondary = Color(0xFF64B5F6);
  static const alphaBoundAccent = Color(0xFF1565C0);

  // LexBox - Purple theme (letter box puzzle)
  static const lexBoxPrimary = Color(0xFF6C63FF);
  static const lexBoxSecondary = Color(0xFF9D97FF);
  static const lexBoxAccent = Color(0xFF4A42D4);

  static Color getPrimaryColor(String gameIdentifier) {
    switch (gameIdentifier) {
      case AppConstants.wordsyGameIdentifier:
        return wordsyPrimary;
      case AppConstants.beeWiseGameIdentifier:
        return beeWisePrimary;
      case AppConstants.alphaBoundGameIdentifier:
        return alphaBoundPrimary;
      case AppConstants.lexBoxGameIdentifier:
        return lexBoxPrimary;
      default:
        return Colors.teal;
    }
  }

  static Color getSecondaryColor(String gameIdentifier) {
    switch (gameIdentifier) {
      case AppConstants.wordsyGameIdentifier:
        return wordsySecondary;
      case AppConstants.beeWiseGameIdentifier:
        return beeWiseSecondary;
      case AppConstants.alphaBoundGameIdentifier:
        return alphaBoundSecondary;
      case AppConstants.lexBoxGameIdentifier:
        return lexBoxSecondary;
      default:
        return Colors.tealAccent;
    }
  }

  static Color getAccentColor(String gameIdentifier) {
    switch (gameIdentifier) {
      case AppConstants.wordsyGameIdentifier:
        return wordsyAccent;
      case AppConstants.beeWiseGameIdentifier:
        return beeWiseAccent;
      case AppConstants.alphaBoundGameIdentifier:
        return alphaBoundAccent;
      case AppConstants.lexBoxGameIdentifier:
        return lexBoxAccent;
      default:
        return Colors.teal.shade700;
    }
  }
}

/// App-wide color palette
class AppColors {
  // Shared accent colors
  static const success = Color(0xFF4CAF50);
  static const error = Color(0xFFE53935);
  static const warning = Color(0xFFFFA726);
  static const info = Color(0xFF29B6F6);

  // Dark theme colors
  static const darkBackground = Color(0xFF121212);
  static const darkSurface = Color(0xFF1E1E1E);
  static const darkSurfaceVariant = Color(0xFF2C2C2C);
  static const darkCard = Color(0xFF252525);
  static const darkOnBackground = Color(0xFFE0E0E0);
  static const darkOnSurface = Color(0xFFFFFFFF);
  static const darkOnSurfaceMuted = Color(0xFFB0B0B0);
  static const darkDivider = Color(0xFF3D3D3D);

  // Light theme colors
  static const lightBackground = Color(0xFFFAFAFA);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceVariant = Color(0xFFF5F5F5);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightOnBackground = Color(0xFF212121);
  static const lightOnSurface = Color(0xFF212121);
  static const lightOnSurfaceMuted = Color(0xFF757575);
  static const lightDivider = Color(0xFFE0E0E0);

  // App brand colors
  static const brandPrimary = Color(0xFF6C63FF);
  static const brandSecondary = Color(0xFF4ECDC4);
}

/// Design constants
class DesignConstants {
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 24.0;

  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;

  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;
}
