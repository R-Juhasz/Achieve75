// lib/models/meal.dart

import 'dart:convert';

class Meal {
  final String name;
  final int calories;

  Meal({required this.name, required this.calories});

  // Convert a Meal into a Map. The keys must correspond to the names of the
  // JSON attributes.
  Map<String, dynamic> toJson() => {
    'name': name,
    'calories': calories,
  };

  // A method that converts a map into a Meal.
  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      name: json['name'],
      calories: json['calories'],
    );
  }

  // Encode a list of meals to JSON string
  static String encode(List<Meal> meals) => json.encode(
    meals.map<Map<String, dynamic>>((meal) => meal.toJson()).toList(),
  );

  // Decode a JSON string to a list of meals
  static List<Meal> decode(String meals) =>
      (json.decode(meals) as List<dynamic>)
          .map<Meal>((item) => Meal.fromJson(item))
          .toList();
}
