import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MetricsLineChart extends StatefulWidget {
  final List<double> values;
  final String startLabel;
  final String endLabel;
  final double? maxY;
  final bool editable;
  final ValueChanged<List<double>>? onValuesChanged;

  const MetricsLineChart({
    super.key,
    required this.values,
    required this.startLabel,
    required this.endLabel,
    this.maxY,
    this.editable = false,
    this.onValuesChanged,
  });

  static const Color _line = Color(0xFF8FD3FF);
  static const Color _grid = Color(0xFF3A3A3C);
  static const Color _axis = Color(0xFF48484A);
  static const Color _muted = Color(0xFF8E8E93);

  @override
  State<MetricsLineChart> createState() => _MetricsLineChartState();
}

class _MetricsLineChartState extends State<MetricsLineChart> {
  late List<double> _values;

  String _formatCompact(double value) {
    final abs = value.abs();

    String trim(double v, {int decimals = 1}) {
      final s = v.toStringAsFixed(decimals);
      // Remove trailing ".0" for cleaner axis labels.
      return s.replaceAll(RegExp(r'\.0$'), '');
    }

    if (abs >= 1e9) return '${trim(value / 1e9)}B';
    if (abs >= 1e6) return '${trim(value / 1e6)}M';
    if (abs >= 1e3) return '${trim(value / 1e3)}K';

    if (abs >= 1) return value.toStringAsFixed(0);
    return value.toStringAsFixed(1);
  }

  @override
  void initState() {
    super.initState();
    _values = List<double>.from(widget.values);
  }

  @override
  void didUpdateWidget(covariant MetricsLineChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.values != widget.values) {
      _values = List<double>.from(widget.values);
    }
  }

  Future<void> _editValueAt(int index) async {
    if (!mounted) return;
    if (index < 0 || index >= _values.length) return;

    final tc = TextEditingController(text: _values[index].toString());

    await showDialog<void>(
      context: context,
      builder: (context) {
        final pointLabel = (index == 0 || index == _values.length - 1)
            ? (index == 0 ? widget.startLabel : widget.endLabel)
            : null;

        return AlertDialog(
          backgroundColor: const Color(0xFF1C1C1E),
          surfaceTintColor: const Color(0xFF1C1C1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Colors.white.withOpacity(0.08),
              width: 0.6,
            ),
          ),
          title: const Text("Edit value",
              style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (pointLabel != null) ...[
                Text(
                  pointLabel,
                  style: TextStyle(color: Colors.white.withOpacity(0.65)),
                ),
                const SizedBox(height: 8),
              ],
              TextField(
                controller: tc,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: false,
                ),
                decoration: InputDecoration(
                  hintText: "Enter a number",
                  hintStyle:
                      TextStyle(color: Colors.white.withOpacity(0.35)),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.white.withOpacity(0.08)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: const Color(0xFF8FD3FF).withOpacity(0.9),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final raw = tc.text.trim();
                final normalized = raw.replaceAll(',', '.');
                final parsed = double.tryParse(normalized);

                if (parsed == null || !parsed.isFinite || parsed < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text("Please enter a valid non-negative number."),
                    ),
                  );
                  return;
                }

                final updated = List<double>.from(_values);
                updated[index] = parsed;

                Navigator.of(context).pop();
                if (!mounted) return;

                setState(() => _values = updated);
                widget.onValuesChanged?.call(updated);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addValueAt(int insertIndex) async {
    if (!mounted) return;
    if (insertIndex < 0 || insertIndex > _values.length) return;

    final tc = TextEditingController(text: "0");

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1C1C1E),
          surfaceTintColor: const Color(0xFF1C1C1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Colors.white.withOpacity(0.08),
              width: 0.6,
            ),
          ),
          title: const Text(
            "Add data point",
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: tc,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: false,
            ),
            decoration: InputDecoration(
              hintText: "Enter a number",
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.35)),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: const Color(0xFF8FD3FF).withOpacity(0.9),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final raw = tc.text.trim();
                final normalized = raw.replaceAll(',', '.');
                final parsed = double.tryParse(normalized);

                if (parsed == null || !parsed.isFinite || parsed < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Please enter a valid non-negative number.",
                      ),
                    ),
                  );
                  return;
                }

                final updated = List<double>.from(_values);
                updated.insert(insertIndex, parsed);

                Navigator.of(context).pop();
                if (!mounted) return;

                setState(() => _values = updated);
                widget.onValuesChanged?.call(updated);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_values.isEmpty) {
      return const SizedBox(height: 170);
    }

    final maxYForAxis = (widget.maxY != null && widget.maxY! > 0)
        ? widget.maxY!
        : _values.reduce((a, b) => a > b ? a : b);

    final safeMaxY = (maxYForAxis > 0 ? maxYForAxis : 1.0).toDouble();
    const maxRightTitles = 5;
    final rightInterval = safeMaxY / (maxRightTitles - 1);

    final spots = List.generate(
      _values.length,
      (i) => FlSpot(i.toDouble(), _values[i]),
    );

    return SizedBox(
      height: 170,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (_values.length - 1).toDouble(),
          minY: 0,
          maxY: safeMaxY,

          borderData: FlBorderData(
            show: true,
            border: const Border(
              bottom: BorderSide(color: MetricsLineChart._axis, width: 1),
            ),
          ),

          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 12,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: MetricsLineChart._grid.withOpacity(0.6),
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
                interval: rightInterval,
                reservedSize: 34,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const SizedBox();

                  // Only show labels close to our intended tick marks,
                  // keeping the number of visible labels <= 5.
                  final tickIndex = (value / rightInterval).round();
                  final expected = tickIndex * rightInterval;
                  if ((value - expected).abs() > rightInterval.abs() * 0.02) {
                    return const SizedBox();
                  }

                  return Text(
                    _formatCompact(value),
                    style: const TextStyle(
                      fontSize: 12,
                      color: MetricsLineChart._muted,
                    ),
                  );
                },
              ),
            ),

            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: (_values.length - 1).toDouble(),
                reservedSize: 22,
                getTitlesWidget: (value, meta) {
                  String label = "";
                  if (value == 0) {
                    label = widget.startLabel;
                  } else if (value == _values.length - 1) {
                    label = widget.endLabel;
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
                      style: const TextStyle(
                        fontSize: 12,
                        color: MetricsLineChart._muted,
                      ),
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
              color: MetricsLineChart._line,

              dotData: FlDotData(
                show: _values.length <= 30,
                getDotPainter: (spot, percent, bar, index) {
                  return FlDotCirclePainter(
                    radius: 2,
                    color: Colors.white,
                    strokeWidth: 1,
                    strokeColor: MetricsLineChart._line,
                  );
                },
              ),

              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    MetricsLineChart._line.withOpacity(0.45),
                    MetricsLineChart._line.withOpacity(0.18),
                    MetricsLineChart._line.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ],

          lineTouchData: LineTouchData(
            enabled: widget.editable,
            handleBuiltInTouches: false,
            touchCallback: (event, response) {
              if (!widget.editable) return;
              if (event is FlTapUpEvent) {
                if (response?.lineBarSpots == null ||
                    response!.lineBarSpots!.isEmpty) {
                  return;
                }

                final spotIndex = response.lineBarSpots!.first.spotIndex;
                _editValueAt(spotIndex);
                return;
              }

              if (event is FlLongPressStart) {
                final spotIndex = response?.lineBarSpots?.isNotEmpty == true
                    ? response!.lineBarSpots!.first.spotIndex
                    : null;
                final insertIndex =
                    spotIndex == null ? _values.length : spotIndex + 1;
                _addValueAt(insertIndex);
                return;
              }
            },
          ),
        ),
        duration: const Duration(milliseconds: 350),
      ),
    );
  }
}
