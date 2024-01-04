import 'package:flutter/widgets.dart';

class CounterText extends StatelessWidget {
  const CounterText({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Count:'),
        child, 
      ],
    );
  }
}
