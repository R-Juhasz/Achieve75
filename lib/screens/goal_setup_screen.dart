// lib/screens/goal_setup_screen.dart

import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../alarm/alarm_page.dart';
import '../utils/image_helper.dart';
import '../extras/drawer_menu.dart';
import '../styles/styles.dart';
import '../providers/water_tracker_provider.dart';

class GoalSetupScreen extends StatefulWidget {
  final int day;
  const GoalSetupScreen({super.key, required this.day});
  static const String routeName = '/goalSetup';

  @override
  _GoalSetupScreenState createState() => _GoalSetupScreenState();
}

class _GoalSetupScreenState extends State<GoalSetupScreen> {
  bool _waterGoalCompleted = false;
  bool _readingGoalCompleted = false;
  bool _dietGoalCompleted = false;
  bool _photoGoalCompleted = false;
  bool _insideWorkoutGoalCompleted = false;
  bool _outsideWorkoutGoalCompleted = false;

  TimeOfDay? _insideWorkoutAlarmTime;
  TimeOfDay? _outsideWorkoutAlarmTime;

  final ImageHelper _imageHelper = ImageHelper();

  @override
  void initState() {
    super.initState();
    developer.log('GoalSetupScreen initState for day ${widget.day}');
    _loadGoals();
  }

  // Load saved goals
  Future<void> _loadGoals() async {
    developer.log('Loading goals for day ${widget.day}');
    final prefs = await SharedPreferences.getInstance();
    final day = widget.day;

    setState(() {
      _waterGoalCompleted = prefs.getBool('day_${day}_water_goal') ?? false;
      _readingGoalCompleted = prefs.getBool('day_${day}_reading_goal') ?? false;
      _dietGoalCompleted = prefs.getBool('day_${day}_diet_goal') ?? false;
      _photoGoalCompleted = prefs.getBool('day_${day}_photo_goal') ?? false;
      _insideWorkoutGoalCompleted = prefs.getBool('day_${day}_inside_workout_goal') ?? false;
      _outsideWorkoutGoalCompleted = prefs.getBool('day_${day}_outside_workout_goal') ?? false;

      // Load alarm times using standardized keys
      final insideAlarmHour = prefs.getInt('alarm_hour_1');
      final insideAlarmMinute = prefs.getInt('alarm_minute_1');
      if (insideAlarmHour != null && insideAlarmMinute != null) {
        _insideWorkoutAlarmTime = TimeOfDay(hour: insideAlarmHour, minute: insideAlarmMinute);
      }

      final outsideAlarmHour = prefs.getInt('alarm_hour_2');
      final outsideAlarmMinute = prefs.getInt('alarm_minute_2');
      if (outsideAlarmHour != null && outsideAlarmMinute != null) {
        _outsideWorkoutAlarmTime = TimeOfDay(hour: outsideAlarmHour, minute: outsideAlarmMinute);
      }
    });

    developer.log('Goals loaded for day ${widget.day}');
  }

  // Save goals
  Future<void> _saveGoals() async {
    developer.log('Saving goals for day ${widget.day}');
    final prefs = await SharedPreferences.getInstance();
    final day = widget.day;
    await prefs.setBool('day_${day}_water_goal', _waterGoalCompleted);
    await prefs.setBool('day_${day}_reading_goal', _readingGoalCompleted);
    await prefs.setBool('day_${day}_diet_goal', _dietGoalCompleted);
    await prefs.setBool('day_${day}_photo_goal', _photoGoalCompleted);
    await prefs.setBool('day_${day}_inside_workout_goal', _insideWorkoutGoalCompleted);
    await prefs.setBool('day_${day}_outside_workout_goal', _outsideWorkoutGoalCompleted);

    // Save alarm times using standardized keys
    if (_insideWorkoutAlarmTime != null) {
      await prefs.setInt('alarm_hour_1', _insideWorkoutAlarmTime!.hour);
      await prefs.setInt('alarm_minute_1', _insideWorkoutAlarmTime!.minute);
    }
    if (_outsideWorkoutAlarmTime != null) {
      await prefs.setInt('alarm_hour_2', _outsideWorkoutAlarmTime!.hour);
      await prefs.setInt('alarm_minute_2', _outsideWorkoutAlarmTime!.minute);
    }

    developer.log('Goals saved for day ${widget.day}');
  }

  // Mark goals as completed or failed
  Future<void> _markGoalsCompleted() async {
    developer.log('Marking goals as completed or failed for day ${widget.day}');
    final prefs = await SharedPreferences.getInstance();
    if (_waterGoalCompleted &&
        _readingGoalCompleted &&
        _dietGoalCompleted &&
        _photoGoalCompleted &&
        _insideWorkoutGoalCompleted &&
        _outsideWorkoutGoalCompleted) {
      // Mark the day as completed
      await prefs.setBool('day_${widget.day}_completed', true);
      // Optionally, reset any failure flag if previously set
      await prefs.remove('day_${widget.day}_failed');
      developer.log('Day ${widget.day} marked as completed');
      Navigator.pop(context, true); // Return true to indicate success
    } else {
      // Mark the day as failed
      await prefs.setBool('day_${widget.day}_failed', true);
      // Optionally, reset the completed flag if previously set
      await prefs.remove('day_${widget.day}_completed');
      developer.log('Day ${widget.day} marked as failed');

      // Show a Snackbar to inform the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Day marked as failed. Please try again tomorrow.',
            style: AppTextStyles.body,
          ),
          backgroundColor: AppColors.error,
        ),
      );

      Navigator.pop(context, false); // Return false to indicate failure
    }
  }

  // Set workout alarm
  Future<void> _setWorkoutAlarm(String workoutType) async {
    developer.log('Setting workout alarm for $workoutType');
    // Directly navigate to AlarmPage without showing showTimePicker here
    bool? alarmSet = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AlarmPage(
          alarmLabel: workoutType,
          initialTime: workoutType == 'Inside Workout' ? _insideWorkoutAlarmTime : _outsideWorkoutAlarmTime,
        ),
      ),
    );

    if (alarmSet == true) {
      setState(() {
        if (workoutType == 'Inside Workout') {
          _insideWorkoutAlarmTime = _insideWorkoutAlarmTime; // Already set in AlarmPage
        } else if (workoutType == 'Outside Workout') {
          _outsideWorkoutAlarmTime = _outsideWorkoutAlarmTime; // Already set in AlarmPage
        }
      });
      await _saveGoals();
      developer.log('Workout alarm set for $workoutType');
    } else {
      developer.log('Workout alarm not set for $workoutType');
      // Optionally, inform the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to set the alarm for $workoutType.',
            style: AppTextStyles.body,
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    developer.log('Building GoalSetupScreen for day ${widget.day}');
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColors.text),
        title: Text(
          'Day ${widget.day} Goals',
          style: AppTextStyles.title.copyWith(color: AppColors.primary),
        ),
        backgroundColor: AppColors.background,
      ),
      drawer: DrawerMenu(),
      body: Consumer<WaterTrackerProvider>(
        builder: (context, waterProvider, child) {
          // Check if water goal is reached
          if (waterProvider.goalReached && !_waterGoalCompleted) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              setState(() {
                _waterGoalCompleted = true;
              });
              await _saveGoals();
              developer.log('Water goal completed automatically');
            });
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Text(
                'Set your goals for the 75 Hard Challenge',
                style: AppTextStyles.body.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildWaterGoalTile(),
              _buildReadingGoalTile(),
              _buildDietGoalTile(),
              _buildPhotoGoalTile(),
              _buildInsideWorkoutGoalTile(),
              _buildOutsideWorkoutGoalTile(),
              const SizedBox(height: 20),
              ElevatedButton(
                style: AppButtonStyles.primary,
                onPressed: _markGoalsCompleted,
                child: Text(
                  'Mark as ${(_waterGoalCompleted && _readingGoalCompleted && _dietGoalCompleted && _photoGoalCompleted && _insideWorkoutGoalCompleted && _outsideWorkoutGoalCompleted) ? 'Completed' : 'Failed'}',
                  style: AppTextStyles.button,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Build Water Goal Tile
  Widget _buildWaterGoalTile() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(
          color: _waterGoalCompleted ? AppColors.primary : AppColors.text,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: CheckboxListTile(
        activeColor: AppColors.primary,
        checkColor: AppColors.background,
        title: Row(
          children: [
            Icon(Icons.local_drink, color: AppColors.primary),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                'Drink a gallon of water',
                style: AppTextStyles.body.copyWith(color: AppColors.text),
              ),
            ),
          ],
        ),
        value: _waterGoalCompleted,
        onChanged: null, // Disable manual toggling
      ),
    );
  }

  // Build Reading Goal Tile
  Widget _buildReadingGoalTile() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(
          color: _readingGoalCompleted ? AppColors.primary : AppColors.text,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: CheckboxListTile(
        activeColor: AppColors.primary,
        checkColor: AppColors.background,
        title: Row(
          children: [
            Icon(Icons.book, color: AppColors.primary),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                'Read 10 pages of a book',
                style: AppTextStyles.body.copyWith(color: AppColors.text),
              ),
            ),
          ],
        ),
        value: _readingGoalCompleted,
        onChanged: (bool? value) async {
          setState(() {
            _readingGoalCompleted = value ?? false;
          });
          await _saveGoals();
        },
      ),
    );
  }

  // Build Diet Goal Tile
  Widget _buildDietGoalTile() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(
          color: _dietGoalCompleted ? AppColors.primary : AppColors.text,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: CheckboxListTile(
        activeColor: AppColors.primary,
        checkColor: AppColors.background,
        title: Row(
          children: [
            Icon(Icons.food_bank, color: AppColors.primary),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                'Follow a diet (no cheat meals)',
                style: AppTextStyles.body.copyWith(color: AppColors.text),
              ),
            ),
          ],
        ),
        value: _dietGoalCompleted,
        onChanged: (bool? value) async {
          setState(() {
            _dietGoalCompleted = value ?? false;
          });
          await _saveGoals();
        },
      ),
    );
  }

  // Build Photo Goal Tile
  Widget _buildPhotoGoalTile() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(
          color: _photoGoalCompleted ? AppColors.primary : AppColors.text,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: CheckboxListTile(
        activeColor: AppColors.primary,
        checkColor: AppColors.background,
        title: Row(
          children: [
            Icon(Icons.camera_alt, color: AppColors.primary),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                'Take a progress picture',
                style: AppTextStyles.body.copyWith(color: AppColors.text),
              ),
            ),
          ],
        ),
        value: _photoGoalCompleted,
        onChanged: (bool? value) async {
          if (value == true) {
            bool hasPermission = await _imageHelper.requestCameraPermission();
            if (!hasPermission) {
              // Permission denied, do not check the box
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Camera permission is required to take progress pictures.',
                    style: AppTextStyles.body,
                  ),
                  backgroundColor: AppColors.error,
                ),
              );
              return;
            }

            File? image = await _imageHelper.captureImage();
            if (image != null) {
              String savedPath = await _imageHelper.saveImage(image, widget.day);
              await _imageHelper.saveImageData(savedPath, widget.day);

              // Update the goal as completed
              setState(() {
                _photoGoalCompleted = true;
              });
              await _saveGoals();

              // Inform the user
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Progress picture saved for Day ${widget.day}.',
                    style: AppTextStyles.body,
                  ),
                  backgroundColor: AppColors.primary,
                ),
              );
            } else {
              // User canceled the image capture, do not check the box
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'No picture taken. Please try again.',
                    style: AppTextStyles.body,
                  ),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          } else {
            // Uncheck the box and possibly remove the saved picture
            setState(() {
              _photoGoalCompleted = false;
            });
            await _saveGoals();
          }
        },
      ),
    );
  }

  // Build Inside Workout Goal Tile
  Widget _buildInsideWorkoutGoalTile() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(
          color: _insideWorkoutGoalCompleted ? AppColors.primary : AppColors.text,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(Icons.fitness_center, color: AppColors.primary),
        title: Text(
          'Inside Workout',
          style: AppTextStyles.body.copyWith(color: AppColors.text),
        ),
        subtitle: _insideWorkoutAlarmTime != null
            ? Text('Alarm set for ${_insideWorkoutAlarmTime!.format(context)}')
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              activeColor: AppColors.primary,
              checkColor: AppColors.background,
              value: _insideWorkoutGoalCompleted,
              onChanged: (bool? value) async {
                setState(() {
                  _insideWorkoutGoalCompleted = value ?? false;
                });
                await _saveGoals();
              },
            ),
            IconButton(
              icon: Icon(Icons.alarm, color: AppColors.primary),
              onPressed: () async {
                await _setWorkoutAlarm('Inside Workout');
              },
            ),
          ],
        ),
      ),
    );
  }

  // Build Outside Workout Goal Tile
  Widget _buildOutsideWorkoutGoalTile() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(
          color: _outsideWorkoutGoalCompleted ? AppColors.primary : AppColors.text,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(Icons.directions_run, color: AppColors.primary),
        title: Text(
          'Outside Workout',
          style: AppTextStyles.body.copyWith(color: AppColors.text),
        ),
        subtitle: _outsideWorkoutAlarmTime != null
            ? Text('Alarm set for ${_outsideWorkoutAlarmTime!.format(context)}')
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              activeColor: AppColors.primary,
              checkColor: AppColors.background,
              value: _outsideWorkoutGoalCompleted,
              onChanged: (bool? value) async {
                setState(() {
                  _outsideWorkoutGoalCompleted = value ?? false;
                });
                await _saveGoals();
              },
            ),
            IconButton(
              icon: Icon(Icons.alarm, color: AppColors.primary),
              onPressed: () async {
                await _setWorkoutAlarm('Outside Workout');
              },
            ),
          ],
        ),
      ),
    );
  }
}


