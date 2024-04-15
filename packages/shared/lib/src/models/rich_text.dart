// ignore_for_file: public_member_api_docs

import 'package:shared/src/models/entity.dart';
import 'package:shared/src/models/type.dart' as t;

class RichableText {
  const RichableText({
    required this.entities,
  });

  factory RichableText.planeText(String text) {
    return RichableText(
      entities: <Entity>[
        Entity(text: text, types: <t.Type>[const t.Type.planeText()]),
      ],
    );
  }

  final List<Entity> entities;
}
