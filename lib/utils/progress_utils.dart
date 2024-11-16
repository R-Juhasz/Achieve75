// progress_utils.dart
import 'package:shared_preferences/shared_preferences.dart';

class ProgressUtils {
  static Future<Map<String, dynamic>> calculateProgress(
      int currentDay) async {
    final prefs = await SharedPreferences.getInstance();
    int completed = 0;
    int failed = 0;

    for (int day = 1; day <= 75; day++) {
      bool? isCompleted = prefs.getBool('day_${day}_completed');
      if (isCompleted == true) {
        completed++;
      } else if (day < currentDay && isCompleted == false) {
        failed++;
      }
    }

    return {
      'daysCompleted': completed,
      'daysFailed': failed,
    };
  }
}
