import 'package:flutter/material.dart';
import 'package:flutter_extension/controller/performance_controller.dart';
import 'package:flutter_extension/views/screen/home/performance_screen.dart';
import 'package:get/get.dart';

class SimpleBarChart extends StatelessWidget {
  final controller = Get.find<PerformanceController>();

  SimpleBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final d = controller.data.value;
      final isMonthly = controller.selectedTimeFilter.value != 0;
      // Always render the full fixed-range timeline.
      final int barCount = isMonthly ? 12 : 31;
      final List<double> chartData =
          isMonthly ? d.monthlyChartValues : d.dailyChartValues;

      // Compute max only from visible fixed range so bar heights match.
      double maxVal = 0.0;
      for (int i = 0; i < barCount; i++) {
        final v = i < chartData.length ? chartData[i] : 0.0;
        if (v > maxVal) maxVal = v;
      }
      maxVal = maxVal > 0 ? maxVal * 1.2 : 3.0;

      return Column(
        children: [
          Expanded(
            child: Row(
              children: [
                // Y Axis Labels
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      maxVal.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white24,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      (maxVal * 0.66).toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white24,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      (maxVal * 0.33).toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white24,
                        fontSize: 10,
                      ),
                    ),
                    const Text(
                      "0",
                      style: TextStyle(color: Colors.white24, fontSize: 10),
                    ),
                  ],
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

                              final double barMaxHeight = 120.0;
                              final double availableWidth =
                                  constraints.maxWidth;
                              final double computedBarWidth =
                                  availableWidth / barCount;

                              final double barWidth = computedBarWidth.clamp(
                                isMonthly ? 6.0 : 2.2,
                                isMonthly ? 20.0 : 6.0,
                              );

                              double valueAt(int index) => index < chartData.length
                                  ? chartData[index]
                                  : 0.0;

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

                              final int activeIndex =
                                  controller.activeChartIndex.value;
                              final int activeIndexClamped =
                                  activeIndex.clamp(0, barCount - 1);

                              final double spacingBetween =
                                  barCount > 1
                                      ? (availableWidth - barCount * barWidth) /
                                          (barCount - 1)
                                      : 0.0;

                              const double tooltipWidth = 200.0;
                              final double barCenter = activeIndexClamped *
                                      (barWidth + spacingBetween) +
                                  barWidth / 2;
                              final double barLeft = barCenter - (barWidth / 2);
                              final double barRight = barCenter + (barWidth / 2);
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
                                tooltipLeft = activeIndexClamped < (barCount / 2)
                                    ? (barRight + sideGap)
                                    : (barLeft - sideGap - tooltipWidth);
                              }

                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTapDown: (details) {
                                      if (availableWidth <= 0 ||
                                          barCount <= 0) return;
                                      final dx = details.localPosition.dx;
                                      final idx = ((dx / availableWidth) *
                                                  barCount)
                                              .floor()
                                              .clamp(0, barCount - 1);
                                      final val = valueAt(idx);
                                      final overlayVisible =
                                          controller.chartOverlayVisible.value;
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
                                          barCount <= 0) return;
                                      final dx = details.localPosition.dx;
                                      final idx = ((dx / availableWidth) *
                                                  barCount)
                                              .floor()
                                              .clamp(0, barCount - 1);
                                      final val = valueAt(idx);

                                      final String barTitle = isMonthly
                                          ? "Month ${idx + 1} Data"
                                          : "Feb ${idx + 1} Data";

                                      _edit(
                                        context,
                                        barTitle,
                                        val.toString(),
                                        (v) {
                                          controller.updateChartValue(idx, v);

                                          final parsed = double.tryParse(
                                                v.trim().replaceAll(',', '.'),
                                              ) ??
                                              0.0;
                                          // Update overlay value if it was already shown.
                                          controller.setChartSelection(
                                            index: idx,
                                            value: parsed,
                                            dateLabel: dateLabelAt(idx),
                                            showOverlay: false,
                                          );
                                        },
                                      );
                                    },
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: List.generate(barCount,
                                          (index) {
                                        final val = valueAt(index);
                                        final isTarget = isMonthly
                                            ? (index == 0) // Jan
                                            : (index == 14); // Feb 15

                                        final double barHeight =
                                            (val / maxVal) * barMaxHeight;

                                        return Container(
                                          width: barWidth,
                                          height: barHeight.clamp(
                                            // Keep zero values visible/clickable.
                                            2.0,
                                            barMaxHeight,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isTarget
                                                ? const Color(0xFF4A4A4A)
                                                : const Color(0xFF2C2C2E),
                                            borderRadius:
                                                const BorderRadius.only(
                                              topLeft:
                                                  Radius.circular(2),
                                              topRight:
                                                  Radius.circular(2),
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                  if (controller.chartOverlayVisible.value)
                                    Positioned(
                                      top: 25,
                                      left: tooltipLeft,
                                      child: SizedBox(
                                        width: tooltipWidth,
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF1C1C1E),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                              color: Colors.white
                                                  .withOpacity(0.12),
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
                                                    controller
                                                        .activeChartDateLabel
                                                        .value,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 50),
                                                  Text(
                                                    "\$${controller.activeChartValue.value.toStringAsFixed(2)}",
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 8),
                                                child: Divider(
                                                  color: Colors.white10,
                                                  height: 1,
                                                ),
                                              ),
                                              _TinyRow(
                                                label: "Standard Reward",
                                                value:
                                                    "\$${controller.activeChartValue.value.toStringAsFixed(2)}",
                                                color: const Color(0xFF0075DB),
                                              ),
                                              const SizedBox(height: 10),
                                              _TinyRow(
                                                label: "Additional Reward",
                                                value: "\$0.00",
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

void _edit(
  BuildContext context,
  String title,
  String initial,
  Function(String) onSave,
) {
  final tc = TextEditingController(text: initial);

  Get.defaultDialog(
    title: title,
    content: TextField(
      controller: tc,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: false,
      ),
      style: const TextStyle(color: Colors.white),
      decoration: const InputDecoration(hintText: "Enter value"),
    ),
    confirm: ElevatedButton(
      onPressed: () {
        onSave(tc.text.trim());
        Get.back();
      },
      child: const Text("Save"),
    ),
    barrierDismissible: true,
  );
}
