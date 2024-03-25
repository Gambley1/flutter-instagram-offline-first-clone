// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: cast_nullable_to_non_nullable, implicit_dynamic_parameter, lines_longer_than_80_chars, prefer_const_constructors, require_trailing_commas

part of 'comment_bloc.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommentState _$CommentStateFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'CommentState',
      json,
      ($checkedConvert) {
        final val = CommentState(
          status: $checkedConvert(
              'status', (v) => $enumDecode(_$CommentStatusEnumMap, v)),
          likes: $checkedConvert('likes', (v) => v as int),
          comments: $checkedConvert('comments', (v) => v as int),
          isLiked: $checkedConvert('is_liked', (v) => v as bool),
          isOwner: $checkedConvert('is_owner', (v) => v as bool),
          isLikedByOwner:
              $checkedConvert('is_liked_by_owner', (v) => v as bool),
          repliedComments: $checkedConvert(
              'replied_comments',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
                  .toList()),
        );
        return val;
      },
      fieldKeyMap: const {
        'isLiked': 'is_liked',
        'isOwner': 'is_owner',
        'isLikedByOwner': 'is_liked_by_owner',
        'repliedComments': 'replied_comments'
      },
    );

Map<String, dynamic> _$CommentStateToJson(CommentState instance) {
  final val = <String, dynamic>{
    'status': _$CommentStatusEnumMap[instance.status]!,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('replied_comments',
      instance.repliedComments?.map((e) => e.toJson()).toList());
  val['likes'] = instance.likes;
  val['comments'] = instance.comments;
  val['is_liked'] = instance.isLiked;
  val['is_owner'] = instance.isOwner;
  val['is_liked_by_owner'] = instance.isLikedByOwner;
  return val;
}

const _$CommentStatusEnumMap = {
  CommentStatus.initial: 'initial',
  CommentStatus.loading: 'loading',
  CommentStatus.success: 'success',
  CommentStatus.failure: 'failure',
};
