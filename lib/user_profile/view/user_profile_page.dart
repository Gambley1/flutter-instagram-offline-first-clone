import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
import 'package:flutter_instagram_offline_first_clone/attachments/attachments.dart';
import 'package:flutter_instagram_offline_first_clone/feed/post/widgets/post_popup.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:flutter_instagram_offline_first_clone/reels/reels.dart';
import 'package:flutter_instagram_offline_first_clone/stories/create_stories/create_stories.dart';
import 'package:flutter_instagram_offline_first_clone/user_profile/bloc/user_profile_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/user_profile/widgets/user_profile_header.dart';
import 'package:go_router/go_router.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:powersync_repository/powersync_repository.dart';
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
        BlocProvider(
          create: (context) => ReelsBloc(
            postsRepository: context.read<PostsRepository>(),
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
              return SliverFillRemaining(
                child: Center(
                  child: Text('No posts', style: context.headlineSmall),
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
                '${user.username ?? ''} ',
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
                  UserProfileLogoutButton(),
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

class UserProfileLogoutButton extends StatelessWidget {
  const UserProfileLogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: () async {
        void callback(ModalOption option) => option.onTap.call(context);

        final option = await context.showListOptionsModal(
          options: [
            ModalOption(
              name: 'Log out',
              actionTitle: 'Log out',
              actionYesText: 'Log out',
              actionContent: 'Are you sure you want to log out?',
              icon: Icons.logout_rounded,
              distractive: true,
              onTap: () =>
                  context.read<AppBloc>().add(const AppLogoutRequested()),
            ),
          ],
        );
        if (option == null) return;
        callback(option);
      },
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

class UserProfileAddMediaButton extends StatelessWidget {
  const UserProfileAddMediaButton({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select((AppBloc bloc) => bloc.state.user);
    final enableStory =
        context.select((CreateStoriesBloc bloc) => bloc.state.isAvailable);

    return Tappable(
      onTap: () async {
        void callback(ModalOption option) => option.onTap.call(context);

        final option = await context.showListOptionsModal(
          title: 'Create',
          options: createMediaModalOptions(
            reelLabel: 'Reel',
            postLabel: 'Post',
            storyLabel: 'Story',
            context: context,
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
                      onLoading: () => openSnackbar(
                        const SnackbarMessage.loading(),
                        clearIfQueue: true,
                      ),
                      onStoryCreated: () => openSnackbar(
                        const SnackbarMessage.success(
                          title: 'Successfully created story!',
                        ),
                        clearIfQueue: true,
                      ),
                    ),
                  );
              context.pop();
            },
            onCreateReelTap: () async {
              void uploadReel({
                required String postId,
                required List<Map<String, dynamic>> media,
              }) =>
                  context.read<ReelsBloc>().add(
                        ReelsCreateReelRequested(
                          postId: postId,
                          userId: user.id,
                          caption: '',
                          media: media,
                        ),
                      );

              await PickImage.pickVideo(
                context,
                onMediaPicked: (context, selectedFiles) async {
                  try {
                    openSnackbar(const SnackbarMessage.loading());
                    late final postId = UidGenerator.v4();
                    late final storage =
                        Supabase.instance.client.storage.from('posts');

                    late final mediaPath = '$postId/video_0';

                    final selectedFile = selectedFiles.selectedFiles.first;
                    final firstFrame = await VideoPlus.getVideoThumbnail(
                      selectedFile.selectedFile,
                    );
                    final blurHash = firstFrame == null
                        ? ''
                        : await BlurHashPlus.blurHashEncode(firstFrame);
                    final compressedVideo = (await VideoPlus.compressVideo(
                          selectedFile.selectedFile,
                        ))
                            ?.file ??
                        selectedFile.selectedFile;
                    final compressedVideoBytes = await PickImage.imageBytes(
                      file: compressedVideo,
                    );
                    final attachment = AttachmentFile(
                      size: compressedVideoBytes.length,
                      bytes: compressedVideoBytes,
                      path: compressedVideo.path,
                    );

                    await storage.uploadBinary(
                      mediaPath,
                      attachment.bytes!,
                      fileOptions: FileOptions(
                        contentType: attachment.mediaType!.mimeType,
                        cacheControl: '9000000',
                      ),
                    );
                    final mediaUrl = storage.getPublicUrl(mediaPath);
                    String? firstFrameUrl;
                    if (firstFrame != null) {
                      late final firstFramePath = '$postId/video_first_frame_0';
                      await storage.uploadBinary(
                        firstFramePath,
                        firstFrame,
                        fileOptions: FileOptions(
                          contentType: attachment.mediaType!.mimeType,
                          cacheControl: '9000000',
                        ),
                      );
                      firstFrameUrl = storage.getPublicUrl(firstFramePath);
                    }
                    final media = [
                      {
                        'media_id': UidGenerator.v4(),
                        'url': mediaUrl,
                        'type': VideoMedia.identifier,
                        'blur_hash': blurHash,
                        'first_frame_url': firstFrameUrl,
                      }
                    ];
                    uploadReel(media: media, postId: postId);
                    openSnackbar(
                      const SnackbarMessage.success(
                        title: 'Successfully created reel!',
                      ),
                    );
                  } catch (error, stackTrace) {
                    logE(
                      'Failed to create reel!',
                      error: error,
                      stackTrace: stackTrace,
                    );
                    openSnackbar(
                      const SnackbarMessage.error(
                        title: 'Failed to create reel!',
                      ),
                    );
                  }
                },
              );
            },
          ),
        );
        if (option == null) return;
        callback(option);
      },
      child: const Icon(
        Icons.add_box_outlined,
        size: AppSize.iconSize,
      ),
    );
  }
}
