import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MetricsLineChart extends StatefulWidget {
  final List<double> values;
  final String startLabel;
  final String endLabel;
  final double? maxY;
  final bool editable;
  final ValueChanged<List<double>>? onValuesChanged;

  /// When true (e.g. "7 Days" range), data points render as dots on the line.
  final bool showDots;

  const MetricsLineChart({
    super.key,
    required this.values,
    required this.startLabel,
    required this.endLabel,
    this.maxY,
    this.editable = false,
    this.onValuesChanged,
    this.showDots = false,
  });

  static const Color _line = Color(0xFF60B3FF);
  static const Color _grid = Color(0xFF3A3A3C);
  static const Color _axis = Color(0xFF48484A);
  static const Color _muted = Color(0xFF8E8E93);

  @override
  State<MetricsLineChart> createState() => _MetricsLineChartState();
}

class _MetricsLineChartState extends State<MetricsLineChart> {
  late List<double> _values;

  /// Editable copy of the four non-zero Y tick labels (high → low). Synced when
  /// [widget.values] changes from the parent.
  late List<String> _rightAxisLabels;

  int? _editingRightLabelIndex;

  /// Tweak this to adjust space under the four labels (matches former axis area).
  static const double _rightColumnBottomGap = 50;

  static const int _rightLabelCount = 4;

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

  List<String> _computeRightAxisLabels(double safeMaxY) {
    const maxRightTitles = 5;
    final rightInterval = safeMaxY / (maxRightTitles - 1);
    return List<String>.generate(
      _rightLabelCount,
      (i) {
        final tickIndex = _rightLabelCount - i;
        return _formatCompact(rightInterval * tickIndex);
      },
    );
  }

  void _finishRightLabelEdit() {
    setState(() => _editingRightLabelIndex = null);
  }

  @override
  void initState() {
    super.initState();
    _values = List<double>.from(widget.values);
    final maxYForAxis = _maxYForAxis();
    final safeMaxY = (maxYForAxis > 0 ? maxYForAxis : 1.0).toDouble();
    _rightAxisLabels = _computeRightAxisLabels(safeMaxY);
  }

  double _maxYForAxis() {
    final fromWidget = widget.maxY;
    if (fromWidget != null && fromWidget > 0) return fromWidget;
    if (_values.isEmpty) return 1.0;
    return _values.reduce((a, b) => a > b ? a : b);
  }

  @override
  void didUpdateWidget(covariant MetricsLineChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.values != widget.values || oldWidget.maxY != widget.maxY) {
      _values = List<double>.from(widget.values);
      final maxYForAxis = _maxYForAxis();
      final safeMaxY = (maxYForAxis > 0 ? maxYForAxis : 1.0).toDouble();
      _rightAxisLabels = _computeRightAxisLabels(safeMaxY);
      _editingRightLabelIndex = null;
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
              color: Colors.white.withValues(alpha: 0.08),
              width: 0.6,
            ),
          ),
          title: const Text(
            "Edit value",
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (pointLabel != null) ...[
                Text(
                  pointLabel,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.65)),
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
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.35),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: const Color(0xFF8FD3FF).withValues(alpha: 0.9),
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
                      content: Text(
                        "Please enter a valid non-negative number.",
                      ),
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
              color: Colors.white.withValues(alpha: 0.08),
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
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: const Color(0xFF8FD3FF).withValues(alpha: 0.9),
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

    final maxYForAxis = _maxYForAxis();
    final safeMaxY = (maxYForAxis > 0 ? maxYForAxis : 1.0).toDouble();

    final spots = List.generate(
      _values.length,
      (i) => FlSpot(i.toDouble(), _values[i]),
    );

    const labelStyle = TextStyle(
      fontSize: 12,
      color: MetricsLineChart._muted,
    );

    return SizedBox(
      height: 170,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
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
            drawVerticalLine: true,
            verticalInterval: 1,
            horizontalInterval: 12,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: MetricsLineChart._grid.withValues(alpha: 0.6),
                strokeWidth: 1,
                dashArray: const [2, 2],
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: MetricsLineChart._grid.withValues(alpha: 0.25),
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

            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false, reservedSize: 0),
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
              barWidth: 1.5,
              color: MetricsLineChart._line,

              dotData: FlDotData(
                show: widget.showDots,
                getDotPainter: (spot, percent, bar, index) {
                  return FlDotCirclePainter(
                    radius: 1.5,
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
                    MetricsLineChart._line.withValues(alpha: 0.55),
                    MetricsLineChart._line.withValues(alpha: 0.28),
                    MetricsLineChart._line.withValues(alpha: 0.05),
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
                final insertIndex = spotIndex == null
                    ? _values.length
                    : spotIndex + 1;
                _addValueAt(insertIndex);
                return;
              }
            },
          ),
        ),
        duration: const Duration(milliseconds: 350),
      ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                height: 170 - _rightColumnBottomGap,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    _rightLabelCount,
                    (i) => _buildRightAxisLabel(
                      context,
                      index: i,
                      labelStyle: labelStyle,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: _rightColumnBottomGap),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRightAxisLabel(
    BuildContext context, {
    required int index,
    required TextStyle labelStyle,
  }) {
    final text = _rightAxisLabels[index];
    final isEditing = _editingRightLabelIndex == index;

    if (isEditing) {
      return SizedBox(
        width: 34,
        child: TextFormField(
          initialValue: text,
          autofocus: true,
          onTapOutside: (_) {
            FocusScope.of(context).unfocus();
            _finishRightLabelEdit();
          },
          style: labelStyle,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-+KkMm,Bb]')),
          ],
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.zero,
            border: InputBorder.none,
          ),
          onChanged: (v) => _rightAxisLabels[index] = v,
          onFieldSubmitted: (_) {
            FocusScope.of(context).unfocus();
            _finishRightLabelEdit();
          },
        ),
      );
    }

    return GestureDetector(
      onTap: () => setState(() => _editingRightLabelIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Text(text, style: labelStyle),
    );
  }
}
