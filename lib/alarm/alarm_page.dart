// lib/alarm/alarm_page.dart

import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart'; // For alarmCallback
import '../styles/styles.dart'; // Import styles

class AlarmPage extends StatefulWidget {
  final String alarmLabel;
  final TimeOfDay? initialTime;

  const AlarmPage({super.key, required this.alarmLabel, this.initialTime});

  @override
  AlarmPageState createState() => AlarmPageState();
}

class AlarmPageState extends State<AlarmPage> {
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime;
  }

  Future<void> _setAlarm(TimeOfDay time) async {
    final now = DateTime.now();
    final alarmTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final durationUntilAlarm = alarmTime.isAfter(now)
        ? alarmTime.difference(now)
        : alarmTime.add(const Duration(days: 1)).difference(now);

    // Unique alarm ID based on label
    final alarmId = widget.alarmLabel == 'Inside Workout' ? 1 : 2;

    // Save alarm label and time using standardized keys
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('alarm_label_$alarmId', widget.alarmLabel);
    await prefs.setInt('alarm_hour_$alarmId', time.hour);
    await prefs.setInt('alarm_minute_$alarmId', time.minute);

    // Cancel existing alarm
    await AndroidAlarmManager.cancel(alarmId);

    // Schedule new alarm
    bool alarmScheduled = await AndroidAlarmManager.oneShot(
      durationUntilAlarm,
      alarmId,
      alarmCallback,
      exact: true,
      wakeup: true,
    );

    if (alarmScheduled) {
      developer.log('Alarm set for $time (${durationUntilAlarm.inSeconds}s)');
      setState(() {
        _selectedTime = time;
      });
      // Return true indicating success
      Navigator.pop(context, true);
    } else {
      developer.log('Failed to schedule alarm');
      // Return false indicating failure
      Navigator.pop(context, false);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary, // Header background color
              onPrimary: AppColors.background, // Header text color
              onSurface: AppColors.text, // Body text color
            ),
            dialogBackgroundColor: AppColors.cardBackground, // Dialog background color
          ),
          child: child ?? Container(),
        );
      },
    );

    if (picked != null) {
      await _setAlarm(picked);
    } else {
      // User canceled the picker, return false
      Navigator.pop(context, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use a gradient background for a modern look
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Card(
            color: AppColors.cardBackground,
            elevation: 8,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Alarm Icon
                  Icon(
                    Icons.alarm,
                    size: 60,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 20),
                  // Alarm Label
                  Text(
                    widget.alarmLabel,
                    style: AppTextStyles.dialogTitle,
                  ),
                  const SizedBox(height: 30),
                  // Display Alarm Time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _selectedTime != null ? Icons.alarm_on : Icons.alarm_off,
                        color: _selectedTime != null ? AppColors.completedGreen : AppColors.error,
                        size: 30,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _selectedTime != null
                            ? 'Alarm set for ${_selectedTime!.format(context)}'
                            : 'No alarm set',
                        style: AppTextStyles.body,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // Set Alarm Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _selectTime(context),
                      icon: const Icon(Icons.schedule),
                      label: const Text('Set Alarm'),
                      style: AppButtonStyles.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      appBar: AppBar(
        title: Text(widget.alarmLabel),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.text),
      ),
    );
  }
}


