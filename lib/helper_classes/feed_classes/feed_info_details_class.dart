class FeedInfoDetails {
  List<Map<String, dynamic>> details;

  FeedInfoDetails({
    this.details,
  });

  factory FeedInfoDetails.fromJson(Map<String, dynamic> json) =>
      FeedInfoDetails(
        details: List<Map<String, dynamic>>.from(json["details"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
    "details": List<Map<String, dynamic>>.from(details.map((x) => x)),
  };
}
