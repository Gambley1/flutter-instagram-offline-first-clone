import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// {@template custom_scaffold}
/// App scaffold that is used as a wrapper for the pages.
/// {@endtemplate}
class AppScaffold extends StatelessWidget {
  /// {@macro custom_scaffold}
  const AppScaffold({
    required this.body,
    super.key,
    this.onWillPop,
    this.safeArea = true,
    this.top = true,
    this.bottom = true,
    this.left = true,
    this.right = true,
    this.releaseFocus = false,
    this.resizeToAvoidBottomInset = false,
    this.extendBody = false,
    this.backgroundColor,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.appBar,
    this.bottomNavigationBar,
    this.drawer,
    this.bottomSheet,
    this.extendBodyBehindAppBar = false,
  });

  /// Will pop callback. If null, will pop the navigator.
  final Future<bool> Function()? onWillPop;

  /// If true, will wrap the [body] with [SafeArea].
  final bool safeArea;

  /// If true, will enable top padding in safe area.
  final bool top;

  /// If true, will enable bottom padding in safe area.
  final bool bottom;

  ///  If true, will enable right padding in safe area.
  final bool right;

  /// If true, will enable left padding in safe area.
  final bool left;

  /// If true, will release the focus when the user taps outside of the
  /// text field.
  final bool releaseFocus;

  /// If true, will resize the body when the keyboard is shown.
  final bool resizeToAvoidBottomInset;

  /// The body of the scaffold.
  final Widget body;

  /// The background color of the scaffold.
  final Color? backgroundColor;

  /// The floating action button of the scaffold.
  final Widget? floatingActionButton;

  /// The location of the floaing action button of the scaffold.
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// The bottom navigation bar of the scaffold.
  final Widget? bottomNavigationBar;

  /// The app bar of the scaffold.
  final PreferredSizeWidget? appBar;

  /// The drawer of the scaffold.
  final Widget? drawer;

  /// The bottom sheet of the scaffold.
  final Widget? bottomSheet;

  /// Wether to extend the body behind the bottom navigation bar.
  final bool extendBody;

  /// Wether to extend the body behind the app bar.
  final bool extendBodyBehindAppBar;

  @override
  Widget build(BuildContext context) {
    if (releaseFocus) {
      return Tappable(
        animationEffect: TappableAnimationEffect.none,
        onTap: () => _releaseFocus(context),
        child: _MaterialScaffold(
          top: top,
          bottom: bottom,
          right: right,
          left: left,
          body: body,
          withSafeArea: safeArea,
          backgroundColor: backgroundColor,
          floatingActionButton: floatingActionButton,
          floatingActionButtonLocation: floatingActionButtonLocation,
          bottomNavigationBar: bottomNavigationBar,
          appBar: appBar,
          drawer: drawer,
          bottomSheet: bottomSheet,
          onWillPop: onWillPop,
          extendBody: extendBody,
          extendBodyBehindAppBar: extendBodyBehindAppBar,
        ),
      );
    }
    return _MaterialScaffold(
      top: top,
      bottom: bottom,
      right: right,
      left: left,
      body: body,
      withSafeArea: safeArea,
      backgroundColor: backgroundColor,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      appBar: appBar,
      drawer: drawer,
      bottomSheet: bottomSheet,
      onWillPop: onWillPop,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
    );
  }

  void _releaseFocus(BuildContext context) => FocusScope.of(context).unfocus();
}

class _MaterialScaffold extends StatelessWidget {
  const _MaterialScaffold({
    required this.top,
    required this.bottom,
    required this.right,
    required this.left,
    required this.body,
    required this.withSafeArea,
    required this.extendBody,
    required this.extendBodyBehindAppBar,
    this.backgroundColor,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.appBar,
    this.drawer,
    this.bottomSheet,
    this.onWillPop,
  });

  final bool top;

  final bool bottom;

  final bool right;

  final bool left;

  final Widget body;

  final bool withSafeArea;

  final Color? backgroundColor;

  final Widget? floatingActionButton;

  final FloatingActionButtonLocation? floatingActionButtonLocation;

  final Widget? bottomNavigationBar;

  final PreferredSizeWidget? appBar;

  final Widget? drawer;

  final Widget? bottomSheet;

  final Future<bool> Function()? onWillPop;

  final bool extendBody;

  final bool extendBodyBehindAppBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      body: withSafeArea
          ? SafeArea(
              top: top,
              bottom: bottom,
              right: right,
              left: left,
              child: body,
            )
          : body,
      backgroundColor: backgroundColor,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      appBar: appBar,
      drawer: drawer,
      bottomSheet: bottomSheet,
    ).onWillPop(onWillPop).withAdaptiveTheme(context);
  }
}

/// Will pop scope extension that wraps widget with [WillPopScope].
extension WillPopScopeX on Widget {
  /// Wraps widget with [WillPopScope].
  Widget onWillPop(Future<bool> Function()? onWillPop) =>
      WillPopScope(onWillPop: onWillPop, child: this);
}

/// Extension used to respectively change the `systemNavigationBar` theme.
extension SystemNavigationBarTheme on Widget {
  /// Overrides default [SystemUiOverlayStyle] with adaptive values.
  Widget withAdaptiveTheme(BuildContext context) =>
      AnnotatedRegion<SystemUiOverlayStyle>(
        value: context.theme.platform == TargetPlatform.android
            ? context.isLight
                ? SystemUiOverlayStyle.dark
                : SystemUiOverlayStyle.light
            : context.isLight
                ? AppTheme.darkSystemBarTheme
                : AppTheme.lightSystemBarTheme,
        child: this,
      );
}
