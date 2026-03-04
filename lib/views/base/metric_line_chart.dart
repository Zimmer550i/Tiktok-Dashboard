import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MetricsLineChart extends StatelessWidget {
  final List<double> values;
  final String startLabel;
  final String endLabel;
  final double? maxY;

  const MetricsLineChart({
    super.key,
    required this.values,
    required this.startLabel,
    required this.endLabel,
    this.maxY,
  });

  static const Color _line = Color(0xFF8FD3FF);
  static const Color _grid = Color(0xFF3A3A3C);
  static const Color _axis = Color(0xFF48484A);
  static const Color _muted = Color(0xFF8E8E93);

  @override
  Widget build(BuildContext context) {
    final spots = List.generate(
      values.length,
      (i) => FlSpot(i.toDouble(), values[i]),
    );

    return SizedBox(
      height: 170,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (values.length - 1).toDouble(),
          minY: 0,
          maxY: maxY,

          borderData: FlBorderData(
            show: true,
            border: const Border(bottom: BorderSide(color: _axis, width: 1)),
          ),

          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 12,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: _grid.withOpacity(0.6),
                strokeWidth: 1,
                dashArray: const [2, 6],
              );
            },
          ),

          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false, reservedSize: 34),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),

            rightTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 12,
                reservedSize: 34,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const SizedBox();

                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 12, color: _muted),
                  );
                },
              ),
            ),

            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: (values.length - 1).toDouble(),
                reservedSize: 22,
                getTitlesWidget: (value, meta) {
                  String label = "";
                  if (value == 0) {
                    label = startLabel;
                  } else if (value == values.length - 1) {
                    label = endLabel;
                  } else {
                    return const SizedBox();
                  }

                  return SideTitleWidget(
                    meta: meta,
                    space: 6,
                    fitInside: SideTitleFitInsideData(
                      enabled: true,
                      axisPosition: meta.axisPosition,
                      parentAxisSize: meta.parentAxisSize,
                      distanceFromEdge: 0,
                    ),
                    child: Text(
                      label,
                      style: const TextStyle(fontSize: 12, color: _muted),
                    ),
                  );
                },
              ),
            ),
          ),

          lineBarsData: [
            LineChartBarData(
              spots: spots,

              isCurved: false, // straight lines like screenshot
              barWidth: 2,
              color: _line,

              dotData: FlDotData(
                show: values.length <= 30,
                getDotPainter: (spot, percent, bar, index) {
                  return FlDotCirclePainter(
                    radius: 3,
                    color: Colors.white,
                    strokeWidth: 1,
                    strokeColor: _line,
                  );
                },
              ),

              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _line.withOpacity(0.45),
                    _line.withOpacity(0.18),
                    _line.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ],

          lineTouchData: const LineTouchData(enabled: false),
        ),
        duration: const Duration(milliseconds: 350),
      ),
    );
  }
}
