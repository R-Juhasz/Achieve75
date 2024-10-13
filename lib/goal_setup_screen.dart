import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GoalSetupScreen extends StatefulWidget {
  final int day;

  const GoalSetupScreen({super.key, required this.day});

  @override
  _GoalSetupScreenState createState() => _GoalSetupScreenState();
}

class _GoalSetupScreenState extends State<GoalSetupScreen> {
  final TextEditingController _firstWorkoutController = TextEditingController();
  final TextEditingController _secondWorkoutController = TextEditingController();
  final DateFormat timeFormat = DateFormat("hh:mm a");

  @override
  void dispose() {
    _firstWorkoutController.dispose();
    _secondWorkoutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set Goals for Day ${widget.day}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _firstWorkoutController,
              decoration: InputDecoration(labelText: 'First Workout Time'),
              readOnly: true,
              onTap: () async {
                TimeOfDay? time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time != null) {
                  String formattedTime = timeFormat.format(DateTime(0, 1, 1, time.hour, time.minute));
                  _firstWorkoutController.text = formattedTime;
                }
              },
            ),
            TextField(
              controller: _secondWorkoutController,
              decoration: InputDecoration(labelText: 'Second Workout Time'),
              readOnly: true,
              onTap: () async {
                TimeOfDay? time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time != null) {
                  String formattedTime = timeFormat.format(DateTime(0, 1, 1, time.hour, time.minute));
                  _secondWorkoutController.text = formattedTime;
                }
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add any actions you want to perform when saving goals
                Navigator.pop(context);
              },
              child: Text('Save Goals'),
            ),
          ],
        ),
      ),
    );
  }
}
