import 'package:flutter/material.dart';

class CarouselDotIndicator extends StatelessWidget {
  const CarouselDotIndicator({
    required this.photoCount,
    required this.activePhotoIndex,
    super.key,
  });

  final int photoCount;
  final int activePhotoIndex;

  Widget _buildDot({required bool isActive}) {
    return Container(
      margin: const EdgeInsets.only(left: 3, right: 3),
      height: isActive ? 7.5 : 6.0,
      width: isActive ? 7.5 : 6.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Colors.blue.shade500 : Colors.grey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(photoCount, (i) => i)
          .map((i) => _buildDot(isActive: i == activePhotoIndex))
          .toList(),
    );
  }
}
