import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
import 'package:flutter_instagram_offline_first_clone/home/home.dart';
import 'package:flutter_instagram_offline_first_clone/reels/reel/reel.dart';
import 'package:flutter_instagram_offline_first_clone/reels/reels.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:powersync_repository/powersync_repository.dart';
import 'package:shared/shared.dart';

class ReelsPage extends StatelessWidget {
  const ReelsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReelsBloc(
        postsRepository: context.read<PostsRepository>(),
      )..add(const ReelsPageRequested()),
      child: const ReelsView(),
    );
  }
}

class ReelsView extends StatefulWidget {
  const ReelsView({super.key});

  @override
  State<ReelsView> createState() => _ReelsViewState();
}

class _ReelsViewState extends State<ReelsView> {
  late PageController _pageController;

  late ValueNotifier<int> _currentIndex;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(keepPage: false);

    _currentIndex = ValueNotifier(0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _currentIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videoPlayer = VideoPlayerProvider.of(context).videoPlayerState;
    final blocks =
        context.select((ReelsBloc bloc) => bloc.state.blocks).cast<PostBlock>();
    final user = context.select((AppBloc bloc) => bloc.state.user);

    return Stack(
      fit: StackFit.expand,
      children: [
        AppScaffold(
          body: AnimatedBuilder(
            animation: Listenable.merge(
              [videoPlayer.shouldPlayReels, videoPlayer.withSound],
            ),
            builder: (context, child) {
              if (blocks.isEmpty) {
                return SizedBox.expand(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'No reels found.',
                          style: context.headlineSmall,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        FittedBox(
                          child: Tappable(
                            onTap: () => context
                                .read<ReelsBloc>()
                                .add(const ReelsPageRequested()),
                            throttle: true,
                            throttleDuration: 550.ms,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(22),
                                ),
                                border: Border.all(
                                  color: context.adaptiveColor,
                                ),
                              ),
                              child: Align(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.lg,
                                    vertical: AppSpacing.sm,
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      const Icon(Icons.refresh),
                                      Text(
                                        'Refresh',
                                        style: context.labelLarge,
                                      ),
                                    ].insertBetween(
                                      const SizedBox(width: AppSpacing.md),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return RefreshIndicator.adaptive(
                onRefresh: () async {
                  context.read<ReelsBloc>().add(const ReelsPageRequested());
                  await _pageController.animateToPage(
                    0,
                    duration: 150.ms,
                    curve: Curves.easeIn,
                  );
                },
                child: PageView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  allowImplicitScrolling: true,
                  itemCount: blocks.length,
                  onPageChanged: (index) => _currentIndex.value = index,
                  controller: _pageController,
                  itemBuilder: (context, index) {
                    return ValueListenableBuilder<int>(
                      valueListenable: _currentIndex,
                      builder: (context, currentIndex, _) {
                        final isCurrent = index == currentIndex;
                        final block = blocks[index];
                        return ReelView(
                          key: ValueKey(block.id),
                          play: isCurrent && videoPlayer.shouldPlayReels.value,
                          withSound: videoPlayer.withSound.value,
                          block: block,
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
        Positioned(
          right: AppSpacing.md,
          top: AppSpacing.md,
          child: Tappable(
            onTap: () async {
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
            child: const Icon(
              Icons.camera_alt_outlined,
              size: AppSize.iconSize,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
