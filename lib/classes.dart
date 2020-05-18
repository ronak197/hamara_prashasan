import 'dart:convert';

class FeedInfo {

  DateTime creationDateTimeStamp;
  String departmentUid;
  String description;
  String title;

  FeedInfo({
    this.creationDateTimeStamp,
    this.departmentUid,
    this.description,
    this.title
  });

  factory FeedInfo.fromJson(Map<String, dynamic> json) => FeedInfo(
      creationDateTimeStamp : json["creationDateTimeStamp"],
      departmentUid : json["departmentUid"],
      description : json["description"],
      title : json["title"],
  );

  Map<String, dynamic> toJson() => {
    "creationDateTimeStamp" : creationDateTimeStamp,
    "departmentUid" : departmentUid,
    "description" : description,
    "title" : title,
  };
}

class FeedInfoDetails {

  List<Map<String,dynamic>> details;

  FeedInfoDetails({
    this.details,
  });

  factory FeedInfoDetails.fromJson(Map<String, dynamic> json) => FeedInfoDetails(
    details: List<Map<String,dynamic>>.from(json["details"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "details": List<Map<String,dynamic>>.from(details.map((x) => x)),
  };
}
