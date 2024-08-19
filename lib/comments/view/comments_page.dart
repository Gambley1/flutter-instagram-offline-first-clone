import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/comments/comment/comment.dart';
import 'package:flutter_instagram_offline_first_clone/comments/comments.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:shared/shared.dart';

class CommentsPage extends StatefulWidget {
  const CommentsPage({
    required this.post,
    required this.scrollController,
    required this.draggableScrollController,
    super.key,
  });

  final PostBlock post;
  final ScrollController scrollController;
  final DraggableScrollableController draggableScrollController;

  static CommentInheritedWidget of(BuildContext context) {
    final provider =
        context.getInheritedWidgetOfExactType<CommentInheritedWidget>();
    assert(provider != null, 'No CommentInheritedWidget found in context!');
    return provider!;
  }

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  late TextEditingController _commentTextController;
  late FocusNode _commentFocusNode;

  late CommentInputController _commentInputController;

  @override
  void initState() {
    super.initState();
    _commentTextController = TextEditingController();
    _commentFocusNode = FocusNode()..addListener(_commentFocusNodeListener);

    _commentInputController = CommentInputController()
      ..init(
        commentFocusNode: _commentFocusNode,
        commentTextController: _commentTextController,
      );
  }

  void _commentFocusNodeListener() {
    if (_commentFocusNode.hasFocus) {
      if (!widget.draggableScrollController.isAttached) return;
      if (widget.draggableScrollController.size == 1.0) return;
      widget.draggableScrollController.animateTo(
        1,
        duration: 250.ms,
        curve: Curves.ease,
      );
    }
  }

  @override
  void dispose() {
    _commentInputController
      ..commentFocusNode
      ..removeListener(_commentFocusNodeListener)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CommentsBloc(
        postId: widget.post.id,
        postsRepository: context.read<PostsRepository>(),
      )..add(const CommentsSubscriptionRequested()),
      child: CommentInheritedWidget(
        commentInputController: _commentInputController,
        child: CommentsView(
          post: widget.post,
          scrollController: widget.scrollController,
          scrollableSheetController: widget.draggableScrollController,
        ),
      ),
    );
  }
}

class CommentsView extends StatelessWidget {
  const CommentsView({
    required this.post,
    required this.scrollController,
    required this.scrollableSheetController,
    super.key,
  });

  final PostBlock post;
  final ScrollController scrollController;
  final DraggableScrollableController scrollableSheetController;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = context.customReversedAdaptiveColor(
      dark: AppColors.background,
      light: AppColors.white,
    );

    return AppScaffold(
      releaseFocus: true,
      resizeToAvoidBottomInset: true,
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: backgroundColor,
        surfaceTintColor: backgroundColor,
        centerTitle: true,
        toolbarHeight: 24,
        title: Text(
          context.l10n.commentsText,
          style: context.titleLarge?.apply(color: AppColors.grey),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromRadius(AppSpacing.md),
          child: SizedBox.shrink(),
        ),
      ),
      bottomNavigationBar: CommentTextField(
        postId: post.id,
        controller: scrollableSheetController,
      ),
      body: CommentsListView(
        post: post,
        scrollController: scrollController,
      ),
    );
  }
}

class CommentsListView extends StatelessWidget {
  const CommentsListView({
    required this.post,
    required this.scrollController,
    super.key,
  });

  final PostBlock post;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final comments = context.select((CommentsBloc bloc) => bloc.state.comments);

    return CustomScrollView(
      cacheExtent: 2760,
      controller: scrollController,
      slivers: [
        if (comments.isNotEmpty)
          SliverList.builder(
            itemCount: comments.length,
            itemBuilder: (context, index) {
              final comment = comments[index];

              return CommentView(comment: comment, post: post);
            },
          )
        else
          SliverFillRemaining(
            child: Center(
              child: Text(
                context.l10n.noCommentsText,
                style: context.headlineSmall,
              ),
            ),
          ),
      ],
    );
  }
}
