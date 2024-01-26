import 'dart:typed_data';

import 'package:blurhash/blurhash.dart';

/// {@template video_thumbnail_plus}
/// A package that manages video thumbnail.
/// {@endtemplate}
class BlurHashPlus {
  const BlurHashPlus._();

  /// Returns a [Uint8List] containing the thumbnail of the video.
  static Future<String> blurHashEncode(Uint8List bytes) =>
      BlurHash.encode(bytes, 4, 3);
}
