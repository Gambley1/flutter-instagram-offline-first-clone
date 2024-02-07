import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_instagram_offline_first_clone/feed/feed.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:shared/shared.dart';

part 'reels_event.dart';
part 'reels_state.dart';

class ReelsBloc extends Bloc<ReelsEvent, ReelsState> {
  ReelsBloc({required PostsRepository postsRepository})
      : _postsRepository = postsRepository,
        super(const ReelsState.intital()) {
    on<ReelsPageRequested>(
      _onReelsPageRequested,
      transformer: throttleDroppable(),
    );
    on<ReelsCreateReelRequested>(_onReelsCreateReelRequested);
  }

  final PostsRepository _postsRepository;

  Future<void> _onReelsPageRequested(
    ReelsPageRequested event,
    Emitter<ReelsState> emit,
  ) async {
    emit(state.copyWith(status: ReelsStatus.loading));
    try {
      final posts =
          await _postsRepository.getPage(offset: 0, limit: 10, onlyReels: true);
      final instaBlocks = <InstaBlock>[];

      for (final post in posts
          .where((element) => element.media.firstOrNull is VideoMedia?)) {
        final reel = post.toPostReelBlock;
        instaBlocks.add(reel);
      }
      emit(state.copyWith(blocks: instaBlocks));
    } catch (error, stackTrace) {
      logE('Reels fetching failed.', error: error, stackTrace: stackTrace);
      addError(error, stackTrace);
      emit(state.copyWith(status: ReelsStatus.failure));
    }
  }

  Future<void> _onReelsCreateReelRequested(
    ReelsCreateReelRequested event,
    Emitter<ReelsState> emit,
  ) =>
      _postsRepository.createPost(
        id: event.postId,
        userId: event.userId,
        caption: event.caption,
        media: json.encode(event.media),
      );
}
