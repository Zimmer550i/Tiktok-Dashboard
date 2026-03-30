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
      final maxVal = controller.getMaxChartValue();
      final isMonthly = controller.selectedTimeFilter.value != 0;
      final chartData =
          isMonthly ? d.monthlyChartValues : d.dailyChartValues;
      final barCount = chartData.length;

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
                              final double availableWidth = constraints.maxWidth;
                              final double computedBarWidth =
                                  availableWidth / barCount;

                              final double barWidth = computedBarWidth.clamp(
                                isMonthly ? 6.0 : 2.2,
                                isMonthly ? 20.0 : 6.0,
                              );

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: List.generate(barCount, (index) {
                                  final val = chartData[index];
                                  final isTarget = isMonthly
                                      ? (index == 0) // Jan
                                      : (index == 14); // Feb 15

                                  final double barHeight =
                                      (val / maxVal) * barMaxHeight;

                                  final String barTitle = isMonthly
                                      ? "Month ${index + 1} Data"
                                      : "Feb ${index + 1} Data";

                                  return GestureDetector(
                                    onTap: () => _edit(
                                      context,
                                      barTitle,
                                      val.toString(),
                                      (v) => controller.updateChartValue(
                                        index,
                                        v,
                                      ),
                                    ),
                                    onLongPress: () => _add(
                                      context,
                                      "Add after ${barTitle}",
                                      (v) => controller
                                          .insertChartValueAfter(index, v),
                                    ),
                                    child: Container(
                                      width: barWidth,
                                      height: barHeight.clamp(
                                        val > 0 ? 2.0 : 0.0,
                                        barMaxHeight,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isTarget
                                            ? const Color(0xFF4A4A4A)
                                            : const Color(0xFF2C2C2E),
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(2),
                                          topRight: Radius.circular(2),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              );
                            },
                          ),
                        ),
                      ),
                      // Tooltip
                      Positioned(
                        top: 25,
                        left: 45,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1C1C1E),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.12),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    controller.selectedTimeFilter.value == 0
                                        ? "Feb 15"
                                        : "Jan ${d.year}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 50),
                                  Text(
                                    "\$${d.creatorRewardsTotal}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Divider(
                                  color: Colors.white10,
                                  height: 1,
                                ),
                              ),
                              _TinyRow(
                                label: "Standard Reward",
                                value: "\$${d.standardReward}",
                                color: const Color(0xFF0075DB),
                              ),
                              const SizedBox(height: 10),
                              _TinyRow(
                                label: "Additional Reward",
                                value: "\$${d.additionalReward}",
                                color: const Color(0xFF00D1FF),
                              ),
                            ],
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
                final labelCount =
                    barCount < maxLabels ? barCount : maxLabels;
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
                ).toSet().toList()
                  ..sort();

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
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 11,
              ),
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

void _add(
  BuildContext context,
  String title,
  Function(String) onSave,
) {
  final tc = TextEditingController(text: "0");

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
