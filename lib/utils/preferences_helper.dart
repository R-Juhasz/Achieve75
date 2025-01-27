// lib/utils/preferences_helper.dart

class PreferencesHelper {
  // Goal-related keys
  static String completedKey(int day) => 'day_${day}_completed';
  static String failedKey(int day) => 'day_${day}_failed';
  static String waterGoalKey(int day) => 'day_${day}_water_goal';
  static String readingGoalKey(int day) => 'day_${day}_reading_goal';
  static String dietGoalKey(int day) => 'day_${day}_diet_goal';
  static String photoGoalKey(int day) => 'day_${day}_photo_goal';
  static String insideWorkoutGoalKey(int day) => 'day_${day}_inside_workout_goal';
  static String outsideWorkoutGoalKey(int day) => 'day_${day}_outside_workout_goal';
  static String hasShownGoalMessageKey(int day) => 'day_${day}_has_shown_goal_message';

  // Alarm-related keys
  static String alarmLabelKey(int alarmId) => 'alarm_label_$alarmId';
  static String alarmHourKey(int alarmId) => 'alarm_hour_$alarmId';
  static String alarmMinuteKey(int alarmId) => 'alarm_minute_$alarmId';
}
