import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

class FunView extends StatelessWidget {
  const FunView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: CustomScrollView(
        slivers: [
          const SeparatedContainer(
            child: Column(
              children: [
                ListTile(
                  title: Text('Hello'),
                ),
                ListTile(
                  title: Text('World'),
                ),
                ListTile(
                  title: Text('How are you?'),
                ),
              ],
            ),
          ),
          const SliverGap.v(AppSpacing.md),
          SeparatedContainer(
            onlyTop: true,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.md,
                      0,
                      AppSpacing.md,
                    ),
                    child: AppButton.outlined(
                      style: ButtonStyle(
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      onPressed: () {},
                      text: 'Buy now',
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Tappable(
                    onTap: () {},
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: HexColor.fromHex('B43CDE').withOpacity(.3),
                            offset: const Offset(0, 10),
                            blurRadius: 40,
                          ),
                        ],
                        gradient: LinearGradient(
                          colors: PremiumGradient.telegram.colors
                              .map(
                                (gradient) => HexColor.fromHex(gradient.hex),
                              )
                              .toList(),
                          stops: PremiumGradient.telegram.stops,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      margin: const EdgeInsets.all(AppSpacing.md),
                      alignment: Alignment.center,
                      child: Text(
                        'Upgrade to Pro+',
                        style: context.labelLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SliverGap.v(AppSpacing.md),
          SeparatedContainer(
            onlyTop: true,
            child: Column(
              children: [
                const ListTile(
                  title: Text('Hello'),
                ),
                const ListTile(
                  title: Text('World'),
                ),
                Material(
                  clipBehavior: Clip.antiAlias,
                  type: MaterialType.transparency,
                  child: ListTile(
                    onTap: () {},
                    title: const Text('How are you?'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SeparatedContainer extends StatelessWidget {
  const SeparatedContainer({
    required this.child,
    this.onlyTop = false,
    this.onlyBottom = true,
    super.key,
  });

  final Widget child;
  final bool onlyTop;
  final bool onlyBottom;

  @override
  Widget build(BuildContext context) {
    final borderRadius = onlyBottom && onlyTop
        ? const BorderRadius.all(Radius.circular(24))
        : onlyBottom
            ? const BorderRadius.vertical(bottom: Radius.circular(24))
            : const BorderRadius.vertical(top: Radius.circular(24));
    return SliverToBoxAdapter(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 27, 25, 25).withOpacity(.7),
          borderRadius: borderRadius,
        ),
        child: child,
      ),
    );
  }
}

class OutlineGradientButton extends StatelessWidget {
  OutlineGradientButton({
    required double strokeWidth,
    required Gradient gradient,
    required Widget child,
    required this.onTap,
    required this.radius,
    this.boxShadow,
    super.key,
  })  : _painter = _GradientPainter(
          strokeWidth: strokeWidth,
          radius: radius,
          gradient: gradient,
        ),
        _child = child;

  final _GradientPainter _painter;
  final Widget _child;
  final VoidCallback onTap;
  final double radius;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _painter,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
        child: Tappable(
          onTap: onTap,
          animationEffect: TappableAnimationEffect.none,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: boxShadow,
              borderRadius: BorderRadius.all(Radius.circular(radius)),
            ),
            constraints: const BoxConstraints(minWidth: 88, minHeight: 48),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GradientPainter extends CustomPainter {
  _GradientPainter({
    required this.strokeWidth,
    required this.radius,
    required this.gradient,
  });
  final Paint _paint = Paint();
  final double radius;
  final double strokeWidth;
  final Gradient gradient;

  @override
  void paint(Canvas canvas, Size size) {
    // create outer rectangle equals size
    final outerRect = Offset.zero & size;
    final outerRRect =
        RRect.fromRectAndRadius(outerRect, Radius.circular(radius));

    // create inner rectangle smaller by strokeWidth
    final innerRect = Rect.fromLTWH(
      strokeWidth,
      strokeWidth,
      size.width - strokeWidth * 2,
      size.height - strokeWidth * 2,
    );
    final innerRRect = RRect.fromRectAndRadius(
      innerRect,
      Radius.circular(radius - strokeWidth),
    );

    // apply gradient shader
    _paint.shader = gradient.createShader(outerRect);

    // create difference between outer and inner paths and draw it
    final path1 = Path()..addRRect(outerRRect);
    final path2 = Path()..addRRect(innerRRect);
    final path = Path.combine(PathOperation.difference, path1, path2);
    canvas.drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => oldDelegate != this;
}
