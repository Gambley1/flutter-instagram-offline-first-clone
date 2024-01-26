import 'dart:io';
import 'dart:typed_data';

import 'package:app_ui/app_ui.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
import 'package:flutter_instagram_offline_first_clone/attachments/attachments.dart';
import 'package:flutter_instagram_offline_first_clone/user_profile/user_profile.dart';
import 'package:go_router/go_router.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:powersync_repository/powersync_repository.dart';
import 'package:shared/shared.dart';
import 'package:user_repository/user_repository.dart';

class UserProfileCreatePost extends StatelessWidget {
  const UserProfileCreatePost({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserProfileBloc(
        userRepository: context.read<UserRepository>(),
        postsRepository: context.read<PostsRepository>(),
      ),
      child: const CreatePostView(),
    );
  }
}

class CreatePostView extends StatefulWidget {
  const CreatePostView({super.key});

  @override
  State<CreatePostView> createState() => _CreatePostViewState();
}

class _CreatePostViewState extends State<CreatePostView> {
  final _captionController = TextEditingController();
  // List<Uint8List>? _imagesBytes;
  // List<File>? _imagesFile;
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
        context.pop();
      },
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: const Text('Create post'),
        actions: [
          if (_selectedFiles != null && (_selectedFiles?.isNotEmpty ?? false))
            Tappable(
              onTap: _busy
                  ? null
                  : () => context.confirmAction(
                        fn: () => setState(() {
                          // _imagesBytes?.clear();
                          // _imagesFile?.clear();
                          _selectedFiles?.clear();
                        }),
                        noText: 'Cancel',
                        yesText: 'Clear',
                        title: 'Are you sure to clear all the images?',
                      ),
              child: const Icon(Icons.cancel, size: 30),
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
                          await PickImage.pickAssetsFromBoth(
                            context,
                            onMediaPicked: (context, details) async {
                              // final imagesFile = <File>[];
                              // final imagesBytes = <Uint8List>[];
                              // for (final file in details.selectedFiles) {
                              //   imagesFile.add(file.selectedFile);
                              //   imagesBytes.add(file.selectedByte);
                              // }
                              // setState(() {
                              //   _imagesFile = imagesFile;
                              //   _imagesBytes = imagesBytes;
                              // });
                              void pop() => context.pop();
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
                                    await PickImage.imageBytes(
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

                              setState(() {
                                _selectedFiles = selectedFiles;
                              });
                              pop.call();
                            },
                            // await Navigator.of(context, rootNavigator: true)
                            //     .push(
                            //   MaterialPageRoute<dynamic>(
                            //     builder: (context) => CreatePostPage(
                            //       selectedFilesDetails: details,
                            //     ),
                            //     maintainState: false,
                            //   ),
                            // );
                          );
                          // await PickImage.pickAssets(
                          //   context,
                          //   closeOnComplete: true,
                          //   onCompleted: (exportDetails) async {
                          //     await for (final details in exportDetails) {
                          //       final files = details.croppedFiles;
                          //       final imagesFile = <File>[];
                          //       final imagesBytes = <Uint8List>[];
                          //       for (final file in files) {
                          //         imagesFile.add(file);

                          //         final bytes =
                          //             await PickImage.imageBytes(file: file);
                          //         imagesBytes.add(bytes);
                          //       }
                          //       setState(() {
                          //         _imagesFile = imagesFile;
                          //         _imagesBytes = imagesBytes;
                          //       });
                          //     }
                          //   },
                          // );
                        },
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                  ),
                  child: const FittedBox(child: Icon(Icons.camera)),
                ),
              ),
              const SizedBox(height: 12),
              AppTextField(
                filled: true,
                border: outlinedBorder(
                  borderRadius: 4,
                  borderSide: BorderSide.none,
                ),
                enabled: !_busy,
                textController: _captionController,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                hintText: 'Description',
                textInputAction: TextInputAction.done,
                textInputType: TextInputType.text,
                textCapitalization: TextCapitalization.sentences,
                suffixIcon: _captionController.text.trim().isEmpty
                    ? null
                    : Tappable(
                        onTap: () => setState(_captionController.clear),
                        child: const Icon(
                          Icons.cancel,
                          size: 20,
                        ),
                      ),
                onChanged: (value) {
                  setState(() {
                    _captionController.text = value;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: CreatePostButton(
                  busy: _busy,
                  onPostCreate: _selectedFiles == null ||
                          (_selectedFiles?.isEmpty ?? true)
                      ? null
                      : () async {
                          try {
                            setState(() {
                              _busy = true;
                            });
                            late final storage =
                                Supabase.instance.client.storage.from('posts');

                            final postId = UidGenerator.v4();
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
                                  bytes = await PickImage.imageBytes(
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
                                  'media_id': UidGenerator.v4(),
                                  'url': mediaUrl,
                                  'type': mediaType,
                                  'blur_hash': blurHash,
                                  'first_frame_url': firstFrameUrl,
                                });
                              } else {
                                media.add({
                                  'media_id': UidGenerator.v4(),
                                  'url': mediaUrl,
                                  'type': mediaType,
                                  'blur_hash': blurHash,
                                });
                              }
                            }
                            if (!mounted) return;
                            await Future.sync(
                              () => context.read<UserProfileBloc>().add(
                                    UserProfilePostCreateRequested(
                                      postId: postId,
                                      userId: user.id,
                                      caption: _captionController.text,
                                      media: media,
                                    ),
                                  ),
                            );
                            setState(() {
                              _busy = false;
                            });
                            if (mounted) {
                              if (context.canPop()) context.pop();
                              // _imagesBytes?.clear();
                              // _imagesFile?.clear();
                              _selectedFiles?.clear();
                              _captionController.clear();
                            }
                            openSnackbar(
                              const SnackbarMessage.success(
                                title: 'Successfully created post!',
                              ),
                            );
                          } catch (error, stackTrace) {
                            logE(error, stackTrace: stackTrace);
                            setState(() => _busy = false);
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
                    setState(() {
                      // _imagesBytes?.removeWhere((e) => e == bytes);
                      // _imagesFile?.removeAt(index);
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
                LocalImageAttachment(
                  bytes: bytes,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return ThumbnailError(
                      error: error,
                      stackTrace: stackTrace,
                      height: double.infinity,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    );
                  },
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Tappable(
                    onTap: () {
                      final index = imagesBytes.indexWhere((e) => e == bytes);
                      if (index == -1) return;
                      onImageDelete(bytes, index);
                    },
                    child: const Icon(
                      Icons.cancel,
                      size: 34,
                      color: Colors.white,
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
    if (busy) return AppButton.inProgress(scale: .5);
    return AppButton.outlined(
      onPressed: onPostCreate,
      text: 'Create',
    );
  }
}
