import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/goal_setup_screen.dart';
import 'screens/challenge_screen.dart';
import 'screens/bulletin_board_screen.dart';
import 'screens/picture_library_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/weight_tracker_screen.dart';
import 'firebase/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

const String alarmTimeKey = 'alarm_time';
const String isolateName = 'isolate';
ReceivePort port = ReceivePort();
SharedPreferences? prefs;
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await _initializeFirebase();

  // Initialize timezone data
  tz.initializeTimeZones();

  // Initialize notification service
  await _initializeNotifications();

  // Initialize Android Alarm Manager
  await _initializeAlarmManager();

  // Register the isolate for background tasks
  _registerIsolate();

  // Initialize SharedPreferences
  prefs = await SharedPreferences.getInstance();

  // Check and request necessary permissions
  await _requestPermissions();

  runApp(const MyApp());
}

Future<void> _initializeFirebase() async {
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    print("Firebase initialized successfully.");
  } catch (e) {
    print("Error initializing Firebase: $e");
  }
}

Future<void> _initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  try {
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    print("Local Notifications initialized successfully.");
  } catch (e) {
    print("Error initializing notifications: $e");
  }
}

Future<void> _initializeAlarmManager() async {
  try {
    await AndroidAlarmManager.initialize();
    print("Android Alarm Manager initialized successfully.");
  } catch (e) {
    print("Error initializing Android Alarm Manager: $e");
  }
}

void _registerIsolate() {
  IsolateNameServer.removePortNameMapping(isolateName);
  IsolateNameServer.registerPortWithName(port.sendPort, isolateName);
  print("Isolate registered for background tasks.");
}

Future<void> _requestPermissions() async {
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }

  if (await Permission.scheduleExactAlarm.isDenied) {
    await Permission.scheduleExactAlarm.request();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '75 Hard Challenge',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: _getHomePage(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/goalSetup': (context) => const GoalSetupScreen(day: 1,),
        '/challenge': (context) => const ChallengeScreen(),
        '/bulletinBoard': (context) => const BulletinBoardScreen(),
        '/pictureLibrary': (context) => const PictureLibraryScreen(),
        '/profile': (context) =>  ProfileScreen(),
        '/weightTracker': (context) => const WeightTrackerScreen(),
      },
    );
  }

  // Determine initial screen based on user login status
  Widget _getHomePage() {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          // User is logged in, navigate to HomeScreen
          return const HomeScreen();
        } else {
          // User is not logged in, navigate to LoginScreen
          return const LoginScreen();
        }
      },
    );
  }
}
