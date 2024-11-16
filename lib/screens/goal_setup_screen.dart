import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../extras/drawer_menu.dart';
import '../alarm/alarm_page.dart';

class GoalSetupScreen extends StatefulWidget {
  final int day;
  static const String routeName = '/goalSetup';

  const GoalSetupScreen({super.key, required this.day});

  @override
  _GoalSetupScreenState createState() => _GoalSetupScreenState();
}

class _GoalSetupScreenState extends State<GoalSetupScreen> {
  List<bool> _goalsCompleted = List.filled(4, false);

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? savedGoals = prefs.getStringList('goals_day_${widget.day}');
    if (savedGoals != null && savedGoals.length == 4) {
      setState(() {
        _goalsCompleted = savedGoals.map((goal) => goal == 'true').toList();
      });
    } else {
      setState(() {
        _goalsCompleted = List.filled(4, false);
      });
    }
  }

  Future<void> _saveGoals() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> goalsToSave = _goalsCompleted.map((goal) => goal.toString()).toList();
    await prefs.setStringList('goals_day_${widget.day}', goalsToSave);
  }

  Future<void> _markGoalsCompleted() async {
    if (_goalsCompleted.every((goal) => goal)) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('day_${widget.day}_completed', true);
      Navigator.pop(context, true); // Return true to indicate success
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please complete all goals before marking as completed.',
            style: TextStyle(fontFamily: 'Gugi'),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white), // Hamburger icon in white
        title: Text(
          'Day ${widget.day} Goals',
          style: const TextStyle(
            color: Colors.blue,
            fontFamily: 'Gugi',
          ),
        ),
        backgroundColor: Colors.black,
      ),
      drawer: DrawerMenu(),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Set your goals for the 75 Hard Challenge',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Gugi',
            ),
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
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 60),
            ),
            onPressed: _goalsCompleted.every((goal) => goal) ? _markGoalsCompleted : null,
            child: const Text(
              'Goals Completed',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Gugi',
              ),
            ),
          ),
        ],
      ),
    );
  }

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
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Gugi',
                ),
              ),
            ),
          ],
        ),
        value: _goalsCompleted[index],
        onChanged: (bool? value) {
          setState(() {
            _goalsCompleted[index] = value ?? false;
          });
          _saveGoals();
        },
      ),
    );
  }
}
