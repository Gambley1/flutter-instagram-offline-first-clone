// ignore_for_file: public_member_api_docs

import 'package:shared/src/models/type.dart';

class Entity {
  Entity({
    required this.text,
    required this.types,
  });

  final String text;
  final List<Type> types;
}
