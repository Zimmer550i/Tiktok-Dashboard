import 'package:flutter/material.dart';
import 'package:flutter_extension/controller/performance_controller.dart';
import 'package:flutter_extension/views/base/simple_bar_chart.dart';
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
                    color: const Color(0xFF0075DB),
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
                    color: const Color(0xFF00D1FF),
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
              child: SimpleBarChart(),
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
          _filterBtn("By year", 1),
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

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.color,
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
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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
