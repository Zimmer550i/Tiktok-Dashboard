import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_extension/controller/performance_controller.dart';
import 'package:flutter_extension/views/screen/home/performance_screen.dart';
import 'package:get/get.dart';

class SimpleBarChart extends StatefulWidget {
  const SimpleBarChart({super.key});

  @override
  State<SimpleBarChart> createState() => _SimpleBarChartState();
}

class _SimpleBarChartState extends State<SimpleBarChart> {
  final controller = Get.find<PerformanceController>();
  static const int _leftLabelCount = 4;
  final List<String> _leftAxisLabels = [];
  int? _editingLeftLabelIndex;
  double? _lastAxisMax;

  List<String> _defaultLeftAxisLabels(double maxVal) {
    return [
      maxVal.toStringAsFixed(1),
      (maxVal * 0.66).toStringAsFixed(1),
      (maxVal * 0.33).toStringAsFixed(1),
      "0",
    ];
  }

  void _syncLeftAxisLabels(double maxVal) {
    final shouldInitialize = _leftAxisLabels.length != _leftLabelCount;
    final axisChanged = _lastAxisMax == null || (_lastAxisMax! - maxVal).abs() > 0.001;

    if (shouldInitialize || (_editingLeftLabelIndex == null && axisChanged)) {
      _leftAxisLabels
        ..clear()
        ..addAll(_defaultLeftAxisLabels(maxVal));
      _lastAxisMax = maxVal;
    }
  }

  void _finishLeftLabelEdit() {
    setState(() => _editingLeftLabelIndex = null);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final d = controller.data.value;
      final isMonthly = controller.selectedTimeFilter.value != 0;
      final overlayVisible = controller.chartOverlayVisible.value;
      final activeIndex = controller.activeChartIndex.value;
      final activeValue = controller.activeChartValue.value;
      final activeDateLabel = controller.activeChartDateLabel.value;
      // Always render the full fixed-range timeline.
      final int barCount = isMonthly ? 12 : 31;
      final List<double> chartData = isMonthly
          ? d.monthlyChartValues
          : d.dailyChartValues;
      final List<double> standardData = isMonthly
          ? d.monthlyStandardValues
          : d.dailyStandardValues;
      final List<double> additionalData = isMonthly
          ? d.monthlyAdditionalValues
          : d.dailyAdditionalValues;

      // Compute max only from visible fixed range so bar heights match.
      double maxVal = 0.0;
      for (int i = 0; i < barCount; i++) {
        final std = i < standardData.length ? standardData[i] : 0.0;
        final add = i < additionalData.length ? additionalData[i] : 0.0;
        final v = std + add;
        if (v > maxVal) maxVal = v;
      }
      maxVal = maxVal > 0 ? maxVal * 1.2 : 3.0;
      _syncLeftAxisLabels(maxVal);

      return Column(
        children: [
          Expanded(
            child: Row(
              children: [
                // Y Axis Labels
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    _leftLabelCount,
                    (index) => _buildLeftAxisLabel(context, index: index),
                  ),
                ),
                const SizedBox(width: 8),
                // Chart Area
                Expanded(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Horizontal Dotted Lines
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(4, (index) {
                          return CustomPaint(
                            size: const Size(double.infinity, 0.5),
                            painter: DashedLinePainter(),
                          );
                        }),
                      ),
                      // Bars
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              if (barCount == 0) {
                                return const SizedBox.shrink();
                              }

                              const double barMaxHeight = 120.0;
                              final double availableWidth =
                                  constraints.maxWidth;
                              final double computedBarWidth =
                                  availableWidth / barCount;

                              final double barWidth = computedBarWidth.clamp(
                                isMonthly ? 6.0 : 2.2,
                                isMonthly ? 20.0 : 6.0,
                              );

                              double standardAt(int index) =>
                                  index < standardData.length
                                  ? standardData[index]
                                  : 0.0;

                              double additionalAt(int index) =>
                                  index < additionalData.length
                                  ? additionalData[index]
                                  : 0.0;

                              double valueAt(int index) {
                                final s = standardAt(index);
                                final a = additionalAt(index);
                                if (s + a > 0) return s + a;
                                return index < chartData.length
                                    ? chartData[index]
                                    : 0.0;
                              }

                              String dateLabelAt(int index) {
                                if (isMonthly) {
                                  const months = [
                                    "Jan",
                                    "Feb",
                                    "Mar",
                                    "Apr",
                                    "May",
                                    "Jun",
                                    "Jul",
                                    "Aug",
                                    "Sep",
                                    "Oct",
                                    "Nov",
                                    "Dec",
                                  ];
                                  return "${months[index]} ${d.year}";
                                }
                                return "Feb ${index + 1}";
                              }

                              final int activeIndexClamped = activeIndex.clamp(
                                0,
                                barCount - 1,
                              );

                              final double spacingBetween = barCount > 1
                                  ? (availableWidth - barCount * barWidth) /
                                        (barCount - 1)
                                  : 0.0;

                              const double tooltipWidth = 200.0;
                              final double barCenter =
                                  activeIndexClamped *
                                      (barWidth + spacingBetween) +
                                  barWidth / 2;
                              final double barLeft = barCenter - (barWidth / 2);
                              final double barRight =
                                  barCenter + (barWidth / 2);
                              const double sideGap = 8.0;

                              final bool canPlaceRight =
                                  barRight + sideGap + tooltipWidth <=
                                  availableWidth;
                              final bool canPlaceLeft =
                                  barLeft - sideGap - tooltipWidth >= 0;

                              final double tooltipLeft;
                              if (canPlaceRight) {
                                tooltipLeft = barRight + sideGap;
                              } else if (canPlaceLeft) {
                                tooltipLeft = barLeft - sideGap - tooltipWidth;
                              } else {
                                // In tight layouts, prioritize not covering the selected bar.
                                // Allow overflow outside the chart area (Stack uses clipBehavior: Clip.none).
                                tooltipLeft =
                                    activeIndexClamped < (barCount / 2)
                                    ? (barRight + sideGap)
                                    : (barLeft - sideGap - tooltipWidth);
                              }

                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTapDown: (details) {
                                      if (availableWidth <= 0 || barCount <= 0) {
                                        return;
                                      }
                                      final dx = details.localPosition.dx;
                                      final idx =
                                          ((dx / availableWidth) * barCount)
                                              .floor()
                                              .clamp(0, barCount - 1);
                                      final val = valueAt(idx);
                                      final isSameIndex =
                                          controller.activeChartIndex.value ==
                                          idx;

                                      // Tap same selected bar again -> hide overlay.
                                      if (overlayVisible && isSameIndex) {
                                        controller.chartOverlayVisible.value =
                                            false;
                                        return;
                                      }

                                      // Otherwise select/switch and show overlay.
                                      controller.setChartSelection(
                                        index: idx,
                                        value: val,
                                        dateLabel: dateLabelAt(idx),
                                        showOverlay: true,
                                      );
                                    },
                                    onLongPressStart: (details) {
                                      if (availableWidth <= 0 ||
                                          barCount <= 0) {
                                        return;
                                      }
                                      final dx = details.localPosition.dx;
                                      final idx =
                                          ((dx / availableWidth) * barCount)
                                              .floor()
                                              .clamp(0, barCount - 1);
                                      final std = standardAt(idx);
                                      final add = additionalAt(idx);
                                      var total = std + add;
                                      final fallback = idx < chartData.length
                                          ? chartData[idx]
                                          : 0.0;
                                      if (total <= 0 && fallback > 0) {
                                        total = fallback;
                                      }
                                      final displayStd = std + add > 0
                                          ? std
                                          : total;
                                      final displayAdd = std + add > 0
                                          ? add
                                          : 0.0;

                                      final String barTitle = isMonthly
                                          ? "Month ${idx + 1} Data"
                                          : "Feb ${idx + 1} Data";

                                      _editChartSplit(
                                        context,
                                        barTitle,
                                        displayStd.toStringAsFixed(2),
                                        displayAdd.toStringAsFixed(2),
                                        (standardV, additionalV) {
                                          controller.updateChartSplit(
                                            idx,
                                            standardV,
                                            additionalV,
                                          );

                                          final parsedStd =
                                              double.tryParse(
                                                standardV.trim().replaceAll(
                                                  ',',
                                                  '.',
                                                ),
                                              ) ??
                                              0.0;
                                          final parsedAdd =
                                              double.tryParse(
                                                additionalV.trim().replaceAll(
                                                  ',',
                                                  '.',
                                                ),
                                              ) ??
                                              0.0;
                                          controller.setChartSelection(
                                            index: idx,
                                            value: parsedStd + parsedAdd,
                                            dateLabel: dateLabelAt(idx),
                                            showOverlay: false,
                                          );
                                        },
                                      );
                                    },
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: SizedBox(
                                        height: barMaxHeight,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: List.generate(barCount, (
                                            index,
                                          ) {
                                            final std = standardAt(index);
                                            final add = additionalAt(index);
                                            var total = std + add;
                                            final fallback =
                                                index < chartData.length
                                                ? chartData[index]
                                                : 0.0;
                                            if (total <= 0 && fallback > 0) {
                                              total = fallback;
                                            }

                                            const standardColor = Color(
                                              0xFF0075DB,
                                            );
                                            const additionalColor = Color(
                                              0xFF00D1FF,
                                            );
                                            const topRadius = Radius.circular(
                                              2,
                                            );

                                            final double rawH =
                                                (total / maxVal) * barMaxHeight;
                                            final double totalBarH = total > 0
                                                ? rawH.clamp(2.0, barMaxHeight)
                                                : 2.0;

                                            final bool hasSplit = std + add > 0;
                                            final double effStd = hasSplit
                                                ? std
                                                : total;
                                            final double effAdd = hasSplit
                                                ? add
                                                : 0.0;

                                            double stdH = 0;
                                            double addH = 0;
                                            if (total > 0) {
                                              stdH =
                                                  (effStd / total) * totalBarH;
                                              addH =
                                                  (effAdd / total) * totalBarH;
                                            } else {
                                              stdH = totalBarH;
                                            }

                                            return SizedBox(
                                              width: barWidth,
                                              height: barMaxHeight,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  if (addH > 0)
                                                    Container(
                                                      height: addH,
                                                      width: barWidth,
                                                      decoration:
                                                          const BoxDecoration(
                                                            color:
                                                                additionalColor,
                                                            borderRadius:
                                                                BorderRadius.only(
                                                                  topLeft:
                                                                      topRadius,
                                                                  topRight:
                                                                      topRadius,
                                                                ),
                                                          ),
                                                    ),
                                                  if (stdH > 0)
                                                    Container(
                                                      height: stdH,
                                                      width: barWidth,
                                                      decoration: BoxDecoration(
                                                        color: standardColor,
                                                        borderRadius:
                                                            BorderRadius.only(
                                                              topLeft: addH > 0
                                                                  ? Radius.zero
                                                                  : topRadius,
                                                              topRight: addH > 0
                                                                  ? Radius.zero
                                                                  : topRadius,
                                                            ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            );
                                          }),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (overlayVisible)
                                    Positioned(
                                      top: 25,
                                      left: tooltipLeft,
                                      child: SizedBox(
                                        width: tooltipWidth,
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF1C1C1E),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            border: Border.all(
                                              color: Colors.white.withValues(
                                                alpha: 0.12,
                                              ),
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    activeDateLabel,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 50),
                                                  Text(
                                                    "\$${activeValue.toStringAsFixed(2)}",
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const Padding(
                                                padding: EdgeInsets.symmetric(
                                                  vertical: 8,
                                                ),
                                                child: Divider(
                                                  color: Colors.white10,
                                                  height: 1,
                                                ),
                                              ),
                                              _TinyRow(
                                                label: "Standard Reward",
                                                value:
                                                    "\$${standardAt(activeIndexClamped).toStringAsFixed(2)}",
                                                color: const Color(0xFF0075DB),
                                              ),
                                              const SizedBox(height: 10),
                                              _TinyRow(
                                                label: "Additional Reward",
                                                value:
                                                    "\$${additionalAt(activeIndexClamped).toStringAsFixed(2)}",
                                                color: const Color(0xFF00D1FF),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Builder(
              builder: (context) {
                final months = [
                  "Jan",
                  "Feb",
                  "Mar",
                  "Apr",
                  "May",
                  "Jun",
                  "Jul",
                  "Aug",
                  "Sep",
                  "Oct",
                  "Nov",
                  "Dec",
                ];

                if (barCount == 0) return const SizedBox.shrink();

                const maxLabels = 5;
                final labelCount = barCount < maxLabels ? barCount : maxLabels;
                if (labelCount <= 1) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isMonthly ? months.first : "1",
                        style: const TextStyle(
                          color: Color(0xFF8E8E93),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  );
                }

                final step = (barCount - 1) / (labelCount - 1);
                final labelIndices = List<int>.generate(
                  labelCount,
                  (i) => (i * step).round().clamp(0, barCount - 1),
                ).toSet().toList()..sort();

                final children = labelIndices.map((i) {
                  final text = isMonthly
                      ? (i < 12 ? months[i] : "M${(i + 1) - 12}")
                      : "${i + 1}";
                  return Text(
                    text,
                    style: const TextStyle(
                      color: Color(0xFF8E8E93),
                      fontSize: 10,
                    ),
                  );
                }).toList();

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: children,
                );
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildLeftAxisLabel(BuildContext context, {required int index}) {
    final text = _leftAxisLabels[index];
    final isEditing = _editingLeftLabelIndex == index;
    const labelStyle = TextStyle(color: Colors.white24, fontSize: 10);

    if (isEditing) {
      return SizedBox(
        width: 34,
        child: TextFormField(
          initialValue: text,
          autofocus: true,
          onTapOutside: (_) {
            FocusScope.of(context).unfocus();
            _finishLeftLabelEdit();
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
          onChanged: (v) => _leftAxisLabels[index] = v,
          onFieldSubmitted: (_) {
            FocusScope.of(context).unfocus();
            _finishLeftLabelEdit();
          },
        ),
      );
    }

    return GestureDetector(
      onTap: () => setState(() => _editingLeftLabelIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Text(text, style: labelStyle),
    );
  }
}

class _TinyRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _TinyRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white60, fontSize: 11),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

void _editChartSplit(
  BuildContext context,
  String title,
  String initialStandard,
  String initialAdditional,
  void Function(String standard, String additional) onSave,
) {
  final stdTc = TextEditingController(text: initialStandard);
  final addTc = TextEditingController(text: initialAdditional);

  Get.defaultDialog(
    title: title,
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: stdTc,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: false,
            ),
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: "Standard reward",
              hintText: "Enter standard reward",
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: addTc,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: false,
            ),
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: "Additional reward",
              hintText: "Enter additional reward",
            ),
          ),
        ],
      ),
    ),
    confirm: ElevatedButton(
      onPressed: () {
        onSave(stdTc.text.trim(), addTc.text.trim());
        Get.back();
      },
      child: const Text("Save"),
    ),
    barrierDismissible: true,
  );
}
