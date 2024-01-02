import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

class ReelsView extends StatelessWidget {
  const ReelsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Reels view'),
        ],
      ),
    );
  }
}
