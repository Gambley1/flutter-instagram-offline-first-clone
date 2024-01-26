import 'package:json_annotation/json_annotation.dart';
import 'package:user_repository/user_repository.dart';

/// Deserializes and serializes [User] instances.
class UserConverter extends JsonConverter<User, Map<String, dynamic>> {
  /// {@macro user_converter}
  const UserConverter();

  @override
  User fromJson(Map<String, dynamic> json) => User.fromJson(json);

  @override
  Map<String, dynamic> toJson(User object) => object.toJson();
}
