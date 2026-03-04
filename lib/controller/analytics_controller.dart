import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_extension/data/model/gender_model.dart';
import 'package:flutter_extension/data/model/search_query_model.dart';
import 'package:flutter_extension/data/model/traffic_source_model.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/model/metric_model.dart';

enum AnalyticsRange { d7, d28, d60, d365, custom }

class AnalyticsController extends GetxController {
  final range = AnalyticsRange.d7.obs;
  final startDate = DateTime(2024, 2, 9).obs;
  final endDate = DateTime(2024, 2, 15).obs;

  // Tab selection (0=Inspiration,1=Overview,2=Content,3=Viewers,4=Followers)
  final selectedTab = 1.obs;

  // Selected metric index within the grid
  final selectedMetricIndex = 0.obs;
  final selectedViewerMetricIndex = 0.obs;

  final metrics = <MetricModel>[].obs;
  final viewerMetrics = <MetricModel>[].obs;
  final series = <double>[].obs;
  final traffic = <TrafficSourceModel>[].obs;
  final gender = <GenderModel>[].obs;
  final age = <GenderModel>[].obs;
  final locations = <GenderModel>[].obs;
  final selectedTrafficTab = 0.obs;
  final searchQueries = <SearchQueryModel>[].obs;

  static const _kMetricsKey = "metrics_";
  static const _kSeriesKey = "series_";
  static const _kTrafficKey = "traffic_";
  static const _kQueriesKey = "queries_";
  static const _kStartKey = "start_";
  static const _kEndKey = "end_";

  // ── convenience ──────────────────────────────────────────────────────────
  bool get show365 => range.value == AnalyticsRange.d365;

  @override
  void onInit() {
    super.onInit();
    _applyDefaultsFor(range.value);
    _loadFor(range.value);
  }

  void toggleEdit(int index) {
    metrics[index].isEditing.value = !metrics[index].isEditing.value;
  }

  // ── Tab selection ─────────────────────────────────────────────────────────
  void selectTab(int index) {
    selectedTab.value = index;
  }

  // ── Range ─────────────────────────────────────────────────────────────────
  Future<void> setRange(AnalyticsRange r, {DateTimeRange? custom}) async {
    range.value = r;

    if (r == AnalyticsRange.custom && custom != null) {
      startDate.value = custom.start;
      endDate.value = custom.end;
    } else {
      final now = DateTime(2025, 2, 15);
      final days = _rangeDays(r);
      endDate.value = now;
      startDate.value = now.subtract(Duration(days: days - 1));
    }

    _applyDefaultsFor(r);
    await _loadFor(r);

    // Refresh graph for the currently selected metric after range/data change
    _updateGraphSeries(selectedMetricIndex.value);
  }

  int _rangeDays(AnalyticsRange r) {
    switch (r) {
      case AnalyticsRange.d7:
        return 7;
      case AnalyticsRange.d28:
        return 28;
      case AnalyticsRange.d60:
        return 60;
      case AnalyticsRange.d365:
        return 365;
      case AnalyticsRange.custom:
        return 7;
    }
  }

  String get dateLabel => "${_fmt(startDate.value)} - ${_fmt(endDate.value)}";
  String _fmt(DateTime d) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return "${months[d.month - 1]} ${d.day}, ${d.year}";
  }

  // ── Metric selection ────────────────────────────────────────────────────────
  void selectMetric(int index) {
    selectedMetricIndex.value = index;
    for (int i = 0; i < metrics.length; i++) {
      metrics[i].isSelected.value = (i == index);
    }
    _updateGraphSeries(index);
  }

  void selectViewerMetric(int index) {
    selectedViewerMetricIndex.value = index;
    for (int i = 0; i < viewerMetrics.length; i++) {
      viewerMetrics[i].isSelected.value = (i == index);
    }
    _updateGraphSeries(index);
  }

  void selectTrafficTab(int index) {
    selectedTrafficTab.value = index;
  }

  void _updateGraphSeries(int metricIndex) {
    final base = _defaultSeries(range.value);
    if (base.isEmpty) return;

    // Simulate different data shapes for different metrics
    final factors = [1.0, 1.45, 0.82, 1.65, 0.38, 0.05];
    final factor = metricIndex < factors.length ? factors[metricIndex] : 0.5;

    series.assignAll(base.map((v) => v * factor).toList());
  }

  List<double> _defaultSeries(AnalyticsRange r) {
    switch (r) {
      case AnalyticsRange.d7:
        return [9.0, 4.0, 14.0, 22.0, 28.0, 18.0, 17.0];
      case AnalyticsRange.d28:
        return [
          6,
          9,
          12,
          18,
          24,
          30,
          22,
          18,
          20,
          25,
          32,
          28,
          22,
          18,
          14,
          16,
          20,
          28,
          34,
          30,
          26,
          22,
          18,
          20,
          24,
          28,
          22,
          18,
        ].map((e) => e.toDouble()).toList();
      case AnalyticsRange.d60:
        return [
          5,
          8,
          12,
          16,
          22,
          28,
          34,
          30,
          26,
          22,
          20,
          24,
          30,
          36,
          32,
          28,
          24,
          20,
          18,
          22,
          28,
          34,
          40,
          36,
          30,
          26,
          22,
          20,
          24,
          28,
          34,
          40,
          44,
          38,
          32,
          28,
          24,
          22,
          26,
          30,
          36,
          42,
          46,
          40,
          34,
          28,
          24,
          22,
          26,
          32,
          38,
          42,
          36,
          30,
          26,
          22,
          20,
          18,
          22,
          26,
        ].map((e) => e.toDouble()).toList();
      case AnalyticsRange.d365:
        return [
          5,
          6,
          6,
          7,
          8,
          9,
          10,
          12,
          14,
          16,
          18,
          20,
          22,
          25,
          30,
          36,
          48,
          55,
          60,
          70,
          75,
          80,
          83,
          80,
          75,
          65,
          55,
          45,
          35,
          28,
          22,
          20,
          18,
          16,
          14,
          12,
          10,
          12,
          14,
          16,
          20,
          25,
          30,
          35,
          40,
          45,
          50,
          55,
          55,
          50,
          45,
          40,
          35,
          30,
          25,
          20,
          16,
          12,
          10,
          8,
          7,
          6,
          6,
          5,
        ].map((e) => e.toDouble()).toList();
      case AnalyticsRange.custom:
        return [9.0, 4.0, 14.0, 22.0, 28.0, 18.0, 17.0];
    }
  }

  void editMetric(int index) {
    final tc = TextEditingController(text: metrics[index].value.value);
    Get.defaultDialog(
      title: "Edit",
      content: TextField(
        controller: tc,
        onSubmitted: (v) {
          metrics[index].value.value = v;
          _saveFor(range.value);
          Get.back();
        },
      ),
      textConfirm: "Save",
      onConfirm: () {
        metrics[index].value.value = tc.text.trim();
        _saveFor(range.value);
        Get.back();
      },
    );
  }

  void saveTraffic() => _saveFor(range.value);

  void saveSearchQueries() => _saveFor(range.value);
  String _suffix(AnalyticsRange r) => r.name;

  Future<void> _loadFor(AnalyticsRange r) async {
    final prefs = await SharedPreferences.getInstance();
    final suf = _suffix(r);

    final mStr = prefs.getString("$_kMetricsKey$suf");
    final sStr = prefs.getString("$_kSeriesKey$suf");
    final tStr = prefs.getString("$_kTrafficKey$suf");
    final qStr = prefs.getString("$_kQueriesKey$suf");

    final st = prefs.getString("$_kStartKey$suf");
    final en = prefs.getString("$_kEndKey$suf");

    if (st != null && en != null) {
      startDate.value = DateTime.tryParse(st) ?? startDate.value;
      endDate.value = DateTime.tryParse(en) ?? endDate.value;
    }

    if (mStr != null) {
      final decoded = (jsonDecode(mStr) as List).cast<Map<String, dynamic>>();
      metrics.assignAll(decoded.map((e) => MetricModel.fromJson(e)).toList());
    }

    if (sStr != null) {
      final decoded = (jsonDecode(sStr) as List).cast<num>();
      series.assignAll(decoded.map((e) => e.toDouble()).toList());
    }

    if (tStr != null) {
      final decoded = (jsonDecode(tStr) as List).cast<Map<String, dynamic>>();
      traffic.assignAll(
        decoded.map((e) => TrafficSourceModel.fromJson(e)).toList(),
      );
    }

    if (qStr != null) {
      final decoded = (jsonDecode(qStr) as List).cast<Map<String, dynamic>>();
      searchQueries.assignAll(
        decoded.map((e) => SearchQueryModel.fromJson(e)).toList(),
      );
    }

    if (mStr == null && sStr == null && tStr == null && qStr == null) {
      await _saveFor(r);
    }
  }

  Future<void> _saveFor(AnalyticsRange r) async {
    final prefs = await SharedPreferences.getInstance();
    final suf = _suffix(r);

    await prefs.setString("$_kStartKey$suf", startDate.value.toIso8601String());
    await prefs.setString("$_kEndKey$suf", endDate.value.toIso8601String());
    await prefs.setString(
      "$_kMetricsKey$suf",
      jsonEncode(metrics.map((e) => e.toJson()).toList()),
    );
    await prefs.setString("$_kSeriesKey$suf", jsonEncode(series.toList()));
    await prefs.setString(
      "$_kTrafficKey$suf",
      jsonEncode(traffic.map((e) => e.toJson()).toList()),
    );
    await prefs.setString(
      "$_kQueriesKey$suf",
      jsonEncode(searchQueries.map((e) => e.toJson()).toList()),
    );
  }

  void _applyDefaultsFor(AnalyticsRange r) {
    switch (r) {
      case AnalyticsRange.d7:
        metrics.assignAll([
          MetricModel(
            title: "Post views",
            value: "118",
            change: "-20 (-14.5%)",
          ),
          MetricModel(title: "Profile views", value: "8", change: "+4 (+100%)"),
          MetricModel(title: "Likes", value: "4", change: "0"),
          MetricModel(title: "Comments", value: "-87", change: "+90 (-50.8%)"),
          MetricModel(title: "Shares", value: "4", change: "+4"),
          MetricModel(
            title: "Est. rewards",
            value: "\$0.00",
            change: "+\$0.00",
          ),
        ]);
        viewerMetrics.assignAll([
          MetricModel(
            title: "Total viewers",
            value: "82",
            change: "-14 (-14.5%)",
          ),
          MetricModel(
            title: "New viewers",
            value: "54",
            change: "+12 (+28.5%)",
          ),
        ]);
        series.assignAll([9.0, 4.0, 14.0, 22.0, 28.0, 18.0, 17.0]);
        traffic.assignAll([
          TrafficSourceModel(title: "Search", percent: 0.698),
          TrafficSourceModel(title: "Personal profile", percent: 0.194),
          TrafficSourceModel(title: "Following", percent: 0.054),
          TrafficSourceModel(title: "For You", percent: 0.054),
          TrafficSourceModel(title: "Sound", percent: 0.000),
        ]);
        gender.assignAll([
          GenderModel(
            title: "Male",
            percent: 0.66,
            color: const Color(0xFF8ECAFF),
          ),
          GenderModel(
            title: "Female",
            percent: 0.25,
            color: const Color(0xFF56738E),
          ),
          GenderModel(
            title: "Other",
            percent: 0.09,
            color: const Color(0xFF34404B),
          ),
        ]);
        age.assignAll([
          GenderModel(
            title: "18-24",
            percent: 0.45,
            color: const Color(0xFF8ECAFF),
          ),
          GenderModel(
            title: "25-34",
            percent: 0.35,
            color: const Color(0xFF56738E),
          ),
          GenderModel(
            title: "35-44",
            percent: 0.15,
            color: const Color(0xFF34404B),
          ),
          GenderModel(
            title: "45+",
            percent: 0.05,
            color: const Color(0xFF1C252E),
          ),
        ]);
        locations.assignAll([
          GenderModel(
            title: "United States",
            percent: 0.40,
            color: const Color(0xFF8ECAFF),
          ),
          GenderModel(
            title: "United Kingdom",
            percent: 0.30,
            color: const Color(0xFF56738E),
          ),
          GenderModel(
            title: "Canada",
            percent: 0.20,
            color: const Color(0xFF34404B),
          ),
          GenderModel(
            title: "Other",
            percent: 0.10,
            color: const Color(0xFF1C252E),
          ),
        ]);

        searchQueries.assignAll([
          SearchQueryModel(title: "Yeat audio", percent: 0.014),
          SearchQueryModel(title: "yeat songs", percent: 0.014),
          SearchQueryModel(title: "yeat no avail slowed", percent: 0.014),
          SearchQueryModel(
            title: "yeat out the way slowed reverb",
            percent: 0.014,
          ),
          SearchQueryModel(title: "slowflowouttheway", percent: 0.014),
        ]);

      case AnalyticsRange.d28:
        metrics.assignAll([
          MetricModel(
            title: "Post views",
            value: "540",
            change: "+120 (+28.5%)",
          ),
          MetricModel(
            title: "Profile views",
            value: "34",
            change: "+10 (+41.6%)",
          ),
          MetricModel(title: "Likes", value: "22", change: "+8 (+57.1%)"),
          MetricModel(title: "Comments", value: "5", change: "+3 (+150%)"),
          MetricModel(title: "Shares", value: "12", change: "+4 (+50%)"),
          MetricModel(
            title: "Est. rewards",
            value: "\$0.20",
            change: "+\$0.10",
          ),
        ]);
        viewerMetrics.assignAll([
          MetricModel(
            title: "Total viewers",
            value: "368",
            change: "+84 (+29.6%)",
          ),
          MetricModel(
            title: "New viewers",
            value: "244",
            change: "+72 (+41.8%)",
          ),
        ]);
        series.assignAll(
          [
            6,
            9,
            12,
            18,
            24,
            30,
            22,
            18,
            20,
            25,
            32,
            28,
            22,
            18,
            14,
            16,
            20,
            28,
            34,
            30,
            26,
            22,
            18,
            20,
            24,
            28,
            22,
            18,
          ].map((e) => e.toDouble()).toList(),
        );
        traffic.assignAll([
          TrafficSourceModel(title: "Search", percent: 0.612),
          TrafficSourceModel(title: "Personal profile", percent: 0.21),
          TrafficSourceModel(title: "Following", percent: 0.078),
          TrafficSourceModel(title: "For You", percent: 0.07),
          TrafficSourceModel(title: "Sound", percent: 0.03),
        ]);
        gender.assignAll([
          GenderModel(
            title: "Male",
            percent: 0.66,
            color: const Color(0xFF8ECAFF),
          ),
          GenderModel(
            title: "Female",
            percent: 0.25,
            color: const Color(0xFF56738E),
          ),
          GenderModel(
            title: "Other",
            percent: 0.09,
            color: const Color(0xFF34404B),
          ),
        ]);

        searchQueries.assignAll([
          SearchQueryModel(title: "Yeat audio", percent: 0.018),
          SearchQueryModel(title: "yeat songs", percent: 0.016),
          SearchQueryModel(title: "yeat no avail slowed", percent: 0.015),
          SearchQueryModel(title: "yeat slowed reverb", percent: 0.013),
          SearchQueryModel(title: "slowflow", percent: 0.012),
        ]);

      case AnalyticsRange.d60:
        metrics.assignAll([
          MetricModel(
            title: "Post views",
            value: "1.1K",
            change: "+320 (+40.9%)",
          ),
          MetricModel(
            title: "Profile views",
            value: "72",
            change: "+22 (+44%)",
          ),
          MetricModel(title: "Likes", value: "58", change: "+18 (+45%)"),
          MetricModel(title: "Comments", value: "14", change: "+6 (+75%)"),
          MetricModel(title: "Shares", value: "28", change: "+9 (+47.3%)"),
          MetricModel(
            title: "Est. rewards",
            value: "\$0.55",
            change: "+\$0.25",
          ),
        ]);
        viewerMetrics.assignAll([
          MetricModel(
            title: "Total viewers",
            value: "712",
            change: "+192 (+36.9%)",
          ),
          MetricModel(
            title: "New viewers",
            value: "482",
            change: "+140 (+40.9%)",
          ),
        ]);
        series.assignAll(
          [
            5,
            8,
            12,
            16,
            22,
            28,
            34,
            30,
            26,
            22,
            20,
            24,
            30,
            36,
            32,
            28,
            24,
            20,
            18,
            22,
            28,
            34,
            40,
            36,
            30,
            26,
            22,
            20,
            24,
            28,
            34,
            40,
            44,
            38,
            32,
            28,
            24,
            22,
            26,
            30,
            36,
            42,
            46,
            40,
            34,
            28,
            24,
            22,
            26,
            32,
            38,
            42,
            36,
            30,
            26,
            22,
            20,
            18,
            22,
            26,
          ].map((e) => e.toDouble()).toList(),
        );
        traffic.assignAll([
          TrafficSourceModel(title: "Search", percent: 0.578),
          TrafficSourceModel(title: "Personal profile", percent: 0.225),
          TrafficSourceModel(title: "Following", percent: 0.092),
          TrafficSourceModel(title: "For You", percent: 0.075),
          TrafficSourceModel(title: "Sound", percent: 0.030),
        ]);
        gender.assignAll([
          GenderModel(
            title: "Male",
            percent: 0.66,
            color: const Color(0xFF8ECAFF),
          ),
          GenderModel(
            title: "Female",
            percent: 0.25,
            color: const Color(0xFF56738E),
          ),
          GenderModel(
            title: "Other",
            percent: 0.09,
            color: const Color(0xFF34404B),
          ),
        ]);

        searchQueries.assignAll([
          SearchQueryModel(title: "Yeat audio", percent: 0.020),
          SearchQueryModel(title: "yeat songs", percent: 0.018),
          SearchQueryModel(title: "yeat no avail slowed", percent: 0.016),
          SearchQueryModel(title: "reverb slowflow", percent: 0.014),
          SearchQueryModel(title: "yeat out the way", percent: 0.012),
        ]);

      case AnalyticsRange.d365:
        metrics.assignAll([
          MetricModel(
            title: "Post views",
            value: "1.2M",
            change: "+800K (+200%)",
          ),
          MetricModel(
            title: "Profile views",
            value: "18K",
            change: "+12K (+200%)",
          ),
          MetricModel(title: "Likes", value: "94K", change: "+60K (+175%)"),
          MetricModel(title: "Comments", value: "18K", change: "+10K (+125%)"),
          MetricModel(title: "Shares", value: "18K", change: "+10K (+125%)"),
          MetricModel(title: "Est. rewards", value: "-", change: "0"),
        ]);
        viewerMetrics.assignAll([
          MetricModel(
            title: "Total viewers",
            value: "1.4M",
            change: "+820K (+141%)",
          ),
          MetricModel(
            title: "New viewers",
            value: "980K",
            change: "+620K (+172%)",
          ),
        ]);
        series.assignAll(
          [
            5,
            6,
            6,
            7,
            8,
            9,
            10,
            12,
            14,
            16,
            18,
            20,
            22,
            25,
            30,
            36,
            48,
            55,
            60,
            70,
            75,
            80,
            83,
            80,
            75,
            65,
            55,
            45,
            35,
            28,
            22,
            20,
            18,
            16,
            14,
            12,
            10,
            12,
            14,
            16,
            20,
            25,
            30,
            35,
            40,
            45,
            50,
            55,
            55,
            50,
            45,
            40,
            35,
            30,
            25,
            20,
            16,
            12,
            10,
            8,
            7,
            6,
            6,
            5,
          ].map((e) => e.toDouble()).toList(),
        );
        traffic.assignAll([
          TrafficSourceModel(title: "For You", percent: 0.942),
          TrafficSourceModel(title: "Personal profile", percent: 0.028),
          TrafficSourceModel(title: "Search", percent: 0.023),
          TrafficSourceModel(title: "Following", percent: 0.005),
          TrafficSourceModel(title: "Sound", percent: 0.002),
        ]);
        searchQueries.assignAll([
          SearchQueryModel(title: "Yeat audio", percent: 0.014),
          SearchQueryModel(title: "yeat songs", percent: 0.014),
          SearchQueryModel(title: "yeat no avail slowed", percent: 0.014),
          SearchQueryModel(
            title: "yeat out the way slowed reverb",
            percent: 0.014,
          ),
          SearchQueryModel(title: "slowflowouttheway", percent: 0.014),
        ]);
        gender.assignAll([
          GenderModel(
            title: "Male",
            percent: 0.66,
            color: const Color(0xFF8ECAFF),
          ),
          GenderModel(
            title: "Female",
            percent: 0.25,
            color: const Color(0xFF56738E),
          ),
          GenderModel(
            title: "Other",
            percent: 0.09,
            color: const Color(0xFF34404B),
          ),
        ]);

      case AnalyticsRange.custom:
        metrics.assignAll([
          MetricModel(
            title: "Post views",
            value: "118",
            change: "-20 (-14.5%)",
          ),
          MetricModel(title: "Profile views", value: "8", change: "+4 (+100%)"),
          MetricModel(title: "Likes", value: "4", change: "0"),
          MetricModel(title: "Comments", value: "-87", change: "+90 (-50.8%)"),
          MetricModel(title: "Shares", value: "4", change: "+4"),
          MetricModel(
            title: "Est. rewards",
            value: "\$0.00",
            change: "+\$0.00",
          ),
        ]);

        series.assignAll([9.0, 4.0, 14.0, 22.0, 28.0, 18.0, 17.0]);
        traffic.assignAll([
          TrafficSourceModel(title: "Search", percent: 0.698),
          TrafficSourceModel(title: "Personal profile", percent: 0.194),
          TrafficSourceModel(title: "Following", percent: 0.054),
          TrafficSourceModel(title: "For You", percent: 0.054),
          TrafficSourceModel(title: "Sound", percent: 0.000),
        ]);
        searchQueries.assignAll([
          SearchQueryModel(title: "Yeat audio", percent: 0.014),
          SearchQueryModel(title: "yeat songs", percent: 0.014),
          SearchQueryModel(title: "yeat no avail slowed", percent: 0.014),
          SearchQueryModel(
            title: "yeat out the way slowed reverb",
            percent: 0.014,
          ),
          SearchQueryModel(title: "slowflowouttheway", percent: 0.014),
        ]);

        gender.assignAll([
          GenderModel(
            title: "Male",
            percent: 0.66,
            color: const Color(0xFF8ECAFF),
          ),
          GenderModel(
            title: "Female",
            percent: 0.25,
            color: const Color(0xFF56738E),
          ),
          GenderModel(
            title: "Other",
            percent: 0.09,
            color: const Color(0xFF34404B),
          ),
        ]);
    }
  }

  double get yMax {
    if (series.isEmpty) return 36;
    final m = series.reduce(max);
    // For 365 days use larger step
    final step = show365 ? 27.0 : 12.0;
    return max(step, (m / step).ceil() * step);
  }
}
