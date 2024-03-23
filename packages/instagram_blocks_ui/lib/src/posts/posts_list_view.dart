import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
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
    if (withLoading && (loading ?? false)) return const LoadingPosts();
    if (blocks == null || (blocks?.isEmpty ?? true)) return const EmptyPosts();

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

class EmptyPosts extends StatelessWidget {
  const EmptyPosts({
    this.text,
    this.icon = Icons.camera_alt_outlined,
    this.child,
    this.isSliver = true,
    super.key,
  });

  final String? text;
  final IconData icon;
  final Widget? child;
  final bool isSliver;

  Widget empty(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox.square(
            dimension: 92,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: context.adaptiveColor, width: 2),
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: FittedBox(child: Icon(icon)),
              ),
            ),
          ),
          Text(
            text ?? BlockSettings().postTextDelegate.noPostsText,
            style: context.headlineSmall,
          ),
          if (child != null) child!,
        ].spacerBetween(height: AppSpacing.sm),
      );

  @override
  Widget build(BuildContext context) {
    return isSliver
        ? SliverFillRemaining(child: empty(context))
        : empty(context);
  }
}

class LoadingPosts extends StatelessWidget {
  const LoadingPosts({super.key});

  @override
  Widget build(BuildContext context) {
    const loadingWidget = Center(child: CircularProgressIndicator());

    return const SliverFillRemaining(child: loadingWidget);
  }
}
