import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_plus/image_picker_plus.dart';
import 'package:image_picker_plus/src/crop_image_view.dart';
import 'package:image_picker_plus/src/custom_crop.dart';
import 'package:image_picker_plus/src/image.dart';
import 'package:image_picker_plus/src/multi_selection_mode.dart';
import 'package:insta_assets_crop/insta_assets_crop.dart';
import 'package:shimmer/shimmer.dart';

class ImagesViewPage extends StatefulWidget {
  final ValueNotifier<List<File>> multiSelectedImages;
  final ValueNotifier<bool> multiSelectionMode;
  final TabsTexts tabsTexts;
  final bool cropImage;
  final bool multiSelection;
  final bool showInternalVideos;
  final bool showInternalImages;
  final int maximumSelection;
  final AsyncValueSetter<SelectedImagesDetails>? callbackFunction;

  /// To avoid lag when you interacting with image when it expanded
  final AppTheme appTheme;
  final VoidCallback clearMultiImages;
  final Color whiteColor;
  final Color blackColor;
  final bool showImagePreview;
  final SliverGridDelegateWithFixedCrossAxisCount gridDelegate;

  final FilterOptionGroup? filterOption;

  const ImagesViewPage({
    Key? key,
    required this.multiSelectedImages,
    required this.multiSelectionMode,
    required this.clearMultiImages,
    required this.appTheme,
    required this.tabsTexts,
    required this.whiteColor,
    required this.cropImage,
    required this.multiSelection,
    required this.showInternalVideos,
    required this.showInternalImages,
    required this.blackColor,
    required this.showImagePreview,
    required this.gridDelegate,
    required this.maximumSelection,
    required this.filterOption,
    this.callbackFunction,
  }) : super(key: key);

  @override
  State<ImagesViewPage> createState() => _ImagesViewPageState();
}

class _ImagesViewPageState extends State<ImagesViewPage>
    with AutomaticKeepAliveClientMixin {
  late PMFilter _filterOption;

  final _mediaList = ValueNotifier(<FutureBuilder<Uint8List?>>[]);

  final allImages = ValueNotifier(<File?>[]);
  final scaleOfCropsKeys = ValueNotifier(<double?>[]);
  final areaOfCropsKeys = ValueNotifier(<Rect?>[]);

  final selectedImage = ValueNotifier<File?>(null);
  final indexOfSelectedImages = ValueNotifier(<int>[]);

  final scrollController = ScrollController();

  final expandImage = ValueNotifier(false);
  final expandHeight = ValueNotifier(0.0);
  final moveAwayHeight = ValueNotifier(0.0);
  final expandImageView = ValueNotifier(false);

  final isImagesReady = ValueNotifier(false);
  final currentPage = ValueNotifier(0);
  final lastPage = ValueNotifier(0);

  /// To avoid lag when you interacting with image when it expanded
  final enableVerticalTapping = ValueNotifier(false);
  final cropKey = GlobalKey<CustomCropState>();
  final noPaddingForGridView = ValueNotifier(false);

  final scrollPixels = ValueNotifier<double>(0.0);
  final isScrolling = ValueNotifier(false);
  final noImages = ValueNotifier(false);
  final noDuration = ValueNotifier(false);
  final indexOfLatestImage = ValueNotifier<int>(-1);

  @override
  void dispose() {
    _mediaList.dispose();
    allImages.dispose();
    scrollController.dispose();
    isImagesReady.dispose();
    lastPage.dispose();
    expandImage.dispose();
    expandHeight.dispose();
    moveAwayHeight.dispose();
    expandImageView.dispose();
    enableVerticalTapping.dispose();
    noDuration.dispose();
    scaleOfCropsKeys.dispose();
    areaOfCropsKeys.dispose();
    indexOfSelectedImages.dispose();
    super.dispose();
  }

  late Widget forBack;

  @override
  void initState() {
    _applyFilerOption();

    _fetchNewMedia(currentPageValue: 0);
    super.initState();
  }

  void _applyFilerOption() {
    final newOption = FilterOptionGroup(
      imageOption: const FilterOption(
        sizeConstraint: SizeConstraint(ignoreSize: true),
      ),
      audioOption: const FilterOption(
        needTitle: true,
        sizeConstraint: SizeConstraint(ignoreSize: true),
      ),
      createTimeCond: DateTimeCond.def().copyWith(ignore: true),
      updateTimeCond: DateTimeCond.def().copyWith(ignore: true),
    );
    if (widget.filterOption != null) {
      newOption.merge(widget.filterOption!);
    }
    _filterOption = newOption;
  }

  bool _handleScrollEvent(ScrollNotification scroll,
      {required int currentPageValue, required int lastPageValue}) {
    if (scroll.metrics.pixels / scroll.metrics.maxScrollExtent > 0.33 &&
        currentPageValue != lastPageValue) {
      _fetchNewMedia(currentPageValue: currentPageValue);
      return true;
    }
    return false;
  }

  Future<void> _fetchNewMedia({required int currentPageValue}) async {
    lastPage.value = currentPageValue;
    final result = await PhotoManager.requestPermissionExtend();
    if (result.isAuth) {
      final type = widget.showInternalVideos && widget.showInternalImages
          ? RequestType.common
          : (widget.showInternalImages ? RequestType.image : RequestType.video);

      final albums = await PhotoManager.getAssetPathList(
        onlyAll: true,
        type: type,
        filterOption: _filterOption,
      );
      if (albums.isEmpty) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => noImages.value = true);
        return;
      } else if (noImages.value) {
        noImages.value = false;
      }

      final media = await albums[0].getAssetListPaged(
        page: currentPageValue,
        size: 60,
      );
      final temp = <FutureBuilder<Uint8List?>>[];
      final imageTemp = <File?>[];

      for (int i = 0; i < media.length; i++) {
        final gridViewImage = getImageGallery(media, i);
        final image = await highQualityImage(media, i);
        temp.add(gridViewImage);
        imageTemp.add(image);
      }
      _mediaList.value.addAll(temp);
      allImages.value.addAll(imageTemp);
      if (selectedImage.value == allImages.value[0] ||
          selectedImage.value == null) {
        selectedImage.value = allImages.value[0];
      }
      currentPage.value++;
      isImagesReady.value = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
    } else {
      await PhotoManager.requestPermissionExtend();
      PhotoManager.openSetting();
    }
  }

  FutureBuilder<Uint8List?> getImageGallery(List<AssetEntity> media, int i) {
    final highResolution = widget.gridDelegate.crossAxisCount <= 3;
    final futureBuilder = FutureBuilder<Uint8List?>(
      future: media[i].thumbnailDataWithSize(highResolution
          ? const ThumbnailSize(350, 350)
          : const ThumbnailSize(200, 200)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final image = snapshot.data;
          if (image != null) {
            return Container(
              color: const Color.fromARGB(255, 189, 189, 189),
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: MemoryImageDisplay(
                      imageBytes: image,
                      appTheme: widget.appTheme,
                    ),
                  ),
                  if (media[i].type == AssetType.video) ...[
                    const Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: EdgeInsets.only(right: 5, bottom: 5),
                        child: Icon(
                          Icons.slow_motion_video_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ]
                ],
              ),
            );
          }
        }
        return const SizedBox();
      },
    );
    return futureBuilder;
  }

  Future<File?> highQualityImage(List<AssetEntity> media, int i) async =>
      media[i].file;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ValueListenableBuilder<bool>(
      valueListenable: noImages,
      builder: (context, noImages, child) {
        if (noImages) {
          return Stack(
            children: [
              normalAppBar(withDoneButton: false),
              Align(
                child: Text(
                  widget.tabsTexts.noImagesFounded,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          );
        } else {
          return buildGridView();
        }
      },
    );
  }

  Widget buildGridView() {
    return ValueListenableBuilder(
      valueListenable: isImagesReady,
      builder: (context, bool isImagesReadyValue, child) {
        if (isImagesReadyValue) {
          return ValueListenableBuilder<List<FutureBuilder<Uint8List?>>>(
            valueListenable: _mediaList,
            builder: (context, mediaList, child) {
              return ValueListenableBuilder(
                valueListenable: lastPage,
                builder: (context, int lastPageValue, child) =>
                    ValueListenableBuilder(
                  valueListenable: currentPage,
                  builder: (context, int currentPageValue, child) {
                    if (!widget.showImagePreview) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          normalAppBar(),
                          Flexible(
                            child: normalGridView(
                              mediaList,
                              currentPageValue,
                              lastPageValue,
                            ),
                          ),
                        ],
                      );
                    } else {
                      return instagramGridView(
                        mediaList,
                        currentPageValue,
                        lastPageValue,
                      );
                    }
                  },
                ),
              );
            },
          );
        } else {
          return loadingWidget();
        }
      },
    );
  }

  Widget loadingWidget() {
    return SingleChildScrollView(
      child: Column(
        children: [
          appBar(),
          Shimmer.fromColors(
            baseColor: widget.appTheme.shimmerBaseColor,
            highlightColor: widget.appTheme.shimmerHighlightColor,
            child: Column(
              children: [
                if (widget.showImagePreview) ...[
                  Container(
                    color: const Color(0xff696969),
                    height: 360,
                    width: double.infinity,
                  ),
                  const SizedBox(height: 1),
                ],
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: widget.gridDelegate.crossAxisSpacing),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    primary: false,
                    gridDelegate: widget.gridDelegate,
                    itemBuilder: (context, index) {
                      return Container(
                          color: const Color(0xff696969),
                          width: double.infinity);
                    },
                    itemCount: 40,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      backgroundColor: widget.appTheme.primaryColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.clear_rounded,
            color: widget.appTheme.focusColor, size: 30),
        onPressed: () {
          Navigator.of(context).maybePop(null);
        },
      ),
    );
  }

  Widget normalAppBar({bool withDoneButton = true}) {
    double width = MediaQuery.of(context).size.width;
    return Container(
      color: widget.whiteColor,
      height: 56,
      width: width,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          exitButton(),
          if (withDoneButton) ...[
            const Spacer(),
            doneButton(),
          ],
        ],
      ),
    );
  }

  IconButton exitButton() {
    return IconButton(
      icon: Icon(Icons.clear_rounded, color: widget.blackColor, size: 30),
      onPressed: () {
        Navigator.of(context).maybePop(null);
      },
    );
  }

  Widget doneButton() {
    return ValueListenableBuilder(
      valueListenable: indexOfSelectedImages,
      builder: (context, List<int> indexOfSelectedImagesValue, child) =>
          ValueListenableBuilder<int>(
              valueListenable: indexOfLatestImage,
              builder: (context, indexOfLatestImage, snapshot) {
                return IconButton(
                  icon: const Icon(Icons.arrow_forward_rounded,
                      color: Colors.blue, size: 30),
                  onPressed: () async {
                    final aspect = expandImage.value ? 4 / 5 : 1.0;
                    if (widget.multiSelectionMode.value &&
                        widget.multiSelection) {
                      if (areaOfCropsKeys.value.length !=
                          widget.multiSelectedImages.value.length) {
                        scaleOfCropsKeys.value.add(cropKey.currentState?.scale);
                        areaOfCropsKeys.value.add(cropKey.currentState?.area);
                      } else {
                        if (indexOfLatestImage != -1) {
                          scaleOfCropsKeys.value[indexOfLatestImage] =
                              cropKey.currentState?.scale;
                          areaOfCropsKeys.value[indexOfLatestImage] =
                              cropKey.currentState?.area;
                        }
                      }

                      final selectedBytes = <SelectedByte>[];
                      for (int i = 0;
                          i < widget.multiSelectedImages.value.length;
                          i++) {
                        final currentImage =
                            widget.multiSelectedImages.value[i];
                        final isThatVideo = currentImage.isVideo;
                        final croppedImage = !isThatVideo && widget.cropImage
                            ? await cropImage(currentImage, indexOfCropImage: i)
                            : null;
                        final image = croppedImage ?? currentImage;
                        final byte = await image.readAsBytes();
                        final img = SelectedByte(
                          isThatImage: !isThatVideo,
                          selectedFile: image,
                          selectedByte: byte,
                        );
                        selectedBytes.add(img);
                      }
                      if (selectedBytes.isNotEmpty) {
                        SelectedImagesDetails details = SelectedImagesDetails(
                          selectedFiles: selectedBytes,
                          multiSelectionMode: true,
                          aspectRatio: aspect,
                        );
                        if (!mounted) return;

                        void pop() => Navigator.of(context).maybePop(details);
                        if (widget.callbackFunction != null) {
                          await widget.callbackFunction!(details);
                          pop.call();
                        } else {
                          pop.call();
                        }
                      }
                    } else {
                      final image = selectedImage.value;
                      if (image == null) return;
                      final isThatVideo = image.isVideo;
                      final croppedImage = !isThatVideo && widget.cropImage
                          ? await cropImage(image)
                          : null;
                      final img = croppedImage ?? image;
                      final byte = await img.readAsBytes();

                      final selectedByte = SelectedByte(
                        isThatImage: !isThatVideo,
                        selectedFile: img,
                        selectedByte: byte,
                      );
                      final details = SelectedImagesDetails(
                        multiSelectionMode: false,
                        aspectRatio: aspect,
                        selectedFiles: [selectedByte],
                      );
                      if (!mounted) return;

                      void pop() => Navigator.of(context).maybePop(details);
                      if (widget.callbackFunction != null) {
                        await widget.callbackFunction!(details);
                        pop.call();
                      } else {
                        pop.call();
                      }
                    }
                  },
                );
              }),
    );
  }

  Widget normalGridView(
    List<FutureBuilder<Uint8List?>> mediaListValue,
    int currentPageValue,
    int lastPageValue,
  ) {
    return NotificationListener(
      onNotification: (ScrollNotification notification) {
        _handleScrollEvent(notification,
            currentPageValue: currentPageValue, lastPageValue: lastPageValue);
        return true;
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: widget.gridDelegate.crossAxisSpacing),
        child: GridView.builder(
          gridDelegate: widget.gridDelegate,
          itemBuilder: (context, index) {
            return buildImage(mediaListValue, index);
          },
          itemCount: mediaListValue.length,
        ),
      ),
    );
  }

  ValueListenableBuilder<File?> buildImage(
      List<FutureBuilder<Uint8List?>> mediaListValue, int index) {
    return ValueListenableBuilder(
      valueListenable: selectedImage,
      builder: (context, File? selectedImageValue, child) {
        return ValueListenableBuilder(
          valueListenable: allImages,
          builder: (context, List<File?> allImagesValue, child) {
            return ValueListenableBuilder(
              valueListenable: widget.multiSelectedImages,
              builder: (context, List<File> selectedImagesValue, child) {
                final mediaList = mediaListValue[index];
                final image = allImagesValue[index];
                if (image != null) {
                  final imageSelected = selectedImagesValue.contains(image);
                  final multiImages = selectedImagesValue;

                  return Stack(
                    children: [
                      gestureDetector(image, index, mediaList),
                      if (selectedImageValue == image)
                        gestureDetector(image, index, blurContainer()),
                      MultiSelectionMode(
                        image: image,
                        multiSelectionMode: widget.multiSelectionMode,
                        imageSelected: imageSelected,
                        multiSelectedImage: multiImages,
                      ),
                    ],
                  );
                } else {
                  return Container();
                }
              },
            );
          },
        );
      },
    );
  }

  Container blurContainer() {
    return Container(
      width: double.infinity,
      color: const Color.fromARGB(184, 234, 234, 234),
      height: double.maxFinite,
    );
  }

  Widget gestureDetector(File image, int index, Widget childWidget) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        widget.multiSelectionMode,
        widget.multiSelectedImages,
        indexOfLatestImage,
      ]),
      builder: (context, child) {
        return GestureDetector(
          key: ValueKey(index),
          onTap: () =>
              onTapImage(image, widget.multiSelectedImages.value, index),
          onLongPress: () {
            if (widget.multiSelection) {
              widget.multiSelectionMode.value = true;
            }
          },
          onLongPressUp: () {
            if (widget.multiSelectionMode.value) {
              selectionImageCheck(
                  image, widget.multiSelectedImages.value, index,
                  enableCopy: true);
              expandImageView.value = false;
              moveAwayHeight.value = 0;

              enableVerticalTapping.value = false;
              noPaddingForGridView.value = true;
            } else {
              onTapImage(image, widget.multiSelectedImages.value, index);
            }
          },
          child: childWidget,
        );
      },
    );
  }

  onTapImage(File image, List<File> selectedImagesValue, int index) {
    // setState(() {
    if (widget.multiSelectionMode.value) {
      final close = selectionImageCheck(image, selectedImagesValue, index);
      if (close) return;
    }
    selectedImage.value = image;
    expandImageView.value = false;
    moveAwayHeight.value = 0;
    enableVerticalTapping.value = false;
    noPaddingForGridView.value = true;
    // });
  }

  bool selectionImageCheck(
      File image, List<File> multiSelectionValue, int index,
      {bool enableCopy = false}) {
    selectedImage.value = image;
    if (multiSelectionValue.contains(image) && selectedImage.value == image) {
      // setState(() {
      final indexOfImage =
          multiSelectionValue.indexWhere((element) => element == image);
      multiSelectionValue.removeAt(indexOfImage);
      if (multiSelectionValue.isNotEmpty &&
          indexOfImage < scaleOfCropsKeys.value.length) {
        indexOfSelectedImages.value.remove(index);

        scaleOfCropsKeys.value.removeAt(indexOfImage);
        areaOfCropsKeys.value.removeAt(indexOfImage);
        indexOfLatestImage.value = -1;
      }
      // });

      return true;
    } else {
      if (multiSelectionValue.length < widget.maximumSelection) {
        // setState(() {
        if (!multiSelectionValue.contains(image)) {
          multiSelectionValue.add(image);
          if (multiSelectionValue.length > 1) {
            scaleOfCropsKeys.value.add(cropKey.currentState?.scale);
            areaOfCropsKeys.value.add(cropKey.currentState?.area);
            indexOfSelectedImages.value.add(index);
          }
        } else if (areaOfCropsKeys.value.length != multiSelectionValue.length) {
          scaleOfCropsKeys.value.add(cropKey.currentState?.scale);
          areaOfCropsKeys.value.add(cropKey.currentState?.area);
        }
        if (widget.showImagePreview && multiSelectionValue.contains(image)) {
          int index =
              multiSelectionValue.indexWhere((element) => element == image);
          if (indexOfLatestImage.value != -1) {
            scaleOfCropsKeys.value[indexOfLatestImage.value] =
                cropKey.currentState?.scale;
            areaOfCropsKeys.value[indexOfLatestImage.value] =
                cropKey.currentState?.area;
          }
          indexOfLatestImage.value = index;
        }

        if (enableCopy) selectedImage.value = image;
        // });
      }
      return false;
    }
  }

  Future<File?> cropImage(File imageFile, {int? indexOfCropImage}) async {
    await InstaAssetsCrop.requestPermissions();
    double? scale;
    Rect? area;
    if (indexOfCropImage == null) {
      scale = cropKey.currentState?.scale;
      area = cropKey.currentState?.area;
    } else {
      scale = scaleOfCropsKeys.value[indexOfCropImage];
      area = areaOfCropsKeys.value[indexOfCropImage];
    }

    if (area == null || scale == null) return null;

    final sample = await InstaAssetsCrop.sampleImage(
      file: imageFile,
      preferredSize: (2000 / scale).round(),
    );

    final file = await InstaAssetsCrop.cropImage(
      file: sample,
      area: area,
    );
    sample.delete();
    return file;
  }

  void clearMultiImages() {
    // setState(() {
    widget.multiSelectedImages.value = [];
    widget.clearMultiImages();
    indexOfSelectedImages.value.clear();
    scaleOfCropsKeys.value.clear();
    areaOfCropsKeys.value.clear();
    // });
  }

  Widget instagramGridView(
    List<FutureBuilder<Uint8List?>> mediaList,
    int currentPageValue,
    int lastPageValue,
  ) {
    return ValueListenableBuilder(
      valueListenable: expandHeight,
      builder: (context, double expandedHeightValue, child) {
        return ValueListenableBuilder(
          valueListenable: moveAwayHeight,
          builder: (context, double moveAwayHeightValue, child) =>
              ValueListenableBuilder<double>(
                  valueListenable: scrollPixels,
                  builder: (context, scrollPixels, snapshot) {
                    return ValueListenableBuilder<bool>(
                        valueListenable: noPaddingForGridView,
                        builder: (context, noPaddingForGridView, snapshot) {
                          return ValueListenableBuilder(
                            valueListenable: expandImageView,
                            builder: (context, bool expandImageValue, child) {
                              double a = expandedHeightValue - 360;
                              double expandHeightV = a < 0 ? a : 0;
                              double moveAwayHeightV = moveAwayHeightValue < 360
                                  ? moveAwayHeightValue * -1
                                  : -360;
                              double topPosition = expandImageValue
                                  ? expandHeightV
                                  : moveAwayHeightV;
                              enableVerticalTapping.value = !(topPosition == 0);
                              double padding = 2;
                              if (scrollPixels < 416) {
                                double pixels = 416 - scrollPixels;
                                padding = pixels >= 58 ? pixels + 2 : 58;
                              } else if (expandImageValue) {
                                padding = 58;
                              } else if (noPaddingForGridView) {
                                padding = 58;
                              } else {
                                padding = topPosition + 418;
                              }
                              int duration = noDuration.value ? 0 : 250;

                              return Stack(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(top: padding),
                                    child: NotificationListener<
                                        ScrollNotification>(
                                      onNotification: (notification) {
                                        expandImageView.value = false;
                                        moveAwayHeight.value =
                                            scrollController.position.pixels;
                                        this.scrollPixels.value =
                                            scrollController.position.pixels;
                                        isScrolling.value = true;
                                        noPaddingForGridView = false;
                                        noDuration.value = false;
                                        if (notification
                                            is ScrollEndNotification) {
                                          expandHeight.value =
                                              expandedHeightValue > 240
                                                  ? 360
                                                  : 0;
                                          isScrolling.value = false;
                                        }

                                        _handleScrollEvent(
                                          notification,
                                          currentPageValue: currentPageValue,
                                          lastPageValue: lastPageValue,
                                        );
                                        return true;
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: widget
                                                .gridDelegate.crossAxisSpacing),
                                        child: GridView.builder(
                                          gridDelegate: widget.gridDelegate,
                                          controller: scrollController,
                                          itemBuilder: (context, index) {
                                            return buildImage(mediaList, index);
                                          },
                                          itemCount: mediaList.length,
                                        ),
                                      ),
                                    ),
                                  ),
                                  AnimatedPositioned(
                                    top: topPosition,
                                    duration: Duration(milliseconds: duration),
                                    child: Column(
                                      children: [
                                        normalAppBar(),
                                        CropImageView(
                                          cropKey: cropKey,
                                          indexOfSelectedImages:
                                              indexOfSelectedImages,
                                          withMultiSelection:
                                              widget.multiSelection,
                                          selectedImage: selectedImage,
                                          appTheme: widget.appTheme,
                                          multiSelectionMode:
                                              widget.multiSelectionMode,
                                          enableVerticalTapping:
                                              enableVerticalTapping,
                                          expandHeight: expandHeight,
                                          expandImage: expandImage,
                                          expandImageView: expandImageView,
                                          noDuration: noDuration,
                                          clearMultiImages: clearMultiImages,
                                          topPosition: topPosition,
                                          whiteColor: widget.whiteColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        });
                  }),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
