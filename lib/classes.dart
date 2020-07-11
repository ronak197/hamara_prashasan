import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hamaraprashasan/app_configurations.dart';

Map<String, String> avatarLocMap = {
  'department' : 'assets/avatars/department.svg',
  'health' : 'assets/avatars/health.svg',
  'police': 'assets/avatars/police.svg',
  'municipality': 'assets/avatars/municipality.svg',
  'transport': 'assets/avatars/transport.svg',
  'commerce': 'assets/avatars/commerce.svg',
  'tourism': 'assets/avatars/tourism.svg',
  'space': 'assets/avatars/space.svg',
  'railway': 'assets/avatars/railway.svg',
  'agriculture': 'assets/avatars/agriculture.svg',
};

Map<String, int> avatarColorMap = {
  'department' : 0xffF7FBFF,
  'health': 0xffFFFAFA,
  'police': 0xffFFFEFA,
  'municipality': 0xffFBFAFF,
  'transport': 0xffFAFAFA,
  'commerce': 0xffFFFBFA,
  'tourism': 0xffFAFCFF,
  'space': 0xffFAFCFF,
  'railway': 0xffFFFAFA,
  'agriculture': 0xffFAFFFC,
};

Map<String, int> categoryTagColorMap = {
  'department' : 0xff175FB4,
  'health': 0xffE2574C,
  'police': 0xffFFCE00,
  'municipality': 0xff3D17BC,
  'transport': 0xff777777,
  'commerce': 0xffB9785F,
  'tourism': 0xff55A4F9,
  'space': 0xff205B98,
  'railway': 0xffC03A2B,
  'agriculture': 0xff02A437,
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
    this.profileAvatar = "assets/avatars/${department.category}.svg";
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
        userType: json["userType"] as String,
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
  String localPhotoLoc;
  String uid;

  AuthUser(
      {this.displayName,
      this.email,
      this.phoneNumber,
      this.photoUrl,
      this.localPhotoLoc,
      this.uid});

  void setPhotoLoc(String s) {
    this.localPhotoLoc = s;
    AppConfigs.prefs.setString('authUserDetails', jsonEncode(this));
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        displayName: json["displayName"],
        email: json["email"],
        phoneNumber: json["phoneNumber"],
        photoUrl: json["photoUrl"],
        uid: json["uid"],
        localPhotoLoc: json['localPhotoLoc'],
      );

  Map<String, dynamic> toJson() => {
        "displayName": displayName,
        "email": email,
        "phoneNumber": phoneNumber,
        "photoUrl": photoUrl,
        "uid": uid,
        "localPhotoLoc": localPhotoLoc,
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

List<String> imageFormats = [
  "jpg",
  "jpeg",
  "jpe",
  "jif",
  "jfif",
  "jfi",
  "png",
  "gif",
  "webp",
  "tiff",
  "tif",
  "psd",
  "raw",
  "arw",
  "cr2",
  "nrw",
  "k25",
  "bmp",
  "dib",
  "heif",
  "heic",
  "ind",
  "indd",
  "indt",
  "jp2",
  "j2k",
  "jpf",
  "jpx",
  "jpm",
  "mj2",
  "svg",
  "svgz",
  "ai",
  "eps"
];
