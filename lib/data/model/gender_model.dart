import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GenderModel {
  RxString title;
  RxDouble percent;
  RxBool isEditing;
  final Color color;

  GenderModel({
    required String title,
    required double percent,
    required this.color,
  }) : title = title.obs,
       percent = percent.obs,
       isEditing = false.obs;
}
