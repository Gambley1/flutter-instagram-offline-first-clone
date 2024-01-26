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
    required super.id,
    required super.url,
    super.blurHash,
    super.type = ImageMedia.identifier,
  });

  /// Converts a `Map<String, dynamic>` into a [ImageMedia] instance.
  factory ImageMedia.fromJson(Map<String, dynamic> json) =>
      _$ImageMediaFromJson(json);

  /// The image media block type identifier.
  static const identifier = '__image_media__';

  @override
  Map<String, dynamic> toJson() => _$ImageMediaToJson(this);
}
