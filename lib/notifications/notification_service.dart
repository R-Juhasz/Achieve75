import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Initialize the notification service
  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: null,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );

    tz.initializeTimeZones();

    await createNotificationChannel();
  }

  Future<void> createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'alarm_channel_id',
      'Alarm Notifications',
      description: 'Your alarm channel for notifications',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('alarm_sound'),
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

  void onDidReceiveNotificationResponse(NotificationResponse response) {
    print("Notification tapped: ${response.payload}");
  }
}
