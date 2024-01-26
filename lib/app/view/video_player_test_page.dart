import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';
import 'package:shared/shared.dart';

class TestPageInViewNotifier extends StatelessWidget {
  const TestPageInViewNotifier({super.key});

  @override
  Widget build(BuildContext context) {
    final mockPosts = List.generate(
      5,
      (index) {
        return PostLargeBlock(
          id: UidGenerator.v4(),
          author: const PostAuthor.confirmed(),
          createdAt: DateTime.now(),
          media: [
            VideoMedia(
              id: UidGenerator.v4(),
              url:
                  'https://wefeasvyrksvvywqgchk.supabase.co/storage/v1/object/public/posts/e009b78d-b582-4ebf-963d-d034f3ed4688/video_0',
              firstFrameUrl: '',
            ),
            VideoMedia(
              id: UidGenerator.v4(),
              url:
                  'https://wefeasvyrksvvywqgchk.supabase.co/storage/v1/object/public/posts/85825290-d2bf-4098-8a4d-65c78770c439/video_0',
              firstFrameUrl: '',
            ),
          ],
          caption: 'Very good post!',
        );
      },
      growable: false,
    );

    return AppScaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          InViewNotifierCustomScrollView(
            initialInViewIds: const ['0'],
            isInViewPortCondition: (deltaTop, deltaBottom, vpHeight) {
              return deltaTop < (0.5 * vpHeight) + 80.0 &&
                  deltaBottom > (0.5 * vpHeight) - 80.0;
            },
            slivers: [
              SliverList.builder(
                itemCount: mockPosts.length,
                itemBuilder: (context, index) {
                  final block = mockPosts[index];
                  return PostLarge(
                    block: block,
                    isOwner: true,
                    postIndex: index,
                    isLiked: Stream.value(false).asBroadcastStream(),
                    likePost: () {},
                    likesCount: Stream.value(100).asBroadcastStream(),
                    commentsCount: Stream.value(48).asBroadcastStream(),
                    createdAt: block.createdAt.timeAgo(context),
                    isFollowed: Stream.value(true).asBroadcastStream(),
                    wasFollowed: true,
                    follow: () {},
                    enableFollowButton: true,
                    onCommentsTap: (value) {},
                    onPostShareTap: (p0, p1) {},
                    likesText: (count) {
                      return 'Likes: $count';
                    },
                    commentsText: (count) {
                      return 'Comments: $count';
                    },
                    onPressed: (action, avatarUrl) {},
                    withInViewNotifier: true,
                    videoPlayerBuilder:
                        (context, media, aspectRatio, shouldPlay) {
                      return VideoPlay(
                        key: ValueKey(media.id),
                        url: media.url,
                        play: shouldPlay,
                        blurHash: media.blurHash,
                        withSound: false,
                        aspectRatio: aspectRatio,
                      );
                    },
                  );
                },
              ),
            ],
          ),
          IgnorePointer(
            child: Align(
              child: Container(
                height: 200,
                color: Colors.redAccent.withOpacity(0.2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VideoPlayer extends StatelessWidget {
  const VideoPlayer({
    required this.play,
    required this.url,
    required this.id,
    super.key,
  });

  final bool play;
  final String id;
  final String url;

  @override
  Widget build(BuildContext context) {
    return InViewNotifierWidget(
      id: id,
      builder: (context, isInView, child) {
        logI('$id is in view: $isInView');

        final play = isInView && this.play;
        return VideoPlay(
          url: url,
          play: play,
          aspectRatio: 1,
          withSound: false,
        );
      },
    );
  }
}
