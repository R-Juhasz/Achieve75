import 'package:flutter/material.dart';
import 'goal_setup_screen.dart';

class ChallengeScreen extends StatelessWidget {
  const ChallengeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set background color to black
      appBar: AppBar(
        title: const Text('75-Day Challenge', style: TextStyle(color: Colors.blue)), // Title color
        backgroundColor: Colors.black, // App bar color
        elevation: 0, // Remove elevation
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7, // 7 days in a week for the calendar format
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemCount: 75, // 75 days challenge
          itemBuilder: (context, index) {
            final day = index + 1;
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GoalSetupScreen(day: day),
                  ),
                );
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.blue, // Set card color to blue
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade800, // Add shadow for better visibility
                      blurRadius: 4.0,
                      offset: Offset(0, 2), // Shadow position
                    ),
                  ],
                ),
                child: Text(
                  'Day $day',
                  style: const TextStyle(color: Colors.white, fontSize: 16), // Text color
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
