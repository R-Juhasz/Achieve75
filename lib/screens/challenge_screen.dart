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
  DateTime? _startDate;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();

    // Load or initialize the start date
    String? startDateString = prefs.getString('startDate');
    if (startDateString != null) {
      _startDate = DateTime.parse(startDateString);
    } else {
      _startDate = DateTime.now();
      await prefs.setString('startDate', _startDate!.toIso8601String());
    }

    _currentDay = _getCurrentDay();
    await prefs.setInt('currentDay', _currentDay); // Save the current day
    _showedRestartPrompt = prefs.getBool('showedRestartPrompt') ?? false;
    await _checkForFailedDay(); // Only check for the current day
    setState(() {}); // Update state to reflect loaded values
  }

  int _getCurrentDay() {
    final now = DateTime.now();
    final difference = now.difference(_startDate!).inDays + 1;
    return difference.clamp(1, 75);
  }

  Future<void> _checkForFailedDay() async {
    if (!_showedRestartPrompt) {
      final prefs = await SharedPreferences.getInstance();
      bool isCurrentDayCompleted =
          prefs.getBool('day_${_currentDay}_completed') ?? false;

      if (!isCurrentDayCompleted && _isCurrentDayOver()) {
        _showRestartPrompt();
      }
    }
  }

  bool _isCurrentDayOver() {
    final now = DateTime.now();
    // Assuming the day ends at midnight
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return now.isAfter(endOfDay);
  }

  Future<void> _resetChallenge() async {
    final prefs = await SharedPreferences.getInstance();

    // Clear all day-specific data (goals and completion status)
    for (int day = 1; day <= 75; day++) {
      await prefs.remove('day_${day}_completed');
      await prefs.remove('goals_day_${day}');
    }

    // Clear other data
    await prefs.remove('startDate');
    await prefs.remove('showedRestartPrompt');
    await prefs.remove('currentDay');

    // Reset the start date to the current day
    _startDate = DateTime.now();
    await prefs.setString('startDate', _startDate!.toIso8601String());

    await prefs.setBool('showedRestartPrompt', false); // Reset the restart prompt flag
    await prefs.setInt('currentDay', 1); // Reset current day to day 1
    setState(() {
      _currentDay = 1;
      _showedRestartPrompt = false;
    });
  }

  void _showRestartPrompt() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Restart Challenge",
            style: TextStyle(fontFamily: 'Gugi'),
          ),
          content: const Text(
            "You have failed the current day. Would you like to restart the challenge or continue?",
            style: TextStyle(fontSize: 16, fontFamily: 'Gugi'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Continue",
                style: TextStyle(fontFamily: 'Gugi'),
              ),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('showedRestartPrompt', true);
                setState(() {
                  _showedRestartPrompt = true;
                });
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                "Restart",
                style: TextStyle(color: Colors.white, fontFamily: 'Gugi'),
              ),
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

  Future<Map<int, bool>> _loadChallengeProgress() async {
    final prefs = await SharedPreferences.getInstance();
    Map<int, bool> progress = {};
    for (int day = 1; day <= 75; day++) {
      progress[day] = prefs.getBool('day_${day}_completed') ?? false;
    }
    return progress;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white), // Hamburger icon in white
        title: Image.asset(
          'assets/images/achieve75-high-resolution-logo-transparent.png',
          height: 40,
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      drawer: DrawerMenu(),
      body: FutureBuilder<Map<int, bool>>(
        future: _loadChallengeProgress(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text(
                'Failed to load challenge progress',
                style: TextStyle(color: Colors.white, fontFamily: 'Gugi'),
              ),
            );
          }

          final progress = snapshot.data!;

          return GridView.builder(
            itemCount: 75,
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (BuildContext context, int index) {
              final day = index + 1;
              Color dayColor;

              // Determine the color of each day
              if (day == _currentDay && progress[day] == true) {
                dayColor = Colors.green; // Current day completed
              } else if (day == _currentDay && progress[day] != true) {
                dayColor = Colors.blue; // Current day not completed
              } else if (day < _currentDay && progress[day] == true) {
                dayColor = Colors.green; // Past day completed
              } else if (day < _currentDay && progress[day] == false) {
                dayColor = Colors.red; // Past day not completed
              } else {
                dayColor = Colors.grey.shade800; // Future days
              }

              return GestureDetector(
                onTap: (day == _currentDay)
                    ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GoalSetupScreen(day: day),
                    ),
                  ).then((result) {
                    if (result == true) {
                      setState(() {}); // Reload state if goals are completed
                    }
                  });
                }
                    : null, // Disable tap for other days
                child: Tooltip(
                  message: (day == _currentDay)
                      ? 'Go to Day $day'
                      : (day < _currentDay
                      ? 'Day $day (Past)'
                      : 'Day $day is locked'),
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
                          fontFamily: 'Gugi',
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
