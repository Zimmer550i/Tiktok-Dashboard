import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  DateTime expiredDate = DateTime(2026, 4, 16);

  RxBool isExpired = false.obs;

  void checkExpired() {
    debugPrint("Expired Date: ${expiredDate.toString()}");

    if (DateTime.now().isAfter(expiredDate)) {
      isExpired.value = true;
    } else {
      isExpired.value = false;
    }
  }
}
