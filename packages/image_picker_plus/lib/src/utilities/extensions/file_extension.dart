import 'dart:io';

extension FileExtension on File {
  bool get isVideo => path.toLowerCase().contains('mp4', path.length - 5);
}
