// progress_section.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProgressSection extends StatelessWidget {
  final int currentDay;
  final int daysCompleted;
  final int daysFailed;
  final DateTime currentDate;

  const ProgressSection({
    super.key,
    required this.currentDay,
    required this.daysCompleted,
    required this.daysFailed,
    required this.currentDate,
  });

  @override
  Widget build(BuildContext context) {
    String formattedDate =
    DateFormat('EEEE, MMMM d, y').format(currentDate);

    double progressPercent = (currentDay / 75).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        color: Colors.grey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 4,
        child: Padding(
          padding:
          const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Date and Current Day
              Text(
                formattedDate,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontFamily: 'Gugi',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                currentDay >= 75
                    ? 'Challenge Complete!'
                    : 'Day $currentDay of 75',
                style: TextStyle(
                  color:
                  currentDay >= 75 ? Colors.green : Colors.white,
                  fontSize: 16,
                  fontFamily: 'Gugi',
                ),
              ),
              const SizedBox(height: 12),
              // Linear Progress Indicator
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: LinearProgressIndicator(
                  value: progressPercent,
                  backgroundColor: Colors.grey.shade800,
                  color: Colors.blue,
                  minHeight: 12, // Adjusted height
                ),
              ),
              const SizedBox(height: 12),
              // Percentage Text
              Text(
                '${(progressPercent * 100).toStringAsFixed(0)}% Completed',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'Gugi',
                ),
              ),
              const SizedBox(height: 12),
              Divider(color: Colors.grey),
              const SizedBox(height: 6),
              // Days Completed and Failed with Icons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard(
                    label: 'Days Completed',
                    value: daysCompleted.toString(),
                    color: Colors.green,
                    icon: Icons.check_circle,
                  ),
                  _buildStatCard(
                    label: 'Days Failed',
                    value: daysFailed.toString(),
                    color: Colors.red,
                    icon: Icons.cancel,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontFamily: 'Gugi',
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontFamily: 'Gugi',
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
