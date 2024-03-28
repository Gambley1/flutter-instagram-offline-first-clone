// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: cast_nullable_to_non_nullable, implicit_dynamic_parameter, lines_longer_than_80_chars, prefer_const_constructors, require_trailing_commas

part of 'user_stories_bloc.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserStoriesState _$UserStoriesStateFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'UserStoriesState',
      json,
      ($checkedConvert) {
        final val = UserStoriesState(
          author: $checkedConvert(
              'author', (v) => User.fromJson(v as Map<String, dynamic>)),
          stories: $checkedConvert(
              'stories',
              (v) => (v as List<dynamic>)
                  .map((e) => Story.fromJson(e as Map<String, dynamic>))
                  .toList()),
          showStories: $checkedConvert('show_stories', (v) => v as bool),
        );
        return val;
      },
      fieldKeyMap: const {'showStories': 'show_stories'},
    );

Map<String, dynamic> _$UserStoriesStateToJson(UserStoriesState instance) =>
    <String, dynamic>{
      'author': instance.author.toJson(),
      'stories': instance.stories.map((e) => e.toJson()).toList(),
      'show_stories': instance.showStories,
    };
