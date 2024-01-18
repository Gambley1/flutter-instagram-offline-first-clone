import 'dart:typed_data';
import 'package:image_picker_plus/image_picker_plus.dart';
import 'package:flutter/material.dart';

class MemoryImageDisplay extends StatefulWidget {
  final Uint8List imageBytes;
  final AppTheme appTheme;

  const MemoryImageDisplay(
      {Key? key, required this.imageBytes, required this.appTheme})
      : super(key: key);

  @override
  State<MemoryImageDisplay> createState() => _NetworkImageDisplayState();
}

class _NetworkImageDisplayState extends State<MemoryImageDisplay> {
  @override
  void didChangeDependencies() {
    precacheImage(MemoryImage(widget.imageBytes), context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return buildOctoImage();
  }

  Widget buildOctoImage() {
    return Container(
      width: double.infinity,
      color: widget.appTheme.shimmerBaseColor,
      child: Image.memory(
        widget.imageBytes,
        errorBuilder: (context, url, error) => buildError(),
        fit: BoxFit.cover,
        width: double.infinity,
      ),
    );
  }

  SizedBox buildError() {
    return SizedBox(
        width: double.infinity,
        child: Icon(Icons.warning_amber_rounded,
            color: widget.appTheme.focusColor));
  }
}
