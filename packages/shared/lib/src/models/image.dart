// ignore_for_file: overridden_fields

import 'dart:typed_data';

import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:shared/src/models/media.dart';

part 'image.g.dart';

@immutable
@JsonSerializable()

/// {@template image_media}
/// An image media block.
/// {@endtemplate}
class ImageMedia extends Media {
  /// {@macro image_media}
  const ImageMedia({
    required this.id,
    required super.url,
    super.blurHash,
    super.type = ImageMedia.identifier,
  }) : super(id: id);

  /// Converts a `Map<String, dynamic>` into a [ImageMedia] instance.
  factory ImageMedia.fromJson(Map<String, dynamic> json) =>
      _$ImageMediaFromJson(json);

  @override
  @JsonKey(name: 'media_id')
  final String id;

  /// The image media block type identifier.
  static const identifier = '__image_media__';

  @override
  Map<String, dynamic> toJson() => _$ImageMediaToJson(this);
}

/// Converts to and from [Uint8List] and [List]<[int]>.
class UintConverter implements JsonConverter<Uint8List, List<int>> {
  /// Create a new instance of [UintConverter].
  const UintConverter();

  @override
  Uint8List fromJson(List<int> json) {
    return Uint8List.fromList(json);
  }

  @override
  List<int> toJson(Uint8List object) {
    return object.toList();
  }
}

@immutable
@JsonSerializable()

/// {@template image_media}
/// A memory image media block.
/// {@endtemplate}
class MemoryImageMedia extends Media {
  /// {@macro memory_image_media}
  const MemoryImageMedia({
    required this.bytes,
    required super.id,
    super.url = '',
    super.type = MemoryImageMedia.identifier,
  });

  /// Bytes of the memory image.
  @UintConverter()
  final Uint8List bytes;

  /// The memory image media block type identifier.
  static const identifier = '__memory_image_media__';

  @override
  Map<String, dynamic> toJson() => _$MemoryImageMediaToJson(this);
}
