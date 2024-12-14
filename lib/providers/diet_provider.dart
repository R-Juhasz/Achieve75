// lib/providers/diet_provider.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/recipe.dart';

class DietProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<DietEntry> _entries = [];
  double _totalCalories = 0;
  double _totalCarbs = 0;
  double _totalProteins = 0;
  double _totalFats = 0;

  // For Recipes
  List<Recipe> _recipes = [];
  bool _isFetchingRecipes = false;
  String? _recipeError;

  List<DietEntry> get entries => _entries;
  double get totalCalories => _totalCalories;
  double get totalCarbs => _totalCarbs;
  double get totalProteins => _totalProteins;
  double get totalFats => _totalFats;

  // Recipes Getters
  List<Recipe> get recipes => _recipes;
  bool get isFetchingRecipes => _isFetchingRecipes;
  String? get recipeError => _recipeError;

  Future<void> fetchTodayEntries(String userId, DateTime today) async {
    String formattedDate = _formatDate(today);
    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('dietEntries')
        .where('date', isEqualTo: formattedDate)
        .get();

    _entries = snapshot.docs.map((doc) => DietEntry.fromFirestore(doc)).toList();

    _calculateTotals();
    notifyListeners();
  }

  void _calculateTotals() {
    _totalCalories = 0;
    _totalCarbs = 0;
    _totalProteins = 0;
    _totalFats = 0;

    for (var entry in _entries) {
      _totalCalories += entry.totalCalories;
      _totalCarbs += entry.totalCarbs;
      _totalProteins += entry.totalProteins;
      _totalFats += entry.totalFats;
    }
  }

  Future<void> addDietEntry(String userId, DietEntry entry) async {
    DocumentReference docRef = await _firestore
        .collection('users')
        .doc(userId)
        .collection('dietEntries')
        .add(entry.toMap());
    DietEntry newEntry = DietEntry(
      id: docRef.id,
      date: entry.date,
      mealType: entry.mealType,
      mealName: entry.mealName,
      foodItems: entry.foodItems,
      totalCalories: entry.totalCalories,
      totalCarbs: entry.totalCarbs,
      totalProteins: entry.totalProteins,
      totalFats: entry.totalFats,
    );
    _entries.add(newEntry);
    _calculateTotals();
    notifyListeners();
  }

  Future<void> deleteDietEntry(String userId, String entryId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('dietEntries')
        .doc(entryId)
        .delete();
    _entries.removeWhere((entry) => entry.id == entryId);
    _calculateTotals();
    notifyListeners();
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)}";
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  // Recipes Related Methods

  Future<void> fetchRecipes() async {
    _isFetchingRecipes = true;
    _recipeError = null;
    notifyListeners();

    final url = Uri.parse('https://www.themealdb.com/api/json/v1/1/search.php?s='); // Fetch all meals

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null) {
          _recipes = List<Recipe>.from(
            data['meals'].map((meal) => Recipe.fromJson(meal)),
          );
        } else {
          _recipes = [];
        }
      } else {
        _recipeError = 'Failed to fetch recipes. Status code: ${response.statusCode}';
      }
    } catch (e) {
      _recipeError = 'An error occurred while fetching recipes.';
    }

    _isFetchingRecipes = false;
    notifyListeners();
  }

// Add more recipe-related methods as needed
}

class DietEntry {
  final String id;
  final String date;
  final String mealType;
  final String mealName;
  final List<FoodItem> foodItems;
  final double totalCalories;
  final double totalCarbs;
  final double totalProteins;
  final double totalFats;

  DietEntry({
    required this.id,
    required this.date,
    required this.mealType,
    required this.mealName,
    required this.foodItems,
    required this.totalCalories,
    required this.totalCarbs,
    required this.totalProteins,
    required this.totalFats,
  });

  factory DietEntry.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    List<FoodItem> items = [];
    if (data['foodItems'] != null) {
      items = List.from(data['foodItems'])
          .map((item) => FoodItem.fromMap(item))
          .toList();
    }
    return DietEntry(
      id: doc.id,
      date: data['date'] ?? '',
      mealType: data['mealType'] ?? '',
      mealName: data['mealName'] ?? '',
      foodItems: items,
      totalCalories: data['totalCalories']?.toDouble() ?? 0.0,
      totalCarbs: data['totalCarbs']?.toDouble() ?? 0.0,
      totalProteins: data['totalProteins']?.toDouble() ?? 0.0,
      totalFats: data['totalFats']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'mealType': mealType,
      'mealName': mealName,
      'foodItems': foodItems.map((item) => item.toMap()).toList(),
      'totalCalories': totalCalories,
      'totalCarbs': totalCarbs,
      'totalProteins': totalProteins,
      'totalFats': totalFats,
    };
  }
}

class FoodItem {
  final String name;
  final String quantity;
  final double calories;
  final double carbs;
  final double proteins;
  final double fats;

  FoodItem({
    required this.name,
    required this.quantity,
    required this.calories,
    required this.carbs,
    required this.proteins,
    required this.fats,
  });

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      name: map['name'] ?? '',
      quantity: map['quantity'] ?? '',
      calories: map['calories']?.toDouble() ?? 0.0,
      carbs: map['carbs']?.toDouble() ?? 0.0,
      proteins: map['proteins']?.toDouble() ?? 0.0,
      fats: map['fats']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'calories': calories,
      'carbs': carbs,
      'proteins': proteins,
      'fats': fats,
    };
  }
}


