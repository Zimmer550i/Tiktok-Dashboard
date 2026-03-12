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

  // Chart Data
  List<double> monthlyChartValues;
  List<double> dailyChartValues;

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
    "year": year,
    "selectedVideoTagIndex": selectedVideoTagIndex,
    "lastUpdate": lastUpdate,
    "videoCards": videoCards.map((v) => v.toJson()).toList(),
    "criteria": criteria.map((v) => v.toJson()).toList(),
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
      monthlyChartValues: json["monthlyChartValues"] != null
          ? List<double>.from(json["monthlyChartValues"])
          : List.filled(12, 0.0),
      dailyChartValues: json["dailyChartValues"] != null
          ? List<double>.from(json["dailyChartValues"])
          : List.filled(31, 0.0),
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
