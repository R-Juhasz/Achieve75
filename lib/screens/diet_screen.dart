// lib/screens/diet_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/meals.dart';
import '../styles/styles.dart'; // Adjust the import based on your project structure

class DietScreen extends StatefulWidget {
  static const String routeName = '/diets';
  @override
  _DietScreenState createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> {
  List<Meal> _meals = [];
  final _formKey = GlobalKey<FormState>();
  String _mealName = '';
  int _calories = 0;

  static  String _mealsKey = 'meals_${_todayDate()}';

  // Calculate total calories
  int get _totalCalories {
    return _meals.fold(0, (sum, meal) => sum + meal.calories);
  }

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  // Function to get today's date in YYYY-MM-DD format
  static String _todayDate() {
    final now = DateTime.now();
    return '${now.year}-${_twoDigits(now.month)}-${_twoDigits(now.day)}';
  }

  static String _twoDigits(int n) => n.toString().padLeft(2, '0');

  // Load meals from Shared Preferences
  Future<void> _loadMeals() async {
    final prefs = await SharedPreferences.getInstance();
    final String? mealsString = prefs.getString(_mealsKey);
    if (mealsString != null) {
      setState(() {
        _meals = Meal.decode(mealsString);
      });
    }
  }

  // Save meals to Shared Preferences
  Future<void> _saveMeals() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = Meal.encode(_meals);
    await prefs.setString(_mealsKey, encodedData);
  }

  // Function to display add meal dialog
  void _showAddMealDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          title: Text('Add Meal', style: AppTextStyles.dialogTitle),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Meal Name Input
                TextFormField(
                  style: AppTextStyles.body,
                  decoration: InputDecoration(
                    labelText: 'Meal Name',
                    labelStyle: AppTextStyles.body,
                    hintText: 'e.g., Breakfast',
                    hintStyle: AppTextStyles.hint,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primary),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primaryDark),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a meal name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _mealName = value!.trim();
                  },
                ),
                SizedBox(height: 10),
                // Calories Input
                TextFormField(
                  style: AppTextStyles.body,
                  decoration: InputDecoration(
                    labelText: 'Calories',
                    labelStyle: AppTextStyles.body,
                    hintText: 'e.g., 500',
                    hintStyle: AppTextStyles.hint,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primary),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primaryDark),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter calories';
                    }
                    if (int.tryParse(value.trim()) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _calories = int.parse(value!.trim());
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: AppTextStyles.cancelButton),
            ),
            ElevatedButton(
              style: AppButtonStyles.primary,
              onPressed: _addMeal,
              child: Text('Add', style: AppTextStyles.button),
            ),
          ],
        );
      },
    );
  }

  // Function to add a meal
  Future<void> _addMeal() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _meals.add(Meal(name: _mealName, calories: _calories));
      });
      await _saveMeals();
      Navigator.of(context).pop();
    }
  }

  // Function to delete a meal
  Future<void> _deleteMeal(int index) async {
    setState(() {
      _meals.removeAt(index);
    });
    await _saveMeals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Diet Tracker', style: AppTextStyles.title),
        backgroundColor: AppColors.primaryDark,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Calorie Summary Card
            Card(
              color: AppColors.cardBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: Icon(Icons.local_fire_department, color: AppColors.primary),
                title: Text('Total Calories', style: AppTextStyles.subtitle),
                trailing: Text('$_totalCalories kcal', style: AppTextStyles.body),
              ),
            ),
            SizedBox(height: 20),
            // Meals List
            Expanded(
              child: _meals.isEmpty
                  ? Center(
                child: Text(
                  'No meals added yet.',
                  style: AppTextStyles.bodySecondary,
                ),
              )
                  : ListView.builder(
                itemCount: _meals.length,
                itemBuilder: (context, index) {
                  final meal = _meals[index];
                  return Card(
                    color: AppColors.cardBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(meal.name, style: AppTextStyles.body),
                      subtitle: Text('${meal.calories} kcal', style: AppTextStyles.bodySecondary),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: AppColors.error),
                        onPressed: () => _deleteMeal(index),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            // Add Meal Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: AppButtonStyles.primary,
                onPressed: _showAddMealDialog,
                icon: Icon(Icons.add, color: AppColors.text),
                label: Text('Add Meal', style: AppTextStyles.button),
              ),
            ),
          ],
        ),
      ),
    );
  }
}





