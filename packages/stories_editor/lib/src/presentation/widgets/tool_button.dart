import 'package:flutter/material.dart';
import 'package:stories_editor/src/presentation/widgets/animated_onTap_button.dart';

class ToolButton extends StatelessWidget {
  final Function() onTap;
  final Widget child;
  final Color? backGroundColor;
  final EdgeInsets? padding;
  final Function()? onLongPress;
  final Color colorBorder;
  const ToolButton({
    super.key,
    required this.onTap,
    required this.child,
    this.backGroundColor,
    this.padding,
    this.onLongPress,
    this.colorBorder = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: AnimatedOnTapButton(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 10),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(90),
            elevation: 1,
            shadowColor: Colors.black.withOpacity(0.5),
            child: Container(
              height: 35,
              width: 35,
              decoration: BoxDecoration(
                  color: backGroundColor ?? Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: colorBorder, width: 2)),
              child: Transform.scale(
                scale: 0.8,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
