// lib/water_tracker_styles.dart

import 'package:flutter/material.dart';

class WaterTrackerColors {
  static const Color background = Colors.white;
  static const Color primary = Colors.blue;
  static const Color error = Colors.red;
  static const Color text = Colors.black87;
}

class WaterTrackerStyles {
  static const TextStyle appBarTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: WaterTrackerColors.text,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: WaterTrackerColors.text,
  );

  static const TextStyle titleText = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: WaterTrackerColors.primary,
  );

  static const TextStyle subtitleText = TextStyle(
    fontSize: 16,
    color: Colors.grey,
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: 16,
    color: WaterTrackerColors.text,
  );

  static const TextStyle hintText = TextStyle(
    fontSize: 14,
    color: Colors.grey,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle dialogTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: WaterTrackerColors.text,
  );

  static const TextStyle cancelButton = TextStyle(
    fontSize: 16,
    color: Colors.grey,
  );

  static const TextStyle errorText = TextStyle(
    fontSize: 16,
    color: WaterTrackerColors.error,
  );
}

