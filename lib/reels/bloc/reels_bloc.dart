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
    on<ReelsUpdateRequested>(_onReelsUpdateRequested);
    on<ReelsCreateReelRequested>(_onReelsCreateReelRequested);
  }

  final PostsRepository _postsRepository;

  Future<void> _onReelsPageRequested(
    ReelsPageRequested event,
    Emitter<ReelsState> emit,
  ) async {
    emit(state.loading());
    try {
      final posts =
          await _postsRepository.getPage(offset: 0, limit: 10, onlyReels: true);
      final instaBlocks = <PostBlock>[];

      for (final post in posts.where((element) => element.media.isReel)) {
        final reel = post.toPostReelBlock;
        instaBlocks.add(reel);
      }
      emit(state.populated(blocks: instaBlocks));
    } catch (error, stackTrace) {
      logE(
        '[ReelsBloc] Reels fetching failed.',
        error: error,
        stackTrace: stackTrace,
      );
      addError(error, stackTrace);
      emit(state.failure());
    }
  }

  Future<void> _onReelsUpdateRequested(
    ReelsUpdateRequested event,
    Emitter<ReelsState> emit,
  ) async {
    emit(state.loading());
    try {
      final blocks = _updateBlocks(
        blocks: state.blocks.whereType<PostBlock>().toList(),
        newBlock: event.block,
        isDelete: event.isDelete,
        isCreate: event.isCreate,
      );
      emit(state.populated(blocks: blocks));
    } catch (error, stackTrace) {
      logE(
        '[ReelsBloc] Failed to update reels.',
        error: error,
        stackTrace: stackTrace,
      );
      addError(error, stackTrace);
      emit(state.failure());
    }
  }

  Future<void> _onReelsCreateReelRequested(
    ReelsCreateReelRequested event,
    Emitter<ReelsState> emit,
  ) async {
    emit(state.loading());
    try {
      final newBlock = await _postsRepository.createPost(
        id: event.id,
        userId: event.userId,
        caption: event.caption,
        media: jsonEncode(event.media),
      );
      if (newBlock == null) {
        emit(state.populated());
        return;
      }
      add(
        ReelsUpdateRequested(
          block: newBlock.toPostReelBlock,
          isCreate: true,
        ),
      );
    } catch (error, stackTrace) {
      logE(
        '[ReelsBloc] Failed to create reel.',
        error: error,
        stackTrace: stackTrace,
      );
      addError(error, stackTrace);
      emit(state.failure());
    }
  }

  List<PostBlock> _updateBlocks({
    required List<PostBlock> blocks,
    required PostBlock newBlock,
    required bool isDelete,
    required bool isCreate,
  }) =>
      blocks.updateWith<PostReelBlock>(
        newItem: newBlock,
        findCallback: (block, newBlock) => block.id == newBlock.id,
        onUpdate: (block, newBlock) =>
            block.copyWith(caption: newBlock.caption),
        isDelete: isDelete,
        insertIfNotFound: isCreate,
      );
}
