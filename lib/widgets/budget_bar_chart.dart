import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BudgetBarChart extends StatelessWidget {
  final Map<String, double> data;

  const BudgetBarChart({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceEvenly,
        barGroups: data.entries.map((entry) {
          return BarChartGroupData(
            x: data.keys.toList().indexOf(entry.key),
            barRods: [
              BarChartRodData(
                toY: entry.value,
                color: Colors.blue,
                width: 20,
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50, // Add extra space for y-axis labels
              getTitlesWidget: (value, meta) => Text(
                '\$${value.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final categoryIndex = value.toInt();
                final categories = data.keys.toList();
                if (categoryIndex >= 0 && categoryIndex < categories.length) {
                  return Text(
                    categories[categoryIndex],
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(
          border: const Border.symmetric(
            horizontal: BorderSide(color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
