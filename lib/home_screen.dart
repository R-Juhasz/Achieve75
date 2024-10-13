import 'package:flutter/material.dart';
import 'challenge_screen.dart'; // Import the challenge screen
import 'main.dart'; // Import the main file to access scheduleTestNotification

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('75 Hard Challenge'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChallengeScreen()),
                );
              },
              child: Text('Start Challenge'),
            ),
            SizedBox(height: 20), // Add some space between buttons
            ElevatedButton(
              onPressed: () {
                // Call to schedule a test notification (update if necessary)
                // scheduleTestNotification();
              },
              child: Text('Schedule Test Notification'),
            ),
          ],
        ),
      ),
    );
  }
}
