import 'package:flutter/material.dart';
import 'package:flutter_extension/views/base/metric_card.dart';
import 'package:flutter_extension/views/base/metric_line_chart.dart';
import 'package:get/get.dart';
import '../../controller/analytics_controller.dart';

class KeyMetricsSection extends StatelessWidget {
  final int tab;
  const KeyMetricsSection({super.key, required this.tab});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AnalyticsController>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Obx(() {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text(
                  "Key metrics",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 6),
                Icon(Icons.info_outline, size: 16, color: Color(0xFF8E8E93)),
              ],
            ),
            const SizedBox(height: 4),
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () async {
                final now = DateTime.now();
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(now.year - 5),
                  lastDate: DateTime(now.year + 1),
                  initialDateRange: DateTimeRange(
                    start: controller.startDate.value,
                    end: controller.endDate.value,
                  ),
                );

                if (picked != null) {
                  await controller.setRange(
                    AnalyticsRange.custom,
                    custom: picked,
                  );
                }
              },
              child: Text(
                controller.dateLabel,
                style: const TextStyle(fontSize: 13, color: Color(0xFF8E8E93)),
              ),
            ),

            const SizedBox(height: 16),

            // Grid
            if (tab == 1) ...[
              LayoutBuilder(
                builder: (context, constraints) {
                  const spacing = 14.0;
                  final total = constraints.maxWidth;
                  final cardWidth = (total - spacing) / 2;
                  final cardHeight = controller.show365
                      ? (cardWidth * 0.36)
                      : (cardWidth * 0.46);
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.metrics.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      mainAxisExtent: cardHeight,
                    ),
                    itemBuilder: (_, index) {
                      final metric = controller.metrics[index];
                      return MetricCard(
                        metric: metric,
                        onTap: () => controller.selectMetric(index),
                        onEdit: () => controller.saveAnalytics(),
                      );
                    },
                  );
                },
              ),
            ],

            if (tab == 3) ...[
              LayoutBuilder(
                builder: (context, constraints) {
                  const spacing = 14.0;
                  final total = constraints.maxWidth;
                  final cardWidth = (total - spacing) / 2;
                  final cardHeight = controller.show365
                      ? (cardWidth * 0.40)
                      : (cardWidth * 0.50);
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.viewerMetrics.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      mainAxisExtent: cardHeight,
                    ),
                    itemBuilder: (_, index) {
                      final metric = controller.viewerMetrics[index];
                      return MetricCard(
                        metric: metric,
                        onTap: () => controller.selectViewerMetric(index),
                        onEdit: () => controller.saveAnalytics(),
                      );
                    },
                  );
                },
              ),
            ],

            const SizedBox(height: 18),

            Container(height: 1, color: Colors.white.withValues(alpha: 0.06)),
            const SizedBox(height: 12),

            // Graph
            MetricsLineChart(
              values: controller.series,
              maxY: controller.yMax,
              startLabel: _fmt(controller.startDate.value),
              endLabel: _fmt(controller.endDate.value),
              editable: true,
              showDots: controller.range.value == AnalyticsRange.d7,
              onValuesChanged: (v) => controller.updateSeriesValues(v),
            ),
          ],
        );
      }),
    );
  }

  static String _fmt(DateTime d) {
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
    return "${months[d.month - 1]} ${d.day}";
  }
}
