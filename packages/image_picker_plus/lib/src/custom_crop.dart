import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

const _kCropGridColumnCount = 3;
const _kCropGridRowCount = 3;
const _kCropGridColor = Color.fromRGBO(0xd0, 0xd0, 0xd0, 0.9);
const _kCropHandleSize = 0.0;
const _kCropHandleHitSize = 48.0;

enum _CropAction { none, moving, cropping, scaling }

enum _CropHandleSide { none, topLeft, topRight, bottomLeft, bottomRight }

class CustomCrop extends StatefulWidget {
  final File image;
  final double? aspectRatio;
  final double maximumScale;

  final bool alwaysShowGrid;
  final Color? paintColor;
  final ImageErrorListener? onImageError;
  final ValueChanged<bool>? scrollCustomList;
  final bool isThatImage;

  const CustomCrop({
    Key? key,
    this.aspectRatio,
    this.paintColor,
    this.scrollCustomList,
    this.maximumScale = 2.0,
    this.alwaysShowGrid = false,
    this.isThatImage = true,
    this.onImageError,
    required this.image,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => CustomCropState();

  static CustomCropState? of(BuildContext context) =>
      context.findAncestorStateOfType<CustomCropState>();
}

class CustomCropState extends State<CustomCrop> with TickerProviderStateMixin {
  final _surfaceKey = GlobalKey();

  late final AnimationController _activeController;
  late final AnimationController _settleController;

  double _scale = 1.0;
  double _ratio = 1.0;
  Rect _view = Rect.zero;
  Rect _area = Rect.zero;
  Offset _lastFocalPoint = Offset.zero;
  _CropAction _action = _CropAction.none;
  _CropHandleSide _handle = _CropHandleSide.none;

  late double _startScale;
  late Rect _startView;
  late Tween<Rect?> _viewTween;
  late Tween<double> _scaleTween;

  ImageStream? _imageStream;
  ui.Image? _image;
  ImageStreamListener? _imageListener;

  double get scale => _area.shortestSide / _scale;

  Rect? get area => _view.isEmpty
      ? null
      : Rect.fromLTWH(
          _area.left * _view.width / _scale - _view.left,
          _area.top * _view.height / _scale - _view.top,
          _area.width * _view.width / _scale,
          _area.height * _view.height / _scale,
        );
  bool get _isEnabled => _view.isEmpty == false && _image != null;

  final Map<double, double> _maxAreaWidthMap = {};

  int pointers = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getImage(force: true);
    });

    _activeController = AnimationController(
      vsync: this,
      value: widget.alwaysShowGrid ? 1.0 : 0.0,
    )..addListener(() => setState(() {}));
    _settleController = AnimationController(vsync: this)
      ..addListener(_settleAnimationChanged);
  }

  @override
  void dispose() {
    final listener = _imageListener;
    if (listener != null) {
      _imageStream?.removeListener(listener);
    }
    _activeController.dispose();
    _settleController.dispose();

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getImage();
  }

  @override
  void didUpdateWidget(CustomCrop oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.image != oldWidget.image) {
      _getImage();
    } else if (widget.aspectRatio != oldWidget.aspectRatio) {
      // _area = _calculateDefaultArea(
      //   viewWidth: _view.width,
      //   viewHeight: _view.height,
      //   imageWidth: _image?.width,
      //   imageHeight: _image?.height,
      // );
      WidgetsBinding.instance.addPostFrameCallback((_) => _updateView());
    }
    if (widget.alwaysShowGrid != oldWidget.alwaysShowGrid) {
      if (widget.alwaysShowGrid) {
        _activate();
      } else {
        _deactivate();
      }
    }
  }

  void _getImage({bool force = false}) {
    if (widget.isThatImage) {
      final oldImageStream = _imageStream;
      FileImage image = FileImage(widget.image, scale: 1.0);
      final newImageStream =
          image.resolve(createLocalImageConfiguration(context));
      _imageStream = newImageStream;
      if (newImageStream.key != oldImageStream?.key || force) {
        final oldImageListener = _imageListener;
        if (oldImageListener != null) {
          oldImageStream?.removeListener(oldImageListener);
        }
        final newImageListener =
            ImageStreamListener(_updateImage, onError: widget.onImageError);
        _imageListener = newImageListener;
        newImageStream.addListener(newImageListener);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints.expand(),
      child: Listener(
        onPointerDown: (event) => pointers++,
        onPointerUp: (event) => pointers = 0,
        child: GestureDetector(
          key: _surfaceKey,
          behavior: HitTestBehavior.opaque,
          onScaleStart: _isEnabled ? _handleScaleStart : null,
          onScaleUpdate: _isEnabled ? _handleScaleUpdate : null,
          onScaleEnd: _isEnabled ? _handleScaleEnd : null,
          child: RepaintBoundary(
            child: AnimatedBuilder(
              builder: (context, child) {
                if (widget.isThatImage) {
                  return buildCustomPaint();
                } else {
                  return _DisplayVideo(selectedFile: widget.image);
                }
              },
              animation: _activeController,
            ),
          ),
        ),
      ),
    );
  }

  void _handleScaleStart(ScaleStartDetails details) {
    if (widget.scrollCustomList != null) widget.scrollCustomList!(true);

    _activate();
    _settleController.stop(canceled: false);
    _lastFocalPoint = details.focalPoint;
    _action = _CropAction.none;
    _handle = _hitCropHandle(_getLocalPoint(details.focalPoint));
    _startScale = _scale;
    _startView = _view;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (_action == _CropAction.none) {
      if (_handle == _CropHandleSide.none) {
        _action = pointers == 2 ? _CropAction.scaling : _CropAction.moving;
      } else {
        _action = _CropAction.cropping;
      }
    }
    if (_action == _CropAction.cropping) {
      final boundaries = _boundaries;
      if (boundaries == null) return;
    } else if (_action == _CropAction.moving) {
      final image = _image;
      if (image == null) return;

      final delta = details.focalPoint - _lastFocalPoint;
      _lastFocalPoint = details.focalPoint;

      setState(() {
        _view = _view.translate(
          delta.dx / (image.width * _scale * _ratio),
          delta.dy / (image.height * _scale * _ratio),
        );
      });
    } else if (_action == _CropAction.scaling) {
      final image = _image;
      final boundaries = _boundaries;
      if (image == null || boundaries == null) return;

      setState(() {
        _scale = _startScale * details.scale;

        final dx = boundaries.width *
            (1.0 - details.scale) /
            (image.width * _scale * _ratio);
        final dy = boundaries.height *
            (1.0 - details.scale) /
            (image.height * _scale * _ratio);
        _view = Rect.fromLTWH(
          _startView.left + dx / 2,
          _startView.top + dy / 2,
          _startView.width,
          _startView.height,
        );
      });
    }
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    if (widget.scrollCustomList != null) widget.scrollCustomList!(false);

    _deactivate();
    final minimumScale = _minimumScale;
    if (minimumScale == null) return;

    final targetScale = _scale.clamp(minimumScale, _maximumScale);
    _scaleTween = Tween<double>(
      begin: _scale,
      end: targetScale,
    );

    _startView = _view;
    _viewTween = RectTween(
      begin: _view,
      end: _getViewInBoundaries(targetScale),
    );

    _settleController.value = 0.0;
    _settleController.animateTo(
      1.0,
      curve: Curves.fastOutSlowIn,
      duration: const Duration(milliseconds: 350),
    );
  }

  Rect _getViewInBoundaries(double scale) =>
      Offset(
        max(
          min(_view.left, _area.left * _view.width / scale),
          _area.right * _view.width / scale - 1.0,
        ),
        max(
            min(
              _view.top,
              _area.top * _view.height / scale,
            ),
            _area.bottom * _view.height / scale - 1.0),
      ) &
      _view.size;

  double get _maximumScale => widget.maximumScale;

  double? get _minimumScale {
    final boundaries = _boundaries;
    final image = _image;
    if (boundaries == null || image == null) {
      return null;
    }

    final scaleX = boundaries.width * _area.width / (image.width * _ratio);
    final scaleY = boundaries.height * _area.height / (image.height * _ratio);
    return min(_maximumScale, max(scaleX, scaleY));
  }

  Widget buildCustomPaint() {
    return CustomPaint(
      painter: _CropPainter(
        image: _image,
        ratio: _ratio,
        view: _view,
        area: _area,
        scale: _scale,
        active: _activeController.value,
        paintColor: widget.paintColor ?? Colors.white,
      ),
    );
  }

  void _activate() {
    _activeController.animateTo(
      1.0,
      curve: Curves.fastOutSlowIn,
      duration: const Duration(milliseconds: 250),
    );
  }

  void _deactivate() {
    if (widget.alwaysShowGrid == false) {
      _activeController.animateTo(
        0.0,
        curve: Curves.fastOutSlowIn,
        duration: const Duration(milliseconds: 250),
      );
    }
  }

  Size? get _boundaries {
    final context = _surfaceKey.currentContext;
    if (context == null) return null;

    final box = context.findRenderObject() as RenderBox;
    final size = box.size;

    return size - const Offset(_kCropHandleSize, _kCropHandleSize) as Size;
  }

  Offset? _getLocalPoint(Offset point) {
    final context = _surfaceKey.currentContext;
    if (context == null) return null;

    final box = context.findRenderObject() as RenderBox;

    return box.globalToLocal(point);
  }

  void _settleAnimationChanged() {
    setState(() {
      _scale = _scaleTween.transform(_settleController.value);
      final nextView = _viewTween.transform(_settleController.value);
      if (nextView != null) {
        _view = nextView;
      }
    });
  }

  Rect _calculateDefaultArea({
    required int? imageWidth,
    required int? imageHeight,
    required double viewWidth,
    required double viewHeight,
  }) {
    if (imageWidth == null || imageHeight == null) {
      return Rect.zero;
    }

    double height;
    double width;
    if ((widget.aspectRatio ?? 1.0) < 1) {
      height = 1.0;
      width =
          ((widget.aspectRatio ?? 1.0) * imageHeight * viewHeight * height) /
              imageWidth /
              viewWidth;
      if (width > 1.0) {
        width = 1.0;
        height = (imageWidth * viewWidth * width) /
            (imageHeight * viewHeight * (widget.aspectRatio ?? 1.0));
      }
    } else {
      width = 1.0;
      height = (imageWidth * viewWidth * width) /
          (imageHeight * viewHeight * (widget.aspectRatio ?? 1.0));
      if (height > 1.0) {
        height = 1.0;
        width =
            ((widget.aspectRatio ?? 1.0) * imageHeight * viewHeight * height) /
                imageWidth /
                viewWidth;
      }
    }
    final aspectRatio = _maxAreaWidthMap[widget.aspectRatio];
    if (aspectRatio != null) {
      _maxAreaWidthMap[aspectRatio] = width;
    }

    return Rect.fromLTWH((1.0 - width) / 2, (1.0 - height) / 2, width, height);
  }

  void _updateImage(ImageInfo imageInfo, bool synchronousCall) {
    final boundaries = _boundaries;
    if (boundaries == null) return;

    final image = imageInfo.image;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        // _image = image;
        // _scale = imageInfo.scale;
        // _ratio = max(
        //   boundaries.width / image.width,
        //   boundaries.height / image.height,
        // );

        // final viewWidth = boundaries.width / (image.width * _scale * _ratio);
        // final viewHeight = boundaries.height / (image.height * _scale * _ratio);
        // _area = _calculateDefaultArea(
        //   viewWidth: viewWidth,
        //   viewHeight: viewHeight,
        //   imageWidth: image.width,
        //   imageHeight: image.height,
        // );
        // _view = Rect.fromLTWH(
        //   (viewWidth - 1.0) / 2,
        //   (viewHeight - 1.0) / 2,
        //   viewWidth,
        //   viewHeight,
        // );
        _image = image;

        _scale = imageInfo.scale;
        _ratio = max(
          boundaries.width / image.width,
          boundaries.height / image.height,
        );

        _updateView(boundaries);
      });
    });

    WidgetsBinding.instance.ensureVisualUpdate();
  }

  void _updateView([Size? b]) {
    final boundaries = b ?? _boundaries;
    if (boundaries == null) {
      return;
    }

    final viewWidth =
        boundaries.width / ((_image?.width ?? 0) * _scale * _ratio);
    final viewHeight =
        boundaries.height / ((_image?.height ?? 0) * _scale * _ratio);

    setState(() {
      _area = _calculateDefaultArea(
        viewWidth: viewWidth,
        viewHeight: viewHeight,
        imageWidth: _image?.width,
        imageHeight: _image?.height,
      );
      _view = Rect.fromLTWH(
        (viewWidth - 1.0) / 2,
        (viewHeight - 1.0) / 2,
        viewWidth,
        viewHeight,
      );
      // disable initial magnification
      _scale = _minimumScale ?? 1.0;
      _view = _getViewInBoundaries(_scale);
    });
  }

  _CropHandleSide _hitCropHandle(Offset? localPoint) {
    final boundaries = _boundaries;
    if (localPoint == null || boundaries == null) {
      return _CropHandleSide.none;
    }

    final viewRect = Rect.fromLTWH(
      boundaries.width * _area.left,
      boundaries.height * _area.top,
      boundaries.width * _area.width,
      boundaries.height * _area.height,
    ).deflate(_kCropHandleSize / 2);

    if (Rect.fromLTWH(
      viewRect.left - _kCropHandleHitSize / 2,
      viewRect.top - _kCropHandleHitSize / 2,
      _kCropHandleHitSize,
      _kCropHandleHitSize,
    ).contains(localPoint)) {
      return _CropHandleSide.topLeft;
    }

    if (Rect.fromLTWH(
      viewRect.right - _kCropHandleHitSize / 2,
      viewRect.top - _kCropHandleHitSize / 2,
      _kCropHandleHitSize,
      _kCropHandleHitSize,
    ).contains(localPoint)) {
      return _CropHandleSide.topRight;
    }

    if (Rect.fromLTWH(
      viewRect.left - _kCropHandleHitSize / 2,
      viewRect.bottom - _kCropHandleHitSize / 2,
      _kCropHandleHitSize,
      _kCropHandleHitSize,
    ).contains(localPoint)) {
      return _CropHandleSide.bottomLeft;
    }

    if (Rect.fromLTWH(
      viewRect.right - _kCropHandleHitSize / 2,
      viewRect.bottom - _kCropHandleHitSize / 2,
      _kCropHandleHitSize,
      _kCropHandleHitSize,
    ).contains(localPoint)) {
      return _CropHandleSide.bottomRight;
    }

    return _CropHandleSide.none;
  }
}

class _CropPainter extends CustomPainter {
  final ui.Image? image;
  final Rect view;
  final double ratio;
  final Rect area;
  final double scale;
  final double active;
  final Color paintColor;

  _CropPainter({
    required this.image,
    required this.view,
    required this.ratio,
    required this.area,
    required this.scale,
    required this.active,
    required this.paintColor,
  });

  @override
  bool shouldRepaint(_CropPainter oldDelegate) {
    return oldDelegate.image != image ||
        oldDelegate.view != view ||
        oldDelegate.ratio != ratio ||
        oldDelegate.area != area ||
        oldDelegate.active != active ||
        oldDelegate.scale != scale;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      _kCropHandleSize / 2,
      _kCropHandleSize / 2,
      size.width - _kCropHandleSize,
      size.height - _kCropHandleSize,
    );
    canvas.save();
    canvas.translate(rect.left, rect.top);

    final paint = Paint()..isAntiAlias = false;

    final image = this.image;
    if (image != null) {
      final src = Rect.fromLTWH(
        0.0,
        0.0,
        image.width.toDouble(),
        image.height.toDouble(),
      );
      final dst = Rect.fromLTWH(
        view.left * image.width * scale * ratio,
        view.top * image.height * scale * ratio,
        image.width * scale * ratio,
        image.height * scale * ratio,
      );

      canvas.save();
      canvas.clipRect(Rect.fromLTWH(0.0, 0.0, rect.width, rect.height));
      canvas.drawImageRect(image, src, dst, paint);
      canvas.restore();
    }

    paint.color = paintColor;

    final boundaries = Rect.fromLTWH(
      rect.width * area.left,
      rect.height * area.top,
      rect.width * area.width,
      rect.height * area.height,
    );
    canvas.drawRect(Rect.fromLTRB(0.0, 0.0, rect.width, boundaries.top), paint);
    canvas.drawRect(
        Rect.fromLTRB(0.0, boundaries.bottom, rect.width, rect.height), paint);
    canvas.drawRect(
        Rect.fromLTRB(0.0, boundaries.top, boundaries.left, boundaries.bottom),
        paint);
    canvas.drawRect(
        Rect.fromLTRB(
            boundaries.right, boundaries.top, rect.width, boundaries.bottom),
        paint);

    if (boundaries.isEmpty == false) {
      _drawGrid(canvas, boundaries);
    }

    canvas.restore();
  }

  void _drawGrid(Canvas canvas, Rect boundaries) {
    if (active == 0.0) return;

    final paint = Paint()
      ..isAntiAlias = false
      ..color = _kCropGridColor.withOpacity(_kCropGridColor.opacity * active)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final path = Path()
      ..moveTo(boundaries.left, boundaries.top)
      ..lineTo(boundaries.right, boundaries.top)
      ..lineTo(boundaries.right, boundaries.bottom)
      ..lineTo(boundaries.left, boundaries.bottom)
      ..lineTo(boundaries.left, boundaries.top);
    for (var column = 1; column < _kCropGridColumnCount; column++) {
      path
        ..moveTo(
            boundaries.left + column * boundaries.width / _kCropGridColumnCount,
            boundaries.top)
        ..lineTo(
            boundaries.left + column * boundaries.width / _kCropGridColumnCount,
            boundaries.bottom);
    }

    for (var row = 1; row < _kCropGridRowCount; row++) {
      path
        ..moveTo(boundaries.left,
            boundaries.top + row * boundaries.height / _kCropGridRowCount)
        ..lineTo(boundaries.right,
            boundaries.top + row * boundaries.height / _kCropGridRowCount);
    }

    canvas.drawPath(path, paint);
  }
}

class _DisplayVideo extends StatefulWidget {
  final File selectedFile;
  const _DisplayVideo({Key? key, required this.selectedFile}) : super(key: key);

  @override
  State<_DisplayVideo> createState() => _DisplayVideoState();
}

class _DisplayVideoState extends State<_DisplayVideo> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _initVideoController();
  }

  @override
  void didUpdateWidget(covariant _DisplayVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedFile != widget.selectedFile) {
      _initVideoController();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initVideoController();
  }

  Future<void> _initVideoController() async {
    _controller = VideoPlayerController.file(widget.selectedFile);
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        return VisibilityDetector(
          key: ValueKey(widget.selectedFile.path),
          onVisibilityChanged: (info) {
            if (info.visibleBounds.isEmpty) {
              _controller
                ..pause()
                ..seekTo(Duration.zero);
            }
          },
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: snapshot.connectionState == ConnectionState.done
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      InteractiveViewer(
                        minScale: 1,
                        child: VideoPlayer(_controller),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              if (_controller.value.isPlaying) {
                                _controller.pause();
                              } else {
                                _controller.play();
                              }
                            });
                          },
                          child: AnimatedSwitcher(
                              reverseDuration:
                                  const Duration(milliseconds: 350),
                              duration: const Duration(milliseconds: 350),
                              transitionBuilder: (child, animation) {
                                return ScaleTransition(
                                  scale: animation,
                                  child: child,
                                );
                              },
                              child: ListenableBuilder(
                                listenable: _controller,
                                builder: (context, child) {
                                  return _controller.value.isPlaying
                                      ? Container(
                                          decoration: const BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black26,
                                                blurRadius: 10.0,
                                                offset: Offset(2.0, 2.0),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.pause,
                                            color: Colors.white,
                                            size: 45,
                                          ))
                                      : Container(
                                          decoration: const BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black26,
                                                blurRadius: 15.0,
                                                offset: Offset(2.0, 2.0),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.play_arrow,
                                            color: Colors.white,
                                            size: 45,
                                          ));
                                },
                              )),
                        ),
                      )
                    ],
                  )
                : const Center(
                    child: CircularProgressIndicator(strokeWidth: 1),
                  ),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
      },
    );
  }
}
