// ignore_for_file: avoid_positional_boolean_parameters

import 'dart:ui';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared/shared.dart';

/// The different animation effects that can be applied when a [Tappable]
/// widget is tapped.
enum TappableAnimationEffect {
  /// Visually makes no effect on tap.
  none,

  /// Visually makes button fade on tap.
  fade,

  /// Visually scales button on tap
  scale,
}

/// {@template tappable}
/// Makes any widget tappable! It visually makes widgets create effect of
/// a tap. The desired effect you can choose from [TappableAnimationEffect].
/// {@endtemplate}
class Tappable extends StatelessWidget {
  /// {@macro tappabled}
  const Tappable({
    required this.child,
    super.key,
    this.onTap,
    this.onHighlightChanged,
    this.borderRadius = 0,
    this.customBorderRadius,
    this.color,
    this.throttle = false,
    this.throttleDuration,
    this.type = MaterialType.canvas,
    this.onLongPress,
    this.onLongPressMoveUpdate,
    this.onLongPressEnd,
    this.animationEffect = TappableAnimationEffect.fade,
    this.scaleStrength = ScaleStrength.xs,
    this.fadeStrength = FadeStrength.large,
    this.triggerOnTap = false,
    this.scaleAlignment = Alignment.center,
    this.onTapUp,
  });

  /// The border radius of the tappable widget.
  final double borderRadius;

  /// The custom border radius to override the default.
  final BorderRadius? customBorderRadius;

  /// Callback invoked when the tappable is tapped.
  final VoidCallback? onTap;

  /// Callback invoked when the gesture was started.
  final ValueSetter<TapUpDetails>? onTapUp;

  /// Callback invoked when the tap highlight changes.
  final ValueChanged<bool>? onHighlightChanged;

  /// The background color of the tappable.
  final Color? color;

  /// The child widget being wrapped.
  final Widget child;

  /// Whether to throttle the button with certain delay.
  final bool throttle;

  /// The duration between each execution of [onTap] function
  /// that will took up by the main `Throttler`.
  final Duration? throttleDuration;

  /// The material type for the tappable.
  final MaterialType type;

  /// Callback invoked on a long press.
  final VoidCallback? onLongPress;

  /// The callback that gives the details on long press when there are moving
  /// gestures.
  final GestureLongPressMoveUpdateCallback? onLongPressMoveUpdate;

  /// The callback that gives the details on the ending of the long press.
  final GestureLongPressEndCallback? onLongPressEnd;

  /// The tap animation effect.
  final TappableAnimationEffect animationEffect;

  /// The scale animation strength on tap.
  final ScaleStrength scaleStrength;

  /// The fade animation strength on tap.
  final FadeStrength fadeStrength;

  /// Whether to trigger the tap callbacks on tap down.
  final bool triggerOnTap;

  /// The alignment of the scale animation.
  final Alignment scaleAlignment;

  @override
  Widget build(BuildContext context) {
    // if (context.theme.platform == TargetPlatform.iOS) {
    //   return FadedButton(
    //     onTap: onTap,
    //     borderRadius: customBorderRadius ?? BorderRadius.circular(borderRadiu
    // s),
    //     color: color ?? Theme.of(context).canvasColor,
    //     onLongPress: onLongPress != null
    //         ? () {
    //             if (context.theme.platform == TargetPlatform.iOS) {
    //               HapticFeedback.heavyImpact();
    //             }
    //             onLongPress!();
    //           }
    //         : null,
    //     child: child,
    //   );
    // }

    // final tappable = Material(
    //   color: color ?? Theme.of(context).canvasColor,
    //   type: type,
    //   borderRadius: customBorderRadius ?? BorderRadius.circular(borderRadius
    // ),
    //   child: InkWell(
    //     splashFactory: kIsWeb
    //         ? InkRipple.splashFactory
    //         : InkSparkle.constantTurbulenceSeedSplashFactory,
    //     borderRadius: customBorderRadius ?? BorderRadius.circular(borderRadiu
    // s),
    //     onTap: onTap,
    //     onHighlightChanged: onHighlightChanged,
    //     onLongPress: onLongPress,
    //     child: child,
    //   ),
    // );
    // // if (!kIsWeb && onLongPress != null) {
    // //   return tappable;
    // // }
    // if (kIsWeb) {
    //   Future<void> onPointerDown(PointerDownEvent event) async {
    //     // Check if right mouse button clicked
    //     if (event.kind == PointerDeviceKind.mouse &&
    //         event.buttons == kSecondaryMouseButton) {
    //       if (onLongPress != null) onLongPress!.call();
    //     }
    //   }

    //   return Listener(
    //     onPointerDown: onPointerDown,
    //     child: tappable,
    //   );
    // }

    return switch (animationEffect) {
      TappableAnimationEffect.none => DefaultButton(
          onTap: onTap,
          onTapUp: onTapUp,
          onLongPress: onLongPress,
          borderRadius:
              customBorderRadius ?? BorderRadius.circular(borderRadius),
          color: color,
          throttle: throttle,
          throttleDuration: throttleDuration?.inMilliseconds,
          child: child,
        ),
      TappableAnimationEffect.fade => FadedButton(
          onTap: onTap,
          onTapUp: onTapUp,
          onLongPressEnd: onLongPressEnd,
          fadeStrength: fadeStrength,
          borderRadius:
              customBorderRadius ?? BorderRadius.circular(borderRadius),
          throttle: throttle,
          throttleDuration: throttleDuration?.inMilliseconds,
          // color: color ?? Theme.of(context).canvasColor,
          color: color ?? AppColors.transparent,
          onLongPress: onLongPress != null
              ? () {
                  if (context.theme.platform == TargetPlatform.iOS) {
                    HapticFeedback.heavyImpact();
                  }
                  onLongPress!();
                }
              : null,
          onLongPressMoveUpdate: onLongPressMoveUpdate,
          child: child,
        ),
      TappableAnimationEffect.scale => ScaledButton(
          onTap: onTap,
          onTapUp: onTapUp,
          onLongPressEnd: onLongPressEnd,
          scaleStrength: scaleStrength,
          borderRadius:
              customBorderRadius ?? BorderRadius.circular(borderRadius),
          throttle: throttle,
          throttleDuration: throttleDuration?.inMilliseconds,
          // color: color ?? Theme.of(context).canvasColor,
          color: color ?? AppColors.transparent,
          scaleAlignment: scaleAlignment,
          onLongPress: onLongPress != null
              ? () {
                  if (context.theme.platform == TargetPlatform.iOS) {
                    HapticFeedback.heavyImpact();
                  }
                  onLongPress!();
                }
              : null,
          onLongPressMoveUpdate: onLongPressMoveUpdate != null
              ? (details) {
                  if (context.theme.platform == TargetPlatform.iOS) {
                    HapticFeedback.heavyImpact();
                  }
                  onLongPressMoveUpdate!.call(details);
                }
              : null,
          child: child,
        ),
    };

    // Future<void> _onPointerDown(PointerDownEvent event) async {
    //   // Check if right mouse button clicked
    //   if (event.kind == PointerDeviceKind.mouse &&
    //       event.buttons == kSecondaryMouseButton) {
    //     if (onLongPress != null) onLongPress!();
    //   }
    // }

    // return Listener(
    //   onPointerDown: _onPointerDown,
    //   child: tappable,
    // );
  }
}

/// {@template default_button}
/// The default button with [TappableAnimationEffect.none].
/// {@endtemplate}
class DefaultButton extends StatelessWidget {
  /// {@macro default_button}
  const DefaultButton({
    required this.onTap,
    required this.onTapUp,
    required this.onLongPress,
    required this.borderRadius,
    required this.color,
    required this.throttle,
    required this.throttleDuration,
    required this.child,
    super.key,
  });

  /// Callback invoked when the tappable is tapped.
  final VoidCallback? onTap;

  /// Callback invoked when the gesture was started.
  final ValueSetter<TapUpDetails>? onTapUp;

  /// Callback invoked on a long press.
  final VoidCallback? onLongPress;

  /// The border radius of the tappable widget.
  final BorderRadius borderRadius;

  /// Whether to throttle the button with certain delay.
  final bool throttle;

  /// The duration between each execution of [onTap] function that will took
  /// up by the main `Throttler`.
  final int? throttleDuration;

  /// The background color of the tappable.
  final Color? color;

  /// The child widget being wrapped.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    Future<void> onPointerDown(PointerDownEvent event) async {
      // Check if right mouse button clicked
      if (event.kind == PointerDeviceKind.mouse &&
          event.buttons == kSecondaryMouseButton) {
        if (onLongPress != null) onLongPress!.call();
      }
    }

    Widget button;
    Widget tappable({required VoidCallback? onTap}) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          onTapUp: onTapUp,
          onLongPress: onLongPress == null
              ? null
              : () {
                  if (context.theme.platform == TargetPlatform.iOS) {
                    HapticFeedback.heavyImpact();
                  }
                  onLongPress!();
                },
          child: Semantics(
            button: true,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                color: color ?? AppColors.transparent,
              ),
              child: child,
            ),
          ),
        );

    if (throttle) {
      button = ThrottledButton(
        onTap: onTap,
        throttleDuration: throttleDuration,
        buttonBuilder: (_, onTap) => tappable(onTap: onTap),
      );
    } else {
      button = tappable(onTap: onTap);
    }

    if (!kIsWeb && onLongPress != null) {
      return button;
    }

    return Listener(
      onPointerDown: onPointerDown,
      child: button,
    );
  }
}

/// {@template throttled_button}
/// The button that executes the on tap function upon the end
/// of certain duration.
/// {@endtemplate}
class ThrottledButton extends StatefulWidget {
  /// {@macro throttled_button}
  const ThrottledButton({
    required this.onTap,
    required this.buttonBuilder,
    super.key,
    this.throttleDuration,
  });

  /// Callback invoked when the tappable is tapped.
  final VoidCallback? onTap;

  /// The duration between each execution of [onTap] function that will took
  /// up by the main `Throttler`.
  final int? throttleDuration;

  /// The builder of the button being wrapped.
  final Widget Function(bool isThrottled, VoidCallback? onTap) buttonBuilder;

  @override
  State<ThrottledButton> createState() => _ThrottledButtonState();
}

class _ThrottledButtonState extends State<ThrottledButton> {
  late Throttler _throttler;

  late ValueNotifier<bool> _isThrottled;

  @override
  void initState() {
    super.initState();
    _throttler = Throttler(milliseconds: widget.throttleDuration);
    _isThrottled = ValueNotifier(false);
  }

  @override
  void dispose() {
    _throttler.dispose();
    _isThrottled.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isThrottled,
      builder: (context, isThrottled, _) => widget.buttonBuilder(
        isThrottled,
        isThrottled
            ? null
            : () => _throttler.run(() {
                  _isThrottled.value = true;
                  widget.onTap?.call();
                  Future<void>.delayed(
                    Duration(
                      milliseconds: widget.throttleDuration ??
                          _throttler.milliseconds ??
                          350,
                    ),
                    () => _isThrottled.value = false,
                  );
                }),
      ),
    );
  }
}

/// Strength values for fading animations. Defines small, medium and large
/// fade strengths as opacity values from 0.0 to 1.0.
enum FadeStrength {
  /// Small fade strength (0.2).
  small(.2),

  /// Medium fade strength (0.4).
  medium(.4),

  /// Large fade strength (1.0).
  large(1);

  const FadeStrength(this.strength);

  /// Maximum value is 1.0.
  final double strength;
}

/// The tappable button that makes a fade effect on tap.
class FadedButton extends StatefulWidget {
  /// {@macro faded_button}
  const FadedButton({
    required this.child,
    required this.onTap,
    required this.onLongPress,
    required this.onLongPressMoveUpdate,
    required this.onLongPressEnd,
    required this.borderRadius,
    required this.color,
    required this.fadeStrength,
    required this.throttle,
    required this.throttleDuration,
    super.key,
    this.pressedOpacity = 0.5,
    this.onTapUp,
  });

  /// The callback that executes upon a tap on tappable.
  final VoidCallback? onTap;

  /// The detailed callback that starts on first user gesture on tappable.
  final ValueSetter<TapUpDetails>? onTapUp;

  /// The callback on long user gesture.
  final VoidCallback? onLongPress;

  /// The callback that gives the details on long press when there are moving
  /// gestures.
  final GestureLongPressMoveUpdateCallback? onLongPressMoveUpdate;

  /// The callback that gives the details on the ending of the long press.
  final GestureLongPressEndCallback? onLongPressEnd;

  /// The opacity value of the tappable.
  final double pressedOpacity;

  /// The widget that tappable is wrapped around.
  final Widget child;

  /// The border radius of the tappable.
  final BorderRadius borderRadius;

  /// Whether to throttle the button with certain delay.
  final bool throttle;

  /// The duration between each execution of [onTap] function that will took
  /// up by the main `Throttler`.
  final int? throttleDuration;

  /// The background color of the tappable.
  final Color color;

  /// Fadee strength, that defines how strong the tappable will fade.
  final FadeStrength fadeStrength;

  @override
  State<FadedButton> createState() => _FadedButtonState();
}

class _FadedButtonState extends State<FadedButton>
    with SingleTickerProviderStateMixin {
  static final kScaleOutDuration = 150.ms;
  static final kScaleInDuration = 230.ms;
  final Tween<double> _scaleTween = Tween<double>(begin: 1);
  late final _fadeAnimationValue = widget.fadeStrength.strength;

  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  Throttler? _throttler;
  ValueNotifier<bool>? _isThrottled;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: 200.ms,
      value: 0,
      vsync: this,
    );
    _opacityAnimation = _animationController
        .drive(CurveTween(curve: Curves.decelerate))
        .drive(_scaleTween);
    _setTween();
  }

  void _setTween() {
    _scaleTween.end = widget.pressedOpacity;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _throttler?.dispose();
    _isThrottled?.dispose();
    super.dispose();
  }

  bool _buttonHeldDown = false;

  void _handleTapDown(TapDownDetails event) {
    if (!_buttonHeldDown) {
      _buttonHeldDown = true;
      _animate();
    }
  }

  void _handleTapUp(TapUpDetails event) {
    if (_buttonHeldDown) {
      _buttonHeldDown = false;
    }
    if (_animationController.value < _fadeAnimationValue) {
      _animationController
          .animateTo(
            _fadeAnimationValue,
            duration: kScaleOutDuration,
            curve: Curves.easeInOutCubicEmphasized,
          )
          .then(
            (value) => _animationController.animateTo(
              0,
              duration: kScaleInDuration,
              curve: Curves.easeOutCubic,
            ),
          );
      widget.onTapUp?.call(event);
    }
    if (_animationController.value >= _fadeAnimationValue) {
      _animationController.animateTo(
        0,
        duration: kScaleInDuration,
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _handleTapCancel() {
    if (_buttonHeldDown) {
      _buttonHeldDown = false;
      _animate();
    }
  }

  void _animate() {
    final wasHeldDown = _buttonHeldDown;
    _buttonHeldDown
        ? _animationController.animateTo(
            _fadeAnimationValue,
            duration: kScaleOutDuration,
            curve: Curves.easeInOutCubicEmphasized,
          )
        : _animationController
            .animateTo(
            0,
            duration: kScaleInDuration,
            curve: Curves.easeOutCubic,
          )
            .then(
            (_) {
              if (mounted && wasHeldDown != _buttonHeldDown) {
                _animate();
              }
            },
          );
  }

  Future<void> onPointerDown(PointerDownEvent event) async {
    // Check if right mouse button clicked
    if (event.kind == PointerDeviceKind.mouse &&
        event.buttons == kSecondaryMouseButton) {
      if (widget.onLongPress != null) widget.onLongPress!.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget button;
    Widget tappable({required VoidCallback? onTap}) => MouseRegion(
          cursor: kIsWeb ? SystemMouseCursors.click : MouseCursor.defer,
          child: IgnorePointer(
            ignoring: widget.onLongPress == null && onTap == null,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              onTap: onTap,
              onLongPressEnd: widget.onLongPressEnd,
              onLongPressMoveUpdate: widget.onLongPressMoveUpdate,
              // Use null so other long press actions can be captured
              onLongPress: widget.onLongPress == null
                  ? null
                  : () {
                      _animate();
                      widget.onLongPress!();
                    },
              child: Semantics(
                button: true,
                child: FadeTransition(
                  opacity: _opacityAnimation,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: widget.borderRadius,
                      color: widget.color,
                    ),
                    child: widget.child,
                  ),
                ),
              ),
            ),
          ),
        );

    if (widget.throttle) {
      button = ThrottledButton(
        onTap: widget.onTap,
        throttleDuration: widget.throttleDuration,
        buttonBuilder: (isThrottled, onTap) => tappable(onTap: onTap),
      );
    } else {
      button = tappable(onTap: widget.onTap);
    }

    if (!kIsWeb && widget.onLongPress != null) {
      return button;
    }

    return Listener(
      onPointerDown: onPointerDown,
      child: button,
    );
  }
}

/// The different scale strength of tappable button.
enum ScaleStrength {
  /// xxxxs scale strength (0.0325)
  xxxxs(0.0325),

  /// xxxs scale strength (0.0625)
  xxxs(0.0625),

  /// xxx scale strength (0.125)
  xxs(0.125),

  /// xs scale strength (0.25)
  xs(0.25),

  /// md scale strength (0.5)
  md(0.5),

  /// lg scale strength (0.75)
  lg(0.75),

  /// xlg scale strength (1)
  xlg(1);

  const ScaleStrength(this.strength);

  /// Maximum value is 1.0.
  final double strength;
}

/// The tappable button that makes a scalled tap animation effect.
class ScaledButton extends StatefulWidget {
  /// {@macro scaled_button}
  const ScaledButton({
    required this.child,
    required this.onTap,
    required this.onLongPress,
    required this.onLongPressMoveUpdate,
    required this.onLongPressEnd,
    required this.borderRadius,
    required this.color,
    required this.scaleStrength,
    required this.scaleAlignment,
    required this.throttle,
    required this.throttleDuration,
    super.key,
    this.pressedOpacity = 0.5,
    this.onTapUp,
  });

  /// The callback that executes upon a tap on tappable.
  final VoidCallback? onTap;

  /// The detailed callback that starts on first user gesture on tappable.
  final ValueSetter<TapUpDetails>? onTapUp;

  /// The callback on long user gesture.
  final VoidCallback? onLongPress;

  /// The callback that gives the details on long press when there are moving
  /// gestures.
  final GestureLongPressMoveUpdateCallback? onLongPressMoveUpdate;

  /// The callback that gives the details on the ending of the long press.
  final GestureLongPressEndCallback? onLongPressEnd;

  /// The opacity value of the tappable.
  final double pressedOpacity;

  /// Whether to throttle the button with certain delay.
  final bool throttle;

  /// The duration in milliseconds between each execution of [onTap] function
  /// that will took up by the main `Throttler`.
  final int? throttleDuration;

  /// The widget that the tappable is wrapped around.
  final Widget child;

  /// The border radius of the tappable.
  final BorderRadius borderRadius;

  /// The background color of the tappable.
  final Color color;

  /// Scale strength, that defines how strong the tappable will scale in.
  final ScaleStrength scaleStrength;

  /// The alignment of the scale animation.
  final Alignment scaleAlignment;

  @override
  State<ScaledButton> createState() => _ScaledButtonState();
}

class _ScaledButtonState extends State<ScaledButton>
    with SingleTickerProviderStateMixin {
  static final kScaleOutDuration = 150.ms;
  static final kScaleInDuration = 230.ms;
  final Tween<double> _scaleTween = Tween<double>(begin: 1);
  late final double _scaleToAnimationValue = widget.scaleStrength.strength;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: 200.ms,
      value: 0,
      vsync: this,
    );
    _scaleAnimation = _animationController
        .drive(CurveTween(curve: Curves.decelerate))
        .drive(_scaleTween);
    _setTween();
  }

  void _setTween() {
    _scaleTween.end = widget.pressedOpacity;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool _buttonHeldDown = false;

  void _handleTapDown(TapDownDetails details) {
    if (!_buttonHeldDown) {
      _buttonHeldDown = true;
      _animate();
    }
  }

  void _handleTapUp(TapUpDetails event) {
    if (_buttonHeldDown) {
      _buttonHeldDown = false;
    }
    if (_animationController.value < _scaleToAnimationValue) {
      _animationController
          .animateTo(
            _scaleToAnimationValue,
            duration: kScaleOutDuration,
            curve: Curves.easeInOutCubicEmphasized,
          )
          .then(
            (value) => _animationController.animateTo(
              0,
              duration: kScaleInDuration,
              curve: Curves.easeOutCubic,
            ),
          );
      widget.onTapUp?.call(event);
    }
    if (_animationController.value >= _scaleToAnimationValue) {
      _animationController.animateTo(
        0,
        duration: kScaleInDuration,
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _handleTapCancel() {
    if (_buttonHeldDown) {
      _buttonHeldDown = false;
      _animate();
    }
  }

  void _animate() {
    final wasHeldDown = _buttonHeldDown;
    _buttonHeldDown
        ? _animationController.animateTo(
            _scaleToAnimationValue,
            duration: kScaleOutDuration,
            curve: Curves.easeInOutCubicEmphasized,
          )
        : _animationController
            .animateTo(
            0,
            duration: kScaleInDuration,
            curve: Curves.easeOutCubic,
          )
            .then(
            (_) {
              if (mounted && wasHeldDown != _buttonHeldDown) {
                _animate();
              }
            },
          );
  }

  Future<void> onPointerDown(PointerDownEvent event) async {
    // Check if right mouse button clicked
    if (event.kind == PointerDeviceKind.mouse &&
        event.buttons == kSecondaryMouseButton) {
      if (widget.onLongPress != null) widget.onLongPress!.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget button;
    Widget tappable({required VoidCallback? onTap}) => MouseRegion(
          cursor: kIsWeb ? SystemMouseCursors.click : MouseCursor.defer,
          child: IgnorePointer(
            ignoring: widget.onLongPress == null && onTap == null,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              onTap: onTap,
              onLongPressEnd: widget.onLongPressEnd,
              onLongPressMoveUpdate: widget.onLongPressMoveUpdate,
              // Use null so other long press actions can be captured
              onLongPress: widget.onLongPress == null
                  ? null
                  : () {
                      _animate();
                      widget.onLongPress!.call();
                    },
              child: Semantics(
                button: true,
                child: ScaleTransition(
                  alignment: widget.scaleAlignment,
                  scale: _scaleAnimation,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: widget.borderRadius,
                      color: widget.color,
                    ),
                    child: widget.child,
                  ),
                ),
              ),
            ),
          ),
        );

    if (widget.throttle) {
      button = ThrottledButton(
        onTap: widget.onTap,
        throttleDuration: widget.throttleDuration,
        buttonBuilder: (_, onTap) => tappable(onTap: onTap),
      );
    } else {
      button = tappable(onTap: widget.onTap);
    }

    if (!kIsWeb && widget.onLongPress != null) {
      return button;
    }

    return Listener(
      onPointerDown: onPointerDown,
      child: button,
    );
  }
}
