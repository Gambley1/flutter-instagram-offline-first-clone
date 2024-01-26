import 'package:json_annotation/json_annotation.dart';

/// Serialize and deserialize [DateTime] instances.
class DateTimeConverter extends JsonConverter<DateTime, String> {
  /// {@macro date_time_convert}
  const DateTimeConverter();

  @override
  DateTime fromJson(String json) {
    var jsonString = json;
    if (jsonString.contains('.')) {
      jsonString = jsonString.substring(0, json.length - 1);
    }

    return DateTime.parse(jsonString);
  }

  @override
  String toJson(DateTime object) => object.toIso8601String();
}
