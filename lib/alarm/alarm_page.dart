import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart';

class AlarmPage extends StatefulWidget {
  final String alarmLabel;

  const AlarmPage({super.key, required this.alarmLabel});

  @override
  _AlarmPageState createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  TimeOfDay? _selectedTime;
  PermissionStatus _exactAlarmPermissionStatus = PermissionStatus.granted;

  // Store the current alarm label in a static variable
  static String? currentAlarmLabel;

  @override
  void initState() {
    super.initState();
    _initializeAlarmSettings();
  }

  Future<void> _initializeAlarmSettings() async {
    await _checkExactAlarmPermission();
    await _checkNotificationPermission();
  }

  Future<void> _checkExactAlarmPermission() async {
    _exactAlarmPermissionStatus = await Permission.scheduleExactAlarm.status;
    setState(() {});
  }

  Future<void> _checkNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  Future<void> _setAlarm(TimeOfDay time) async {
    final now = DateTime.now();
    final alarmTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final durationUntilAlarm = alarmTime.isAfter(now)
        ? alarmTime.difference(now)
        : alarmTime.add(Duration(days: 1)).difference(now);

    // Store the alarm label globally
    currentAlarmLabel = widget.alarmLabel;

    // Use unique ID for each alarm
    final alarmId = currentAlarmLabel.hashCode;

    await AndroidAlarmManager.oneShot(
      durationUntilAlarm,
      alarmId,
      _alarmCallback,
      exact: true,
      wakeup: true,
    );

    await prefs?.setString(alarmTimeKey, '${time.hour}:${time.minute}');
    setState(() {
      _selectedTime = time;
    });
  }

  @pragma('vm:entry-point')
  static Future<void> _alarmCallback() async {
    developer.log('Alarm fired!');

    const androidNotificationDetails = AndroidNotificationDetails(
      'alarm_channel_id',
      'Alarm Notifications',
      channelDescription: 'Channel for alarm notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true, // Ensure sound plays
    );
    const notificationDetails = NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Alarm: ${currentAlarmLabel ?? "Workout"}', // Use the stored label
      "It's time for your goal!",
      notificationDetails,
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      await _setAlarm(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.alarmLabel)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _selectedTime != null
                  ? 'Alarm set for ${_selectedTime!.format(context)}'
                  : 'No alarm set',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_exactAlarmPermissionStatus.isDenied) {
                  await Permission.scheduleExactAlarm.request();
                  _checkExactAlarmPermission();
                } else {
                  await _selectTime(context);
                }
              },
              child: const Text('Set Alarm'),
            ),
          ],
        ),
      ),
    );
  }
}

