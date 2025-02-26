import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

class DateTimeSerializer implements JsonConverter<DateTime, dynamic> {
  const DateTimeSerializer();

  @override
  DateTime fromJson(dynamic json) {
    if (json is Timestamp) {
      return json.toDate(); // 🔹 Convert Firestore Timestamp to DateTime
    } else if (json is String) {
      return DateTime.parse(json); // 🔹 Handle string format (if stored as a string)
    }
    throw Exception("Invalid timestamp format");
  }

  @override
  dynamic toJson(DateTime date) => Timestamp.fromDate(date); // 🔹 Convert DateTime to Firestore Timestamp
}
