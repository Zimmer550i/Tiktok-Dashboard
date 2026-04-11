import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSnackbar {
  static void subscriptionExpired() {
    Get.snackbar(
      "Subscription Expired",
      "Your subscription has expired.",
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      backgroundColor: const Color(0xFF1E1E2C),
      colorText: Colors.white,
      icon: const Icon(
        Icons.warning_amber_rounded,
        color: Colors.orange,
        size: 28,
      ),
      duration: const Duration(seconds: 4),
      animationDuration: const Duration(milliseconds: 400),
      forwardAnimationCurve: Curves.easeOutBack,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.25),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      shouldIconPulse: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
