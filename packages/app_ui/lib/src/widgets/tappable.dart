import 'dart:ui';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum TappableAnimationEffect {
  none,
  fade,
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
    this.type = MaterialType.canvas,
    this.onLongPress,
    this.animationEffect = TappableAnimationEffect.fade,
    this.scaleStrength = ScaleStrength.xs,
    this.fadeStrength = FadeStrength.large,
    this.triggerOnTap = false,
    this.scaleAlignment = Alignment.center,
    this.onTapUp,
  });

  final double borderRadius;
  final BorderRadius? customBorderRadius;
  final VoidCallback? onTap;
  final ValueSetter<TapUpDetails>? onTapUp;
  final ValueChanged<bool>? onHighlightChanged;
  final Color? color;
  final Widget child;
  final MaterialType type;
  final VoidCallback? onLongPress;
  final TappableAnimationEffect animationEffect;
  final ScaleStrength scaleStrength;
  final FadeStrength fadeStrength;
  final bool triggerOnTap;
  final Alignment scaleAlignment;

  @override
  Widget build(BuildContext context) {
    // if (context.theme.platform == TargetPlatform.iOS) {
    //   return FadedButton(
    //     onTap: onTap,
    //     borderRadius: customBorderRadius ?? BorderRadius.circular(borderRadius),
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
    //   borderRadius: customBorderRadius ?? BorderRadius.circular(borderRadius),
    //   child: InkWell(
    //     splashFactory: kIsWeb
    //         ? InkRipple.splashFactory
    //         : InkSparkle.constantTurbulenceSeedSplashFactory,
    //     borderRadius: customBorderRadius ?? BorderRadius.circular(borderRadius),
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
      TappableAnimationEffect.none => GestureDetector(
          onTap: onTap,
          onTapUp: onTapUp,
          onLongPress: onLongPress != null
              ? () {
                  if (context.theme.platform == TargetPlatform.iOS) {
                    HapticFeedback.heavyImpact();
                  }
                  onLongPress!();
                }
              : null,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius:
                  customBorderRadius ?? BorderRadius.circular(borderRadius),
              color: color ?? Colors.transparent,
            ),
            child: child,
          ),
        ),
      TappableAnimationEffect.fade => FadedButton(
          onTap: onTap,
          onTapUp: onTapUp,
          fadeStrength: fadeStrength,
          borderRadius:
              customBorderRadius ?? BorderRadius.circular(borderRadius),
          // color: color ?? Theme.of(context).canvasColor,
          color: color ?? Colors.transparent,
          onLongPress: onLongPress != null
              ? () {
                  if (context.theme.platform == TargetPlatform.iOS) {
                    HapticFeedback.heavyImpact();
                  }
                  onLongPress!();
                }
              : null,
          child: child,
        ),
      TappableAnimationEffect.scale => ScaledButton(
          onTap: onTap,
          onTapUp: onTapUp,
          scaleStrength: scaleStrength,
          borderRadius:
              customBorderRadius ?? BorderRadius.circular(borderRadius),
          // color: color ?? Theme.of(context).canvasColor,
          color: color ?? Colors.transparent,
          scaleAlignment: scaleAlignment,
          onLongPress: onLongPress != null
              ? () {
                  if (context.theme.platform == TargetPlatform.iOS) {
                    HapticFeedback.heavyImpact();
                  }
                  onLongPress!();
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

enum FadeStrength {
  small(.2),
  medium(.4),
  large(1);

  const FadeStrength(this.strength);

  /// Maximum value is 1.0.
  final double strength;
}

class FadedButton extends StatefulWidget {
  const FadedButton({
    required this.child,
    required this.onTap,
    required this.onLongPress,
    required this.borderRadius,
    required this.color,
    required this.fadeStrength,
    super.key,
    this.pressedOpacity = 0.5,
    this.onTapUp,
  });

  final VoidCallback? onTap;
  final ValueSetter<TapUpDetails>? onTapUp;
  final VoidCallback? onLongPress;
  final double pressedOpacity;
  final Widget child;
  final BorderRadius borderRadius;
  final Color color;
  final FadeStrength fadeStrength;

  @override
  State<FadedButton> createState() => _FadedButtonState();
}

class _FadedButtonState extends State<FadedButton>
    with SingleTickerProviderStateMixin {
  static const Duration kScaleOutDuration = Duration(milliseconds: 150);
  static const Duration kScaleInDuration = Duration(milliseconds: 230);
  final Tween<double> _scaleTween = Tween<double>(begin: 1);
  late final _fadeAnimationValue = widget.fadeStrength.strength;

  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
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
    final tappable = MouseRegion(
      cursor: kIsWeb ? SystemMouseCursors.click : MouseCursor.defer,
      child: IgnorePointer(
        ignoring: widget.onLongPress == null && widget.onTap == null,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          onTap: widget.onTap,
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

    if (!kIsWeb && widget.onLongPress != null) {
      return tappable;
    }

    return Listener(
      onPointerDown: onPointerDown,
      child: tappable,
    );
  }
}

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

class ScaledButton extends StatefulWidget {
  const ScaledButton({
    required this.child,
    required this.onTap,
    required this.onLongPress,
    required this.borderRadius,
    required this.color,
    required this.scaleStrength,
    required this.scaleAlignment,
    super.key,
    this.pressedOpacity = 0.5,
    this.onTapUp,
  });

  final VoidCallback? onTap;
  final ValueSetter<TapUpDetails>? onTapUp;
  final VoidCallback? onLongPress;
  final double pressedOpacity;
  final Widget child;
  final BorderRadius borderRadius;
  final Color color;
  final ScaleStrength scaleStrength;
  final Alignment scaleAlignment;

  @override
  State<ScaledButton> createState() => _ScaledButtonState();
}

class _ScaledButtonState extends State<ScaledButton>
    with SingleTickerProviderStateMixin {
  static const Duration kScaleOutDuration = Duration(milliseconds: 150);
  static const Duration kScaleInDuration = Duration(milliseconds: 230);
  final Tween<double> _scaleTween = Tween<double>(begin: 1);
  late final double _scaleToAnimationValue = widget.scaleStrength.strength;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
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
    final tappable = MouseRegion(
      cursor: kIsWeb ? SystemMouseCursors.click : MouseCursor.defer,
      child: IgnorePointer(
        ignoring: widget.onLongPress == null && widget.onTap == null,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          onTap: widget.onTap,
          // Use null so other long press actions can be captured
          onLongPress: widget.onLongPress == null
              ? null
              : () {
                  _animate();
                  widget.onLongPress!();
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

    if (!kIsWeb && widget.onLongPress != null) {
      return tappable;
    }

    return Listener(
      onPointerDown: onPointerDown,
      child: tappable,
    );
  }
}
