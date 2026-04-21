class VideoCardModel {
  String title;
  String author;
  String imageUrl;
  String authorImageUrl;

  VideoCardModel({
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.authorImageUrl,
  });

  Map<String, dynamic> toJson() => {
    "title": title,
    "author": author,
    "imageUrl": imageUrl,
    "authorImageUrl": authorImageUrl,
  };

  factory VideoCardModel.fromJson(Map<String, dynamic> json) {
    return VideoCardModel(
      title: json["title"] ?? "TikTok is now",
      author: json["author"] ?? "Seth",
      imageUrl: json["imageUrl"] ?? "",
      authorImageUrl: json["authorImageUrl"] ?? "",
    );
  }
}

class CriteriaModel {
  String title;
  String desc;
  String icon;

  CriteriaModel({required this.title, required this.desc, required this.icon});

  Map<String, dynamic> toJson() => {"title": title, "desc": desc, "icon": icon};

  factory CriteriaModel.fromJson(Map<String, dynamic> json) {
    return CriteriaModel(
      title: json["title"] ?? "",
      desc: json["desc"] ?? "",
      icon: json["icon"] ?? "face",
    );
  }
}

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

  // Video Section
  int selectedVideoTagIndex;
  List<VideoCardModel> videoCards;

  // Chart Data (totals; kept in sync with standard + additional per index)
  List<double> monthlyChartValues;
  List<double> dailyChartValues;
  List<double> monthlyStandardValues;
  List<double> monthlyAdditionalValues;
  List<double> dailyStandardValues;
  List<double> dailyAdditionalValues;

  // Criteria Section
  List<CriteriaModel> criteria;

  String lastUpdate;

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
    required this.monthlyStandardValues,
    required this.monthlyAdditionalValues,
    required this.dailyStandardValues,
    required this.dailyAdditionalValues,
    required this.year,
    required this.selectedVideoTagIndex,
    required this.videoCards,
    required this.criteria,
    required this.lastUpdate,
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
    "monthlyStandardValues": monthlyStandardValues,
    "monthlyAdditionalValues": monthlyAdditionalValues,
    "dailyStandardValues": dailyStandardValues,
    "dailyAdditionalValues": dailyAdditionalValues,
    "year": year,
    "selectedVideoTagIndex": selectedVideoTagIndex,
    "lastUpdate": lastUpdate,
    "videoCards": videoCards.map((v) => v.toJson()).toList(),
    "criteria": criteria.map((v) => v.toJson()).toList(),
  };

  factory PerformanceModel.fromJson(Map<String, dynamic> json) {
    final monthlyChartValues = json["monthlyChartValues"] != null
        ? List<double>.from(json["monthlyChartValues"])
        : List.filled(12, 0.0);
    final dailyChartValues = json["dailyChartValues"] != null
        ? List<double>.from(json["dailyChartValues"])
        : List.filled(31, 0.0);

    final monthlyStandardValues = json["monthlyStandardValues"] != null
        ? List<double>.from(json["monthlyStandardValues"])
        : List<double>.from(monthlyChartValues);
    final monthlyAdditionalValues = json["monthlyAdditionalValues"] != null
        ? List<double>.from(json["monthlyAdditionalValues"])
        : List<double>.filled(monthlyChartValues.length, 0.0);
    _trimOrPadChartSplit(monthlyChartValues, monthlyStandardValues,
        monthlyAdditionalValues);

    final dailyStandardValues = json["dailyStandardValues"] != null
        ? List<double>.from(json["dailyStandardValues"])
        : List<double>.from(dailyChartValues);
    final dailyAdditionalValues = json["dailyAdditionalValues"] != null
        ? List<double>.from(json["dailyAdditionalValues"])
        : List<double>.filled(dailyChartValues.length, 0.0);
    _trimOrPadChartSplit(
        dailyChartValues, dailyStandardValues, dailyAdditionalValues);

    return PerformanceModel(
      rewards: json["rewards"] ?? "0.00",
      rpm: json["rpm"] ?? "--",
      qualifiedViews: json["qualifiedViews"] ?? "Less than 1,000",
      creatorRewardsTotal: json["creatorRewardsTotal"] ?? "0.00",
      creatorRewardsChange: json["creatorRewardsChange"] ?? "0.00 (Feb 15)",
      dateRange: json["dateRange"] ?? "Jan 1, 2026 - Jan 31, 2026",
      standardReward: json["standardReward"] ?? "\$0.00",
      additionalReward: json["additionalReward"] ?? "\$0.00",
      year: json["year"] ?? "2026",
      selectedVideoTagIndex: json["selectedVideoTagIndex"] ?? 0,
      lastUpdate: json["lastUpdate"] ?? "Feb 15",
      videoCards:
          (json["videoCards"] as List?)
              ?.map((v) => VideoCardModel.fromJson(v))
              .toList() ??
          List.generate(
            3,
            (index) => VideoCardModel(
              title: "TikTok is now",
              author: "Seth",
              imageUrl: "",
              authorImageUrl: "",
            ),
          ),
      monthlyChartValues: monthlyChartValues,
      dailyChartValues: dailyChartValues,
      monthlyStandardValues: monthlyStandardValues,
      monthlyAdditionalValues: monthlyAdditionalValues,
      dailyStandardValues: dailyStandardValues,
      dailyAdditionalValues: dailyAdditionalValues,
      criteria:
          (json["criteria"] as List?)
              ?.map((v) => CriteriaModel.fromJson(v))
              .toList() ??
          [
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
    );
  }
}

/// Keeps standard/additional lists aligned with chart total series length.
void _trimOrPadChartSplit(
  List<double> totals,
  List<double> standard,
  List<double> additional,
) {
  final n = totals.length;
  while (standard.length < n) {
    standard.add(0.0);
  }
  if (standard.length > n) {
    standard.removeRange(n, standard.length);
  }
  while (additional.length < n) {
    additional.add(0.0);
  }
  if (additional.length > n) {
    additional.removeRange(n, additional.length);
  }
}
