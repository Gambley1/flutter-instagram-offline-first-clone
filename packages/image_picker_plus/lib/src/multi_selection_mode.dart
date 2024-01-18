import 'dart:io';

import 'package:flutter/material.dart';

class MultiSelectionMode extends StatelessWidget {
  final ValueNotifier<bool> multiSelectionMode;
  final bool imageSelected;
  final List<File> multiSelectedImage;

  final File image;
  const MultiSelectionMode({
    Key? key,
    required this.image,
    required this.imageSelected,
    required this.multiSelectedImage,
    required this.multiSelectionMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: multiSelectionMode,
      builder: (context, bool multiSelectionModeValue, child) => Visibility(
        visible: multiSelectionModeValue,
        child: Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: Container(
              height: 25,
              width: 25,
              decoration: BoxDecoration(
                color: imageSelected
                    ? Colors.blue
                    : const Color.fromARGB(115, 222, 222, 222),
                border: Border.all(
                  color: Colors.white,
                ),
                shape: BoxShape.circle,
              ),
              child: imageSelected
                  ? Center(
                      child: Text(
                        "${multiSelectedImage.indexOf(image) + 1}",
                        style: const TextStyle(color: Colors.white),
                      ),
                    )
                  : Container(),
            ),
          ),
        ),
      ),
    );
  }
}
