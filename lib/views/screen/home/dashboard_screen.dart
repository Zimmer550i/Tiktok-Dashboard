import 'package:flutter/material.dart';
import 'package:tiktok_dashboard/controller/home_controller.dart';
import 'package:tiktok_dashboard/util/app_colors.dart';
import 'package:tiktok_dashboard/util/app_snackbar.dart';
import 'package:tiktok_dashboard/views/screen/home/analytics_screen.dart';
import 'package:tiktok_dashboard/views/screen/home/performance_screen.dart';
import 'package:get/get.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final HomeController homeController = Get.put(HomeController());

  @override
  void initState() {
    super.initState();
    homeController.checkExpired();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildButton(
              onTap: () {
                if (homeController.isExpired.value) {
                  AppSnackbar.subscriptionExpired();
                } else {
                  Get.to(() => AnalyticsScreen());
                }
              },
              title: "Analytics",
            ),
            const SizedBox(height: 20),
            _buildButton(
              onTap: () {
                if (homeController.isExpired.value) {
                  AppSnackbar.subscriptionExpired();
                } else {
                  Get.to(() => PerformancePage());
                }
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
