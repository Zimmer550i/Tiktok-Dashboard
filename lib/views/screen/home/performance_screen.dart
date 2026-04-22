// ignore_for_file: unused_element_parameter

import 'package:flutter/material.dart';
import 'package:tiktok_dashboard/controller/performance_controller.dart';
import 'package:tiktok_dashboard/views/base/creating_video.dart';
import 'package:tiktok_dashboard/views/base/creator_reward_section.dart';
import 'package:tiktok_dashboard/views/base/reward_calculation.dart';
import 'package:tiktok_dashboard/views/base/reward_criteria.dart';
import 'package:get/get.dart';

class PerformancePage extends StatelessWidget {
  final controller = Get.put(PerformanceController());

  PerformancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: ListView(
          children: [
            const _Header(),

            // const SizedBox(height: 8),
            CreatorRewardsSection(),

            const SizedBox(height: 16),

            RewardsCard(),

            const SizedBox(height: 16),

            const CreatingVideos(),

            const SizedBox(height: 16),

            const RewardCriteria(),

            const SizedBox(height: 16),

            _ViewMoreButton(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 8,
            child: Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: const SizedBox(
                  height: 24,
                  width: 24,
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
          Obx(() {
            final controller = Get.find<PerformanceController>();
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Performance",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: Colors.red,
                              onPrimary: Colors.white,
                              surface: Color(0xFF1C1C1E),
                              onSurface: Colors.white,
                            ),
                            dialogTheme: const DialogThemeData(
                              backgroundColor: Color(0xFF1C1C1E),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      final months = [
                        'Jan',
                        'Feb',
                        'Mar',
                        'Apr',
                        'May',
                        'Jun',
                        'Jul',
                        'Aug',
                        'Sep',
                        'Oct',
                        'Nov',
                        'Dec',
                      ];
                      final formattedDate =
                          "${months[picked.month - 1]} ${picked.day}";
                      controller.updateLastUpdate(formattedDate);
                    }
                  },
                  child: Text(
                    "Last update: ${controller.data.value.lastUpdate}",
                    style: const TextStyle(
                      color: Color(0xFF8E8E93),
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _ViewMoreButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xff2c2c2c),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: const Text(
        "View more",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 2, dashSpace = 2, startX = 0;
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
