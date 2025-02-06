import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:permission_handler/permission_handler.dart';

import 'firebase/firebase_options.dart';
import 'notifications/notifications_callback_handler.dart';
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

/// ✅ **Request Exact Alarm Permission (Android 12+)**
Future<void> requestExactAlarmPermission() async {
  if (await Permission.scheduleExactAlarm.isDenied) {
    final intent = AndroidIntent(
      action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
      package: 'com.juhaszstudios.achieve75', // Ensure this matches your app package
    );
    await intent.launch();
  }
}

/// ✅ **Alarm Callback Function**
@pragma('vm:entry-point')
Future<void> alarmCallback(int alarmId) async {
  // Ensure Flutter bindings are initialized in background
  WidgetsFlutterBinding.ensureInitialized();
  developer.log('alarmCallback triggered with alarmId: $alarmId');
  await NotificationsCallbackHandler.alarmCallback(alarmId);
}

/// ✅ **Main Function**
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  developer.log('Initializing application');

  // Request exact alarm permission for Android 12+
  await requestExactAlarmPermission();

  // Initialize Time Zones
  initializeTimeZones();

  // Initialize Android Alarm Manager
  await AndroidAlarmManager.initialize();

  // ✅ Initialize Firebase asynchronously without blocking UI
  runApp(
    FutureBuilder(
      future: Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
              home: Scaffold(body: Center(child: CircularProgressIndicator())));
        }
        if (snapshot.hasError) {
          return MaterialApp(
              home: Scaffold(body: Center(child: Text("Firebase Init Error!"))));
        }
        return const MyApp();
      },
    ),
  );
}

/// ✅ **Main Application Widget**
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MyAuthProvider>(create: (_) => MyAuthProvider()),
        ChangeNotifierProvider<PostProvider>(create: (_) => PostProvider()),
        ChangeNotifierProvider<WaterTrackerProvider>(
          create: (context) {
            final authProvider = Provider.of<MyAuthProvider>(context, listen: false);
            return WaterTrackerProvider(userId: authProvider.userId ?? '');
          },
        ),
        ChangeNotifierProvider<DietProvider>(create: (_) => DietProvider()),
      ],
      child: MaterialApp(
        title: 'Achieve75',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: AppColors.background,
          textTheme: const TextTheme(bodyMedium: TextStyle(color: AppColors.text)),
        ),
        home: const AuthHandler(),
        routes: {
          WaterTrackerScreen.routeName: (_) => const WaterTrackerScreen(),
          LoginScreen.routeName: (_) => const LoginScreen(),
          HomeScreen.routeName: (_) => const HomeScreen(),
          ChallengeScreen.routeName: (_) => const ChallengeScreen(),
          BulletinBoardScreen.routeName: (_) => const BulletinBoardScreen(),
          PictureLibraryScreen.routeName: (_) => const PictureLibraryScreen(),
          ProfileScreen.routeName: (_) => const ProfileScreen(),
          WeightTrackerScreen.routeName: (_) => const WeightTrackerScreen(),
          GoalSetupScreen.routeName: (_) => GoalSetupScreen(day: 1),
          WorkoutsScreen.routeName: (_) => const WorkoutsScreen(),
          DietScreen.routeName: (_) => DietScreen(),
        },
      ),
    );
  }
}

/// ✅ **Authentication Handler Widget**
class AuthHandler extends StatelessWidget {
  const AuthHandler({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<MyAuthProvider>(context);

    return StreamBuilder<User?>(
      stream: authProvider.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          return const HomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
