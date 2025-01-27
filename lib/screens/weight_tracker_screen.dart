import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import '../extras/drawer_menu.dart';
import '../styles/styles.dart'; // Import styles

class WeightTrackerScreen extends StatefulWidget {
  const WeightTrackerScreen({super.key});
  static const String routeName = '/weightTracker';

  @override
  _WeightTrackerScreenState createState() => _WeightTrackerScreenState();
}

class _WeightTrackerScreenState extends State<WeightTrackerScreen> {
  final TextEditingController _weightController = TextEditingController();
  List<double> _weights = [];

  @override
  void initState() {
    super.initState();
    _loadWeights();
  }

  Future<void> _loadWeights() async {
    final prefs = await SharedPreferences.getInstance();
    final savedWeights = prefs.getStringList('weights') ?? [];
    setState(() {
      _weights = savedWeights.map((weight) => double.parse(weight)).toList();
    });
  }

  Future<void> _saveWeight() async {
    final weight = double.tryParse(_weightController.text);
    if (weight == null || weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a valid weight!',
            style: AppTextStyles.body,
          ),
        ),
      );
      return;
    }

    setState(() {
      _weights.add(weight);
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'weights', _weights.map((w) => w.toString()).toList());

    _weightController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColors.text),
        title: Text(
          'Weight Tracker',
          style: AppTextStyles.title,
        ),
        backgroundColor: AppColors.background,
      ),
      drawer: DrawerMenu(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              style: AppTextStyles.body,
              decoration: InputDecoration(
                labelText: 'Enter Weight (kg)',
                labelStyle: AppTextStyles.subtitle.copyWith(
                  color: AppColors.primary,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primaryDark),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: AppButtonStyles.primary,
              onPressed: _saveWeight,
              child: Text(
                'Save Weight',
                style: AppTextStyles.button,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _weights.isEmpty
                  ? Center(
                child: Text(
                  'No weight data available.',
                  style: AppTextStyles.body,
                ),
              )
                  : LineChart(
                LineChartData(
                  borderData: FlBorderData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(1),
                            style: AppTextStyles.bodySecondary,
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: AppTextStyles.bodySecondary,
                          );
                        },
                      ),
                    ),
                  ),
                  minY: _weights.isNotEmpty
                      ? _weights.reduce((a, b) => a < b ? a : b) - 5
                      : 0,
                  maxY: _weights.isNotEmpty
                      ? _weights.reduce((a, b) => a > b ? a : b) + 5
                      : 10,
                  lineBarsData: [
                    LineChartBarData(
                      spots: _weights.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value);
                      }).toList(),
                      isCurved: true,
                      color: AppColors.primary,
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
