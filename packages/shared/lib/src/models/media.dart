import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:shared/shared.dart';

/// Deserializes and serializes [Media] instances.
class ListMediaConverterFromDb extends JsonConverter<List<Media>, String> {
  /// {@macro list_media_converter}
  const ListMediaConverterFromDb();

  @override
  List<Media> fromJson(String json) => List<Media>.from(
        (jsonDecode(json) as List<dynamic>)
            .map((e) => Media.fromJson(e as Map<String, dynamic>)),
      ).toList();

  @override
  String toJson(List<Media> object) =>
      json.encode(object.map((media) => media.toJson()).toList());
}

/// Deserializes and serializes [Media] instances.
class ListMediaConverterFromRemoteConfig
    extends JsonConverter<List<Media>, List<dynamic>> {
  /// {@macro list_media_converter_from_remove_config}
  const ListMediaConverterFromRemoteConfig();

  @override
  List<Media> fromJson(List<dynamic> json) => List<Media>.from(
        json.map((e) => Media.fromJson(e as Map<String, dynamic>)),
      );

  @override
  List<Map<String, dynamic>> toJson(List<Media> object) =>
      object.map((e) => e.toJson()).toList();
}

/// {@template insta_block}
/// A reusable Instagram Media which represents a content-based component.
/// {@endtemplate}
@immutable
abstract class Media extends Equatable {
  /// {@macro insta_bloc}
  const Media({
    required this.id,
    required this.url,
    required this.type,
    this.blurHash,
  });

  /// The unique identifier of the media.
  final String id;

  /// The URL of the media.
  final String url;

  /// The block type key used to identify the type of block/metadata.
  final String type;

  /// The blur hash of the media used to display image loading like in Instagram
  final String? blurHash;

  /// Converts current instance to a `Map<String, dynamic>`.
  Map<String, dynamic> toJson();

  /// Deserialize [json] into a [Media] instance.
  static Media fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      ImageMedia.identifier => ImageMedia.fromJson(json),
      VideoMedia.identifier => VideoMedia.fromJson(json),
      _ => ImageMedia.fromJson(json),
    };
  }

  @override
  List<Object?> get props => [id, url, blurHash, type];
}

/// The extension on `List<Media>` which provides methods to check if the list
/// contains any video media.
extension HasVideoMedia on List<Media> {
  /// Whether the list of media has any video.
  bool get hasVideo => any((e) => e is VideoMedia || e is MemoryVideoMedia);

  /// Whether the list of media is reel, meaning there is only one video.
  bool get isReel =>
      length == 1 && every((e) => e is VideoMedia || e is MemoryVideoMedia);
}
