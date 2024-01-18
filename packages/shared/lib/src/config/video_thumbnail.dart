import 'dart:io';
import 'dart:typed_data';

import 'package:video_thumbnail/video_thumbnail.dart';

/// {@template video_thumbnail_plus}
/// A package that manages video thumbnail.
/// {@endtemplate}
class VideoThumbnailPlus {
  /// Returns a [Uint8List] containing the thumbnail of the video.
  static Future<Uint8List?> getVideoThumbnail(File video) =>
      VideoThumbnail.thumbnailData(video: video.path);
}
