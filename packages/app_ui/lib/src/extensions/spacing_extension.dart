import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// Calculates spacing based on current [screenWidth].
extension SpacingExtension on BuildContext {
  /// Calculate the spacing based on the screen width.
  double get textSpacing => baseTextSpacing * (screenWidth / 375.0);

  /// Defines value of spacing width based on current screen width.
  double get spacingWidth {
    double? spacingWidth;
    if (screenWidth < 375) {
      // Small screen width
      spacingWidth = baseSpacingWidthS;
    } else if (screenWidth >= 375 && screenWidth < 600) {
      // Medium screen width
      spacingWidth = baseSpacingWidthM;
    } else if (screenWidth >= 600 && screenWidth < 800) {
      // Large screen width
      spacingWidth = baseSpacingWidthL;
    } else if (screenWidth >= 800 && screenWidth < 1200) {
      // Extra Large screen width
      spacingWidth = baseSpacingWidthXL;
    } else {
      // Extra Extra Large screen width
      spacingWidth = baseSpacingWidthXXL;
    }
    return spacingWidth;
  }

  /// Defines value of spacing height based on current screen height.
  double get spacingHeight {
    double? spacingHeight;
    if (screenWidth < 375) {
      // Small screen width
      spacingHeight = baseSpacingHeightS;
    } else if (screenWidth >= 375 && screenWidth < 600) {
      // Medium screen width
      spacingHeight = baseSpacingHeightM;
    } else if (screenWidth >= 600 && screenWidth < 800) {
      // Large screen width
      spacingHeight = baseSpacingHeightL;
    } else if (screenWidth >= 800 && screenWidth < 1200) {
      // Extra Large screen width
      spacingHeight = baseSpacingHeightXL;
    } else {
      // Extra Extra Large screen width
      spacingHeight = baseSpacingHeightXXL;
    }
    return spacingHeight;
  }

  /// Take the average of the width and height spacing to ensure balance.
  double get spacing => (spacingWidth + spacingHeight) / 2.0;
}
