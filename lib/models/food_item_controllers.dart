// lib/models/food_item_controllers.dart

import 'package:flutter/material.dart';

class FoodItemControllers {
  final TextEditingController foodNameController;
  final TextEditingController quantityController;
  final TextEditingController caloriesController;
  final TextEditingController carbsController;
  final TextEditingController proteinsController;
  final TextEditingController fatsController;

  FoodItemControllers()
      : foodNameController = TextEditingController(),
        quantityController = TextEditingController(),
        caloriesController = TextEditingController(),
        carbsController = TextEditingController(),
        proteinsController = TextEditingController(),
        fatsController = TextEditingController();

  void dispose() {
    foodNameController.dispose();
    quantityController.dispose();
    caloriesController.dispose();
    carbsController.dispose();
    proteinsController.dispose();
    fatsController.dispose();
  }
}



