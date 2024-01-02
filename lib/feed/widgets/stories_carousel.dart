import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';

class StoriesCarousel extends StatelessWidget {
  const StoriesCarousel({super.key});

  static const _storiesCarouselHeight = 124.0;

  @override
  Widget build(BuildContext context) {
    final hasStories = List.generate(12, (index) => Random().nextInt(4).isEven);
    return SliverPadding(
      padding: const EdgeInsets.only(top: 2, bottom: 2),
      sliver: SliverToBoxAdapter(
        child: SizedBox(
          height: _storiesCarouselHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 12,
            itemBuilder: (context, index) {
              final isMine = index == 0;

              return Padding(
                padding: EdgeInsets.only(left: isMine ? 12 : 0),
                child: StoryAvatar(
                  avatarUrl: 'https://i.ibb.co.com/fQpyCY9/54-cleaned.png',
                  isMine: isMine,
                  hasStories: hasStories[index],
                  username: 'gambley1',
                  mineStoryLabel: context.l10n.yourStoryLabel,
                  onTap: () {},
                  onLongPress: () {},
                ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(width: 16),
          ),
        ),
      ),
    );
  }
}
