import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:task_manager/helpers/date_time_helper.dart';
import 'package:task_manager/models/serializers/color_serializer.dart';
import 'package:task_manager/models/serializers/datetime_serializer.dart';
import 'package:uuid/uuid.dart';

part 'category.g.dart';

@JsonSerializable()
class Category extends Equatable{
  final String? id;
  final String name;
  final String userId;

  @ColorSerializer()
  final Color color;

  @DateTimeSerializer()
  final DateTime createdAt;

  @DateTimeSerializer()
  final DateTime updatedAt;

  @NullableDateTimeSerializer()
  final DateTime? deletedAt;

  const Category({
    required this.id,
    required this.name,
    required this.userId,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  bool get isGeneral => id == null;

  static Category create({
    bool isGeneral = false,
    required String name,
    required Color color,
    required userId
  }){
    return Category(
      id: isGeneral ? null : const Uuid().v4(),
      name: name,
      color: color,
      userId:isGeneral?" ":userId,
      createdAt: DateTime.now().copyWith(microsecond: 0),
      updatedAt: DateTime.now().copyWith(microsecond: 0)
    );
  }

  Category copyWith({
    String? id,
    String? name,
    Color? color,
    DateTime? deletedAt
  }){
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      createdAt: createdAt,
      userId: this.userId,
      updatedAt: DateTime.now().copyWith(microsecond: 0),
      deletedAt: deletedAt ?? this.deletedAt
    );
  }

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryToJson(this);

  @override
  List<Object?> get props => [id, name, color, createdAt, updatedAt, deletedAt];

  @override
  bool get stringify => true;
}