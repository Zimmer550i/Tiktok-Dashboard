import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_extension/controller/analytics_controller.dart';
import 'package:flutter_extension/model/metric_model.dart';
import 'package:get/get.dart';

class MetricCard extends StatelessWidget {
  final MetricModel metric;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const MetricCard({
    super.key,
    required this.metric,
    required this.onTap,
    required this.onEdit,
  });

  static const _bg = Color(0xFF1C1C1E);
  static const _border = Color.fromARGB(255, 125, 125, 130);
  static const _selected = Color(0xFF0075DB);
  static const _blue = Color(0xFF8ECAFF);
  static const _muted = Color(0xFF8E8E93);
  static const _muted2 = Color(0xFF636366);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final controller = Get.find<AnalyticsController>();

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Obx(() {
        final show365 = controller.show365;
        final changeInfo = _analyzeChange(metric.change.value);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.all(10),
          decoration: _buildDecoration(metric.isSelected.value),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTitle(textTheme),

              _buildValue(context, textTheme),

              if (!show365) _buildChangeRow(context, textTheme, changeInfo),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTitle(TextTheme textTheme) {
    return Text(
      metric.title,
      style: textTheme.bodyMedium?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }

  Widget _buildValue(BuildContext context, TextTheme textTheme) {
    return metric.isEditing.value
        ? TextFormField(
            initialValue: metric.value.value,
            autofocus: true,
            onTapOutside: (_) {
              FocusScope.of(context).unfocus();
              _finishEdit();
            },
            style: textTheme.headlineLarge?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: Colors.white,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-+,$KkMm]')),
            ],
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
            ),
            onChanged: (v) => metric.value.value = v,
            onFieldSubmitted: (_) {
              FocusScope.of(context).unfocus();
              _finishEdit();
            },
          )
        : GestureDetector(
            onTap: () => metric.isEditing.value = true,
            child: Text(
              metric.value.value,
              style: textTheme.headlineLarge?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
                color: Colors.white,
              ),
            ),
          );
  }

  Widget _buildChangeRow(
    BuildContext context,
    TextTheme textTheme,
    _ChangeInfo changeInfo,
  ) {
    if (metric.isEditing.value) {
      return Row(
        children: [
          if (changeInfo.trend != _ChangeTrend.none) _buildArrow(changeInfo),
          const SizedBox(width: 6),
          Expanded(
            child: TextFormField(
              initialValue: metric.change.value,
              onTapOutside: (_) {
                FocusScope.of(context).unfocus();
                _finishEdit();
              },
              style: textTheme.bodySmall?.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'[\n\r]')),
              ],
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
              ),
              onChanged: (v) => metric.change.value = v,
              onFieldSubmitted: (_) {
                FocusScope.of(context).unfocus();
                _finishEdit();
              },
            ),
          ),
        ],
      );
    }

    if (changeInfo.delta.isEmpty && changeInfo.secondary.isEmpty) {
      return Text(
        "0",
        style: textTheme.bodySmall?.copyWith(fontSize: 12, color: _muted),
      );
    }

    return GestureDetector(
      onTap: () => metric.isEditing.value = true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (changeInfo.trend != _ChangeTrend.none) _buildArrow(changeInfo),
          const SizedBox(width: 6),
          Text(
            changeInfo.delta,
            style: textTheme.bodySmall?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: changeInfo.trend == _ChangeTrend.up ? _blue : _muted,
            ),
          ),
          if (changeInfo.secondary.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(
              changeInfo.secondary,
              style: textTheme.bodySmall?.copyWith(
                fontSize: 12,
                color: _muted2,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildArrow(_ChangeInfo info) {
    switch (info.trend) {
      case _ChangeTrend.up:
        return const CircleAvatar(
          radius: 6,
          backgroundColor: _blue,
          child: Icon(
            Icons.arrow_upward_rounded,
            size: 10,
            color: _bg,
          ),
        );
      case _ChangeTrend.down:
        return const CircleAvatar(
          radius: 6,
          backgroundColor: _muted,
          child: Icon(
            Icons.arrow_downward_rounded,
            size: 10,
            color: _bg,
          ),
        );
      case _ChangeTrend.none:
        return const SizedBox.shrink();
    }
  }

  BoxDecoration _buildDecoration(bool selected) {
    return BoxDecoration(
      color: selected ? _selected.withValues(alpha: 0.05) : _bg,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: selected ? _selected : _border.withValues(alpha: 0.7),
      ),
    );
  }

  void _finishEdit() {
    metric.isEditing.value = false;
    onEdit();
  }

  // ================= LOGIC =================
  _ChangeInfo _analyzeChange(String raw) {
    final trimmed = raw.trim();

    if (trimmed.isEmpty) {
      return const _ChangeInfo("", "", 0, _ChangeTrend.none);
    }

    final openIndex = trimmed.indexOf('(');

    String deltaPart = trimmed;
    String secondaryPart = "";

    if (openIndex != -1) {
      deltaPart = trimmed.substring(0, openIndex).trim();
      secondaryPart = trimmed.substring(openIndex).trim();
    }

    // extract numeric value
    final match = RegExp(r'-?\+?\d+(\.\d+)?').firstMatch(deltaPart);

    double number = 0;

    if (match != null) {
      number = double.tryParse(match.group(0)!) ?? 0;
    }

    final trend = _trendFromDelta(deltaPart);
    return _ChangeInfo(deltaPart, secondaryPart, number, trend);
  }

  static _ChangeTrend _trendFromDelta(String s) {
    if (s.isEmpty) return _ChangeTrend.none;
    if (s[0] == '-') return _ChangeTrend.down;
    if (s == '0' || s == '+0') return _ChangeTrend.none;
    return _ChangeTrend.up;
  }

  // String _compact(double v) {
  //   if (v >= 1000000) return "${(v / 1000000).toStringAsFixed(1)}M";
  //   if (v >= 1000) return "${(v / 1000).toStringAsFixed(1)}K";
  //   return v == v.truncateToDouble() ? v.toInt().toString() : v.toString();
  // }
}


enum _ChangeTrend { up, down, none }

class _ChangeInfo {
  final String delta;
  final String secondary;
  final double number;
  final _ChangeTrend trend;

  const _ChangeInfo(this.delta, this.secondary, this.number, this.trend);

  bool get isPositive => number > 0;
  bool get isNegative => number < 0;
  bool get isNeutral => number == 0;
}
