import 'dart:io';
import 'dart:typed_data';

import 'package:video_compress/video_compress.dart';

/// {@template video_thumbnail_plus}
/// A package that manages video thumbnail.
/// {@endtemplate}
class VideoPlus {
  const VideoPlus._();

  /// Returns a [Uint8List] containing the thumbnail of the video.
  static Future<Uint8List?> getVideoThumbnail(File video) =>
      VideoCompress.getByteThumbnail(video.path);

  /// Compresses the video.
  static Future<MediaInfo?> compressVideo(File video) async {
    await VideoCompress.setLogLevel(0);

    return VideoCompress.compressVideo(
      video.path,
      includeAudio: true,
    );
  }
}
