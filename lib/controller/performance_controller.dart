import 'dart:convert';
import 'package:flutter_extension/data/model/performance_model.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PerformanceController extends GetxController {
  final data = PerformanceModel(
    rewards: "0.00",
    rpm: "--",
    qualifiedViews: "Less than 1,000",
    creatorRewardsTotal: "0.00",
    creatorRewardsChange: "0.00 (Feb 15)",
    dateRange: "Jan 1, 2026 - Jan 31, 2026",
    standardReward: "0.00",
    additionalReward: "0.00",
    year: "2026",
    monthlyChartValues: List.filled(12, 0.0),
    dailyChartValues: List.filled(31, 0.0),
  ).obs;

  final selectedTimeFilter = 0.obs; // 0=By month, 1=By year, 2=Custom

  Future<void> load() async {
    final pref = await SharedPreferences.getInstance();
    final raw = pref.getString("performance_data");

    if (raw != null) {
      data.value = PerformanceModel.fromJson(jsonDecode(raw));
    }
  }

  Future<void> save() async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString("performance_data", jsonEncode(data.value.toJson()));
  }

  void updateRewards(String v) {
    data.update((e) => e!.rewards = v);
    save();
  }

  void updateRPM(String v) {
    data.update((e) => e!.rpm = v);
    save();
  }

  void updateQualifiedViews(String v) {
    data.update((e) => e!.qualifiedViews = v);
    save();
  }

  void updateCreatorRewardsTotal(String v) {
    data.update((e) => e!.creatorRewardsTotal = v);
    save();
  }

  void updateCreatorRewardsChange(String v) {
    data.update((e) => e!.creatorRewardsChange = v);
    save();
  }

  void updateDateRange(String v) {
    data.update((e) => e!.dateRange = v);
    save();
  }

  void updateStandardReward(String v) {
    data.update((e) => e!.standardReward = v);
    save();
  }

  void updateAdditionalReward(String v) {
    data.update((e) => e!.additionalReward = v);
    save();
  }

  void updateYear(String v) {
    data.update((e) => e!.year = v);
    save();
  }

  void updateChartValue(int index, String v) {
    try {
      double value = double.parse(v);
      data.update((e) {
        if (e != null) {
          if (selectedTimeFilter.value == 0) {
            if (index < e.dailyChartValues.length) {
              e.dailyChartValues[index] = value;
            }
          } else {
            if (index < e.monthlyChartValues.length) {
              e.monthlyChartValues[index] = value;
            }
          }
        }
      });
      save();
    } catch (_) {}
  }

  void setTimeFilter(int index) {
    selectedTimeFilter.value = index;
    // Logic for changing data based on filter could go here
  }

  @override
  void onInit() {
    load();
    super.onInit();
  }
}
