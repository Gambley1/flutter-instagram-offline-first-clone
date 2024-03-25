// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: cast_nullable_to_non_nullable, implicit_dynamic_parameter, lines_longer_than_80_chars, prefer_const_constructors, require_trailing_commas

part of 'block_action.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NavigateToPostAuthorProfileAction _$NavigateToPostAuthorProfileActionFromJson(
        Map<String, dynamic> json) =>
    $checkedCreate(
      'NavigateToPostAuthorProfileAction',
      json,
      ($checkedConvert) {
        final val = NavigateToPostAuthorProfileAction(
          authorId: $checkedConvert('author_id', (v) => v as String),
          type: $checkedConvert(
              'type',
              (v) =>
                  v as String? ?? NavigateToPostAuthorProfileAction.identifier),
        );
        return val;
      },
      fieldKeyMap: const {'authorId': 'author_id'},
    );

Map<String, dynamic> _$NavigateToPostAuthorProfileActionToJson(
        NavigateToPostAuthorProfileAction instance) =>
    <String, dynamic>{
      'author_id': instance.authorId,
      'type': instance.type,
    };

NavigateToSponsoredPostAuthorProfileAction
    _$NavigateToSponsoredPostAuthorProfileActionFromJson(
            Map<String, dynamic> json) =>
        $checkedCreate(
          'NavigateToSponsoredPostAuthorProfileAction',
          json,
          ($checkedConvert) {
            final val = NavigateToSponsoredPostAuthorProfileAction(
              authorId: $checkedConvert('author_id', (v) => v as String),
              promoPreviewImageUrl: $checkedConvert(
                  'promo_preview_image_url', (v) => v as String),
              promoUrl: $checkedConvert('promo_url', (v) => v as String),
              type: $checkedConvert(
                  'type',
                  (v) =>
                      v as String? ??
                      NavigateToSponsoredPostAuthorProfileAction.identifier),
            );
            return val;
          },
          fieldKeyMap: const {
            'authorId': 'author_id',
            'promoPreviewImageUrl': 'promo_preview_image_url',
            'promoUrl': 'promo_url'
          },
        );

Map<String, dynamic> _$NavigateToSponsoredPostAuthorProfileActionToJson(
        NavigateToSponsoredPostAuthorProfileAction instance) =>
    <String, dynamic>{
      'author_id': instance.authorId,
      'promo_preview_image_url': instance.promoPreviewImageUrl,
      'promo_url': instance.promoUrl,
      'type': instance.type,
    };

UnknownBlockAction _$UnknownBlockActionFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'UnknownBlockAction',
      json,
      ($checkedConvert) {
        final val = UnknownBlockAction(
          type: $checkedConvert(
              'type', (v) => v as String? ?? UnknownBlockAction.identifier),
        );
        return val;
      },
    );

Map<String, dynamic> _$UnknownBlockActionToJson(UnknownBlockAction instance) =>
    <String, dynamic>{
      'type': instance.type,
    };
