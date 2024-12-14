// lib/main.dart

import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase/firebase_options.dart';
import 'notifications/notification_service.dart'; // Import NotificationService
import 'providers/auth_provider.dart';
import 'providers/post_provider.dart';
import 'providers/water_tracker_provider.dart';
import 'providers/diet_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/challenge_screen.dart';
import 'screens/bulletin_board_screen.dart';
import 'screens/picture_library_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/water_tracker_screen.dart';
import 'screens/weight_tracker_screen.dart';
import 'screens/workouts_screen.dart';
import 'screens/goal_setup_screen.dart';
import 'screens/diet_screen.dart';
import 'styles/styles.dart';

@pragma('vm:entry-point')
Future<void> alarmCallback(int alarmId) async {
  developer.log('alarmCallback triggered with alarmId: $alarmId');
  await NotificationsCallbackHandler.alarmCallback(alarmId);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  developer.log('Initializing application');

  // Initialize Time Zones
  initializeTimeZones();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Android Alarm Manager
  await AndroidAlarmManager.initialize();

  // Initialize Notification Service and request permissions
  final notificationService = NotificationService();
  await notificationService.init(requestPermissions: true);

  // Initialize Notification Reminders
  final notificationReminders = NotificationReminders();
  await notificationReminders.initReminders();

  // Display immediate test notification using the new method
  await notificationReminders.showImmediateTestNotification();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<MyAuthProvider>(create: (_) => MyAuthProvider()),
        ChangeNotifierProvider<PostProvider>(create: (_) => PostProvider()),
        ChangeNotifierProvider<WaterTrackerProvider>(
          create: (context) => WaterTrackerProvider(
            userId: context.read<MyAuthProvider>().userId ?? '',
          ),
        ),
        ChangeNotifierProvider<DietProvider>(
          create: (_) => DietProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Achieve75',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: AppColors.background,
        textTheme: const TextTheme(bodyMedium: TextStyle(color: AppColors.text)),
      ),
      home: const AuthHandler(),
      routes: {
        WaterTrackerScreen.routeName: (context) => const WaterTrackerScreen(),
        LoginScreen.routeName: (context) => const LoginScreen(),
        HomeScreen.routeName: (context) => const HomeScreen(),
        ChallengeScreen.routeName: (context) => const ChallengeScreen(),
        BulletinBoardScreen.routeName: (context) => const BulletinBoardScreen(),
        PictureLibraryScreen.routeName: (context) => const PictureLibraryScreen(),
        ProfileScreen.routeName: (context) => const ProfileScreen(),
        WeightTrackerScreen.routeName: (context) => const WeightTrackerScreen(),
        GoalSetupScreen.routeName: (context) => GoalSetupScreen(day: 1),
        WorkoutsScreen.routeName: (context) => const WorkoutsScreen(),
        DietScreen.routeName: (context) => DietScreen(),
      },
    );
  }
}

class AuthHandler extends StatelessWidget {
  const AuthHandler({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<MyAuthProvider>(context);

    return StreamBuilder<User?>(
      stream: authProvider.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          return const HomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
