import 'package:flutter/material.dart';
import 'package:tiktok_dashboard/controller/performance_controller.dart';
import 'package:tiktok_dashboard/views/base/simple_bar_chart.dart';
import 'package:get/get.dart';

const Color _creatorChangeBlue = Color(0xFF0075DB);
const Color _creatorChangeMuted = Color(0xFF8E8E93);

double _parseCreatorChangeAmount(String valPart) {
  final cleaned = valPart.replaceAll(r'$', '').replaceAll(',', '.').trim();
  return double.tryParse(cleaned) ?? 0.0;
}

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
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        const TextSpan(
                          text: "\$",
                          style: TextStyle(fontSize: 16),
                        ),
                        TextSpan(
                          text: d.creatorRewardsTotal,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ],
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
                        final changeAmt = _parseCreatorChangeAmount(valPart);
                        final isUp = changeAmt > 0;
                        final IconData trendIcon = changeAmt < 0
                            ? Icons.arrow_drop_down
                            : changeAmt > 0
                            ? Icons.arrow_drop_up
                            : Icons.arrow_drop_down;
                        final Color trendColor = isUp
                            ? _creatorChangeBlue
                            : _creatorChangeMuted;

                        return Row(
                          children: [
                            Icon(trendIcon, color: trendColor, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              "\$$valPart",
                              style: TextStyle(
                                color: trendColor,
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: const Column(
                children: [
                  _RewardTextFieldRow(
                    label: "Standard Reward",
                    color: Color(0xFF0075DB),
                  ),
                  SizedBox(height: 10),
                  _RewardTextFieldRow(
                    label: "Additional Reward",
                    color: Color(0xFF00D1FF),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Bar Chart Placeholder
            const SizedBox(
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

/// Purely local fields: not bound to [PerformanceModel], prefs, or the chart — no reads or writes.
class _RewardTextFieldRow extends StatefulWidget {
  final String label;
  final Color color;

  const _RewardTextFieldRow({required this.label, required this.color});

  @override
  State<_RewardTextFieldRow> createState() => _RewardTextFieldRowState();
}

class _RewardTextFieldRowState extends State<_RewardTextFieldRow> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '\$0.00');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              widget.label,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
        Expanded(
          child: TextField(
            controller: _controller,
            textAlign: TextAlign.right,
            // keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
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
