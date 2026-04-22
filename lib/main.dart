import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tiktok_dashboard/util/app_constants.dart';
import 'package:tiktok_dashboard/util/app_theme.dart';
import 'package:tiktok_dashboard/views/screen/home/dashboard_screen.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.APP_NAME,
      debugShowCheckedModeBanner: false,
      navigatorKey: Get.key,
      theme: AppTheme.darkTheme,
      defaultTransition: Transition.topLevel,
      transitionDuration: const Duration(milliseconds: 500),
      home: const DashboardScreen(),
    );
  }
}
