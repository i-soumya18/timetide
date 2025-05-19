import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/health_metric_model.dart';

class HealthInsightCard extends StatelessWidget {
  final String title;
  final String type;
  final List<HealthMetricModel> metrics;
  final int goal;
  final Function(int) onUpdate;

  const HealthInsightCard({
    super.key,
    required this.title,
    required this.type,
    required this.metrics,
    required this.goal,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayMetric = metrics.firstWhere(
          (m) => m.date.day == today.day && m.date.month == today.month && m.date.year == today.year,
      orElse: () => HealthMetricModel(id: '', userId: '', date: today, type: type, value: 0),
    );

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: todayMetric.value.toDouble(),
                      color: const Color(0xFFFFB703),
                      title: '${todayMetric.value}/$goal',
                      radius: 40,
                      titleStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.black),
                    ),
                    PieChartSectionData(
                      value: (goal - todayMetric.value).toDouble(),
                      color: Colors.grey[300]!,
                      title: '',
                      radius: 40,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress: ${todayMetric.value}/$goal',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Color(0xFF219EBC)),
                  onPressed: () => onUpdate(todayMetric.value + 1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}