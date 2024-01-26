import 'package:app_ui/app_ui.dart';
import 'package:firebase_config/firebase_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
import 'package:flutter_instagram_offline_first_clone/feed/feed.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:flutter_instagram_offline_first_clone/stories/create_stories/create_stories.dart';
import 'package:flutter_instagram_offline_first_clone/user_profile/bloc/user_profile_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/user_profile/widgets/user_profile_header.dart';
import 'package:go_router/go_router.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:shared/shared.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:stories_repository/stories_repository.dart';
import 'package:user_repository/user_repository.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({
    super.key,
    this.userId,
    this.isSponsored = false,
    this.promoBlockAction,
  });

  final String? userId;
  final bool isSponsored;
  final BlockAction? promoBlockAction;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => UserProfileBloc(
            postsRepository: context.read<PostsRepository>(),
            userRepository: context.read<UserRepository>(),
            userId: userId,
          ),
        ),
        BlocProvider(
          create: (context) => CreateStoriesBloc(
            storiesRepository: context.read<StoriesRepository>(),
            remoteConfig: context.read<FirebaseConfig>(),
          )..add(const CreateStoriesFeatureAvaiableSubscriptionRequested()),
        ),
        BlocProvider(
          create: (context) => FeedBloc(
            postsRepository: context.read<PostsRepository>(),
            userRepository: context.read<UserRepository>(),
            remoteConfig: context.read<FirebaseConfig>(),
          ),
        ),
      ],
      child: UserProfileView(
        userId: userId,
        isSponsored: isSponsored,
        promoBlockAction: promoBlockAction,
      ),
    );
  }
}

class UserProfileView extends StatefulWidget {
  const UserProfileView({
    super.key,
    this.userId,
    this.isSponsored = false,
    this.promoBlockAction,
  });

  final String? userId;
  final bool isSponsored;
  final BlockAction? promoBlockAction;

  @override
  State<UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView>
    with SingleTickerProviderStateMixin {
  late ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    final promoAction =
        widget.promoBlockAction as NavigateToSponsoredPostAuthorProfileAction?;
    return AppScaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: !widget.isSponsored
          ? null
          : PromoFloatingAction(
              url: promoAction!.promoUrl,
              promoImageUrl: promoAction.promoPreviewImageUrl,
              title: context.l10n.learnMoreAboutUserPromoText,
              subtitle: context.l10n.visitUserPromoWebsiteText,
            ),
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          controller: _controller,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverOverlapAbsorber(
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                sliver: MultiSliver(
                  children: [
                    UserProfileAppBar(userId: widget.userId),
                    UserProfileHeader(userId: widget.userId),
                    SliverPersistentHeader(
                      pinned: !ModalRoute.of(context)!.isFirst,
                      delegate: _SliverAppBarDelegate(
                        const TabBar(
                          indicatorSize: TabBarIndicatorSize.tab,
                          padding: EdgeInsets.zero,
                          labelPadding: EdgeInsets.zero,
                          indicatorWeight: 1,
                          tabs: [
                            Tab(
                              icon: Icon(Icons.grid_on),
                              iconMargin: EdgeInsets.zero,
                            ),
                            Tab(
                              icon: Icon(Icons.person_outline),
                              iconMargin: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ];
          },
          body: const TabBarView(
            children: [
              PostsPage(),
              UserProfileMentionedPostsPage(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: context.theme.scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}

class PostsPage extends StatefulWidget {
  const PostsPage({super.key});

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<UserProfileBloc>();

    super.build(context);
    return CustomScrollView(
      slivers: [
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        StreamBuilder<List<PostBlock>>(
          stream: bloc.userPosts(),
          builder: (context, snapshot) {
            final loading = snapshot.connectionState == ConnectionState.waiting;
            final blocks = snapshot.data;
            final showNothing = loading || blocks == null;
            final showEmpty = blocks != null && blocks.isEmpty;
            if (showNothing) {
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            }
            if (showEmpty) {
              return SliverToBoxAdapter(
                child: Text(
                  'No posts',
                  style: context.titleLarge
                      ?.copyWith(fontWeight: AppFontWeight.bold),
                ),
              );
            }
            return SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisExtent: 120,
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
              ),
              itemCount: blocks.length,
              itemBuilder: (context, index) {
                final block = blocks[index];
                final media = block.media.first;
                late String mediaUrl;
                if (media is ImageMedia) {
                  mediaUrl = media.url;
                } else if (media is VideoMedia) {
                  mediaUrl = media.firstFrameUrl;
                }
                final multiMedia = block.media.length > 1;

                return PostSmall(
                  key: ValueKey(block.id),
                  isOwner: bloc.isOwnerOfPostBy(block.author.id),
                  onTap: () => context.pushNamed(
                    'user_posts',
                    queryParameters: {
                      'user_id': block.author.id,
                      'index': index.toString(),
                    },
                  ),
                  onPostDelete: () => bloc.add(
                    UserProfileDeletePostRequested(block.id),
                  ),
                  pinned: false,
                  multiMedia: multiMedia,
                  mediaUrl: mediaUrl,
                  isReel: block.isReel,
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class UserProfileMentionedPostsPage extends StatelessWidget {
  const UserProfileMentionedPostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        const SliverFillRemaining(
          hasScrollBody: false,
          child: Text('Hello'),
        ),
      ],
    );
  }
}

class UserProfileAppBar extends StatelessWidget {
  const UserProfileAppBar({required this.userId, super.key});

  final String? userId;

  @override
  Widget build(BuildContext context) {
    final user = context.select((UserProfileBloc b) => b.state.user);
    return SliverPadding(
      padding: const EdgeInsets.only(right: 12),
      sliver: SliverAppBar(
        centerTitle: false,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Flexible(
              flex: 12,
              child: Text(
                '${user.username ?? ''} ',
                style: context.titleLarge?.copyWith(
                  fontWeight: AppFontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Flexible(
              child: Assets.icons.verifiedUser.svg(width: 16, height: 16),
            ),
          ],
        ),
        actions: userId != null && userId != user.id ||
                (userId == null && !ModalRoute.of(context)!.isFirst)
            ? const [
                UserProfileActions(),
              ]
            : [
                const UserProfileAddMediaButton(),
                if (ModalRoute.of(context)!.isFirst) ...const [
                  SizedBox(width: 12),
                  UserProfileLogoutButton(),
                ],
              ],
        pinned: !ModalRoute.of(context)!.isFirst,
        floating: ModalRoute.of(context)!.isFirst,
      ),
    );
  }
}

class UserProfileActions extends StatelessWidget {
  const UserProfileActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: () {},
      child: Icon(Icons.adaptive.more_outlined, size: 36),
    );
  }
}

class UserProfileLogoutButton extends StatelessWidget {
  const UserProfileLogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: () => context.read<AppBloc>().add(const AppLogoutRequested()),
      child: const Icon(Icons.logout, size: 36),
    );
  }
}

class UserProfileAddMediaButton extends StatelessWidget {
  const UserProfileAddMediaButton({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select((AppBloc bloc) => bloc.state.user);
    final enableStory =
        context.select((CreateStoriesBloc bloc) => bloc.state.isAvailable);
    return Tappable(
      onTap: () async {
        final option = await context.showListOptionsModal(
          options: createMediaModalOptions(
            reelLabel: 'Reel',
            postLabel: 'Post',
            storyLabel: 'Story',
            goTo: (route, {extra}) => context.pushNamed(route, extra: extra),
            enableStory: enableStory,
            storyExtra: (String path) {
              context.read<CreateStoriesBloc>().add(
                    CreateStoriesStoryCreateRequested(
                      author: user,
                      contentType: StoryContentType.image,
                      filePath: path,
                      onError: (_, __) => openSnackbar(
                        const SnackbarMessage.error(
                          title: 'Something went wrong!',
                          description: 'Failed to create story',
                        ),
                      ),
                      onLoading: () =>
                          openSnackbar(const SnackbarMessage.loading()),
                      onStoryCreated: () => openSnackbar(
                        const SnackbarMessage.success(
                          title: 'Successfully created story!',
                        ),
                      ),
                    ),
                  );
              context.pop();
            },
          ),
          title: 'Create',
        );
        if (option == null) return;
        option.onTap?.call();
      },
      child: const Icon(
        Icons.add_box_outlined,
        size: 36,
      ),
    );
  }
}
