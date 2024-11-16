import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_service.dart';
import 'package:timezone/timezone.dart' as tz;

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
    // Add more messages as needed
  ];

  // Initialize reminders
  Future<void> initReminders() async {
    await _notificationService.init();
    await _notificationService.requestPermissions();
    await schedulePeriodicNotifications();
  }

  // Schedule periodic notifications every few hours
  Future<void> schedulePeriodicNotifications() async {
    // Cancel any existing scheduled notifications
    await _notificationService.flutterLocalNotificationsPlugin.cancelAll();

    // Schedule notifications at intervals
    for (int i = 0; i < _messages.length; i++) {
      Duration delay = Duration(hours: 3 * i); // Every 3 hours
      await _scheduleNotification(_messages[i], delay, i);
    }
  }

  Future<void> _scheduleNotification(String message, Duration delay, int id) async {
    tz.TZDateTime scheduledDate = tz.TZDateTime.now(tz.local).add(delay);

    await _notificationService.flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'Motivation',
      message,
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'main_channel_id',
          'Main Notifications',
          channelDescription: 'Channel for main notifications',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('notification_sound'),
        ),
      ),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      // Removed 'androidAllowWhileIdle'
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Added required parameter
    );
  }

// Additional methods to manage reminders can be added here
}
