import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_instagram_offline_first_clone/feed/feed.dart'
    show PostX;
import 'package:posts_repository/posts_repository.dart';
import 'package:shared/shared.dart';

part 'timeline_event.dart';
part 'timeline_state.dart';

class TimelineBloc extends Bloc<TimelineEvent, TimelineState> {
  TimelineBloc({
    required PostsRepository postsRepository,
  })  : _postsRepository = postsRepository,
        super(const TimelineState.intital()) {
    on<TimelinePageRequested>(
      _onTimelinePageRequested,
      transformer: throttleDroppable(),
    );
    on<TimelineRefreshRequested>(
      _onTimelineRefreshRequested,
      transformer: throttleDroppable(duration: 550.ms),
    );
  }

  final PostsRepository _postsRepository;

  static const _pageSize = 20;

  Future<void> _onTimelinePageRequested(
    TimelinePageRequested event,
    Emitter<TimelineState> emit,
  ) async {
    emit(state.copyWith(status: TimelineStatus.populated));
    try {
      final currentPage = event.page ?? state.timeline.page;

      final posts = await _postsRepository.getPage(
        limit: _pageSize,
        offset: _pageSize * currentPage,
      );

      final newPage = currentPage + 1;

      final hasMore = posts.length >= _pageSize;

      final blocks = <InstaBlock>[];
      for (final post in posts) {
        final block = post.toPostSmallBlock;
        blocks.add(block);
      }

      final timeline = state.timeline.copyWith(
        page: newPage,
        hasMore: hasMore,
        feed: state.timeline.feed.copyWith(
          blocks: [...state.timeline.feed.blocks, ...blocks],
          totalBlocks: state.timeline.feed.totalBlocks + blocks.length,
        ),
      );

      emit(
        state.copyWith(status: TimelineStatus.populated, timeline: timeline),
      );
    } catch (error, stackTrace) {
      emit(state.copyWith(status: TimelineStatus.failure));
      addError(error, stackTrace);
      logE(
        'Failed to request timeline page: ${event.page}',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _onTimelineRefreshRequested(
    TimelineRefreshRequested event,
    Emitter<TimelineState> emit,
  ) async {
    emit(state.copyWith(status: TimelineStatus.loading));
    try {
      const currentPage = 0;

      final posts = await _postsRepository.getPage(
        limit: _pageSize,
        offset: _pageSize * currentPage,
      );

      const newPage = currentPage + 1;

      final hasMore = posts.length >= _pageSize;

      final blocks = <InstaBlock>[];
      for (final post in posts) {
        final block = post.toPostSmallBlock;
        blocks.add(block);
      }

      final timeline = state.timeline.copyWith(
        page: newPage,
        hasMore: hasMore,
        feed: state.timeline.feed.copyWith(
          blocks: blocks,
          totalBlocks: blocks.length,
        ),
      );

      emit(
        state.copyWith(status: TimelineStatus.populated, timeline: timeline),
      );
    } catch (error, stackTrace) {
      emit(state.copyWith(status: TimelineStatus.failure));
      addError(error, stackTrace);
      logE(
        'Failed to refresh timeline.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
