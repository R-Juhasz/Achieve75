import 'package:flutter/material.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

import '../extras/progress_section.dart';
import '../extras/drawer_menu.dart';
import '../styles/styles.dart';
import '../utils/preferences_helper.dart';
import 'goal_setup_screen.dart';
import '../main.dart'; // Import alarmCallback

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key});
  static const String routeName = '/challenge';

  @override
  _ChallengeScreenState createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  int _currentDay = 1;
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
    final prefs = await SharedPreferences.getInstance();

    String? startDateString = prefs.getString('startDate');
    if (startDateString != null) {
      _startDate = DateTime.parse(startDateString);
    } else {
      _startDate = DateTime.now();
      await prefs.setString('startDate', _startDate!.toIso8601String());
    }

    _currentDay = _getCurrentDay();
    await prefs.setInt('currentDay', _currentDay);
    await _calculateProgress();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _calculateProgress() async {
    final prefs = await SharedPreferences.getInstance();
    int completed = 0;
    int failed = 0;

    for (int day = 1; day <= _currentDay; day++) {
      if (prefs.getBool(PreferencesHelper.completedKey(day)) == true) {
        completed++;
      } else if (prefs.getBool(PreferencesHelper.failedKey(day)) == true) {
        failed++;
      }
    }

    if (!mounted) return;
    setState(() {
      _daysCompleted = completed;
      _daysFailed = failed;
      _currentDate = DateTime.now();
    });
  }

  int _getCurrentDay() {
    final now = DateTime.now();
    final difference = now.difference(_startDate!).inDays + 1;
    return difference.clamp(1, 75);
  }

  Future<Map<int, String>> _loadChallengeProgress() async {
    final prefs = await SharedPreferences.getInstance();
    Map<int, String> progress = {};
    for (int day = 1; day <= 75; day++) {
      if (prefs.getBool(PreferencesHelper.completedKey(day)) == true) {
        progress[day] = 'completed';
      } else if (prefs.getBool(PreferencesHelper.failedKey(day)) == true) {
        progress[day] = 'failed';
      } else {
        progress[day] = 'pending';
      }
    }
    return progress;
  }

  Future<void> _scheduleDailyAlarm() async {
    final prefs = await SharedPreferences.getInstance();


    // Unique alarmId for each day to prevent duplicates
    final int alarmId = 1000 + _currentDay;

    // Cancel existing alarm for the day to avoid duplicates
    bool canceled = await AndroidAlarmManager.cancel(alarmId);
    developer.log(canceled
        ? 'Canceled existing alarm for Day $_currentDay with alarmId $alarmId'
        : 'No existing alarm found for Day $_currentDay with alarmId $alarmId');

    // Schedule the alarm
    bool scheduled = await AndroidAlarmManager.oneShot(
      initialDelay,
      alarmId,
      alarmCallback, // Top-level function in main.dart
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );

    if (scheduled) {
      developer.log(
    } else {
    }

    // Set the alarm label to 'end_of_day' in SharedPreferences
    await prefs.setString('alarm_label_$alarmId', 'end_of_day');
    developer.log('Set alarm_label_$alarmId to end_of_day');
  }

  // Function to reset the challenge (can be called from dialogs)
  Future<void> _resetChallenge() async {
    final prefs = await SharedPreferences.getInstance();

    // Remove all saved days' progress
    for (int day = 1; day <= 75; day++) {
      await prefs.remove(PreferencesHelper.completedKey(day));
      await prefs.remove(PreferencesHelper.failedKey(day));
      // Remove other keys if necessary
    }

    // Reset the start date to now
    _startDate = DateTime.now();
    await prefs.setString('startDate', _startDate!.toIso8601String());

    // Reset the current day to 1
    _currentDay = _getCurrentDay();
    await prefs.setInt('currentDay', _currentDay);

    // Reset days completed and failed
    _daysCompleted = 0;
    _daysFailed = 0;

    // Cancel any scheduled alarms
    await _cancelAllAlarms();

    // Remove alarm-related SharedPreferences keys
    for (int alarmId = 1001; alarmId <= 1075; alarmId++) {
      await prefs.remove('alarm_label_$alarmId');
    }

    // Show confirmation to the user
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Challenge has been reset.",
          style: AppTextStyles.body.copyWith(color: AppColors.background),
        ),
        backgroundColor: AppColors.primary,
      ),
    );

    // Reload state and reschedule the alarm
    await _loadState();
  }

  // Function to cancel all alarms (used during reset)
  Future<void> _cancelAllAlarms() async {
    // Assuming alarmIds are 1001 to 1075 for days 1 to 75
    for (int day = 1; day <= 75; day++) {
      int alarmId = 1000 + day;
      bool canceled = await AndroidAlarmManager.cancel(alarmId);
      if (canceled) {
        developer.log('Canceled alarm for Day $day');
      } else {
        developer.log('No alarm found to cancel for Day $day');
      }
    }
  }

  // Optional: Function to manually trigger the alarm for testing
  Future<void> _manualTriggerAlarm() async {
    final int alarmId = 1000 + _currentDay;
    developer.log('Manually triggering alarmCallback for alarmId $alarmId');
    await alarmCallback(alarmId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColors.text),
        title: Image.asset(
          'assets/images/achieve75-high-resolution-logo-transparent.png',
          height: 40,
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.primary),
            onPressed: _resetChallenge,
          ),
          IconButton(
            icon: Icon(Icons.alarm, color: AppColors.primary),
            onPressed: _manualTriggerAlarm, // For testing purposes
          ),
        ],
      ),
      drawer: DrawerMenu(),
      body: FutureBuilder<Map<int, String>>(
        future: _loadChallengeProgress(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (!snapshot.hasData) {
            return Center(
              child: Text(
                'Failed to load challenge progress',
                style: AppTextStyles.body,
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
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    final day = index + 1;
                    Color dayColor;

                    if (day < _currentDay) {
                      // Past days
                      if (progress[day] == 'completed') {
                        dayColor = Colors.green;
                      } else if (progress[day] == 'failed') {
                        dayColor = Colors.red;
                      } else {
                        dayColor = Colors.grey;
                      }
                    } else if (day == _currentDay) {
                      // Current day
                      if (progress[day] == 'completed') {
                        dayColor = Colors.green;
                      } else if (progress[day] == 'failed') {
                        dayColor = Colors.red;
                      } else {
                        dayColor = Colors.yellow;
                      }
                    } else {
                      // Future days
                      dayColor = Colors.grey;
                    }

                    return GestureDetector(
                      onTap: (day <= _currentDay)
                          ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GoalSetupScreen(day: day),
                          ),
                        ).then((result) async {
                          if (result == true || result == false) {
                            await _calculateProgress();
                            if (!mounted) return;
                            setState(() {});
                          }
                        });
                      }
                          : null,
                      child: Container(
                        decoration: BoxDecoration(
                          color: dayColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'Day $day',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.text,
                              fontSize: 18,
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
