import 'package:flutter/material.dart';
import 'package:flutter_extension/controller/analytics_controller.dart';
import 'package:get/get.dart';

class RangeRow extends StatelessWidget {
  final AnalyticsController controller;
  const RangeRow({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return SizedBox(
        height: 30,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _RangePill(
              label: "7 days",
              active: controller.range.value == AnalyticsRange.d7,
              onTap: () => controller.setRange(AnalyticsRange.d7),
            ),
            _RangePill(
              label: "28 days",
              active: controller.range.value == AnalyticsRange.d28,
              onTap: () => controller.setRange(AnalyticsRange.d28),
            ),
            _RangePill(
              label: "60 days",
              active: controller.range.value == AnalyticsRange.d60,
              onTap: () => controller.setRange(AnalyticsRange.d60),
            ),
            _RangePill(
              label: "365 days",
              active: controller.range.value == AnalyticsRange.d365,
              onTap: () => controller.setRange(AnalyticsRange.d365),
            ),
            _RangePill(
              label: "Custom",
              active: controller.range.value == AnalyticsRange.custom,
              onTap: () => controller.setRange(
                AnalyticsRange.custom,
                custom: DateTimeRange(
                  start: controller.startDate.value,
                  end: controller.endDate.value,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _RangePill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _RangePill({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 5),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: active ? Colors.white : const Color(0xFF2C2C2E),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: active ? Colors.black : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
