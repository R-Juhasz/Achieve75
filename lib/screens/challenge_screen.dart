import 'package:flutter/material.dart';
import '../extras/drawer_menu.dart';
import 'goal_setup_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key});
  static const String routeName = '/challenge';

  @override
  _ChallengeScreenState createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  int _currentDay = 1;
  bool _showedRestartPrompt = false;

  @override
  void initState() {
    super.initState();
    _currentDay = _getCurrentDay();
    _checkForFailedDays(); // Check if any day has failed on startup
  }

  // Get current day based on the date
  int _getCurrentDay() {
    final now = DateTime.now();
    final startDate = DateTime(2024, 11, 1); // Adjust as needed
    final difference = now.difference(startDate).inDays + 1;
    return difference.clamp(1, 75); // Ensure it stays within day 1 to 75
  }

  // Check if a specific day is completed
  Future<bool> _isDayCompleted(int day) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('day_${day}_completed') ?? false;
  }

  // Reset all progress if the user chooses to restart
  Future<void> _resetChallenge() async {
    final prefs = await SharedPreferences.getInstance();
    for (int day = 1; day <= 75; day++) {
      await prefs.remove('day_${day}_completed');
    }
    setState(() {
      _currentDay = 1;
      _showedRestartPrompt = false; // Reset the prompt tracker
    });
  }

  // Show the restart prompt dialog once if a day has failed
  void _showRestartPrompt() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Restart Challenge"),
          content: const Text(
              "You have failed a day. Would you like to restart the challenge or continue?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Continue"),
              onPressed: () {
                setState(() {
                  _showedRestartPrompt = true; // Prevent showing the prompt again
                });
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Restart"),
              onPressed: () async {
                await _resetChallenge();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Check for failed days and show prompt if needed
  Future<void> _checkForFailedDays() async {
    final prefs = await SharedPreferences.getInstance();
    for (int day = 1; day < _currentDay; day++) {
      bool isCompleted = prefs.getBool('day_${day}_completed') ?? true;
      if (!isCompleted && !_showedRestartPrompt) {
        _showRestartPrompt();
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Achieve75', style: TextStyle(color: Colors.blue)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      drawer: DrawerMenu(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          itemCount: 75,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (BuildContext context, int index) {
            final day = index + 1;

            return FutureBuilder<bool>(
              future: _isDayCompleted(day),
              builder: (context, snapshot) {
                Color dayColor = Colors.blue; // Default to blue for all days

                if (snapshot.connectionState == ConnectionState.done && snapshot.data == true) {
                  dayColor = Colors.green; // Set to green only if the day is completed
                }

                return GestureDetector(
                  onTap: (day <= _currentDay)
                      ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GoalSetupScreen(day: day),
                      ),
                    ).then((_) {
                      // Reload current day after returning
                      setState(() {});
                    });
                  }
                      : null, // Disable tap for days beyond the current day
                  child: Container(
                    decoration: BoxDecoration(
                      color: dayColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        'Day $day',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
