// ignore_for_file: overridden_fields

import 'dart:io';

import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:shared/shared.dart';

part 'video.g.dart';

@immutable
@JsonSerializable()

/// {@template video_media}
/// A video media block.
/// {@endtemplate}
class VideoMedia extends Media {
  /// {@macro video_media}
  const VideoMedia({
    required this.id,
    required super.url,
    required this.firstFrameUrl,
    super.blurHash,
    super.type = VideoMedia.identifier,
  }) : super(id: id);

  /// Converts a `Map<String, dynamic>` into a [VideoMedia] instance.
  factory VideoMedia.fromJson(Map<String, dynamic> json) =>
      _$VideoMediaFromJson(json);

  @override
  @JsonKey(name: 'media_id')
  final String id;

  /// The `url` of the first frame of the video.
  @JsonKey(defaultValue: '')
  final String firstFrameUrl;

  /// The video media block type identifier.
  static const identifier = '__video_media__';

  @override
  Map<String, dynamic> toJson() => _$VideoMediaToJson(this);
}

@immutable

/// {@template memory_video_media}
/// A memory video media block.
/// {@endtemplate}
class MemoryVideoMedia extends Media {
  /// {@macro memory_video_media}
  const MemoryVideoMedia({
    required super.id,
    required this.file,
    super.url = '',
    super.blurHash,
    super.type = MemoryVideoMedia.identifier,
  });

  /// The file of the memory image.
  final File file;

  /// The video media block type identifier.
  static const identifier = '__memory_video_media__';

  @override
  Map<String, dynamic> toJson() => {
        'file': file.readAsBytesSync().toList(),
      };
}
