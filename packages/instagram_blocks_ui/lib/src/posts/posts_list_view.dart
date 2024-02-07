import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared/shared.dart';

typedef IndexedPostBuilder = Widget Function(
  BuildContext context,
  int index,
  PostBlock block,
);

class PostsListView extends StatelessWidget {
  const PostsListView({
    required this.blocks,
    required this.postBuilder,
    this.withLoading = true,
    this.loading,
    this.withItemController = false,
    this.itemScrollController,
    this.index,
    super.key,
    this.scrollOffsetController,
    this.itemPositionsListener,
    this.scrollOffsetListener,
  });

  final List<PostBlock>? blocks;
  final IndexedPostBuilder postBuilder;
  final bool withLoading;
  final bool? loading;
  final bool withItemController;
  final ItemScrollController? itemScrollController;
  final ScrollOffsetController? scrollOffsetController;
  final ItemPositionsListener? itemPositionsListener;
  final ScrollOffsetListener? scrollOffsetListener;
  final int? index;

  @override
  Widget build(BuildContext context) {
    if (withLoading && (loading ?? false)) return const _LoadingPosts();
    if (blocks == null || (blocks?.isEmpty ?? true)) return const _EmptyPosts();

    if (withItemController) {
      return _PostsItemController(
        blocks: blocks!,
        postBuilder: postBuilder,
        index: index!,
        itemScrollController: itemScrollController!,
        itemPositionsListener: itemPositionsListener!,
        scrollOffsetController: scrollOffsetController!,
        scrollOffsetListener: scrollOffsetListener!,
      );
    }
    return SliverList.builder(
      itemBuilder: (context, index) {
        final block = blocks![index];

        return postBuilder.call(context, index, block);
      },
      itemCount: blocks!.length,
    );
  }
}

class _PostsItemController extends StatefulWidget {
  const _PostsItemController({
    required this.blocks,
    required this.postBuilder,
    required this.itemScrollController,
    required this.scrollOffsetController,
    required this.itemPositionsListener,
    required this.scrollOffsetListener,
    required this.index,
  });

  final List<PostBlock> blocks;
  final IndexedPostBuilder postBuilder;
  final ItemScrollController itemScrollController;
  final ScrollOffsetController scrollOffsetController;
  final ItemPositionsListener itemPositionsListener;
  final ScrollOffsetListener scrollOffsetListener;
  final int index;

  @override
  State<_PostsItemController> createState() => _PostsItemControllerState();
}

class _PostsItemControllerState extends State<_PostsItemController> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      widget.itemScrollController.jumpTo(index: widget.index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: ScrollablePositionedList.builder(
        itemScrollController: widget.itemScrollController,
        itemPositionsListener: widget.itemPositionsListener,
        scrollOffsetController: widget.scrollOffsetController,
        scrollOffsetListener: widget.scrollOffsetListener,
        itemBuilder: (context, index) {
          final block = widget.blocks[index];

          return widget.postBuilder.call(context, index, block);
        },
        itemCount: widget.blocks.length,
      ),
    );
  }
}

class _EmptyPosts extends StatelessWidget {
  const _EmptyPosts();

  static const _noPostsText = 'No Posts';

  @override
  Widget build(BuildContext context) {
    const noPostsWidget = Center(child: Text(_noPostsText));

    return const SliverFillRemaining(child: noPostsWidget);
  }
}

class _LoadingPosts extends StatelessWidget {
  const _LoadingPosts();

  @override
  Widget build(BuildContext context) {
    const loadingWidget = Center(child: CircularProgressIndicator());

    return const SliverFillRemaining(child: loadingWidget);
  }
}
