import 'package:cloud_firestore/cloud_firestore.dart';

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
