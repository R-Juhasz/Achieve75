import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';
import '../utils/preferences_helper.dart';

/// This class handles background alarm callbacks.
/// Its methods are annotated with @pragma('vm:entry-point')
/// to prevent removal during tree shaking in release mode.
class NotificationsCallbackHandler {
  static final NotificationService _notificationService = NotificationService();

  /// Invoked when an alarm is triggered.
  @pragma('vm:entry-point')
  static Future<void> alarmCallback(int alarmId) async {
    WidgetsFlutterBinding.ensureInitialized();
    developer.log('NotificationsCallbackHandler.alarmCallback triggered with alarmId: $alarmId');

    final prefs = await SharedPreferences.getInstance();
    final alarmLabel = prefs.getString('alarm_label_$alarmId') ?? 'Workout';
    developer.log('Alarm label for alarmId $alarmId: $alarmLabel');

    if (alarmLabel == 'end_of_day') {
      // Example: calculate a day number from alarmId.
      final int day = alarmId - 1000;
      developer.log('Handling end-of-day alarm for day: $day');

      final bool isCompleted = prefs.getBool(PreferencesHelper.completedKey(day)) ?? false;
      final bool isFailed = prefs.getBool(PreferencesHelper.failedKey(day)) ?? false;
      developer.log('Day $day - Completed: $isCompleted, Failed: $isFailed');

      if (!isCompleted && !isFailed) {
        await prefs.setBool(PreferencesHelper.failedKey(day), true);
        developer.log('Day $day marked as failed.');
        await _notificationService.init(shouldRequestPermissions: false);
        await _notificationService.showDayFailedNotification(day);
        developer.log('Failure notification sent for Day $day');
      } else {
        developer.log('Day $day is already marked as completed or failed.');
      }
    } else {
      try {
        await _notificationService.init(shouldRequestPermissions: false);
        await _notificationService.showWorkoutAlarmNotification(alarmId, alarmLabel);
      } catch (e) {
        developer.log('Error in alarmCallback for workout alarmId $alarmId: $e');
      }
    }
  }

  /// Callback for "confidence booster" alarms.
  @pragma('vm:entry-point')
  static Future<void> confidenceBoosterCallback() async {
    WidgetsFlutterBinding.ensureInitialized();
    developer.log('NotificationsCallbackHandler.confidenceBoosterCallback triggered');

    final prefs = await SharedPreferences.getInstance();
    final currentDay = prefs.getInt('currentDay') ?? 1;
    int completedGoals = 0;

    if (prefs.getBool('day_${currentDay}_water_goal') ?? false) completedGoals++;
    if (prefs.getBool('day_${currentDay}_reading_goal') ?? false) completedGoals++;
    if (prefs.getBool('day_${currentDay}_diet_goal') ?? false) completedGoals++;
    if (prefs.getBool('day_${currentDay}_photo_goal') ?? false) completedGoals++;
    if (prefs.getBool('day_${currentDay}_inside_workout_goal') ?? false) completedGoals++;
    if (prefs.getBool('day_${currentDay}_outside_workout_goal') ?? false) completedGoals++;

    await _notificationService.init(shouldRequestPermissions: false);

    if (completedGoals == 0) {
      await _notificationService.showMotivationalNotification(
        201,
        "I see you have had a slow start, let's get some goals completed!",
      );
    } else if (completedGoals < 6) {
      await _notificationService.showMotivationalNotification(
        202,
        "You're doing well! You've completed $completedGoals of 6 so far. Keep going!",
      );
    } else {
      await _notificationService.showMotivationalNotification(
        203,
        "Well done! You've completed all your goals for today!",
      );
    }
  }
}
