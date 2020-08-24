import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

  bool get isCitizen => this.userType != null && this.userType == "citizen";
  bool get isDepartment =>
      this.userType != null && this.userType == "department";
}