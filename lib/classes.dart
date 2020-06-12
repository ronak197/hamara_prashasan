import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Map<String, String> avatarLocMap = {
  'health': 'assets/health_avatar.svg',
  'police': 'assets/police_avatar.svg',
  'muncorp': 'assets/muncorp_avatar.svg',
};

Map<String, int> avatarColorMap = {
  'health': 0xffFFFDFC,
  'police': 0xffFFFFFC,
  'muncorp': 0xffFDFCFF,
};

Map<String, int> categoryTagColorMap = {
  'health': 0xff01C8B5,
  'police': 0xffFFCE00,
  'muncorp': 0xff3D17BC,
};

class Feed {
  FeedInfo feedInfo;
  Department department;
  FeedInfoDetails feedInfoDetails;
  String profileAvatar;
  int bgColor;
  String feedId;

  Feed(
      {FeedInfo feedInfo,
      Department department,
      FeedInfoDetails feedInfoDetails,
      String feedId}) {
    this.feedInfo = feedInfo;
    this.department = department;
    this.feedInfoDetails = feedInfoDetails;
    this.profileAvatar = "assets/${department.category}_avatar.svg";
    this.bgColor = avatarColorMap['${department.category}'];
    this.feedId = feedId;
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

  factory FeedInfo.fromFirestoreJson(Map<String, dynamic> json) => FeedInfo(
        creationDateTimeStamp:
            (json["creationDateTimeStamp"] as Timestamp).toDate(),
        departmentUid: json["departmentUid"],
        description: json["description"],
        title: json["title"],
      );

  Map<String, dynamic> toFirestoreJson() => {
        "creationDateTimeStamp": Timestamp.fromDate(creationDateTimeStamp),
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

class UserData {
  List<String> bookmarkedFeeds;
  String email;
  DateTime lastUpdateTime;
  String lastUserState;
  LatLng lastLocation;
  List<String> subscribedDepartmentIDs;
  String userType;

  UserData(
      {this.bookmarkedFeeds,
      this.email,
      this.lastUpdateTime,
      this.lastUserState,
      this.lastLocation,
      this.subscribedDepartmentIDs,
      this.userType});

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
        bookmarkedFeeds: List<String>.from(
            (json["bookmarkedFeeds"] ?? List<dynamic>()).map((x) => x)),
        email: json["email"] as String,
        lastUpdateTime: json["lastUpdateTime"] != null
            ? (json["lastUpdateTime"].runtimeType == Timestamp
                ? (json["lastUpdateTime"] as Timestamp)?.toDate()
                : DateTime.parse(json["lastUpdateTime"]))
            : DateTime.now(),
        lastUserState: json["lastUserState"] as String,
        lastLocation: LatLng.fromJson(json["lastLocation"]),
        subscribedDepartmentIDs: List<String>.from(
            (json["subscribedDepartmentIDs"] ?? List<dynamic>()).map((x) => x)),
        userType: json["userType "] as String,
      );

  Map<String, dynamic> toJson() => {
        "bookmarkedFeeds": bookmarkedFeeds,
        "email": email,
        "lastUpdateTime": lastUpdateTime?.toIso8601String(),
        "lastUserState": lastUserState,
        "lastLocation": lastLocation.toJson(),
        "subscribedDepartmentIDs": subscribedDepartmentIDs,
        "userType": userType,
      };

  factory UserData.fromFirestoreJson(Map<String, dynamic> json) => UserData(
        bookmarkedFeeds: List<String>.from(
            (json["bookmarkedFeeds"] ?? List<dynamic>()).map((x) => x)),
        email: json["email"] as String,
        lastUpdateTime: json["lastUpdateTime"] != null
            ? (json["lastUpdateTime"].runtimeType == Timestamp
                ? (json["lastUpdateTime"] as Timestamp)?.toDate()
                : DateTime.parse(json["lastUpdateTime"]))
            : DateTime.now(),
        lastUserState: json["lastUserState"] as String,
        lastLocation: LatLng((json["lastLocation"] as GeoPoint).latitude ?? 0,
            (json["lastLocation"] as GeoPoint).longitude ?? 0),
        subscribedDepartmentIDs: List<String>.from(
            (json["subscribedDepartmentIDs"] ?? List<dynamic>()).map((x) => x)),
        userType: json["userType"] as String,
      );

  Map<String, dynamic> toFirestoreJson() => {
        "bookmarkedFeeds": bookmarkedFeeds,
        "email": email,
        "lastUpdateTime": Timestamp.fromDate(lastUpdateTime ?? DateTime.now()),
        "lastUserState": lastUserState,
        "lastLocation": GeoPoint(lastLocation.latitude, lastLocation.longitude),
        "subscribedDepartmentIDs": subscribedDepartmentIDs,
        "userType": userType,
      };
}

class AuthUser {
  String displayName;
  String email;
  String phoneNumber;
  String photoUrl;
  String photoString;
  String uid;

  AuthUser(
      {this.displayName,
      this.email,
      this.phoneNumber,
      this.photoUrl,
      this.uid});

  void setPhotoString(String s) {
    this.photoString = s;
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        displayName: json["displayName"],
        email: json["email"],
        phoneNumber: json["phoneNumber"],
        photoUrl: json["photoUrl"],
        uid: json["uid"],
      );

  Map<String, dynamic> toJson() => {
        "displayName": displayName,
        "email": email,
        "phoneNumber": phoneNumber,
        "photoUrl": photoUrl,
        "uid": uid,
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

class Feeds {
  List<Feed> feeds = List<Feed>();
}
