import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CashflowChart extends StatelessWidget {
  const CashflowChart({super.key});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(show: false),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            color: Colors.white,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            spots: const [
              FlSpot(0, 3),
              FlSpot(1, 2),
              FlSpot(2, 5),
              FlSpot(3, 4),
              FlSpot(4, 6),
              FlSpot(5, 5),
              FlSpot(6, 8),
            ],
          ),
        ],
      ),
    );
  }
}