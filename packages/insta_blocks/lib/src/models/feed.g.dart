// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: cast_nullable_to_non_nullable, implicit_dynamic_parameter, lines_longer_than_80_chars, prefer_const_constructors, require_trailing_commas

part of 'feed.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Feed _$FeedFromJson(Map<String, dynamic> json) => $checkedCreate(
      'Feed',
      json,
      ($checkedConvert) {
        final val = Feed(
          blocks: $checkedConvert(
              'blocks',
              (v) => const InstaBlocksConverter()
                  .fromJson(v as List<Map<String, dynamic>>)),
          totalBlocks: $checkedConvert('total_blocks', (v) => v as int),
        );
        return val;
      },
      fieldKeyMap: const {'totalBlocks': 'total_blocks'},
    );

Map<String, dynamic> _$FeedToJson(Feed instance) => <String, dynamic>{
      'blocks': const InstaBlocksConverter().toJson(instance.blocks),
      'total_blocks': instance.totalBlocks,
    };
