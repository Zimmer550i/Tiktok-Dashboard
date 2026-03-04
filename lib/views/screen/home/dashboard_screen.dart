import 'package:flutter/material.dart';
import 'package:flutter_extension/util/app_colors.dart';
import 'package:flutter_extension/views/screen/home/analytics_screen.dart';
import 'package:flutter_extension/views/screen/home/performance_screen.dart';
import 'package:get/get.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildButton(
              onTap: () {
                Get.to(() => AnalyticsScreen());
              },
              title: "Analytics",
            ),
            const SizedBox(height: 20),
            _buildButton(
              onTap: () {
                Get.to(() => PerformancePage());
              },
              title: "Performance",
            ),
          ],
        ),
      ),
    );
  }

  InkWell _buildButton({required VoidCallback onTap, required String? title}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 100,
        width: 300,
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            title!,
            style: const TextStyle(color: Colors.white, fontSize: 26),
          ),
        ),
      ),
    );
  }
}
