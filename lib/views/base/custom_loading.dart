import 'package:flutter/material.dart';
import 'package:tiktok_dashboard/util/app_colors.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CustomLoading extends StatelessWidget {
  const CustomLoading({super.key, this.color, this.size});
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SpinKitCircle(
        color: color ?? AppColors.primaryColor,
        size: size ?? 20.0,
      ),
    );
  }
}
