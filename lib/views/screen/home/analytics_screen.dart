import 'package:flutter/material.dart';
import 'package:flutter_extension/controller/analytics_controller.dart';
import 'package:flutter_extension/views/base/gender_traffic_source.dart';
import 'package:flutter_extension/views/base/key_metrics.dart';
import 'package:flutter_extension/views/base/row_date.dart';
import 'package:flutter_extension/views/base/search_queries_section.dart';
import 'package:flutter_extension/views/base/traffic_source.dart';
import 'package:get/get.dart';

class AnalyticsScreen extends StatelessWidget {
  AnalyticsScreen({super.key});

  final controller = Get.put(AnalyticsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: Column(
          children: [
            const _TopBar(),
            const SizedBox(height: 12),
            _TabRow(controller: controller),
            RangeRow(controller: controller),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                final tab = controller.selectedTab.value;

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      KeyMetricsSection(tab: controller.selectedTab.value),
                      const SizedBox(height: 8),

                      if (tab == 1) ...[
                        TrafficSourceSection(),
                        const SizedBox(height: 8),
                        SearchQueriesSection(),
                      ],

                      if (tab == 3) ...[GenderTrafficSourceSection()],

                      const SizedBox(height: 30),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Row(
        children: [
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => Get.back(),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 18,
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                "Analytics",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 26),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _TabRow extends StatelessWidget {
  final AnalyticsController controller;
  const _TabRow({required this.controller});

  static const _tabs = [
    "Inspiration",
    "Overview",
    "Content",
    "Viewers",
    "Followers",
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.selectedTab.value;
      return Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final isSelected = i == selected;
                return GestureDetector(
                  onTap: () => controller.selectTab(i),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        Text(
                          _tabs[i],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF999999),
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (isSelected)
                          Container(width: 80, height: 2, color: Colors.white)
                        else
                          const SizedBox(height: 2),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
          Container(height: 1, color: Colors.white.withOpacity(0.08)),
        ],
      );
    });
  }
}
