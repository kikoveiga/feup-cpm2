import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/daily_weather.dart';

class WeeklyTempChart extends StatelessWidget {
  final List<DailyWeather> data;

  const WeeklyTempChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minY: _getMinTemp(data),
        maxY: _getMaxTemp(data),
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                int i = value.toInt();
                if (i >= 0 && i < data.length) {
                  // Show only day (DD)
                  return Text(data[i].date.substring(8));
                }
                return const Text('');
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: data.asMap().entries.map(
                  (e) => FlSpot(e.key.toDouble(), e.value.tempMax),
            ).toList(),
            isCurved: true,
            color: Colors.red,
            barWidth: 3,
            dotData: FlDotData(show: true),
          ),
          LineChartBarData(
            spots: data.asMap().entries.map(
                  (e) => FlSpot(e.key.toDouble(), e.value.tempMin),
            ).toList(),
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }

  double _getMaxTemp(List<DailyWeather> data) =>
      data.map((e) => e.tempMax).reduce((a, b) => a > b ? a : b) + 2;

  double _getMinTemp(List<DailyWeather> data) =>
      data.map((e) => e.tempMin).reduce((a, b) => a < b ? a : b) - 2;
}
