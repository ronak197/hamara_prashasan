import 'package:cloud_firestore/cloud_firestore.dart';

Map<String, String> avatarLocMap = {
  'health': 'assets/health_avatar.svg',
  'police': 'assets/police_avatar.svg',
  'muncorp': 'assets/muncorp_avatar.svg',
};

Map<String, int> avatarColorMap = {
  'health': 0xffFFEEED,
  'police': 0xffFFFCED,
  'muncorp': 0xffF1EDFF,
};

class Feed {
  FeedInfo feedInfo;
  Department department;
  FeedInfoDetails feedInfoDetails;
  String profileAvatar;
  int bgColor;

  Feed(FeedInfo feedInfo, Department department,
      FeedInfoDetails feedInfoDetails) {
    this.feedInfo = feedInfo;
    this.department = department;
    this.feedInfoDetails = feedInfoDetails;
    this.profileAvatar = "assets/${department.category}_avatar.svg";
    this.bgColor = avatarColorMap['${department.category}'];
  }
}

class FeedInfo {
  DateTime creationDateTimeStamp;
  String departmentUid;
  String description;
  String title;

  FeedInfo(
      {this.creationDateTimeStamp,
      this.departmentUid,
      this.description,
      this.title});

  factory FeedInfo.fromJson(Map<String, dynamic> json) => FeedInfo(
        creationDateTimeStamp: json["creationDateTimeStamp"],
        departmentUid: json["departmentUid"],
        description: json["description"],
        title: json["title"],
      );

  Map<String, dynamic> toJson() => {
        "creationDateTimeStamp": creationDateTimeStamp,
        "departmentUid": departmentUid,
        "description": description,
        "title": title,
      };
}

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

class User {
  List<String> bookmarkedFeeds;
  String email;
  DateTime lastFeedUpdateTime;
  GeoPoint lastLocation;
  List<String> subscribedDepartmentIDs;
  String userType;

  User(
      {this.bookmarkedFeeds,
      this.email,
      this.lastFeedUpdateTime,
      this.lastLocation,
      this.subscribedDepartmentIDs,
      this.userType});

  factory User.fromJson(Map<String, dynamic> json) => User(
        bookmarkedFeeds: json["bookmarkedFeeds"],
        email: json["email"],
        lastFeedUpdateTime: json["lastFeedUpdateTime"],
        lastLocation: json["lastLocation"],
        subscribedDepartmentIDs: json["subscribedDepartmentIDs"],
        userType: json["userType"],
      );

  Map<String, dynamic> toJson() => {
        "bookmarkedFeeds": bookmarkedFeeds,
        "email": email,
        "lastFeedUpdateTime": lastFeedUpdateTime,
        "lastLocation": lastLocation,
        "subscribedDepartmentIDs": subscribedDepartmentIDs,
        "userType": userType,
      };
}

class Department {
  String areaOfAdministration;
  String category;
  String email;
  String name;
  String userType;

  Department(
      {this.areaOfAdministration,
      this.category,
      this.email,
      this.name,
      this.userType});

  factory Department.fromJson(Map<String, dynamic> json) => Department(
        areaOfAdministration: json["areaOfAdministration"],
        category: json["category"],
        email: json["email"],
        name: json["name"],
        userType: json["userType"],
      );

  Map<String, dynamic> toJson() => {
        "areaOfAdministration": areaOfAdministration,
        "category": category,
        "email": email,
        "name": name,
        "userType": userType,
      };
}

class TableData {
  List<String> headers;
  List<List<String>> contents;
  TableData({this.headers, this.contents});
}
