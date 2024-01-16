import 'package:flutter/material.dart';

class MediaPickerParamsModel {
  MediaPickerParamsModel(
      {this.maxPickImages = 2,
      this.singlePick = true,
      this.appBarColor = Colors.black,
      this.albumBackGroundColor = Colors.black,
      this.albumDividerColor = Colors.white,
      this.albumTextColor = Colors.white,
      this.appBarIconColor,
      this.appBarTextColor = Colors.white,
      this.crossAxisCount = 3,
      this.gridViewBackgroundColor = Colors.black54,
      this.childAspectRatio = 0.5,
      this.appBarLeadingWidget,
      this.appBarHeight = 100,
      this.imageBackgroundColor = Colors.white,
      this.gridPadding,
      this.gridViewController,
      this.gridViewPhysics,
      this.selectedBackgroundColor = Colors.white,
      this.selectedCheckColor = Colors.white,
      this.thumbnailBoxFix = BoxFit.cover,
      this.selectedCheckBackgroundColor = Colors.white,
      this.onlyImages = true,
      this.onlyVideos = false,
      this.thumbnailQuality = 200});

  /// maximum images allowed (default 2)
  final int maxPickImages;

  /// picker mode
  final bool singlePick;

  /// dropdown appbar color
  final Color appBarColor;

  /// appBar TextColor
  final Color appBarTextColor;

  /// appBar icon Color
  final Color? appBarIconColor;

  /// gridView background color
  final Color gridViewBackgroundColor;

  /// grid image backGround color
  final Color imageBackgroundColor;

  /// album background color
  final Color albumBackGroundColor;

  /// album text color
  final Color albumTextColor;

  /// album divider color
  final Color albumDividerColor;

  /// gallery gridview crossAxisCount
  final int crossAxisCount;

  /// gallery gridview aspect ratio
  final double childAspectRatio;

  /// appBar leading widget
  final Widget? appBarLeadingWidget;

  /// appBar height
  final double appBarHeight;

  /// gridView Padding
  final EdgeInsets? gridPadding;

  /// gridView physics
  final ScrollPhysics? gridViewPhysics;

  /// gridView controller
  final ScrollController? gridViewController;

  /// selected background color
  final Color selectedBackgroundColor;

  /// selected check color
  final Color selectedCheckColor;

  /// thumbnail box fit
  final BoxFit thumbnailBoxFix;

  /// selected Check Background Color
  final Color selectedCheckBackgroundColor;

  /// load video
  final bool onlyVideos;

  /// load images
  final bool onlyImages;

  /// image quality thumbnail
  final int thumbnailQuality;
}
