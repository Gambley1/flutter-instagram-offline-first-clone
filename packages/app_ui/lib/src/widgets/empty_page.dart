import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// {@template empty_page}
/// Empty page that is used as a placholder for pages that are not implemented
/// yet or there is not content to show in case of some exceptions or no
/// network scenarios.
/// {@endtemplate}
class EmptyPage extends StatelessWidget {
  /// {@macro empty_page}
  const EmptyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      body: SizedBox(),
    );
  }
}
