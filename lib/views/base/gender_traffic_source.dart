import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_extension/controller/analytics_controller.dart';
import 'package:flutter_extension/data/model/gender_model.dart';
import 'package:get/get.dart';
import 'dart:math' as math;

class GenderTrafficSourceSection extends StatelessWidget {
  GenderTrafficSourceSection({super.key});

  final controller = Get.find<AnalyticsController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Obx(() {
        final tabIndex = controller.selectedTrafficTab.value;
        final data = tabIndex == 0
            ? controller.gender.toList()
            : tabIndex == 1
            ? controller.age.toList()
            : controller.locations.toList();

        if (data.isEmpty) {
          return const SizedBox(
            height: 120,
            child: Center(
              child: Text("No data", style: TextStyle(color: Colors.white70)),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Header(),
            const SizedBox(height: 16),
            const _Tabs(),
            const SizedBox(height: 40),
            _GaugeChart(data),
            ...data.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return _TrafficRow(
                item: item,
                onSave: controller.saveTraffic,
                isLast: index == data.length - 1,
              );
            }),
          ],
        );
      }),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Text(
          "Traffic Source",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        SizedBox(width: 6),
        Icon(Icons.info_outline, size: 18, color: Color(0xFF8E8E93)),
      ],
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs();

  Widget _tab(int index, String title, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF2C3843) : const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: active ? const Color(0xFF8ECAFF) : Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AnalyticsController>();
    return Obx(() {
      final selected = controller.selectedTrafficTab.value;
      return Row(
        children: [
          _tab(
            0,
            "Gender",
            selected == 0,
            () => controller.selectTrafficTab(0),
          ),
          const SizedBox(width: 10),
          _tab(1, "Age", selected == 1, () => controller.selectTrafficTab(1)),
          const SizedBox(width: 10),
          _tab(
            2,
            "Locations",
            selected == 2,
            () => controller.selectTrafficTab(2),
          ),
        ],
      );
    });
  }
}

class _GaugeChart extends StatelessWidget {
  final List<GenderModel> data;

  const _GaugeChart(this.data);

  @override
  Widget build(BuildContext context) {
    final total = data.fold<double>(0.0, (sum, e) => sum + e.percent.value);

    if (data.isEmpty || total <= 0) {
      return const SizedBox(height: 120);
    }

    return SizedBox(
      height: 120,
      width: double.infinity,
      child: Center(
        child: AspectRatio(
          aspectRatio: 2,
          child: Transform.rotate(
            angle: -math.pi / 2,
            child: PieChart(
              PieChartData(
                startDegreeOffset: 270,
                sectionsSpace: 2,
                centerSpaceRadius: 60,
                sections: [
                  ...data.map((item) {
                    return PieChartSectionData(
                      value: item.percent.value,
                      showTitle: false,
                      radius: 25,
                      color: item.color,
                    );
                  }),
                  PieChartSectionData(
                    value: total,
                    color: Colors.transparent,
                    showTitle: false,
                    radius: 25,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TrafficRow extends StatelessWidget {
  final GenderModel item;
  final VoidCallback onSave;
  final bool isLast;

  const _TrafficRow({
    required this.item,
    required this.onSave,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final editing = item.isEditing.value;

      return GestureDetector(
        onLongPress: () => item.isEditing.value = true,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: item.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: editing
                        ? TextFormField(
                            initialValue: item.title.value,
                            onChanged: (v) => item.title.value = v,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          )
                        : Text(
                            item.title.value,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                  ),
                  editing
                      ? SizedBox(
                          width: 60,
                          child: TextFormField(
                            initialValue: (item.percent.value * 100)
                                .toStringAsFixed(0),
                            onChanged: (v) {
                              final d = double.tryParse(v);
                              if (d != null) {
                                item.percent.value = (d / 100).clamp(0.0, 1.0);
                              }
                            },
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              suffixText: "%",
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        )
                      : Text(
                          "${(item.percent.value * 100).toStringAsFixed(0)}%",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                ],
              ),
            ),
            if (!isLast)
              Container(height: 1, color: Colors.white.withOpacity(0.08)),
          ],
        ),
      );
    });
  }
}
