import 'dart:developer' as developer;
import 'dart:typed_data';
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
    developer.log('Initializing alarm settings');
    await _checkExactAlarmPermission();
    await _checkNotificationPermission();
  }

  Future<void> _checkExactAlarmPermission() async {
    _exactAlarmPermissionStatus = await Permission.scheduleExactAlarm.status;
    developer.log('Exact Alarm Permission Status: $_exactAlarmPermissionStatus');
    setState(() {});
  }

  Future<void> _checkNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      developer.log('Notification permission denied, requesting...');
      await Permission.notification.request();
    } else {
      developer.log('Notification permission granted');
    }
  }

  Future<void> _setAlarm(TimeOfDay time) async {
    developer.log('Setting alarm for ${time.format(context)}');
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

    developer.log('Alarm set with ID: $alarmId, Duration: $durationUntilAlarm');

    await prefs?.setString(alarmTimeKey, '${time.hour}:${time.minute}');
    setState(() {
      _selectedTime = time;
    });
  }

  @pragma('vm:entry-point')
  static Future<void> _alarmCallback() async {
    developer.log('Alarm fired! Executing callback.');

    var androidNotificationDetails = AndroidNotificationDetails(
      'alarm_channel_id',
      'Alarm Notifications',
      channelDescription: 'Channel for alarm notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('alarm_sound'),
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
    );

    var notificationDetails = NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Alarm: ${currentAlarmLabel ?? "Workout"}',
      "It's time for your goal!",
      notificationDetails,
    );

    developer.log('Notification displayed with sound for alarm label: ${currentAlarmLabel}');
  }

  Future<void> _selectTime(BuildContext context) async {
    developer.log('Opening time picker');
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
                  developer.log('Exact Alarm Permission denied, requesting...');
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

