import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/feed/feed.dart';
import 'package:flutter_instagram_offline_first_clone/feed/post/video/video.dart';
import 'package:go_router/go_router.dart';
import 'package:powersync_repository/powersync_repository.dart';
import 'package:shared/shared.dart';

class FeedPageController extends ChangeNotifier {
  factory FeedPageController() => _internal;

  FeedPageController._();

  static final FeedPageController _internal = FeedPageController._();

  late ScrollController _nestedScrollController;
  late BuildContext _context;

  void init({
    required ScrollController nestedScrollController,
    required BuildContext context,
  }) {
    _nestedScrollController = nestedScrollController;
    _context = context;
  }

  bool _hasPlayedAnimation = false;
  double _animationValue = 0;

  bool get hasPlayedAnimation => _hasPlayedAnimation;
  set hasPlayedAnimation(bool value) {
    _hasPlayedAnimation = value;
    notifyListeners();
  }

  double get animationValue => _animationValue;
  set animationValue(double value) {
    _animationValue = value;
    notifyListeners();
  }

  void markAnimationAsUnseen() {
    _hasPlayedAnimation = false;
    _animationValue = 0;
    notifyListeners();
  }

  void scrollToTop() => _nestedScrollController.animateTo(
        0,
        duration: 250.ms,
        curve: Curves.ease,
      );

  Future<void> processPostMedia({
    required List<SelectedByte> selectedFiles,
    required String postId,
    required String caption,
    required bool pickVideo,
  }) async {
    final isReel =
        selectedFiles.length == 1 && selectedFiles.every((e) => !e.isThatImage);
    final navigateToReelPage = isReel;
    StatefulNavigationShell.of(_context)
        .goBranch(navigateToReelPage ? 3 : 0, initialLocation: true);
    if (pickVideo) {
      VideoPlayerInheritedWidget.of(_context).videoPlayerProvider.playReels();
    }

    late final postId = uuid.v4();

    void uploadPost({required List<Map<String, dynamic>> media}) =>
        _context.read<FeedBloc>().add(
              FeedPostCreateRequested(
                postId: postId,
                caption: caption,
                media: media,
              ),
            );

    late final storage = Supabase.instance.client.storage.from('posts');

    if (isReel) {
      try {
        final mediaPath = '$postId/video_0';

        final selectedFile = selectedFiles.first;
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
        final compressedVideoBytes = await PickImage().imageBytes(
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
            'media_id': uuid.v4(),
            'url': mediaUrl,
            'type': VideoMedia.identifier,
            'blur_hash': blurHash,
            'first_frame_url': firstFrameUrl,
          }
        ];
        uploadPost(media: media);
      } catch (error, stackTrace) {
        logE(
          'Failed to create reel!',
          error: error,
          stackTrace: stackTrace,
        );
      }
    } else {
      final media = <Map<String, dynamic>>[];
      for (var i = 0; i < selectedFiles.length; i++) {
        late final selectedByte = selectedFiles[i].selectedByte;
        late final selectedFile = selectedFiles[i].selectedFile;
        late final isVideo = selectedFile.isVideo;
        String blurHash;
        Uint8List? convertedBytes;
        if (isVideo) {
          convertedBytes = await VideoPlus.getVideoThumbnail(
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
        late final mediaExtension =
            selectedFile.path.split('.').last.toLowerCase();

        late final mediaPath = '$postId/${!isVideo ? 'image_$i' : 'video_$i'}';

        Uint8List bytes;
        if (isVideo) {
          try {
            final compressedVideo = await VideoPlus.compressVideo(
              selectedFile,
            );
            bytes = await PickImage().imageBytes(
              file: compressedVideo!.file!,
            );
          } catch (error, stackTrace) {
            logE(
              'Error compressing video',
              error: error,
              stackTrace: stackTrace,
            );
            bytes = selectedByte;
          }
        } else {
          bytes = selectedByte;
        }
        await storage.uploadBinary(
          mediaPath,
          bytes,
          fileOptions: FileOptions(
            contentType: '${!isVideo ? 'image' : 'video'}/$mediaExtension',
            cacheControl: '9000000',
          ),
        );
        final mediaUrl = storage.getPublicUrl(mediaPath);
        String? firstFrameUrl;
        if (convertedBytes != null) {
          late final firstFramePath = '$postId/video_first_frame_$i';
          await storage.uploadBinary(
            firstFramePath,
            convertedBytes,
            fileOptions: FileOptions(
              contentType: 'video/$mediaExtension',
              cacheControl: '9000000',
            ),
          );
          firstFrameUrl = storage.getPublicUrl(firstFramePath);
        }
        final mediaType =
            isVideo ? VideoMedia.identifier : ImageMedia.identifier;
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
      uploadPost(media: media);
    }
  }
}
