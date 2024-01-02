import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';

class FeedAppBar extends StatelessWidget {
  const FeedAppBar({required this.innerBoxIsScrolled, super.key});

  final bool innerBoxIsScrolled;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      centerTitle: false,
      forceElevated: innerBoxIsScrolled,
      title: Text(
        context.l10n.feedAppBarTitle,
        style: context.headlineMedium,
      ),
      scrolledUnderElevation: 0,
    );
  }
}
