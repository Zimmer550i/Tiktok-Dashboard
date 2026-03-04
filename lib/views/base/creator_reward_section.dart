import 'package:flutter/material.dart';
import 'package:flutter_extension/controller/performance_controller.dart';
import 'package:flutter_extension/views/screen/home/performance_screen.dart';
import 'package:get/get.dart';

class CreatorRewardsSection extends StatelessWidget {
  final controller = Get.find<PerformanceController>();

  CreatorRewardsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final d = controller.data.value;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TimeFilter(),

            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Text(
                      "Creator Rewards",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Color(0xFF8E8E93),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => _edit(
                    context,
                    "Edit Year",
                    d.year,
                    controller.updateYear,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        d.year,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _edit(
                context,
                "Total Rewards",
                d.creatorRewardsTotal,
                controller.updateCreatorRewardsTotal,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "\$${d.creatorRewardsTotal}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => _edit(
                      context,
                      "Change Stats",
                      d.creatorRewardsChange,
                      controller.updateCreatorRewardsChange,
                    ),
                    child: Builder(
                      builder: (context) {
                        final parts = d.creatorRewardsChange.split('(');
                        final valPart = parts[0].trim();
                        final datePart = parts.length > 1 ? "(${parts[1]}" : "";

                        return Row(
                          children: [
                            const Icon(
                              Icons.cloud_upload,
                              color: Color(0xFF0075DB),
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "\$$valPart",
                              style: const TextStyle(
                                color: Color(0xFF0075DB),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (datePart.isNotEmpty)
                              Text(
                                " $datePart",
                                style: const TextStyle(
                                  color: Color(0xFF8E8E93),
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () => _edit(
                context,
                "Date Range",
                d.dateRange,
                controller.updateDateRange,
              ),
              child: Text(
                d.dateRange,
                style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 12),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                children: [
                  _SummaryRow(
                    label: "Standard Reward",
                    value: "\$${d.standardReward}",
                    onTap: () => _edit(
                      context,
                      "Standard Reward",
                      d.standardReward,
                      controller.updateStandardReward,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _SummaryRow(
                    label: "Additional Reward",
                    value: "\$${d.additionalReward}",
                    onTap: () => _edit(
                      context,
                      "Additional Reward",
                      d.additionalReward,
                      controller.updateAdditionalReward,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Bar Chart Placeholder
            SizedBox(
              height: 150,
              width: double.infinity,
              child: _SimpleBarChart(),
            ),
          ],
        ),
      );
    });
  }
}

class _TimeFilter extends StatelessWidget {
  final controller = Get.find<PerformanceController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Row(
        children: [
          _filterBtn("By month", 0),
          const SizedBox(width: 8),
          _filterBtn("365 days", 1),
          const SizedBox(width: 8),
          _filterBtn("Custom", 2, hasArrow: true),
        ],
      );
    });
  }

  Widget _filterBtn(String text, int index, {bool hasArrow = false}) {
    final isSelected = controller.selectedTimeFilter.value == index;

    return GestureDetector(
      onTap: () => controller.setTimeFilter(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.black : Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (hasArrow) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                size: 14,
                color: isSelected ? Colors.black : Colors.white,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SimpleBarChart extends StatelessWidget {
  final controller = Get.find<PerformanceController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final d = controller.data.value;
      return Column(
        children: [
          Expanded(
            child: Row(
              children: [
                // Y Axis Labels
                const Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "3",
                      style: TextStyle(color: Colors.white24, fontSize: 10),
                    ),
                    Text(
                      "2",
                      style: TextStyle(color: Colors.white24, fontSize: 10),
                    ),
                    Text(
                      "1",
                      style: TextStyle(color: Colors.white24, fontSize: 10),
                    ),
                    Text(
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: () {
                            final isMonthly =
                                controller.selectedTimeFilter.value != 0;
                            final barCount = isMonthly ? 12 : 31;
                            final barWidth = isMonthly ? 20.0 : 4.0;
                            final chartData = isMonthly
                                ? d.monthlyChartValues
                                : d.dailyChartValues;

                            return List.generate(barCount, (index) {
                              final val = chartData.length > index
                                  ? chartData[index]
                                  : 0.0;
                              final isTarget = index == 0;

                              final double barMaxHeight = 120.0;
                              final double barHeight =
                                  (val / 3.0) * barMaxHeight;

                              return GestureDetector(
                                onTap: () => _edit(
                                  context,
                                  isMonthly
                                      ? "Month ${index + 1} Data"
                                      : "Day ${index + 1} Data",
                                  val.toString(),
                                  (v) => controller.updateChartValue(index, v),
                                ),
                                child: Container(
                                  width: barWidth,
                                  height: barHeight.clamp(0, barMaxHeight),
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
                            });
                          }(),
                        ),
                      ),
                      // Tooltip
                      Positioned(
                        top: 10,
                        left: 100,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C2C2E).withOpacity(0.95),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    controller.selectedTimeFilter.value == 0
                                        ? "Jan 1, ${d.year}"
                                        : "Jan ${d.year}",
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(width: 40),
                                  Text(
                                    "\$${d.creatorRewardsTotal}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
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
                              const SizedBox(height: 6),
                              _TinyRow(
                                label: "Standard Reward",
                                value: "\$${d.standardReward}",
                                color: const Color(0xFF8ECAFF),
                              ),
                              const SizedBox(height: 8),
                              _TinyRow(
                                label: "Additional Reward",
                                value: "\$${d.additionalReward}",
                                color: const Color(0xFF8ECAFF),
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
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: controller.selectedTimeFilter.value == 0
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "1",
                        style: TextStyle(
                          color: Color(0xFF8E8E93),
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        "5",
                        style: TextStyle(
                          color: Color(0xFF8E8E93),
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        "10",
                        style: TextStyle(
                          color: Color(0xFF8E8E93),
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        "15",
                        style: TextStyle(
                          color: Color(0xFF8E8E93),
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        "20",
                        style: TextStyle(
                          color: Color(0xFF8E8E93),
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        "25",
                        style: TextStyle(
                          color: Color(0xFF8E8E93),
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        "31",
                        style: TextStyle(
                          color: Color(0xFF8E8E93),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Jan",
                        style: TextStyle(
                          color: Color(0xFF8E8E93),
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        "Mar",
                        style: TextStyle(
                          color: Color(0xFF8E8E93),
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        "May",
                        style: TextStyle(
                          color: Color(0xFF8E8E93),
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        "Jul",
                        style: TextStyle(
                          color: Color(0xFF8E8E93),
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        "Sep",
                        style: TextStyle(
                          color: Color(0xFF8E8E93),
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        "Nov",
                        style: TextStyle(
                          color: Color(0xFF8E8E93),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      );
    });
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFF8ECAFF),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
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

void _edit(
  BuildContext context,
  String title,
  String initial,
  Function(String) onSave,
) {
  final controller = TextEditingController(text: initial);

  Get.defaultDialog(
    title: title,
    content: TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: const InputDecoration(hintText: "Enter value"),
    ),
    confirm: ElevatedButton(
      onPressed: () {
        onSave(controller.text);
        Get.back();
      },
      child: const Text("Save"),
    ),
  );
}
