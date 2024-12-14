// lib/notifications/notifications.dart

import 'dart:developer' as developer;
import 'dart:typed_data'; // For vibration pattern
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart'; // Ensure time zones are initialized
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/preferences_helper.dart';
import 'package:flutter/material.dart';

class NotificationService {
  // Singleton instance
  static final NotificationService _notificationService = NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> init({bool requestPermissions = false}) async {
    // Initialize time zones
    initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      // iOS: InitializationSettings for iOS if needed
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: selectNotification,
    );

    await _createNotificationChannels();

    if (requestPermissions) {
      await this.requestPermissions();
    }
  }

  Future<void> _createNotificationChannels() async {
    const AndroidNotificationChannel mainChannel = AndroidNotificationChannel(
      'main_channel_id',
      'Main Notifications',
      description: 'Channel for main notifications',
      importance: Importance.max,
    );

    const AndroidNotificationChannel alarmChannel = AndroidNotificationChannel(
      'alarm_channel_id',
      'Alarm Notifications',
      description: 'Channel for alarm notifications',
      importance: Importance.high,
    );

    const AndroidNotificationChannel dayFailedChannel = AndroidNotificationChannel(
      'day_failed_channel_id',
      'Day Failed Notifications',
      description: 'Channel for day failed notifications',
      importance: Importance.max,
    );

    // Create the notification channels
    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(mainChannel);
      await androidPlugin.createNotificationChannel(alarmChannel);
      await androidPlugin.createNotificationChannel(dayFailedChannel);
    }
  }

  Future<void> requestPermissions() async {
    final status = await Permission.notification.request();

    if (status.isGranted) {
      developer.log("Notification permissions granted.");
    } else {
      developer.log("Notification permissions denied.");
      // Optionally, prompt the user to enable permissions in app settings
    }
  }

  Future<void> showImmediateTestNotification() async {
    try {
      await flutterLocalNotificationsPlugin.show(
        999, // Unique Notification ID
        'Test Notification',
        'This is a test notification to verify functionality.',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'main_channel_id',
            'Main Notifications',
            channelDescription: 'Channel for main notifications',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
      developer.log('Displayed immediate test notification with ID 999');
    } catch (e) {
      developer.log('Error displaying immediate test notification: $e');
    }
  }

  Future<void> showDayFailedNotification(int day) async {
    await flutterLocalNotificationsPlugin.show(
      0, // Unique Notification ID
      'Day $day Failed',
      'You have failed to complete Day $day. Reset the challenge or continue.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'day_failed_channel_id',
          'Day Failed Notifications',
          channelDescription: 'Channel for day failed notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
    developer.log('Displayed Day $day Failed notification with ID 0');
  }

  Future<void> showMotivationalNotification(int id, String message) async {
    await flutterLocalNotificationsPlugin.show(
      id, // Unique Notification ID
      'Motivation Reminder',
      message,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'main_channel_id',
          'Main Notifications',
          channelDescription: 'Channel for main notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
    developer.log('Displayed Motivational notification with ID $id');
  }

  Future<void> showIncompleteGoalsNotification(int day) async {
    await flutterLocalNotificationsPlugin.show(
      101, // Unique Notification ID
      'Incomplete Goals',
      'You still have goals to complete today. Stay strong and finish strong!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'main_channel_id',
          'Main Notifications',
          channelDescription: 'Channel for main notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
    developer.log('Displayed Incomplete Goals notification for Day $day with ID 101');
  }

  Future<void> showWorkoutAlarmNotification(int alarmId, String alarmLabel) async {
    await flutterLocalNotificationsPlugin.show(
      alarmId, // Unique Notification ID based on alarmId
      'Alarm: $alarmLabel',
      "It's time for your $alarmLabel!",
      NotificationDetails(
        android: AndroidNotificationDetails(
          'alarm_channel_id',
          'Alarm Notifications',
          channelDescription: 'Channel for alarm notifications',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          // sound: const RawResourceAndroidNotificationSound('alarm_sound'), // Uncomment if you have a custom sound
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
        ),
      ),
    );
    developer.log('Displayed Workout Alarm notification for alarmId: $alarmId');
  }

  Future<void> selectNotification(NotificationResponse response) async {
    // Handle notification tapped logic here
    developer.log('Notification with payload ${response.payload} tapped.');
  }
}

// NotificationReminders Class
class NotificationReminders {
  final NotificationService _notificationService = NotificationService();

  // List of motivational messages
  final List<String> _messages = [
    "Keep up the good work!",
    "Stay focused on your goals!",
    "You're doing great!",
    "Don't give up!",
    "Believe in yourself!",
    "Keep pushing forward!",
  ];

  // Initialize reminders
  Future<void> initReminders() async {
    // No need to request permissions here; it should be done in main()
    await _notificationService.init();
    await scheduleDailyNotifications();
    await _scheduleIncompleteGoalCheck(); // Call the method here
  }

  // Expose the immediate test notification
  Future<void> showImmediateTestNotification() async {
    await _notificationService.showImmediateTestNotification();
  }

  // Schedule notifications every two hours
  Future<void> scheduleDailyNotifications() async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    // Define the hours at which notifications should be sent
    List<int> notificationHours = [
      8, 10, 12, 14, 16, 18, 20, 22
    ]; // Every 2 hours from 8 AM to 10 PM

    int notificationId = 1; // Start IDs from 1

    for (int hour in notificationHours) {
      tz.TZDateTime scheduledTime = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour);

      // If the scheduled time is before now, schedule for the next day
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      await _scheduleMotivationalNotification(
        _messages[notificationId % _messages.length],
        scheduledTime,
        notificationId,
      );
      developer.log(
          'Scheduled motivational notification "${_messages[notificationId % _messages.length]}" at ${scheduledTime.toLocal()} with ID $notificationId');
      notificationId++;
    }
  }

  // Schedule motivational notifications
  Future<void> _scheduleMotivationalNotification(
      String message, tz.TZDateTime scheduledTime, int id) async {
    try {
      await _notificationService.flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        'Motivation Reminder',
        message,
        scheduledTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'main_channel_id',
            'Main Notifications',
            channelDescription: 'Channel for main notifications',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents:
        DateTimeComponents.time, // Repeat daily at the same time
      );
      developer.log('Scheduled motivational notification with ID $id');
    } catch (e, stackTrace) {
      developer.log('Error scheduling notification: $e',
          error: e, stackTrace: stackTrace);
    }
  }

  // Schedule nightly checks for incomplete goals
  Future<void> _scheduleIncompleteGoalCheck() async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledTime =
    tz.TZDateTime(tz.local, now.year, now.month, now.day, 23, 0, 0); // 11:00 PM

    if (scheduledTime.isBefore(now)) {
      // Schedule for the next day
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    try {
      await _notificationService.flutterLocalNotificationsPlugin.zonedSchedule(
        100, // Unique ID for this notification
        'Daily Goal Check',
        'Have you completed all your goals today? Don’t give up now!',
        scheduledTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'main_channel_id',
            'Main Notifications',
            channelDescription: 'Channel for main notifications',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents:
        DateTimeComponents.time, // Repeat daily at the same time
      );
      developer.log(
          'Scheduled daily goal check notification at ${scheduledTime.toLocal()} with ID 100');
    } catch (e, stackTrace) {
      developer.log('Error scheduling daily goal check notification: $e',
          error: e, stackTrace: stackTrace);
    }
  }

  // Check incomplete goals and notify the user
  Future<void> checkIncompleteGoals() async {
    final prefs = await SharedPreferences.getInstance();

    // Retrieve the current day
    final int currentDay = prefs.getInt('currentDay') ?? 1;

    // Check if the goals for the current day are completed
    bool goalsCompleted = prefs.getBool(PreferencesHelper.completedKey(currentDay)) ?? false;

    if (!goalsCompleted) {
      await _notificationService.showIncompleteGoalsNotification(currentDay);
    } else {
      developer.log(
          'All goals completed for Day $currentDay. No incomplete goals notification displayed.');
    }
  }
}

// NotificationsCallbackHandler Class
class NotificationsCallbackHandler {
  static final NotificationService _notificationService = NotificationService();

  static Future<void> alarmCallback(int alarmId) async {
    // Ensure bindings are initialized
    WidgetsFlutterBinding.ensureInitialized();
    developer.log('alarmCallback triggered with alarmId: $alarmId');

    final prefs = await SharedPreferences.getInstance();
    final alarmLabel = prefs.getString('alarm_label_$alarmId') ?? 'Workout';
    developer.log('Alarm label for alarmId $alarmId: $alarmLabel');

    if (alarmLabel == 'end_of_day') {
      // Handle end-of-day alarm
      developer.log('Handling end-of-day alarm for alarmId: $alarmId');

      // Corrected day calculation
      final int day = alarmId - 1000;
      developer.log('Derived day number from alarmId: $day');

      if (day < 1 || day > 75) {
        developer.log('Invalid day number derived from alarmId: $day');
        return;
      }

      final bool isCompleted = prefs.getBool(PreferencesHelper.completedKey(day)) ?? false;
      final bool isFailed = prefs.getBool(PreferencesHelper.failedKey(day)) ?? false;
      developer.log('Day $day - Completed: $isCompleted, Failed: $isFailed');

      if (!isCompleted && !isFailed) {
        // Mark the day as failed
        await prefs.setBool(PreferencesHelper.failedKey(day), true);
        developer.log('Day $day marked as failed.');

        // Initialize NotificationService without requesting permissions
        await _notificationService.init(requestPermissions: false);

        // Send a notification to the user
        await _notificationService.showDayFailedNotification(day);
        developer.log('Failure notification sent for Day $day');
      } else {
        developer.log('Day $day is already marked as completed or failed.');
      }
    } else {
      // Handle workout alarms
      developer.log('Handling workout alarm with label: $alarmLabel');

      try {
        // Initialize NotificationService without requesting permissions
        await _notificationService.init(requestPermissions: false);

        await _notificationService.showWorkoutAlarmNotification(alarmId, alarmLabel);
      } catch (e) {
        developer.log('Error in alarmCallback for workout alarmId $alarmId: $e');
      }
    }
  }
}





