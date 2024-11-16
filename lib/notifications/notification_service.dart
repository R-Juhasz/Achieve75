import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  // Singleton pattern
  static final NotificationService _notificationService =
  NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Initialize the notification service
  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );

    tz.initializeTimeZones();

    await _createNotificationChannels();
  }

  Future<void> _createNotificationChannels() async {
    // Main Notification Channel
    const AndroidNotificationChannel mainChannel = AndroidNotificationChannel(
      'main_channel_id',
      'Main Notifications',
      description: 'Channel for main notifications',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
    );

    // Create the channel on the device
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(mainChannel);

    // Additional channels can be created here
  }

  Future<void> requestPermissions() async {
    final status = await Permission.notification.request();

    if (status.isGranted) {
      print("Notification permissions granted.");
    } else {
      print("Notification permissions denied.");
    }
  }

  void onDidReceiveNotificationResponse(NotificationResponse response) {
    print("Notification tapped: ${response.payload}");
    // Handle notification tap event here
  }

// Existing notification methods can be added here
}
