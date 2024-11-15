import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';

import '../alarm/alarm_page.dart';
import '../extras/drawer_menu.dart';
import 'weight_tracker_screen.dart';
import 'challenge_screen.dart';

class GoalSetupScreen extends StatefulWidget {
  final int day;
  static const String routeName = '/goalSetup';

  const GoalSetupScreen({super.key, required this.day});

  @override
  _GoalSetupScreenState createState() => _GoalSetupScreenState();
}

class _GoalSetupScreenState extends State<GoalSetupScreen> {
  final DateFormat timeFormat = DateFormat("hh:mm a");
  List<bool> _goalsCompleted = List.filled(4, false);
  final ImagePicker _picker = ImagePicker();
  static const String routeName = '/goalsetupscreen';

  @override
  void initState() {
    super.initState();
    _loadGoals(); // Load goals when the screen is initialized
  }

  Future<void> _loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    // Load the saved goals for the specific day
    List<String>? savedGoals = prefs.getStringList('goals_day_${widget.day}');
    if (savedGoals != null) {
      setState(() {
        _goalsCompleted = savedGoals.map((goal) => goal == 'true').toList();
      });
    }
  }

  Future<void> _saveGoals() async {
    final prefs = await SharedPreferences.getInstance();
    // Save the goals state for the specific day
    List<String> goalsToSave = _goalsCompleted.map((goal) => goal.toString()).toList();
    await prefs.setStringList('goals_day_${widget.day}', goalsToSave);
  }

  Future<void> _markGoalsCompleted() async {
    setState(() {
      _goalsCompleted = List.filled(4, true); // Mark all goals as completed
    });
    await _saveGoals();

    // Mark the day as completed in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('day_${widget.day}_completed', true);

    // Navigate back to the ChallengeScreen and update the day's color
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ChallengeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Day ${widget.day} Goals',
          style: const TextStyle(color: Colors.blue),
        ),
        backgroundColor: Colors.black,
      ),
      drawer: DrawerMenu(),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'Set your goals for the 75 Hard Challenge',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AlarmPage(alarmLabel: 'Workout 1'),
                ),
              );
            },
            child: const Text(
              'Set Workout 1 Alarm',
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AlarmPage(alarmLabel: 'Workout 2'),
                ),
              );
            },
            child: const Text(
              'Set Workout 2 Alarm',
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          _buildGoalTile(0, Icons.local_drink, 'Drink a gallon of water'),
          _buildGoalTile(1, Icons.book, 'Read 10 pages of a book'),
          _buildGoalTile(2, Icons.food_bank, 'Follow a diet (no cheat meals)'),
          _buildGoalTile(3, Icons.camera_alt, 'Take a progress picture'),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 60),
            ),
            onPressed: () async {
              await _saveGoals(); // Save goals when pressed
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WeightTrackerScreen(),
                ),
              );
            },
            child: const Text(
              'Track Weight',
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 60),
            ),
            onPressed: () async {
              await _saveGoals(); // Save goals when pressed
              Navigator.pop(context);
            },
            child: const Text(
              'Save Goals',
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green, // Completed goals button
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 60),
            ),
            onPressed: _markGoalsCompleted, // Mark all goals as completed
            child: const Text(
              'Goals Completed',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Build individual goal tiles
  Widget _buildGoalTile(int index, IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: _goalsCompleted[index] ? Colors.blue : Colors.white),
        borderRadius: BorderRadius.circular(10),
      ),
      child: CheckboxListTile(
        activeColor: Colors.blue,
        checkColor: Colors.black,
        title: Row(
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                title,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        value: _goalsCompleted[index],
        onChanged: (bool? value) {
          setState(() {
            _goalsCompleted[index] = value!;
          });
          _saveGoals(); // Save goals state on change
        },
      ),
    );
  }
}
