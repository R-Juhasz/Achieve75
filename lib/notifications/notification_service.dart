import 'dart:developer' as developer;
import 'dart:typed_data'; // For vibration pattern
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart'; // Ensure time zones are initialized


class NotificationService {
  // Singleton instance
  static final NotificationService _notificationService = NotificationService._internal();

  factory NotificationService() => _notificationService;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  /// ✅ Updated parameter name: `shouldRequestPermissions` instead of `requestPermissions`
  Future<void> init({bool shouldRequestPermissions = false}) async {
    // Initialize time zones
    initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    // Initialize plugin
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: selectNotification,
    );

    // Create updated notification channels
    await _createNotificationChannels();

    if (shouldRequestPermissions) {
      // Correctly invoke the method
      await requestPermissions();
    }
  }

  /// ✅ Updated to force creation of a new alarm channel
  Future<void> _createNotificationChannels() async {
    // Main channel
    const AndroidNotificationChannel mainChannel = AndroidNotificationChannel(
      'main_channel_id',
      'Main Notifications',
      description: 'Channel for main notifications',
      importance: Importance.max,
    );

    // Use a **new channel ID** so we get fresh settings
    const AndroidNotificationChannel alarmChannel = AndroidNotificationChannel(
      'alarm_channel_new', // changed from 'alarm_channel_id'
      'Alarm Notifications',
      description: 'Channel for alarm notifications (new)',
      importance: Importance.high,
    );

    // Day-failed channel
    const AndroidNotificationChannel dayFailedChannel = AndroidNotificationChannel(
      'day_failed_channel_id',
      'Day Failed Notifications',
      description: 'Channel for day failed notifications',
      importance: Importance.max,
    );

    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      // Create (or re-create) channels
      await androidPlugin.createNotificationChannel(mainChannel);
      await androidPlugin.createNotificationChannel(alarmChannel);
      await androidPlugin.createNotificationChannel(dayFailedChannel);
    }
  }

  /// Request POST_NOTIFICATIONS permission (Android 13+) or normal notification permission otherwise
  Future<void> requestPermissions() async {
    final status = await Permission.notification.request();
    if (status.isGranted) {
      developer.log("Notification permissions granted.");
    } else {
      developer.log("Notification permissions denied.");
    }
  }

  /// Basic test notification
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

  /// Day-failed notification
  Future<void> showDayFailedNotification(int day) async {
    await flutterLocalNotificationsPlugin.show(
      0,
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

  /// Generic motivational reminder
  Future<void> showMotivationalNotification(int id, String message) async {
    await flutterLocalNotificationsPlugin.show(
      id,
      'Motivation Reminder',
      message,
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
    developer.log('Displayed Motivational notification with ID $id');
  }

  /// Nightly incomplete goals
  Future<void> showIncompleteGoalsNotification(int day) async {
    await flutterLocalNotificationsPlugin.show(
      101,
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

  /// The workout alarm notification with fullScreenIntent set to true
  Future<void> showWorkoutAlarmNotification(int alarmId, String alarmLabel) async {
    await flutterLocalNotificationsPlugin.show(
      alarmId,
      'Alarm: $alarmLabel',
      "It's time for your $alarmLabel!",
      NotificationDetails(
        android: AndroidNotificationDetails(
          'alarm_channel_new', // Must match the newly created channel ID
          'Alarm Notifications',
          channelDescription: 'Channel for alarm notifications (new)',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          fullScreenIntent: true,
          vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
        ),
      ),
    );
    developer.log('Displayed Workout Alarm notification for alarmId: $alarmId');
  }

  /// Called when user taps the notification
  Future<void> selectNotification(NotificationResponse response) async {
    developer.log('Notification with payload ${response.payload} tapped.');
  }
}
