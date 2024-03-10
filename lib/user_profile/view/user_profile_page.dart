import 'package:app_ui/app_ui.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
import 'package:flutter_instagram_offline_first_clone/feed/post/widgets/post_popup.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:flutter_instagram_offline_first_clone/selector/selector.dart';
import 'package:flutter_instagram_offline_first_clone/stories/create_stories/create_stories.dart';
import 'package:flutter_instagram_offline_first_clone/user_profile/bloc/user_profile_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/user_profile/widgets/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:shared/shared.dart';
import 'package:sliver_tools/sliver_tools.dart';
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
            userId: userId,
            postsRepository: context.read<PostsRepository>(),
            userRepository: context.read<UserRepository>(),
          )
            ..add(const UserProfileSubscriptionRequested())
            ..add(const UserProfilePostsCountSubscriptionRequested())
            ..add(const UserProfileFollowingsCountSubscriptionRequested())
            ..add(const UserProfileFollowersCountSubscriptionRequested()),
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
    final user = context.select((UserProfileBloc bloc) => bloc.state.user);

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
          floatHeaderSlivers: true,
          controller: _controller,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverOverlapAbsorber(
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                sliver: MultiSliver(
                  children: [
                    UserProfileAppBar(userId: widget.userId),
                    if (!user.isAnonymous) ...[
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
      cacheExtent: 2760,
      slivers: [
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        BetterStreamBuilder<List<PostBlock>>(
          initialData: const <PostBlock>[],
          stream: bloc.userPosts(),
          comparator: const ListEquality<PostBlock>().equals,
          builder: (context, blocks) {
            if (blocks.isEmpty) {
              return const EmptyPosts();
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
                final multiMedia = block.media.length > 1;

                return BlocBuilder<AppBloc, AppState>(
                  builder: (context, state) {
                    final user = state.user;
                    final isOwner = block.author.id == user.id;

                    return PostPopup(
                      block: block,
                      index: index,
                      builder: (_) => PostSmall(
                        key: ValueKey(block.id),
                        isOwner: isOwner,
                        pinned: false,
                        isReel: block.isReel,
                        multiMedia: multiMedia,
                        mediaUrl: block.firstMediaUrl!,
                        imageThumbnailBuilder: (_, url) =>
                            ImageAttachmentThumbnail(
                          image: Attachment(imageUrl: url),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
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
        const EmptyPosts(icon: Icons.person_pin_outlined),
      ],
    );
  }
}

class UserProfileAppBar extends StatelessWidget {
  const UserProfileAppBar({required this.userId, super.key});

  final String? userId;

  @override
  Widget build(BuildContext context) {
    final currentUser = context.select((AppBloc bloc) => bloc.state.user);
    final user = context.select((UserProfileBloc b) => b.state.user);

    return SliverPadding(
      padding: const EdgeInsets.only(right: AppSpacing.md),
      sliver: SliverAppBar(
        centerTitle: false,
        pinned: !ModalRoute.of(context)!.isFirst,
        floating: ModalRoute.of(context)!.isFirst,
        title: Row(
          children: [
            Flexible(
              flex: 12,
              child: Text(
                '${user.displayUsername} ',
                style: context.titleLarge?.copyWith(
                  fontWeight: AppFontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Flexible(
              child: Assets.icons.verifiedUser.svg(
                width: AppSize.iconSizeSmall,
                height: AppSize.iconSizeSmall,
              ),
            ),
          ],
        ),
        actions: userId != null && userId != currentUser.id ||
                (userId == null && !ModalRoute.of(context)!.isFirst)
            ? const [
                UserProfileActions(),
              ]
            : [
                const UserProfileAddMediaButton(),
                if (ModalRoute.of(context)!.isFirst) ...const [
                  SizedBox(width: AppSpacing.md),
                  UserProfileSettingsButton(),
                ],
              ],
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
      child: Icon(Icons.adaptive.more_outlined, size: AppSize.iconSize),
    );
  }
}

class UserProfileSettingsButton extends StatelessWidget {
  const UserProfileSettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: () => context.showListOptionsModal(
        options: [
          ModalOption(child: const LocaleModalOption()),
          ModalOption(child: const ThemeSelectorModalOption()),
          ModalOption(child: const LogoutModalOption()),
        ],
      ).then((option) {
        if (option == null) return;
        option.onTap(context);
      }),
      child: Assets.icons.setting.svg(
        height: AppSize.iconSize,
        width: AppSize.iconSize,
        colorFilter: ColorFilter.mode(
          context.adaptiveColor,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}

class LogoutModalOption extends StatelessWidget {
  const LogoutModalOption({super.key});

  @override
  Widget build(BuildContext context) {
    return Tappable(
      animationEffect: TappableAnimationEffect.none,
      onTap: () => context.confirmAction(
        fn: () {
          context.pop();
          context.read<AppBloc>().add(const AppLogoutRequested());
        },
        title: context.l10n.logOutText,
        content: context.l10n.logOutConfirmationText,
        noText: context.l10n.cancelText,
        yesText: context.l10n.logOutText,
      ),
      child: ListTile(
        title: Text(
          context.l10n.logOutText,
          style: context.bodyLarge?.apply(color: AppColors.red),
        ),
        leading: const Icon(Icons.logout, color: AppColors.red),
      ),
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
      onTap: () => context
          .showListOptionsModal(
        title: context.l10n.createText,
        options: createMediaModalOptions(
          reelLabel: context.l10n.reelText,
          postLabel: context.l10n.postText,
          storyLabel: context.l10n.storyText,
          context: context,
          goTo: (route, {extra}) => context.pushNamed(route, extra: extra),
          enableStory: enableStory,
          storyExtra: (String path) {
            context.read<CreateStoriesBloc>().add(
                  CreateStoriesStoryCreateRequested(
                    author: user,
                    contentType: StoryContentType.image,
                    filePath: path,
                    onError: (_, __) {
                      toggleLoadingIndeterminate(enable: false);
                      openSnackbar(
                        SnackbarMessage.error(
                          title: context.l10n.somethingWentWrongText,
                          description: context.l10n.failedToCreateStoryText,
                        ),
                      );
                    },
                    onLoading: toggleLoadingIndeterminate,
                    onStoryCreated: () {
                      toggleLoadingIndeterminate(enable: false);
                      openSnackbar(
                        SnackbarMessage.success(
                          title: context.l10n.successfullyCreatedStoryText,
                        ),
                        clearIfQueue: true,
                      );
                    },
                  ),
                );
            context.pop();
          },
          onCreateReelTap: () => PickImage().pickVideo(
            context,
            onMediaPicked: (context, details) => context.pushNamed(
              'publish_post',
              extra: CreatePostProps(
                details: details,
                isReel: true,
                context: context,
              ),
            ),
          ),
        ),
      )
          .then((option) {
        if (option == null) return;
        option.onTap(context);
      }),
      child: const Icon(
        Icons.add_box_outlined,
        size: AppSize.iconSize,
      ),
    );
  }
}
