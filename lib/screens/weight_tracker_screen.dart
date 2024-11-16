import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';

import '../extras/drawer_menu.dart';

class WeightTrackerScreen extends StatefulWidget {
  const WeightTrackerScreen({Key? key}) : super(key: key);
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
        const SnackBar(content: Text('Please enter a valid weight!')),
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white), // Hamburger icon in white
        title: const Text(
          'Weight Tracker',
          style: TextStyle(fontFamily: 'Gugi', fontSize: 24),
        ),
      ),

      drawer: DrawerMenu(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Gugi',
              ),
              decoration: const InputDecoration(
                labelText: 'Enter Weight (kg)',
                labelStyle: TextStyle(
                  color: Colors.blue,
                  fontFamily: 'Gugi',
                ),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 60),
              ),
              onPressed: _saveWeight,
              child: const Text(
                'Save Weight',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Gugi',
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _weights.isEmpty
                  ? const Center(
                child: Text(
                  'No weight data available.',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Gugi',
                  ),
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
                            style: const TextStyle(
                              fontFamily: 'Gugi',
                              color: Colors.white,
                              fontSize: 12,
                            ),
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
                            style: const TextStyle(
                              fontFamily: 'Gugi',
                              color: Colors.white,
                              fontSize: 12,
                            ),
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
                      color: Colors.blue,
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.3),
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
