import 'dart:io';
import 'dart:typed_data';

import 'package:app_ui/app_ui.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
import 'package:flutter_instagram_offline_first_clone/attachments/attachments.dart';
import 'package:flutter_instagram_offline_first_clone/feed/bloc/feed_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/feed/feed.dart';
import 'package:flutter_instagram_offline_first_clone/home/home.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:go_router/go_router.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:powersync_repository/powersync_repository.dart';
import 'package:shared/shared.dart';

class UserProfileCreatePost extends StatelessWidget {
  const UserProfileCreatePost({this.onPopInvoked, super.key});

  final VoidCallback? onPopInvoked;

  @override
  Widget build(BuildContext context) {
    return CreatePostView(onPopInvoked: onPopInvoked);
  }
}

class CreatePostView extends StatefulWidget {
  const CreatePostView({required this.onPopInvoked, super.key});

  final VoidCallback? onPopInvoked;

  @override
  State<CreatePostView> createState() => _CreatePostViewState();
}

class _CreatePostViewState extends State<CreatePostView>
    with SafeSetStateMixin {
  final _captionController = TextEditingController();
  List<SelectedByte>? _selectedFiles;
  bool _busy = false;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select((AppBloc b) => b.state.user);
    return AppScaffold(
      releaseFocus: true,
      onPopInvoked: (didPop) {
        if (didPop) return;
        if (_busy) return;
        if (widget.onPopInvoked == null) {
          context.pop();
        } else {
          widget.onPopInvoked!.call();
        }
      },
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.clear, size: AppSize.iconSize),
          onPressed: () {
            _selectedFiles?.clear();
            HomeProvider.instance.animateToPage(1);
          },
        ),
        title: const Text('Create post'),
        actions: [
          if (_selectedFiles != null && (_selectedFiles?.isNotEmpty ?? false))
            Tappable(
              onTap: _busy
                  ? null
                  : () => context.confirmAction(
                        title: 'Clear images',
                        content: 'Are you sure you want to clear all images?',
                        yesText: 'Clear',
                        fn: () => safeSetState(() {
                          _selectedFiles?.clear();
                        }),
                      ),
              child: const Icon(Icons.cancel, size: AppSize.iconSize),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            children: [
              SizedBox.square(
                dimension: 128,
                child: ElevatedButton(
                  onPressed: _busy
                      ? null
                      : () async {
                          await PickImage.instance.pickAssetsFromBoth(
                            context,
                            onMediaPicked: (context, details) async {
                              final selectedFiles = <SelectedByte>[];
                              for (final selectedFile
                                  in details.selectedFiles) {
                                if (selectedFile.selectedFile.isVideo ||
                                    !selectedFile.isThatImage) {
                                  selectedFiles.add(selectedFile);
                                  continue;
                                }
                                final compressedFile =
                                    await ImageCompress.compressFile(
                                  selectedFile.selectedFile,
                                );
                                final compressedByte =
                                    await PickImage.instance.imageBytes(
                                  file: compressedFile != null
                                      ? File(compressedFile.path)
                                      : selectedFile.selectedFile,
                                );
                                final byte = SelectedByte(
                                  isThatImage:
                                      selectedFile.selectedFile.isVideo,
                                  selectedFile: compressedFile == null
                                      ? selectedFile.selectedFile
                                      : File(compressedFile.path),
                                  selectedByte: compressedByte,
                                );
                                selectedFiles.add(byte);
                              }

                              safeSetState(() {
                                _selectedFiles = selectedFiles;
                              });
                            },
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                  ),
                  child: const FittedBox(child: Icon(Icons.camera)),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                filled: true,
                enabled: !_busy,
                textController: _captionController,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                labelText: context.l10n.captionText,
                labelStyle: context.bodyLarge?.apply(color: AppColors.grey),
                textInputAction: TextInputAction.done,
                textInputType: TextInputType.text,
                textCapitalization: TextCapitalization.sentences,
                suffixIcon: _captionController.text.trim().isEmpty
                    ? null
                    : Tappable(
                        onTap: () => safeSetState(_captionController.clear),
                        child: const Icon(
                          Icons.cancel,
                        ),
                      ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: CreatePostButton(
                  busy: _busy,
                  onPostCreate: _selectedFiles == null ||
                          (_selectedFiles?.isEmpty ?? true)
                      ? null
                      : () async {
                          void pop() {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              HomeProvider.instance.animateToPage(1);
                            }
                          }

                          try {
                            safeSetState(() {
                              _busy = true;
                            });
                            loadingIndeterminateKey.currentState
                                ?.setVisibility(visible: true);

                            late final storage =
                                Supabase.instance.client.storage.from('posts');

                            final postId = uuid.v4();
                            final media = <Map<String, dynamic>>[];
                            for (var i = 0; i < _selectedFiles!.length; i++) {
                              late final selectedByte =
                                  _selectedFiles![i].selectedByte;
                              late final selectedFile =
                                  _selectedFiles![i].selectedFile;
                              late final isVideo = selectedFile.isVideo;
                              String blurHash;
                              Uint8List? convertedBytes;
                              if (isVideo) {
                                convertedBytes =
                                    await VideoPlus.getVideoThumbnail(
                                  selectedFile,
                                );
                                blurHash = convertedBytes == null
                                    ? ''
                                    : await BlurHashPlus.blurHashEncode(
                                        convertedBytes,
                                      );
                              } else {
                                blurHash = await BlurHashPlus.blurHashEncode(
                                  selectedByte,
                                );
                              }
                              if (!mounted) return;
                              late final mediaExtension = selectedFile.path
                                  .split('.')
                                  .last
                                  .toLowerCase();

                              late final mediaPath =
                                  '$postId/${!isVideo ? 'image_$i' : 'video_$i'}';

                              if (!mounted) return;
                              Uint8List bytes;
                              if (isVideo) {
                                try {
                                  final compressedVideo =
                                      await VideoPlus.compressVideo(
                                    selectedFile,
                                  );
                                  bytes = await PickImage.instance.imageBytes(
                                    file: compressedVideo!.file!,
                                  );
                                } catch (error, stackTrace) {
                                  logE(
                                    'Error compressing video',
                                    error: error,
                                    stackTrace: stackTrace,
                                  );
                                  continue;
                                }
                              } else {
                                bytes = selectedByte;
                              }
                              await storage.uploadBinary(
                                mediaPath,
                                bytes,
                                fileOptions: FileOptions(
                                  contentType:
                                      '${!isVideo ? 'image' : 'video'}/$mediaExtension',
                                  cacheControl: '9000000',
                                ),
                              );
                              final mediaUrl = storage.getPublicUrl(mediaPath);
                              String? firstFrameUrl;
                              if (convertedBytes != null) {
                                late final firstFramePath =
                                    '$postId/video_first_frame_$i';
                                await storage.uploadBinary(
                                  firstFramePath,
                                  convertedBytes,
                                  fileOptions: FileOptions(
                                    contentType: 'video/$mediaExtension',
                                    cacheControl: '9000000',
                                  ),
                                );
                                firstFrameUrl =
                                    storage.getPublicUrl(firstFramePath);
                              }
                              final mediaType = isVideo
                                  ? VideoMedia.identifier
                                  : ImageMedia.identifier;
                              if (isVideo) {
                                media.add({
                                  'media_id': uuid.v4(),
                                  'url': mediaUrl,
                                  'type': mediaType,
                                  'blur_hash': blurHash,
                                  'first_frame_url': firstFrameUrl,
                                });
                              } else {
                                media.add({
                                  'media_id': uuid.v4(),
                                  'url': mediaUrl,
                                  'type': mediaType,
                                  'blur_hash': blurHash,
                                });
                              }
                            }
                            if (!mounted) return;
                            await Future.microtask(
                              () => context.read<FeedBloc>().add(
                                    FeedPostCreateRequested(
                                      postId: postId,
                                      userId: user.id,
                                      caption: _captionController.text,
                                      media: media,
                                    ),
                                  ),
                            );
                            safeSetState(() {
                              _busy = false;
                            });
                            if (mounted) {
                              pop();
                              _selectedFiles?.clear();
                              _captionController.clear();
                            }
                            loadingIndeterminateKey.currentState
                                ?.setVisibility(visible: false);
                            openSnackbar(
                              const SnackbarMessage.success(
                                title: 'Successfully created post!',
                              ),
                            );
                          } catch (error, stackTrace) {
                            logE(error, stackTrace: stackTrace);
                            safeSetState(() => _busy = false);
                            openSnackbar(
                              const SnackbarMessage.error(
                                title: 'Failed to create post!',
                              ),
                            );
                          }
                        },
                ),
              ),
              if (_selectedFiles != null)
                ImagesCarouselPreview(
                  imagesBytes:
                      _selectedFiles!.map((e) => e.selectedByte).toList(),
                  onImageDelete: (bytes, index) {
                    safeSetState(() {
                      _selectedFiles?.removeAt(index);
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ImagesCarouselPreview extends StatelessWidget {
  const ImagesCarouselPreview({
    required this.imagesBytes,
    required this.onImageDelete,
    super.key,
  });

  final List<Uint8List> imagesBytes;
  final void Function(Uint8List, int) onImageDelete;

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      itemCount: imagesBytes.length,
      itemBuilder: (context, index, realIndex) {
        final bytes = imagesBytes[index];
        return Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md,
            horizontal: AppSpacing.lg,
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            child: Stack(
              children: <Widget>[
                ImageAttachmentThumbnail(
                  image: Attachment(
                    file: AttachmentFile(size: bytes.length, bytes: bytes),
                  ),
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: AppSpacing.md,
                  left: AppSpacing.md,
                  child: Tappable(
                    onTap: () {
                      final index = imagesBytes.indexWhere((e) => e == bytes);
                      if (index == -1) return;
                      onImageDelete(bytes, index);
                    },
                    child: const Icon(
                      Icons.cancel,
                      size: AppSize.iconSizeBig,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      options: CarouselOptions(
        aspectRatio: 1,
        enableInfiniteScroll: false,
        viewportFraction: .6,
      ),
    );
  }
}

class CreatePostButton extends StatelessWidget {
  const CreatePostButton({
    this.onPostCreate,
    this.busy = false,
    super.key,
  });

  final VoidCallback? onPostCreate;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    Widget button;
    if (busy) {
      button = const AppButton.inProgress(scale: .5);
    } else {
      button = AppButton.outlined(
        onPressed: onPostCreate,
        text: 'Create',
      );
    }
    return SizedBox(width: double.infinity, child: button);
  }
}
