import '../utils/shared_preferences_helper.dart';

class ProgressUtils {
  static Future<Map<String, dynamic>> calculateProgress(int currentDay) async {
    final prefs = await SharedPreferencesHelper.prefs;
    int daysCompleted = 0;
    int daysFailed = 0;

    for (int day = 1; day <= currentDay; day++) {
      if (prefs.getBool('day_${day}_completed') == true) {
        daysCompleted++;
      } else if (prefs.getBool('day_${day}_failed') == true) {
        daysFailed++;
      }
    }

    return {
      'daysCompleted': daysCompleted,
      'daysFailed': daysFailed,
    };
  }
}
