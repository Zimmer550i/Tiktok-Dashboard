import 'package:flutter/material.dart';
import 'package:flutter_extension/controller/performance_controller.dart';
import 'package:get/get.dart';

class RewardsCard extends StatelessWidget {
  final c = Get.find<PerformanceController>();

  RewardsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final d = c.data.value;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text(
                  "Rewards calculation",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 6),
                Icon(Icons.info_outline, size: 16, color: Color(0xFF8E8E93)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _MetricItem(
                  title: "Rewards",
                  value: "\$${d.rewards}",
                  onTap: () =>
                      _edit(context, "Rewards", d.rewards, c.updateRewards),
                ),
                Container(height: 24, width: 0.5, color: Colors.white10),
                const SizedBox(width: 24),
                _MetricItem(
                  title: "RPM",
                  value: d.rpm,
                  onTap: () => _edit(context, "RPM", d.rpm, c.updateRPM),
                ),
                Container(height: 24, width: 0.5, color: Colors.white10),
                const SizedBox(width: 48),
                _MetricItem(
                  title: "Qualified views",
                  value: d.qualifiedViews,
                  onTap: () => _edit(
                    context,
                    "Qualified Views",
                    d.qualifiedViews,
                    c.updateQualifiedViews,
                  ),
                  fontSize: 12,
                  color: const Color(0xFF707070),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.only(right: 100),
              child: Divider(color: Colors.white10),
            ),
            const SizedBox(height: 8),
            const Text(
              "video must have at least 1,000 qualified views\nto be included in RPM calculation",
              style: TextStyle(color: Color(0xFF8E8E93), fontSize: 12),
            ),
          ],
        ),
      );
    });
  }
}

class _MetricItem extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback onTap;
  final double? fontSize;
  final Color? color;

  const _MetricItem({
    required this.title,
    required this.value,
    required this.onTap,
    this.fontSize = 16,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),

          const SizedBox(height: 4),

          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
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
