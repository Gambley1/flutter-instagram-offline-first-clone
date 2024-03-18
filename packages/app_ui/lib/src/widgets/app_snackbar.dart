import 'dart:async';
import 'dart:math';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:pausable_timer/pausable_timer.dart';

/// Snackbar message to be displayed.
class SnackbarMessage {
  /// {@macro snackbar_message}
  const SnackbarMessage({
    this.title = '',
    this.description,
    this.icon,
    this.iconSize,
    this.iconColor,
    this.timeout = const Duration(milliseconds: 3500),
    this.onTap,
    this.isError = false,
    this.shakeCount = 3,
    this.shakeOffset = 10,
    this.undismissable = false,
    this.dismissWhen,
    this.isLoading = false,
    this.backgroundColor,
  });

  /// {@macro snackbar_message_success}
  const SnackbarMessage.success({
    String title = 'Successfully!',
    String? description,
    Duration timeout = const Duration(milliseconds: 3500),
  }) : this(
          title: title,
          description: description,
          icon: Icons.done,
          backgroundColor: const Color.fromARGB(255, 41, 166, 64),
          timeout: timeout,
        );

  /// {@macro snackbar_message_error}
  const SnackbarMessage.loading({
    String title = 'Loading...',
    Duration timeout = const Duration(milliseconds: 3500),
  }) : this(
          title: title,
          isLoading: true,
          timeout: timeout,
        );

  /// {@macro snackbar_message_error}
  const SnackbarMessage.error({
    String title = '',
    String? description,
    IconData? icon,
    Duration timeout = const Duration(milliseconds: 3500),
  }) : this(
          title: title,
          description: description,
          icon: icon ?? Icons.cancel_rounded,
          backgroundColor: const Color.fromARGB(255, 228, 71, 71),
          isError: true,
          timeout: timeout,
        );

  /// Snackbar title.
  final String title;

  /// Snackbar description.
  final String? description;

  /// Snackbar icon.
  final IconData? icon;

  /// The size of the icon.
  final double? iconSize;

  /// The color of the icon.
  final Color? iconColor;

  /// Snackbar duration before it disappears.
  final Duration timeout;

  /// Snackbar onTap callback.
  final VoidCallback? onTap;

  /// Returns true if the snackbar is an error.
  final bool isError;

  /// The number of times the snackbar should shake in case of error.
  final int shakeCount;

  /// The offset of the snackbar when it shakes.
  final int shakeOffset;

  /// Returns true if the snackbar is undismissable.
  final bool undismissable;

  /// Returns when the snackbar should be dismissed.
  final FutureOr<bool>? dismissWhen;

  /// Returns true if the snackbar is loading.
  final bool isLoading;

  /// The background color of the snackbar message.
  final Color? backgroundColor;
}

/// {@template app_snackbar}
/// Snackbar widget that displays messages.
/// {@endtemplate}
class AppSnackbar extends StatefulWidget {
  /// {@macro app_snackbar}
  const AppSnackbar({super.key});

  @override
  State<AppSnackbar> createState() => AppSnackbarState();
}

/// {@template app_snackbar_state}
/// Snackbar widget state.
/// {@endtemplate}
class AppSnackbarState extends State<AppSnackbar>
    with TickerProviderStateMixin {
  /// {@macro app_snackbar_state}
  PausableTimer? currentTimeout;

  late AnimationController _animationControllerY;
  late AnimationController _animationControllerX;
  late AnimationController _animationControllerErrorShake;

  /// Total moved negative.
  double totalMovedNegative = 0;

  /// Current queue of snackbar messages.
  List<SnackbarMessage> currentQueue = [];

  /// Current snackbar message.
  SnackbarMessage? currentMessage;

  /// Posts a new snackbar message to the queue.
  void post(
    SnackbarMessage message, {
    required bool clearIfQueue,
    required bool undismissable,
  }) {
    if (clearIfQueue && currentQueue.isNotEmpty) {
      currentQueue.add(message);
      animateOut();
      return;
    }
    currentQueue.add(message);
    if (currentQueue.length <= 1) {
      animateIn(message, undismissable: undismissable);
    }
  }

  /// Animates the current snackbar out and the next one in.
  void animateIn(SnackbarMessage message, {bool undismissable = false}) {
    setState(() {
      currentMessage = currentQueue[0];
    });
    _animationControllerX.animateTo(0.5, duration: Duration.zero);
    _animationControllerY.animateTo(
      0.5,
      curve: const ElasticOutCurve(0.8),
      duration: Duration(
        milliseconds:
            ((_animationControllerY.value - 0.5).abs() * 800 + 900).toInt(),
      ),
    );
    if (message.isError) {
      shake();
    }
    currentTimeout = PausableTimer(message.timeout, animateOut);
    currentTimeout!.start();
  }

  /// Animates the current snackbar out.
  void animateOut() {
    currentTimeout?.cancel();
    _animationControllerY.animateTo(
      0,
      curve: Curves.elasticOut,
      duration: Duration(
        milliseconds:
            ((_animationControllerY.value - 0.5).abs() * 800 + 2000).toInt(),
      ),
    );

    if (currentQueue.isNotEmpty) {
      currentQueue.removeAt(0);
    }
    if (currentQueue.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 150), () {
        animateIn(currentQueue[0]);
      });
    }
  }

  /// Closes all snackbar messages.
  void closeAll() {
    // if (currentQueue.isNotEmpty) {
    //   if (currentQueue.length != 1) {
    //     currentQueue.removeRange(1, currentQueue.length);
    //     animateOut();
    //   }
    //   animateOut();
    // }
    currentQueue.clear();
    currentTimeout?.cancel();
    _animationControllerY.animateTo(
      0,
      curve: Curves.elasticOut,
      duration: Duration(
        milliseconds:
            ((_animationControllerY.value - 0.5).abs() * 800 + 2000).toInt(),
      ),
    );
  }

  /// Shakes the current snackbar in case of error.
  void shake() => _animationControllerErrorShake.forward();

  @override
  void initState() {
    super.initState();

    _animationControllerY = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animationControllerX = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animationControllerErrorShake = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..addStatusListener(_updateStatus);
  }

  void _updateStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _animationControllerErrorShake.reset();
    }
  }

  void _onPointerMove(PointerMoveEvent ptr) {
    if (ptr.delta.dy <= 0) {
      totalMovedNegative += ptr.delta.dy;
    }
    if (_animationControllerY.value <= 0.5) {
      _animationControllerY.value += ptr.delta.dy / 400;
    } else {
      _animationControllerY.value +=
          ptr.delta.dy / (2000 * _animationControllerY.value * 8);
    }
    _animationControllerX.value +=
        ptr.delta.dx / (1000 + (_animationControllerX.value - 0.5).abs() * 100);

    currentTimeout!.pause();
  }

  void _onPointerUp(PointerUpEvent event) {
    if (totalMovedNegative <= -200) {
      // if user drags it around but has a net negative, swipe up
      animateOut();
    } else if (_animationControllerY.value <= 0.4) {
      // it is swiped up
      animateOut();
    } else {
      _animationControllerY.animateTo(
        0.5,
        curve: Curves.elasticOut,
        duration: Duration(
          milliseconds:
              ((_animationControllerY.value - 0.5).abs() * 800 + 700).toInt(),
        ),
      );

      currentTimeout!.start();
    }

    _animationControllerX.animateTo(
      0.5,
      curve: Curves.elasticOut,
      duration: Duration(
        milliseconds:
            ((_animationControllerX.value - 0.5).abs() * 800 + 700).toInt(),
      ),
    );
    totalMovedNegative = 0;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationControllerX,
      builder: (context, child) {
        return child!;
      },
      child: AnimatedBuilder(
        animation: _animationControllerY,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              (_animationControllerX.value - 0.5) * 100,
              (_animationControllerY.value - 0.5) * 400 +
                  context.viewPadding.top +
                  10,
            ),
            child: child,
          );
        },
        child: Listener(
          onPointerMove: _onPointerMove,
          onPointerUp: _onPointerUp,
          child: Center(
            child: Align(
              alignment: Alignment.topCenter,
              child: AnimatedBuilder(
                animation: _animationControllerErrorShake,
                builder: (context, child) {
                  final sineValue = sin(
                    currentMessage?.shakeCount ??
                        3 * 2 * pi * _animationControllerErrorShake.value,
                  );
                  final shakeOffset = currentMessage?.shakeOffset ?? 10;
                  return Transform.translate(
                    offset: Offset(sineValue * shakeOffset, 0),
                    child: child,
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        // color: Theme.of(context).brightness == Brightness.
                        // light
                        //     ? getColor(context, 'shadowColorLight')
                        //     : getColor(context, 'shadowColor').withOpacity(0.
                        // 1),
                        color: AppColors.black.withOpacity(.1),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Tappable(
                    onTap: () {
                      if (currentMessage?.onTap != null) {
                        currentMessage?.onTap!.call();
                      }
                      animateOut();
                    },
                    borderRadius: 13,
                    // color: context.theme.colorScheme.secondaryContainer,
                    color: currentMessage?.backgroundColor ?? AppColors.blue,
                    // color: appStateSettings['materialYou']
                    //     ? dynamicPastel(
                    //         context,
                    //         Theme.of(context).colorScheme.secondaryContainer,
                    //         amountLight: 1,
                    //         amountDark: 0.4,
                    //       )
                    //     : getColor(context, 'lightDarkAccent'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (currentMessage?.icon == null)
                                const SizedBox.shrink()
                              else
                                Padding(
                                  padding: const EdgeInsets.only(
                                    right: AppSpacing.md - AppSpacing.xxs,
                                  ),
                                  child: Icon(
                                    currentMessage?.icon,
                                    size: currentMessage?.iconSize ??
                                        AppSize.iconSize,
                                    color: currentMessage?.iconColor,
                                  ),
                                ),
                              if (currentMessage?.isLoading == null)
                                const SizedBox.shrink()
                              else if (currentMessage?.isLoading != null &&
                                  currentMessage!.isLoading == true)
                                const Padding(
                                  padding: EdgeInsets.only(
                                    right: AppSpacing.md - AppSpacing.xxs,
                                  ),
                                  child: SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment:
                                      currentMessage?.icon == null
                                          ? CrossAxisAlignment.center
                                          : CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      currentMessage?.icon == null
                                          ? MainAxisAlignment.center
                                          : MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      currentMessage?.title ?? '',
                                      style: context.titleMedium,
                                      textAlign: currentMessage?.icon == null
                                          ? TextAlign.center
                                          : TextAlign.left,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 3,
                                    ),
                                    if (currentMessage?.description == null)
                                      const SizedBox.shrink()
                                    else
                                      Text(
                                        currentMessage?.description ?? '',
                                        style: context.titleSmall,
                                        textAlign: currentMessage?.icon == null
                                            ? TextAlign.center
                                            : TextAlign.left,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 3,
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
