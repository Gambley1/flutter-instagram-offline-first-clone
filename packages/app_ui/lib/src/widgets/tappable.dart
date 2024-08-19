// ignore_for_file: one_member_abstracts, avoid_positional_boolean_parameters

import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Variant of a tappable button.
enum TappableVariant {
  /// No animation effect will be applied for the child widget.
  normal,

  /// The child widget will be faded in and out on tap.
  faded,

  /// The child widget will be scaled in and out on tap.
  scaled
}

abstract class _ParentTappableState {
  void markChildTappablePressed(
    _ParentTappableState childState,
    bool value,
  );
}

class _ParentTappableProvider extends InheritedWidget {
  const _ParentTappableProvider({
    required this.state,
    required super.child,
  });

  final _ParentTappableState state;

  @override
  bool updateShouldNotify(_ParentTappableProvider oldWidget) =>
      state != oldWidget.state;

  static _ParentTappableState? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_ParentTappableProvider>()
        ?.state;
  }
}

/// {@template tappable}
/// Makes any widget tappable! It visually makes widgets create effect of
/// a tap. The desired effect you can choose from [TappableVariant].
/// {@endtemplate}
class Tappable extends StatelessWidget {
  /// {@macro tappable}
  const Tappable({
    required this.child,
    super.key,
    this.onTap,
    this.onDoubleTap,
    this.borderRadius,
    this.backgroundColor,
    this.throttle = false,
    this.throttleDuration,
    this.padding,
    this.onTapUp,
    this.onTapDown,
    this.onLongPress,
    this.onLongPressMoveUpdate,
    this.onLongPressStart,
    this.onLongPressEnd,
    this.scaleStrength,
    this.fadeStrength,
    this.scaleAlignment,
    this.boxShadow,
    this.enableFeedback = true,
  }) : _variant = TappableVariant.normal;

  /// {@macro tappable.raw}
  const Tappable.raw({
    required this.child,
    required TappableVariant variant,
    super.key,
    this.onTap,
    this.onDoubleTap,
    this.borderRadius,
    this.backgroundColor,
    this.throttle = false,
    this.throttleDuration,
    this.padding,
    this.onTapUp,
    this.onTapDown,
    this.onLongPress,
    this.onLongPressMoveUpdate,
    this.onLongPressStart,
    this.onLongPressEnd,
    this.scaleStrength = ScaleStrength.sm,
    this.fadeStrength = FadeStrength.md,
    this.scaleAlignment = Alignment.center,
    this.boxShadow,
    this.enableFeedback = true,
  }) : _variant = variant;

  /// {@macro tappable.faded}
  const Tappable.faded({
    required this.child,
    super.key,
    this.onTap,
    this.onDoubleTap,
    this.borderRadius,
    this.backgroundColor,
    this.fadeStrength = FadeStrength.md,
    this.throttle = false,
    this.throttleDuration,
    this.padding,
    this.onTapUp,
    this.onTapDown,
    this.onLongPress,
    this.onLongPressMoveUpdate,
    this.onLongPressStart,
    this.onLongPressEnd,
    this.boxShadow,
    this.enableFeedback = true,
  })  : _variant = TappableVariant.faded,
        scaleAlignment = null,
        scaleStrength = null;

  /// {@macro tappable.scaled}
  const Tappable.scaled({
    required this.child,
    super.key,
    this.onTap,
    this.onDoubleTap,
    this.borderRadius,
    this.backgroundColor,
    this.throttle = false,
    this.throttleDuration,
    this.scaleStrength = ScaleStrength.sm,
    this.scaleAlignment = Alignment.center,
    this.padding,
    this.onTapUp,
    this.onTapDown,
    this.onLongPress,
    this.onLongPressMoveUpdate,
    this.onLongPressStart,
    this.onLongPressEnd,
    this.boxShadow,
    this.enableFeedback = true,
  })  : _variant = TappableVariant.scaled,
        fadeStrength = null;

  /// The tappable variant, which is used to determine the visual effect.
  final TappableVariant _variant;

  /// The border radius of the tappable widget.
  final BorderRadiusGeometry? borderRadius;

  /// Whether to enable feedback on tap.
  final bool enableFeedback;

  /// Callback invoked when the tappable is tapped.
  final GestureTapCallback? onTap;

  /// Callback invoked when the tappable is double tapped.
  final GestureDoubleTapCallback? onDoubleTap;

  /// Callback invoked when the gesture was started.
  final GestureTapDownCallback? onTapDown;

  /// Callback invoked when the gesture was ended.
  final GestureTapUpCallback? onTapUp;

  /// The background color of the tappable.
  final Color? backgroundColor;

  /// The child widget being wrapped.
  final Widget child;

  /// The padding of the tappable widget.
  final EdgeInsetsGeometry? padding;

  /// Whether to throttle the button with certain delay.
  final bool throttle;

  /// The duration between each execution of [onTap] function
  /// that will took up by the main `Throttler`.
  final Duration? throttleDuration;

  /// Callback invoked on a long press.
  final GestureLongPressCallback? onLongPress;

  /// The callback that gives the details on long press when there are moving
  /// gestures.
  final GestureLongPressMoveUpdateCallback? onLongPressMoveUpdate;

  /// The callback that gives the details on the starting of the long press.
  final GestureLongPressStartCallback? onLongPressStart;

  /// The callback that gives the details on the ending of the long press.
  final GestureLongPressEndCallback? onLongPressEnd;

  /// The shadow of the tappable.
  final List<BoxShadow>? boxShadow;

  /// The scale animation strength on tap.
  final ScaleStrength? scaleStrength;

  /// The fade animation strength on tap.
  final FadeStrength? fadeStrength;

  /// The alignment of the scale animation.
  final Alignment? scaleAlignment;

  @override
  Widget build(BuildContext context) {
    final parentState = _ParentTappableProvider.maybeOf(context);
    return _TappableStateWidget(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onTapUp: onTapUp,
      onTapDown: onTapDown,
      borderRadius: borderRadius,
      backgroundColor: backgroundColor,
      enableFeedback: enableFeedback,
      variant: _variant,
      padding: padding,
      fadeStrength: fadeStrength,
      onLongPress: onLongPress,
      onLongPressMoveUpdate: onLongPressMoveUpdate,
      onLongPressStart: onLongPressStart,
      onLongPressEnd: onLongPressEnd,
      boxShadow: boxShadow,
      scaleAlignment: scaleAlignment,
      scaleStrength: scaleStrength,
      throttle: throttle,
      throttleDuration: throttleDuration,
      parentState: parentState,
      child: child,
    );
  }
}

class _TappableStateWidget extends StatefulWidget {
  const _TappableStateWidget({
    required this.child,
    required this.variant,
    required this.enableFeedback,
    this.onTap,
    this.onDoubleTap,
    this.borderRadius,
    this.backgroundColor,
    this.throttle = false,
    this.throttleDuration,
    this.padding,
    this.onTapUp,
    this.onTapDown,
    this.parentState,
    this.onLongPress,
    this.onLongPressMoveUpdate,
    this.onLongPressStart,
    this.onLongPressEnd,
    this.boxShadow,
    this.scaleStrength,
    this.fadeStrength,
    this.scaleAlignment,
  });

  final TappableVariant variant;
  final BorderRadiusGeometry? borderRadius;
  final bool enableFeedback;
  final GestureTapCallback? onTap;
  final GestureDoubleTapCallback? onDoubleTap;
  final GestureTapDownCallback? onTapDown;
  final GestureTapUpCallback? onTapUp;
  final Color? backgroundColor;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool throttle;
  final Duration? throttleDuration;
  final _ParentTappableState? parentState;
  final GestureLongPressCallback? onLongPress;
  final GestureLongPressMoveUpdateCallback? onLongPressMoveUpdate;
  final GestureLongPressStartCallback? onLongPressStart;
  final GestureLongPressEndCallback? onLongPressEnd;
  final List<BoxShadow>? boxShadow;
  final ScaleStrength? scaleStrength;
  final FadeStrength? fadeStrength;
  final Alignment? scaleAlignment;

  @override
  State<_TappableStateWidget> createState() => _TappableStateWidgetState();
}

class _TappableStateWidgetState extends State<_TappableStateWidget>
    with SingleTickerProviderStateMixin
    implements _ParentTappableState {
  final ObserverList<_ParentTappableState> _activeChildren =
      ObserverList<_ParentTappableState>();

  @override
  void markChildTappablePressed(
    _ParentTappableState childState,
    bool value,
  ) {
    final lastAnyPressed = _anyChildTappablePressed;
    if (value) {
      _activeChildren.add(childState);
    } else {
      _activeChildren.remove(childState);
    }
    final nowAnyPressed = _anyChildTappablePressed;
    if (nowAnyPressed != lastAnyPressed) {
      widget.parentState?.markChildTappablePressed(this, nowAnyPressed);
    }
  }

  bool get _anyChildTappablePressed => _activeChildren.isNotEmpty;

  void updateHighlight({required bool value}) {
    widget.parentState?.markChildTappablePressed(this, value);
  }

  static const animationOutDuration = Duration(milliseconds: 150);
  static const animationInDuration = Duration(milliseconds: 230);
  final Tween<double> _animationTween = Tween<double>(begin: 1);
  late double _animationValue = switch (widget.variant) {
    TappableVariant.faded => widget.fadeStrength!.strength,
    TappableVariant.scaled => widget.scaleStrength!.strength,
    _ => 0.0,
  };

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      value: 0,
      vsync: this,
    );
    _animation = _animationController
        .drive(CurveTween(curve: Curves.decelerate))
        .drive(_animationTween);
    _setTween();
  }

  @override
  void didUpdateWidget(covariant _TappableStateWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scaleStrength != widget.scaleStrength) {
      _animationValue = widget.scaleStrength?.strength ?? 0;
    } else if (oldWidget.fadeStrength != widget.fadeStrength) {
      _animationValue = widget.fadeStrength?.strength ?? 0;
    }
  }

  void _setTween() {
    _animationTween.end = 0.5;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool _buttonHeldDown = false;

  void Function()? _handleTap() {
    if (widget.onTap == null) return null;
    return () {
      updateHighlight(value: false);
      if (widget.onTap != null) {
        if (widget.enableFeedback) {
          Feedback.forTap(context);
        }
        widget.onTap!.call();
      }
    };
  }

  void _handleTapDown(TapDownDetails event) {
    if (_anyChildTappablePressed) return;
    updateHighlight(value: true);
    if (!_buttonHeldDown) {
      _buttonHeldDown = true;
      _animate();
      widget.onTapDown?.call(event);
    }
  }

  void _handleTapUp(TapUpDetails event) {
    if (_buttonHeldDown) {
      _buttonHeldDown = false;
    }
    if (_animationController.value < _animationValue) {
      _animationController
          .animateTo(
            _animationValue,
            duration: animationOutDuration,
            curve: Curves.easeInOutCubicEmphasized,
          )
          .then(
            (value) => _animationController.animateTo(
              0,
              duration: animationInDuration,
              curve: Curves.easeOutCubic,
            ),
          );
      widget.onTapUp?.call(event);
    }
    if (_animationController.value >= _animationValue) {
      _animationController.animateTo(
        0,
        duration: animationInDuration,
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _handleTapCancel() {
    if (_buttonHeldDown) {
      _buttonHeldDown = false;
      _animate();
    }
    updateHighlight(value: false);
  }

  void _handleLongPress() {
    _animate();
    if (widget.onLongPress != null) {
      if (widget.enableFeedback) {
        Feedback.forLongPress(context);
      }
      widget.onLongPress!.call();
    }
  }

  void _animate() {
    final wasHeldDown = _buttonHeldDown;
    _buttonHeldDown
        ? _animationController.animateTo(
            _animationValue,
            duration: animationOutDuration,
            curve: Curves.easeInOutCubicEmphasized,
          )
        : _animationController
            .animateTo(
            0,
            duration: animationInDuration,
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

  Future<void> _onPointerDown(PointerDownEvent event) async {
    // Check if right mouse button clicked
    if (event.kind == PointerDeviceKind.mouse &&
        event.buttons == kSecondaryMouseButton) {
      if (widget.onLongPress != null) widget.onLongPress!.call();
    }
  }

  @override
  void deactivate() {
    widget.parentState?.markChildTappablePressed(this, false);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    final animatedDecoratedBox = Semantics(
      button: true,
      child: _ButtonAnimationWrapper(
        variant: widget.variant,
        animation: _animation,
        scaleAlignment: widget.scaleAlignment,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            color: widget.backgroundColor,
            boxShadow: widget.boxShadow,
          ),
          child: Padding(
            padding: widget.padding ?? EdgeInsets.zero,
            child: widget.child,
          ),
        ),
      ),
    );

    Widget button;
    Widget tappable({required VoidCallback? onTap, required Widget child}) =>
        MouseRegion(
          cursor: kIsWeb ? SystemMouseCursors.click : MouseCursor.defer,
          child: IgnorePointer(
            ignoring: widget.onLongPress == null && onTap == null,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              onDoubleTap: widget.onDoubleTap,
              onTapUp: _handleTapUp,
              onTapDown: _handleTapDown,
              onTapCancel: _handleTapCancel,
              onLongPressStart: widget.onLongPressStart,
              onLongPressEnd: widget.onLongPressEnd,
              onLongPressMoveUpdate: widget.onLongPressMoveUpdate,
              // Use null so other long press actions can be captured
              onLongPress: widget.onLongPress == null ? null : _handleLongPress,
              child: child,
            ),
          ),
        );

    if (widget.throttle) {
      button = ThrottledButton(
        onTap: _handleTap(),
        throttleDuration: widget.throttleDuration?.inMilliseconds,
        child: animatedDecoratedBox,
        builder: (isThrottled, onTap, child) =>
            tappable(onTap: onTap, child: child!),
      );
    } else {
      button = tappable(onTap: _handleTap(), child: animatedDecoratedBox);
    }

    if (!kIsWeb && widget.onLongPress != null) {
      return _ParentTappableProvider(state: this, child: button);
    }

    return _ParentTappableProvider(
      state: this,
      child: Listener(
        onPointerDown: _onPointerDown,
        child: button,
      ),
    );
  }
}

class _ButtonAnimationWrapper extends StatelessWidget {
  const _ButtonAnimationWrapper({
    required this.variant,
    required this.child,
    required this.animation,
    this.scaleAlignment,
  });

  final TappableVariant variant;
  final Widget child;
  final Animation<double> animation;
  final Alignment? scaleAlignment;

  @override
  Widget build(BuildContext context) {
    return switch (variant) {
      TappableVariant.faded => FadeTransition(opacity: animation, child: child),
      TappableVariant.scaled => ScaleTransition(
          scale: animation,
          alignment: scaleAlignment!,
          child: child,
        ),
      _ => child,
    };
  }
}

/// Default duration of throttler.
const kDefaultThrottlerDuration = 300;

/// {@template throttler}
/// A simple class for throttling functions execution
/// {@endtemplate}
class Throttler {
  /// {@macro throttler}
  Throttler({this.milliseconds = kDefaultThrottlerDuration});

  /// The delay in milliseconds.
  final int? milliseconds;

  /// The timer of the throttler.
  Timer? timer;

  /// Runs the [action] after [milliseconds] delay.
  void run(VoidCallback action) {
    if (timer?.isActive ?? false) return;

    timer?.cancel();
    action();
    timer = Timer(
      Duration(milliseconds: milliseconds ?? kDefaultThrottlerDuration),
      () {},
    );
  }

  /// Disposes the timer.
  void dispose() {
    timer?.cancel();
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
    required this.builder,
    required this.child,
    super.key,
    this.throttleDuration,
  });

  /// Callback invoked when the tappable is tapped.
  final VoidCallback? onTap;

  /// The duration between each execution of [onTap] function that will took
  /// up by the main `Throttler`.
  final int? throttleDuration;

  /// A listenable independent widget which is passed back to the [builder].
  final Widget? child;

  /// The builder of the button being wrapped.
  final Widget Function(bool isThrottled, VoidCallback? onTap, Widget? child)
      builder;

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
      child: widget.child,
      builder: (context, isThrottled, _) {
        final onTap = isThrottled || widget.onTap == null
            ? null
            : () => _throttler.run(
                  () {
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
                  },
                );

        return widget.builder(isThrottled, onTap, widget.child);
      },
    );
  }
}

/// Strength values for fading animations. Defines small, medium and large
/// fade strengths as opacity values from 0.0 to 1.0.
enum FadeStrength {
  /// Small fade strength (0.2).
  sm(.2),

  /// Medium fade strength (0.4).
  md(.4),

  /// Large fade strength (1.0).
  lg(1);

  const FadeStrength(this.strength);

  /// Maximum value is 1.0.
  final double strength;
}

/// The scale strength of tappable button.
enum ScaleStrength {
  /// xxxs scale strength (0.0325)
  xxxs(0.0325),

  /// xxs scale strength (0.0625)
  xxs(0.0625),

  /// xs scale strength (0.125)
  xs(0.125),

  /// sm scale strength (0.25)
  sm(0.25),

  /// lg scale strength (0.5)
  lg(0.5),

  /// xlg scale strength (0.75)
  xlg(0.75),

  /// xxlg scale strength (1)
  xxlg(1);

  const ScaleStrength(this.strength);

  /// Maximum value is 1.0.
  final double strength;
}
