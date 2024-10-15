import 'package:flutter/material.dart';
import 'challenge_screen.dart'; // Import the challenge screen
import 'notification_service.dart'; // Import NotificationService

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NotificationService notificationService = NotificationService(); // Create an instance of NotificationService

  @override
  void initState() {
    super.initState();
    // Initialize the notification service
    notificationService.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('75 Hard Challenge'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChallengeScreen()),
                );
              },
              child: const Text('Start Challenge'),
            ),
            const SizedBox(height: 20), // Add some space between buttons
            ElevatedButton(
              onPressed: () async {
                // Show a basic notification for testing
                await notificationService.showBasicNotification(); // Call the method from NotificationService
              },
              child: const Text('Show Basic Notification'),
            ),
          ],
        ),
      ),
    );
  }
}


