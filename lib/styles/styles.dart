// lib/styles.dart

import 'package:flutter/material.dart';

/// Common Colors
class AppColors {
  static const Color primary = Color(0xFF84a98c); // Soft green for primary buttons and highlights
  static const Color primaryDark = Color(0xFF52797f); // Muted teal for darker accents
  static const Color background = Color(0xFF2f3e46); // Deep dark green for the background
  static const Color text = Color(0xFFcad2c5); // Light green for text on dark background
  static const Color textSecondary = Color(0xFF354f52); // Darker green for secondary text
  static const Color hintText = Color(0xFFcad2c5); // Light green for hint text
  static const Color error = Colors.redAccent; // Bright red for errors
  static const Color cardBackground = Color(0xFF354f52); // Darker teal for card backgrounds
  static const Color completedGreen = Color(0xFF28a745); // Bright green for completed days
}

/// Common Text Styles
class AppTextStyles {
  static const String fontFamily = 'Gugi';

  static const TextStyle title = TextStyle(
    color: AppColors.text,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    fontFamily: fontFamily,
  );

  static const TextStyle subtitle = TextStyle(
    color: AppColors.text,
    fontSize: 18,
    fontFamily: fontFamily,
  );

  static const TextStyle body = TextStyle(
    color: AppColors.text,
    fontSize: 16,
    fontFamily: fontFamily,
  );

  static const TextStyle bodySecondary = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 14,
    fontFamily: fontFamily,
  );

  static const TextStyle hint = TextStyle(
    color: AppColors.hintText,
    fontFamily: fontFamily,
  );

  static const TextStyle button = TextStyle(
    color: AppColors.text, // Consider changing to Colors.white for better contrast
    fontSize: 16,
    fontFamily: fontFamily,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle error = TextStyle(
    color: AppColors.error,
    fontSize: 14,
    fontFamily: fontFamily,
  );

  /// **Added Text Styles**

  /// Text style for dialog titles
  static const TextStyle dialogTitle = TextStyle(
    color: AppColors.text,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    fontFamily: fontFamily,
  );

  /// Text style for cancel buttons in dialogs
  static const TextStyle cancelButton = TextStyle(
    color: AppColors.primary,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    fontFamily: fontFamily,
  );
}

/// Common Button Styles
class AppButtonStyles {
  static ButtonStyle primary = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 60),
    textStyle: AppTextStyles.button, // Ensures text style consistency
  );

  static ButtonStyle secondary = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryDark,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 60),
    textStyle: AppTextStyles.button,
  );

  static ButtonStyle danger = ElevatedButton.styleFrom(
    backgroundColor: AppColors.error,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 60),
    textStyle: AppTextStyles.button,
  );
}

/// Common Input Decorations
class AppInputDecorations {
  static InputDecoration email = InputDecoration(
    prefixIcon: const Icon(Icons.email, color: AppColors.primary),
    labelText: 'Email',
    labelStyle: AppTextStyles.body,
    hintText: 'Enter your email',
    hintStyle: AppTextStyles.hint,
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: AppColors.primary),
      borderRadius: BorderRadius.circular(10),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: AppColors.primaryDark),
      borderRadius: BorderRadius.circular(10),
    ),
  );

  static InputDecoration password = InputDecoration(
    prefixIcon: const Icon(Icons.lock, color: AppColors.primary),
    labelText: 'Password',
    labelStyle: AppTextStyles.body,
    hintText: 'Enter your password',
    hintStyle: AppTextStyles.hint,
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: AppColors.primary),
      borderRadius: BorderRadius.circular(10),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: AppColors.primaryDark),
      borderRadius: BorderRadius.circular(10),
    ),
  );
}

// Additional screen-specific styles (e.g., LoginScreenStyles, HomeScreenStyles, etc.) remain unchanged,
// but they now inherit the new color definitions from `AppColors`.
