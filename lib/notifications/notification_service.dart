import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher'); // Default app icon

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: null, // Add iOS settings if necessary
    );

    // Initialize notification plugin
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );

    // Initialize timezone data
    tz.initializeTimeZones();

    // Create notification channel
    await createNotificationChannel();
  }

  Future<void> createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'channel_01', // Channel ID
      'channel_01', // Channel Name
      description: 'Your channel description',
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    print("Notification channel created!");
  }

  Future<void> requestPermissions() async {
    final status = await Permission.notification.request();
    final alarmStatus = await Permission.scheduleExactAlarm.request();

    print('Notification permission: ${status.isGranted}');
    print('Exact alarm permission: ${alarmStatus.isGranted}');

    if (!status.isGranted || !alarmStatus.isGranted) {
      print("Notification or Exact Alarm permissions denied.");
    } else {
      print("Notification and Exact Alarm permissions granted.");
    }
  }

  // Handle notification click
  void onDidReceiveNotificationResponse(NotificationResponse notificationResponse) {
    final String? payload = notificationResponse.payload;
    if (payload != null) {
      print('Notification payload: $payload');
      // Handle the notification tap action here
    } else {
      print("Notification tapped with no payload.");
    }
  }

  // Basic notification for testing with a 10-second delay
  Future<void> showBasicNotification() async {
    await requestPermissions(); // Ensure permissions are granted

    // Add a delay of 10 seconds
    await Future.delayed(const Duration(seconds: 10));

    var androidDetails = AndroidNotificationDetails(
      'channel_01',
      'channel_01', // Ensure this matches
      importance: Importance.max,
      priority: Priority.high,
      playSound: true, // Play sound
    );

    var platformDetails = NotificationDetails(android: androidDetails);

    try {
      await flutterLocalNotificationsPlugin.show(
        0, // Notification ID
        'Basic Test Notification',
        'This notification appears after a 10-second delay!',
        platformDetails,
      );
      print("Basic notification shown after 10 seconds delay!");
    } catch (e) {
      print("Error showing notification: $e");
    }
  }
}
