import 'package:get/get.dart';

class MetricModel {
  final String title;

  RxString value;
  RxString change;

  RxBool isSelected;
  RxBool isEditing;

  MetricModel({
    required this.title,
    required String value,
    required String change,
    bool isSelected = false,
  }) : value = value.obs,
       change = change.obs,
       isSelected = isSelected.obs,
       isEditing = false.obs;

  // ----------------------------
  // Safe update methods
  // ----------------------------
  void updateDelta(String d) {
    final parts = _extractChangeParts(change.value);
    change.value = _composeChange(d, parts.percent);
  }

  void updatePercent(String p) {
    final parts = _extractChangeParts(change.value);
    change.value = _composeChange(parts.delta, p);
  }

  Map<String, dynamic> toJson() => {
    "title": title,
    "value": value.value,
    "delta": _extractChangeParts(change.value).delta,
    "percent": _extractChangeParts(change.value).percent,
    "change": change.value,
    "isSelected": isSelected.value,
  };

  factory MetricModel.fromJson(Map<String, dynamic> json) {
    final rawChange = (json["change"] ?? "").toString().trim();
    final delta = json["delta"] ?? "0";
    final percent = json["percent"] ?? "0";

    return MetricModel(
      title: json["title"],
      value: json["value"],
      change: rawChange.isNotEmpty ? rawChange : _composeChange(delta, percent),
      isSelected: json["isSelected"] ?? false,
    );
  }

  static _ChangeParts _extractChangeParts(String raw) {
    final trimmed = raw.trim();
    final open = trimmed.indexOf('(');
    final close = trimmed.lastIndexOf(')');

    if (open == -1 || close == -1 || close <= open) {
      return _ChangeParts(trimmed, "0");
    }

    final delta = trimmed.substring(0, open).trim();
    var percent = trimmed.substring(open + 1, close).trim();
    if (percent.endsWith('%')) {
      percent = percent.substring(0, percent.length - 1).trim();
    }

    return _ChangeParts(delta, percent.isEmpty ? "0" : percent);
  }

  static String _composeChange(String delta, String percent) {
    final d = delta.trim();
    final p = percent.trim();
    if (d.isEmpty) return "0";
    if (p.isEmpty) return d;
    return "$d ($p%)";
  }
}

class _ChangeParts {
  final String delta;
  final String percent;

  const _ChangeParts(this.delta, this.percent);
}
