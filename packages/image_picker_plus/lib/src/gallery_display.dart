import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_plus/image_picker_plus.dart';
import 'package:image_picker_plus/src/camera_display.dart';
import 'package:image_picker_plus/src/images_view_page.dart';

class CustomImagePicker extends StatefulWidget {
  final ImageSource source;
  final bool multiSelection;
  final GalleryDisplaySettings? galleryDisplaySettings;
  final PickerSource pickerSource;
  final FilterOptionGroup? filterOption;

  const CustomImagePicker({
    required this.source,
    required this.multiSelection,
    required this.galleryDisplaySettings,
    required this.pickerSource,
    this.filterOption,
    super.key,
  });

  @override
  CustomImagePickerState createState() => CustomImagePickerState();
}

class CustomImagePickerState extends State<CustomImagePicker>
    with TickerProviderStateMixin {
  final pageController = PageController();
  final clearVideoRecord = ValueNotifier(false);
  final redDeleteText = ValueNotifier(false);
  final selectedPage = ValueNotifier(SelectedPage.left);
  final multiSelectedImages = ValueNotifier(<File>[]);
  final multiSelectionMode = ValueNotifier(false);
  final showDeleteText = ValueNotifier(false);
  final selectedVideo = ValueNotifier(false);
  var noGallery = true;
  final selectedCameraImage = ValueNotifier<File?>(null);
  late bool cropImage;
  late AppTheme appTheme;
  late TabsTexts tabsNames;
  late bool showImagePreview;
  late int maximumSelection;
  final isImagesReady = ValueNotifier(false);
  final currentPage = ValueNotifier(0);
  final lastPage = ValueNotifier(0);

  late Color whiteColor;
  late Color blackColor;
  late GalleryDisplaySettings imagePickerDisplay;

  late bool enableCamera;
  late bool enableVideo;
  late String limitingText;

  late bool showInternalVideos;
  late bool showInternalImages;
  late SliverGridDelegateWithFixedCrossAxisCount gridDelegate;
  late bool cameraAndVideoEnabled;
  late bool cameraVideoOnlyEnabled;
  late bool showAllTabs;
  late AsyncValueSetter<SelectedImagesDetails>? callbackFunction;

  @override
  void initState() {
    _initializeVariables();
    super.initState();
  }

  _initializeVariables() {
    imagePickerDisplay =
        widget.galleryDisplaySettings ?? GalleryDisplaySettings();
    appTheme = imagePickerDisplay.appTheme ?? AppTheme();
    tabsNames = imagePickerDisplay.tabsTexts ?? TabsTexts();
    callbackFunction = imagePickerDisplay.callbackFunction;
    cropImage = imagePickerDisplay.cropImage;
    maximumSelection = imagePickerDisplay.maximumSelection;
    limitingText = tabsNames.limitingText ??
        "The limit is $maximumSelection photos or videos.";

    showImagePreview = cropImage || imagePickerDisplay.showImagePreview;
    gridDelegate = imagePickerDisplay.gridDelegate;

    showInternalImages = widget.pickerSource != PickerSource.video;
    showInternalVideos = widget.pickerSource != PickerSource.image;

    noGallery = widget.source != ImageSource.camera;
    bool notGallery = widget.source != ImageSource.gallery;

    enableCamera = showInternalImages && notGallery;
    enableVideo = showInternalVideos && notGallery;
    cameraAndVideoEnabled = enableCamera && enableVideo;
    cameraVideoOnlyEnabled =
        cameraAndVideoEnabled && widget.source == ImageSource.camera;
    showAllTabs = cameraAndVideoEnabled && noGallery;
    whiteColor = appTheme.primaryColor;
    blackColor = appTheme.focusColor;
  }

  @override
  void dispose() {
    showDeleteText.dispose();
    selectedVideo.dispose();
    selectedPage.dispose();
    selectedCameraImage.dispose();
    pageController.dispose();
    clearVideoRecord.dispose();
    redDeleteText.dispose();
    multiSelectionMode.dispose();
    multiSelectedImages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return tabController();
  }

  Widget tabBarMessage(bool isThatDeleteText) {
    Color deleteColor = redDeleteText.value ? Colors.red : appTheme.focusColor;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: GestureDetector(
          onTap: () async {
            if (isThatDeleteText) {
              setState(() {
                if (!redDeleteText.value) {
                  redDeleteText.value = true;
                } else {
                  selectedCameraImage.value = null;
                  clearVideoRecord.value = true;
                  showDeleteText.value = false;
                  redDeleteText.value = false;
                }
              });
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (isThatDeleteText)
                Icon(Icons.arrow_back_ios_rounded,
                    color: deleteColor, size: 15),
              Text(
                isThatDeleteText ? tabsNames.deletingText : limitingText,
                style: TextStyle(
                    fontSize: 14,
                    color: deleteColor,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget clearSelectedImages() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: GestureDetector(
          onTap: () async {
            setState(() {
              multiSelectionMode.value = !multiSelectionMode.value;
              multiSelectedImages.value.clear();
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                tabsNames.clearImagesText,
                style: TextStyle(
                    fontSize: 14,
                    color: appTheme.focusColor,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  replacingDeleteWidget(bool showDeleteText) {
    this.showDeleteText.value = showDeleteText;
  }

  moveToVideo() {
    setState(() {
      selectedPage.value = SelectedPage.right;
      selectedVideo.value = true;
    });
  }

  DefaultTabController tabController() {
    return DefaultTabController(
        length: 2, child: Material(color: whiteColor, child: safeArea()));
  }

  SafeArea safeArea() {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: PageView(
              controller: pageController,
              dragStartBehavior: DragStartBehavior.start,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                if (noGallery) imagesViewPage(),
                if (enableCamera || enableVideo) cameraPage(),
              ],
            ),
          ),
          if (multiSelectedImages.value.length < maximumSelection) ...[
            ValueListenableBuilder(
              valueListenable: multiSelectionMode,
              builder: (context, bool multiSelectionModeValue, child) {
                if (enableVideo || enableCamera) {
                  if (!showImagePreview) {
                    if (multiSelectionModeValue) {
                      return clearSelectedImages();
                    } else {
                      return buildTabBar();
                    }
                  } else {
                    return Visibility(
                      visible: !multiSelectionModeValue,
                      child: buildTabBar(),
                    );
                  }
                } else {
                  return multiSelectionModeValue
                      ? clearSelectedImages()
                      : const SizedBox();
                }
              },
            )
          ] else ...[
            tabBarMessage(false)
          ],
        ],
      ),
    );
  }

  ValueListenableBuilder<bool> cameraPage() {
    return ValueListenableBuilder(
      valueListenable: selectedVideo,
      builder: (context, bool selectedVideoValue, child) => CustomCameraDisplay(
        appTheme: appTheme,
        selectedCameraImage: selectedCameraImage,
        tabsNames: tabsNames,
        enableCamera: enableCamera,
        enableVideo: enableVideo,
        replacingTabBar: replacingDeleteWidget,
        clearVideoRecord: clearVideoRecord,
        redDeleteText: redDeleteText,
        moveToVideoScreen: moveToVideo,
        selectedVideo: selectedVideoValue,
        callbackFunction: callbackFunction,
      ),
    );
  }

  void clearMultiImages() {
    setState(() {
      multiSelectedImages.value.clear();
      multiSelectionMode.value = false;
    });
  }

  ImagesViewPage imagesViewPage() {
    return ImagesViewPage(
      appTheme: appTheme,
      clearMultiImages: clearMultiImages,
      callbackFunction: callbackFunction,
      gridDelegate: gridDelegate,
      multiSelectionMode: multiSelectionMode,
      blackColor: blackColor,
      showImagePreview: showImagePreview,
      tabsTexts: tabsNames,
      multiSelectedImages: multiSelectedImages,
      whiteColor: whiteColor,
      cropImage: cropImage,
      multiSelection: widget.multiSelection,
      showInternalVideos: showInternalVideos,
      showInternalImages: showInternalImages,
      maximumSelection: maximumSelection,
      filterOption: widget.filterOption,
    );
  }

  ValueListenableBuilder<bool> buildTabBar() {
    return ValueListenableBuilder(
      valueListenable: showDeleteText,
      builder: (context, bool showDeleteTextValue, child) => AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        switchInCurve: Curves.easeInOutQuart,
        child: widget.source == ImageSource.both ||
                widget.pickerSource == PickerSource.both
            ? (showDeleteTextValue ? tabBarMessage(true) : tabBar())
            : const SizedBox(),
      ),
    );
  }

  Widget tabBar() {
    double widthOfScreen = MediaQuery.of(context).size.width;
    int divideNumber = showAllTabs ? 3 : 2;
    double widthOfTab = widthOfScreen / divideNumber;
    return ValueListenableBuilder(
      valueListenable: selectedPage,
      builder: (context, SelectedPage selectedPageValue, child) {
        Color photoColor =
            selectedPageValue == SelectedPage.center ? blackColor : Colors.grey;
        return Stack(
          alignment: Alignment.bottomLeft,
          children: [
            Row(
              children: [
                if (noGallery) galleryTabBar(widthOfTab, selectedPageValue),
                if (enableCamera) photoTabBar(widthOfTab, photoColor),
                if (enableVideo) videoTabBar(widthOfTab),
              ],
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOutQuad,
              right: selectedPageValue == SelectedPage.center
                  ? widthOfTab
                  : (selectedPageValue == SelectedPage.right
                      ? 0
                      : (divideNumber == 2 ? widthOfTab : widthOfScreen / 1.5)),
              child: Container(height: 1, width: widthOfTab, color: blackColor),
            ),
          ],
        );
      },
    );
  }

  GestureDetector galleryTabBar(
      double widthOfTab, SelectedPage selectedPageValue) {
    return GestureDetector(
      onTap: () {
        centerPage(numPage: 0, selectedPage: SelectedPage.left);
      },
      child: SizedBox(
        width: widthOfTab,
        height: 40,
        child: Center(
          child: Text(
            tabsNames.galleryText,
            style: TextStyle(
                color: selectedPageValue == SelectedPage.left
                    ? blackColor
                    : Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  GestureDetector photoTabBar(double widthOfTab, Color textColor) {
    return GestureDetector(
      onTap: () => centerPage(
          numPage: cameraVideoOnlyEnabled ? 0 : 1,
          selectedPage:
              cameraVideoOnlyEnabled ? SelectedPage.left : SelectedPage.center),
      child: SizedBox(
        width: widthOfTab,
        height: 40,
        child: Center(
          child: Text(
            tabsNames.photoText,
            style: TextStyle(
                color: textColor, fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  centerPage({required int numPage, required SelectedPage selectedPage}) {
    if (!enableVideo && numPage == 1) selectedPage = SelectedPage.right;

    this.selectedPage.value = selectedPage;
    pageController.animateToPage(numPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutQuad);
    selectedVideo.value = false;
  }

  GestureDetector videoTabBar(double widthOfTab) {
    return GestureDetector(
      onTap: () {
        pageController.animateToPage(cameraVideoOnlyEnabled ? 0 : 1,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutQuad);
        selectedPage.value = SelectedPage.right;
        selectedVideo.value = true;
      },
      child: SizedBox(
        width: widthOfTab,
        height: 40,
        child: ValueListenableBuilder(
          valueListenable: selectedVideo,
          builder: (context, bool selectedVideoValue, child) => Center(
            child: Text(
              tabsNames.videoText,
              style: TextStyle(
                  fontSize: 14,
                  color: selectedVideoValue ? blackColor : Colors.grey,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
    );
  }
}
