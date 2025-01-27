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

    // Load or initialize the start date
    final startDateString = prefs.getString('startDate');
    if (startDateString != null) {
      _startDate = DateTime.parse(startDateString);
    } else {
      _startDate = DateTime.now();
      await prefs.setString('startDate', _startDate!.toIso8601String());
    }

    // Calculate currentDay based on how many 24-hour blocks have elapsed
    _currentDay = _getCurrentDay();
    await prefs.setInt('currentDay', _currentDay);

    await _calculateProgress();

    // Schedule all fail alarms upfront (one per day, days 1..75)
    await _scheduleAllDayFailAlarms();

    if (!mounted) return;
    setState(() {});
  }

  /// Loops through all 75 days and schedules an alarm for each day-end
  /// so that the user fails automatically if they don't complete that day.
  Future<void> _scheduleAllDayFailAlarms() async {
    final prefs = await SharedPreferences.getInstance();

    // Cancel any old alarms first to avoid duplicates
    for (int day = 1; day <= 75; day++) {
      final oldAlarmId = 1000 + day;
      await AndroidAlarmManager.cancel(oldAlarmId);
      await prefs.remove('alarm_label_$oldAlarmId');
    }

    final now = DateTime.now();

    // For each day 1..75, schedule an alarm if its 24-hour window hasn't ended
    for (int day = 1; day <= 75; day++) {
      // dayStart is the time this day began:
      // e.g. if startDate is Jan1 2:00PM, Day1 = Jan1->Jan2, Day2 = Jan2->Jan3, etc.
      final dayStart = _startDate!.add(Duration(days: day - 1));
      final dayEnd = dayStart.add(const Duration(days: 1)); // 24 hours later

      if (dayEnd.isBefore(now)) {
        // If we've already passed dayEnd, do nothing (that day is in the past)
        developer.log("Day $day ended at $dayEnd, which is already past. Skipping alarm.");
        continue;
      }

      final alarmId = 1000 + day; // Unique alarm ID for each day
      final initialDelay = dayEnd.difference(now);

      // Schedule the day-failure check alarm
      final scheduled = await AndroidAlarmManager.oneShot(
        initialDelay,
        alarmId,
        alarmCallback, // This is the top-level function in main.dart
        exact: true,
        wakeup: true,
        rescheduleOnReboot: true,
      );

      if (scheduled) {
        // Label the alarm so alarmCallback knows it's an end-of-day
        await prefs.setString('alarm_label_$alarmId', 'end_of_day');
        developer.log(
          "Scheduled fail alarm for Day $day to trigger in "
              "${initialDelay.inHours}h (${dayEnd.toLocal()}). AlarmId=$alarmId",
        );
      } else {
        developer.log("Failed scheduling alarm for Day $day (AlarmId=$alarmId).");
      }
    }
  }

  Future<void> _calculateProgress() async {
    final prefs = await SharedPreferences.getInstance();
    int completed = 0;
    int failed = 0;

    // Count how many days are marked completed or failed so far
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

  /// Returns how many full 24-hour blocks have passed since _startDate
  /// plus 1 => so day1 is from the moment you start until 24 hours later, day2 is the next 24 hours, etc.
  int _getCurrentDay() {
    final now = DateTime.now();
    final difference = now.difference(_startDate!).inDays + 1;
    return difference.clamp(1, 75);
  }

  /// For the UI grid: load all days from prefs (1..75), see if each is completed/failed/pending
  Future<Map<int, String>> _loadChallengeProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<int, String> progress = {};

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

  // Reset the entire challenge
  Future<void> _resetChallenge() async {
    final prefs = await SharedPreferences.getInstance();

    // Clear all completed/failed flags
    for (int day = 1; day <= 75; day++) {
      await prefs.remove(PreferencesHelper.completedKey(day));
      await prefs.remove(PreferencesHelper.failedKey(day));
    }

    // Reset start date to now
    _startDate = DateTime.now();
    await prefs.setString('startDate', _startDate!.toIso8601String());

    // Reset day counters
    _currentDay = _getCurrentDay();
    await prefs.setInt('currentDay', _currentDay);
    _daysCompleted = 0;
    _daysFailed = 0;

    // Cancel all existing alarms
    await _cancelAllAlarms();

    // Remove alarm-related SharedPreferences keys for each day
    for (int alarmId = 1001; alarmId <= 1075; alarmId++) {
      await prefs.remove('alarm_label_$alarmId');
    }

    // Inform the user
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

    // Reload everything, which also reschedules new alarms
    await _loadState();
  }

  // Cancel all day-failure alarms
  Future<void> _cancelAllAlarms() async {
    for (int day = 1; day <= 75; day++) {
      final alarmId = 1000 + day;
      final canceled = await AndroidAlarmManager.cancel(alarmId);
      if (canceled) {
        developer.log('Canceled alarm for Day $day (alarmId=$alarmId)');
      } else {
        developer.log('No alarm found to cancel for Day $day (alarmId=$alarmId)');
      }
    }
  }

  // Optional: test an alarm callback manually
  Future<void> _manualTriggerAlarm() async {
    final alarmId = 1000 + _currentDay;
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
            onPressed: _manualTriggerAlarm, // For testing
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
              // Displays current day, days completed/failed, etc.
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
                          ? () async {
                        // Open goals for that day
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GoalSetupScreen(day: day),
                          ),
                        );

                        // result == true => day completed
                        // result == false => day failed
                        if (result == true || result == false) {
                          await _calculateProgress();
                          if (!mounted) return;
                          setState(() {});
                        }
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

