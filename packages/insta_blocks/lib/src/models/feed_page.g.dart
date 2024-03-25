// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: cast_nullable_to_non_nullable, implicit_dynamic_parameter, lines_longer_than_80_chars, prefer_const_constructors, require_trailing_commas

part of 'feed_page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FeedPage _$FeedPageFromJson(Map<String, dynamic> json) => $checkedCreate(
      'FeedPage',
      json,
      ($checkedConvert) {
        final val = FeedPage(
          blocks: $checkedConvert(
              'blocks',
              (v) => const InstaBlocksConverter()
                  .fromJson(v as List<Map<String, dynamic>>)),
          totalBlocks: $checkedConvert('total_blocks', (v) => v as int),
          page: $checkedConvert('page', (v) => v as int),
          hasMore: $checkedConvert('has_more', (v) => v as bool),
        );
        return val;
      },
      fieldKeyMap: const {'totalBlocks': 'total_blocks', 'hasMore': 'has_more'},
    );

Map<String, dynamic> _$FeedPageToJson(FeedPage instance) => <String, dynamic>{
      'blocks': const InstaBlocksConverter().toJson(instance.blocks),
      'total_blocks': instance.totalBlocks,
      'page': instance.page,
      'has_more': instance.hasMore,
    };
