import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/feed/feed.dart';
import 'package:go_router/go_router.dart';
import 'package:powersync_repository/powersync_repository.dart';
import 'package:shared/shared.dart';

class FeedPageController extends ChangeNotifier {
  factory FeedPageController() => _internal;

  FeedPageController._();

  static final FeedPageController _internal = FeedPageController._();

  late ScrollController nestedScrollController;
  late ScrollController feedScrollController;
  late BuildContext _context;

  void init({
    required ScrollController nestedController,
    required ScrollController feedController,
    required BuildContext context,
  }) {
    nestedScrollController = nestedController;
    feedScrollController = feedController;
    _context = context;
  }

  final _animationPlayed = ValueNotifier(false);

  final _animationValue = ValueNotifier<double>(0);

  bool get hasPlayedAnimation => _animationPlayed.value;

  double get animationValue => _animationValue.value;

  void setPlayedAnimation(double value) {
    if (_animationPlayed.value == true) return;

    _animationPlayed.value = true;
    _animationValue.value = value;
    notifyListeners();
  }

  void scrollToTop() => nestedScrollController.animateTo(
        0,
        duration: 250.ms,
        curve: Curves.ease,
      );

  Future<void> processPostMedia({
    required List<SelectedByte> selectedFiles,
    required String postId,
    required String caption,
    required bool isReel,
  }) async {
    final navigateToReelPage = isReel ||
        (selectedFiles.length == 1 &&
            selectedFiles.every((e) => !e.isThatImage));
    StatefulNavigationShell.of(_context)
        .goBranch(navigateToReelPage ? 3 : 0, initialLocation: true);
    void uploadPost({
      required String id,
      required List<Map<String, dynamic>> media,
    }) =>
        _context.read<FeedBloc>().add(
              FeedPostCreateRequested(
                postId: id,
                caption: caption,
                media: media,
              ),
            );
    if (isReel) {
      try {
        late final postId = uuid.v4();
        late final storage = Supabase.instance.client.storage.from('posts');

        late final mediaPath = '$postId/video_0';

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
        uploadPost(media: media, id: postId);
      } catch (error, stackTrace) {
        logE(
          'Failed to create reel!',
          error: error,
          stackTrace: stackTrace,
        );
      }
    } else {
      final storage = Supabase.instance.client.storage.from('posts');

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
      uploadPost(id: postId, media: media);
    }
  }
}
