// challenge_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../extras/progress_section.dart';
import '../utils/progress_utils.dart';
import '../utils/shared_preferences_helper.dart';
import '../extras/drawer_menu.dart';
import 'goal_setup_screen.dart';

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({Key? key});
  static const String routeName = '/challenge';

  @override
  _ChallengeScreenState createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  int _currentDay = 1;
  bool _showedRestartPrompt = false;
  DateTime? _startDate;
  int _daysCompleted = 0;
  int _daysFailed = 0;
  DateTime _currentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferencesHelper.prefs;

    String? startDateString = prefs.getString('startDate');
    if (startDateString != null) {
      _startDate = DateTime.parse(startDateString);
    } else {
      _startDate = DateTime.now();
      prefs.setString('startDate', _startDate!.toIso8601String());
    }

    _currentDay = _getCurrentDay();
    prefs.setInt('currentDay', _currentDay);
    _showedRestartPrompt =
        prefs.getBool('showedRestartPrompt') ?? false;
    await _checkForFailedDay();
    await _calculateProgress();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _calculateProgress() async {
    Map<String, dynamic> progressData =
    await ProgressUtils.calculateProgress(_currentDay);
    if (!mounted) return;
    setState(() {
      _daysCompleted = progressData['daysCompleted'];
      _daysFailed = progressData['daysFailed'];
      _currentDate = DateTime.now();
    });
  }

  int _getCurrentDay() {
    final now = DateTime.now();
    final difference = now.difference(_startDate!).inDays + 1;
    return difference.clamp(1, 75);
  }

  Future<void> _checkForFailedDay() async {
    if (!_showedRestartPrompt) {
      final prefs = await SharedPreferencesHelper.prefs;
      bool isCurrentDayCompleted =
          prefs.getBool('day_${_currentDay}_completed') ?? false;

      if (!isCurrentDayCompleted && _isCurrentDayOver()) {
        _showRestartPrompt();
      }
    }
  }

  bool _isCurrentDayOver() {
    final now = DateTime.now();
    final endOfDay = DateTime(
        now.year, now.month, now.day, 23, 59, 59);
    return now.isAfter(endOfDay);
  }

  Future<void> _resetChallenge() async {
    final prefs = await SharedPreferencesHelper.prefs;

    for (int day = 1; day <= 75; day++) {
      await prefs.remove('day_${day}_completed');
      await prefs.remove('goals_day_${day}');
    }

    await prefs.remove('startDate');
    await prefs.remove('showedRestartPrompt');
    await prefs.remove('currentDay');

    _startDate = DateTime.now();
    await prefs.setString('startDate',
        _startDate!.toIso8601String());

    await prefs.setBool('showedRestartPrompt', false);
    await prefs.setInt('currentDay', 1);
    if (!mounted) return;
    setState(() {
      _currentDay = 1;
      _showedRestartPrompt = false;
      _daysCompleted = 0;
      _daysFailed = 0;
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
            "You have failed the current day. Would you like to "
                "restart the challenge or continue?",
            style: TextStyle(fontSize: 16, fontFamily: 'Gugi'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Continue",
                style: TextStyle(fontFamily: 'Gugi'),
              ),
              onPressed: () async {
                final prefs =
                await SharedPreferencesHelper.prefs;
                await prefs.setBool('showedRestartPrompt', true);
                if (!mounted) return;
                setState(() {
                  _showedRestartPrompt = true;
                });
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red),
              child: const Text(
                "Restart",
                style: TextStyle(
                    color: Colors.white, fontFamily: 'Gugi'),
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
    final prefs = await SharedPreferencesHelper.prefs;
    Map<int, bool> progress = {};
    for (int day = 1; day <= 75; day++) {
      progress[day] =
          prefs.getBool('day_${day}_completed') ?? false;
    }
    return progress;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme:
        const IconThemeData(color: Colors.white),
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
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                  color: Colors.blue),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text(
                'Failed to load challenge progress',
                style: TextStyle(
                    color: Colors.white, fontFamily: 'Gugi'),
              ),
            );
          }

          final progress = snapshot.data!;

          return Column(
            children: [
              ProgressSection(
                currentDay: _currentDay,
                daysCompleted: _daysCompleted,
                daysFailed: _daysFailed,
                currentDate: _currentDate,
              ),
              const SizedBox(height: 10),
              Expanded(
                child: GridView.builder(
                  itemCount: 75,
                  padding: const EdgeInsets.all(10),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder:
                      (BuildContext context, int index) {
                    final day = index + 1;
                    Color dayColor;

                    if (day == _currentDay &&
                        progress[day] == true) {
                      dayColor = Colors.green;
                    } else if (day == _currentDay &&
                        progress[day] != true) {
                      dayColor = Colors.blue;
                    } else if (day < _currentDay &&
                        progress[day] == true) {
                      dayColor = Colors.green;
                    } else if (day < _currentDay &&
                        progress[day] == false) {
                      dayColor = Colors.red;
                    } else {
                      dayColor = Colors.grey.shade800;
                    }

                    return GestureDetector(
                      onTap: (day == _currentDay)
                          ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                GoalSetupScreen(day: day),
                          ),
                        ).then((result) {
                          if (result == true) {
                            _calculateProgress();
                            if (!mounted) return;
                            setState(() {});
                          }
                        });
                      }
                          : null,
                      child: Tooltip(
                        message: (day == _currentDay)
                            ? 'Go to Day $day'
                            : (day < _currentDay
                            ? 'Day $day (Past)'
                            : 'Day $day is locked'),
                        child: Container(
                          decoration: BoxDecoration(
                            color: dayColor,
                            borderRadius:
                            BorderRadius.circular(8),
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
