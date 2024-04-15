// ignore_for_file: public_member_api_docs

import 'package:freezed_annotation/freezed_annotation.dart';

part 'type.freezed.dart';

@immutable
@freezed
class Type with _$Type {
  const factory Type.planeText() = PlaneText;
  const factory Type.textUrl({required String url}) = TextUrl;
  const factory Type.customEmoji({required int customEmojiId}) = CustomEmoji;
}
