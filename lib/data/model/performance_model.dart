class PerformanceModel {
  String rewards;
  String rpm;
  String qualifiedViews;

  // Creator Rewards section
  String creatorRewardsTotal;
  String creatorRewardsChange;
  String dateRange;
  String standardReward;
  String additionalReward;
  String year;

  // Chart Data
  List<double> monthlyChartValues;
  List<double> dailyChartValues;

  PerformanceModel({
    required this.rewards,
    required this.rpm,
    required this.qualifiedViews,
    required this.creatorRewardsTotal,
    required this.creatorRewardsChange,
    required this.dateRange,
    required this.standardReward,
    required this.additionalReward,
    required this.monthlyChartValues,
    required this.dailyChartValues,
    required this.year,
  });

  Map<String, dynamic> toJson() => {
    "rewards": rewards,
    "rpm": rpm,
    "qualifiedViews": qualifiedViews,
    "creatorRewardsTotal": creatorRewardsTotal,
    "creatorRewardsChange": creatorRewardsChange,
    "dateRange": dateRange,
    "standardReward": standardReward,
    "additionalReward": additionalReward,
    "monthlyChartValues": monthlyChartValues,
    "dailyChartValues": dailyChartValues,
    "year": year,
  };

  factory PerformanceModel.fromJson(Map<String, dynamic> json) {
    return PerformanceModel(
      rewards: json["rewards"] ?? "0.00",
      rpm: json["rpm"] ?? "--",
      qualifiedViews: json["qualifiedViews"] ?? "Less than 1,000",
      creatorRewardsTotal: json["creatorRewardsTotal"] ?? "0.00",
      creatorRewardsChange: json["creatorRewardsChange"] ?? "0.00 (Feb 15)",
      dateRange: json["dateRange"] ?? "Jan 1, 2026 - Jan 31, 2026",
      standardReward: json["standardReward"] ?? "0.00",
      additionalReward: json["additionalReward"] ?? "0.00",
      year: json["year"] ?? "2026",
      monthlyChartValues: json["monthlyChartValues"] != null
          ? List<double>.from(json["monthlyChartValues"])
          : List.filled(12, 0.0),
      dailyChartValues: json["dailyChartValues"] != null
          ? List<double>.from(json["dailyChartValues"])
          : List.filled(31, 0.0),
    );
  }
}
