

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

TodoModel todoModelFromJson(String str) => TodoModel.fromJson(json.decode(str));

String todoModelToJson(TodoModel data) => json.encode(data.toJson());

class TodoModel {
  String? id;
  String? title;
  DateTime? dateTime;
  bool? isDone;
  bool? isStarred;
  bool? isPinned;
  String? category;
  int? orderIndex;
  DateTime? deletedAt;
  bool? isSynced;     // synced with firestore
  bool? isDeleted;    // soft delete locally
  bool? isUpdated;    // updated locally

  TodoModel({
    this.id,
    this.title,
    this.dateTime,
    this.isDone,
    this.isStarred,
    this.isPinned,
    this.category,
    this.orderIndex,
    this.deletedAt,
    this.isSynced,
    this.isDeleted,
    this.isUpdated,
  });

  TodoModel copyWith({
    String? id,
    String? title,
    DateTime? dateTime,
    bool? isDone,
    bool? isStarred,
    bool? isPinned,
    String? category,
    DateTime? deletedAt,
    bool? isSynced,
    bool? isDeleted,
    bool? isUpdated,
  }) =>
      TodoModel(
        id: id ?? this.id,
        title: title ?? this.title,
        dateTime: dateTime ?? this.dateTime,
        isDone: isDone ?? this.isDone,
        isStarred: isStarred ?? this.isStarred,
        isPinned: isPinned ?? this.isPinned,
        category: category ?? this.category,
        deletedAt: deletedAt ?? this.deletedAt,
        isSynced: isSynced ?? this.isSynced,
        isDeleted: isDeleted ?? this.isDeleted,
        isUpdated: isUpdated ?? this.isUpdated,
      );

  factory TodoModel.fromJson(Map<String, dynamic> json) =>
      TodoModel(
        id: json["id"],
        title: json["title"],
        dateTime: json["dateTime"] == null
            ? null
            : DateTime.parse(json["dateTime"].toString()),
        isDone: json["isDone"],
        isStarred: json["isStarred"],
        isPinned: json["isPinned"],
        category: json["category"],
        orderIndex: json["orderIndex"],

        deletedAt: json["deletedAt"] != null
            ? (json["deletedAt"] as Timestamp).toDate()
            : null,
        isSynced: json["isSynced"] ?? false,
        isDeleted: json["isDeleted"] ?? false,
        isUpdated: json["isUpdated"] ?? false,
      );

  Map<String, dynamic> toJson() =>
      {
        "id": id,
        "title": title,
        "dateTime": dateTime?.toIso8601String(),
        "isDone": isDone,
        "isStarred": isStarred,
        "isPinned": isPinned,
        "category": category,
        "orderIndex": orderIndex,
        "deletedAt": deletedAt,
        "isSynced": isSynced ?? false,
        "isDeleted": isDeleted ?? false,
        "isUpdated": isUpdated ?? false,
      };
}