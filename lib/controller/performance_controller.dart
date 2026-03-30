import 'dart:convert';
import 'package:flutter_extension/model/performance_model.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
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
    selectedVideoTagIndex: 0,
    videoCards: List.generate(
      3,
      (index) => VideoCardModel(
        title: "TikTok is now",
        author: "Seth",
        imageUrl: "",
        authorImageUrl: "",
      ),
    ),
    monthlyChartValues: List.filled(12, 0.0),
    dailyChartValues: List.filled(31, 0.0),
    criteria: [
      CriteriaModel(
        title: "Well-crafted",
        icon: "face",
        desc:
            "High-quality 1 min+ videos that show an attention to detail in the creation process.",
      ),
      CriteriaModel(
        title: "Engaging",
        icon: "face",
        desc:
            "Captivating 1 min+ videos that resonate with and inspire viewers.",
      ),
      CriteriaModel(
        title: "Specialized",
        icon: "face",
        desc:
            "In-depth 1 min+ videos that focus on a specific theme or expertise.",
      ),
    ],
    lastUpdate: "Feb 15",
  ).obs;

  final selectedTimeFilter = 0.obs; // 0=By month, 1=By year, 2=Custom

  // Chart overlay state (used by `SimpleBarChart`)
  final chartOverlayVisible = false.obs;
  final activeChartIndex = 0.obs;
  final activeChartValue = 0.0.obs;
  final activeChartDateLabel = "".obs;

  void setChartSelection({
    required int index,
    required double value,
    required String dateLabel,
    bool showOverlay = false,
  }) {
    activeChartIndex.value = index;
    activeChartValue.value = value;
    activeChartDateLabel.value = dateLabel;
    if (showOverlay) chartOverlayVisible.value = true;
  }

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

  void updateLastUpdate(String v) {
    data.update((e) => e!.lastUpdate = v);
    save();
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
    _syncChartFromRewards();
    save();
  }

  void updateAdditionalReward(String v) {
    data.update((e) => e!.additionalReward = v);
    _syncChartFromRewards();
    save();
  }

  void _syncChartFromRewards() {
    try {
      final s =
          double.tryParse(data.value.standardReward.replaceAll(',', '')) ?? 0.0;
      final a =
          double.tryParse(data.value.additionalReward.replaceAll(',', '')) ??
          0.0;
      final total = s + a;

      data.update((e) {
        if (e != null) {
          e.creatorRewardsTotal = total.toStringAsFixed(2);
          // Sync to Jan (Monthly) and Feb 15 (Daily) to match images
          e.monthlyChartValues[0] = total;
          e.dailyChartValues[14] = total;
        }
      });
    } catch (_) {}
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
            // Ensure all indices exist (missing entries default to 0.0).
            if (index >= e.dailyChartValues.length) {
              e.dailyChartValues
                  .addAll(List.filled(index + 1 - e.dailyChartValues.length, 0.0));
            }
            e.dailyChartValues[index] = value;

            // Sync back if Feb 15
            if (index == 14) {
              e.standardReward = value.toStringAsFixed(2);
              e.additionalReward = "0.00";
            }
          } else {
            // Ensure all indices exist (missing entries default to 0.0).
            if (index >= e.monthlyChartValues.length) {
              e.monthlyChartValues
                  .addAll(List.filled(index + 1 - e.monthlyChartValues.length, 0.0));
            }
            e.monthlyChartValues[index] = value;

            // Sync back if Jan
            if (index == 0) {
              e.standardReward = value.toStringAsFixed(2);
              e.additionalReward = "0.00";
            }
          }
        }
      });

      if (index == activeChartIndex.value) {
        activeChartValue.value = value;
      }
      save();
    } catch (_) {}
  }

  void insertChartValueAfter(int index, String v) {
    try {
      final value = double.parse(v);

      data.update((e) {
        if (e == null) return;

        final isMonthly = selectedTimeFilter.value != 0;
        final list = isMonthly ? e.monthlyChartValues : e.dailyChartValues;

        final insertAt = (index + 1).clamp(0, list.length);
        list.insert(insertAt, value);

        // Keep reward fields consistent with the "special" chart indices.
        // (Monthly: Jan is index 0. Daily: Feb 15 is index 14.)
        if (isMonthly) {
          if (list.isNotEmpty && list.length > 0) {
            e.standardReward = list[0].toStringAsFixed(2);
            e.additionalReward = "0.00";
            e.creatorRewardsTotal =
                (double.tryParse(e.standardReward.replaceAll(',', '')) ?? 0.0)
                    .toStringAsFixed(2);
          }
        } else {
          if (list.length > 14) {
            e.standardReward = list[14].toStringAsFixed(2);
            e.additionalReward = "0.00";
            e.creatorRewardsTotal =
                (double.tryParse(e.standardReward.replaceAll(',', '')) ?? 0.0)
                    .toStringAsFixed(2);
          } else if (list.isNotEmpty) {
            // Fallback if user inserted early and list is shorter.
            e.standardReward = list.first.toStringAsFixed(2);
            e.additionalReward = "0.00";
            e.creatorRewardsTotal =
                (double.tryParse(e.standardReward.replaceAll(',', '')) ?? 0.0)
                    .toStringAsFixed(2);
          }
        }
      });

      save();
    } catch (_) {}
  }

  double getMaxChartValue() {
    final values = selectedTimeFilter.value == 0
        ? data.value.dailyChartValues
        : data.value.monthlyChartValues;
    if (values.isEmpty) return 3.0;
    double max = 0.0;
    for (var v in values) {
      if (v > max) max = v;
    }
    return max > 0 ? max * 1.2 : 3.0; // Add 20% headroom
  }

  void setSelectedVideoTag(int index) {
    data.update((e) => e!.selectedVideoTagIndex = index);
    save();
  }

  void updateVideoCardTitle(int index, String v) {
    data.update((e) => e!.videoCards[index].title = v);
    save();
  }

  void updateVideoCardAuthor(int index, String v) {
    data.update((e) => e!.videoCards[index].author = v);
    save();
  }

  void updateVideoCardImage(int index, String v) {
    data.update((e) => e!.videoCards[index].imageUrl = v);
    save();
  }

  void updateVideoCardAuthorImage(int index, String v) {
    data.update((e) => e!.videoCards[index].authorImageUrl = v);
    save();
  }

  Future<void> pickImage(int index) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      updateVideoCardImage(index, image.path);
    }
  }

  Future<void> pickAuthorImage(int index) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      updateVideoCardAuthorImage(index, image.path);
    }
  }

  void setTimeFilter(int index) {
    selectedTimeFilter.value = index;
    // Logic for changing data based on filter could go here
  }

  void updateCriteriaTitle(int index, String v) {
    data.update((e) => e!.criteria[index].title = v);
    save();
  }

  void updateCriteriaDesc(int index, String v) {
    data.update((e) => e!.criteria[index].desc = v);
    save();
  }

  void updateCriteriaIcon(int index, String v) {
    data.update((e) => e!.criteria[index].icon = v);
    save();
  }

  @override
  void onInit() {
    load();
    super.onInit();
  }
}
