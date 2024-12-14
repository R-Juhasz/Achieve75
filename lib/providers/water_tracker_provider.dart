// lib/providers/water_tracker_provider.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WaterTrackerProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId; // User ID from MyAuthProvider

  WaterTrackerProvider({required this.userId}) {
    initializeGoalStatus();
  }

  double _totalWaterIntake = 0.0;
  bool _goalReached = false;

  double get totalWaterIntake => _totalWaterIntake;
  bool get goalReached => _goalReached;

  // Fetch total water intake for today
  Future<double> getTotalWaterIntake() async {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('waterIntake')
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .get();

    _totalWaterIntake = snapshot.docs.fold(
        0.0, (sum, doc) => sum + (doc['amount'] as double));

    _checkGoalReached();
    notifyListeners();
    return _totalWaterIntake;
  }

  // Add water intake
  Future<void> addWaterIntake(double amount) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('waterIntake')
        .add({
      'amount': amount,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await getTotalWaterIntake();
  }

  // Check if the daily goal is reached
  void _checkGoalReached() {
    double dailyGoal = 3000.0; // Example: 3000 ml = 3 liters

    if (_totalWaterIntake >= dailyGoal && !_goalReached) {
      _goalReached = true;
      _saveGoalStatus(true);
      notifyListeners();
    } else if (_totalWaterIntake < dailyGoal && _goalReached) {
      _goalReached = false;
      _saveGoalStatus(false);
      notifyListeners();
    }
  }

  // Save goal status to SharedPreferences
  Future<void> _saveGoalStatus(bool status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('day_${DateTime.now().day}_water_goal', status);
  }

  // Initialize goal status from SharedPreferences
  Future<void> initializeGoalStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _goalReached =
        prefs.getBool('day_${DateTime.now().day}_water_goal') ?? false;
    notifyListeners();
  }

  // Stream of water intake entries for today
  Stream<QuerySnapshot> getTodayWaterIntakeStream() {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('waterIntake')
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
