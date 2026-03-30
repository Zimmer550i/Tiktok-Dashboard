import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  DateTime expiredDate = DateTime.parse("2026-04-05 10:20:57.556371");

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
