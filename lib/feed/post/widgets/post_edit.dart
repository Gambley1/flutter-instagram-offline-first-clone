import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/feed/feed.dart';
import 'package:flutter_instagram_offline_first_clone/feed/post/bloc/post_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/feed/post/post.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:go_router/go_router.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:shared/shared.dart';
import 'package:user_repository/user_repository.dart';

class PostEditPage extends StatelessWidget {
  const PostEditPage({required this.post, super.key});

  final PostBlock post;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PostBloc(
        postId: post.id,
        postsRepository: context.read<PostsRepository>(),
        userRepository: context.read<UserRepository>(),
      ),
      child: PostEditView(post: post),
    );
  }
}

class PostEditView extends StatefulWidget {
  const PostEditView({required this.post, super.key});

  final PostBlock post;

  @override
  State<PostEditView> createState() => _PostEditViewState();
}

class _PostEditViewState extends State<PostEditView> {
  late TextEditingController _captionController;

  @override
  void initState() {
    super.initState();
    _captionController = TextEditingController(text: widget.post.caption);
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  void _onEditSubmitted(String value) {
    if (value == widget.post.caption) {
      context.pop();
    } else {
      context.read<PostBloc>().add(
            PostUpdateRequested(
              caption: value,
              onPostUpdated: (post) {
                context.read<FeedBloc>().add(FeedUpdateRequested(block: post));
                context.pop();
              },
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      releaseFocus: true,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        centerTitle: false,
        title: Text(context.l10n.editPostText),
        actions: [
          AnimatedBuilder(
            animation: _captionController,
            builder: (context, _) {
              return Tappable(
                onTap: () => _onEditSubmitted(_captionController.text),
                child: const Icon(
                  Icons.check,
                  color: AppColors.blue,
                  size: AppSize.iconSize,
                ),
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: constraints.maxWidth,
                minHeight: constraints.maxHeight,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PostMedia(
                    media: widget.post.media,
                    withLikeOverlay: false,
                    withInViewNotifier: false,
                    autoHideCurrentIndex: false,
                    mediaCarouselSettings: const MediaCarouselSettings.empty(
                      fit: BoxFit.cover,
                      viewportFraction: .9,
                    ),
                  ),
                  const Gap.v(AppSpacing.lg),
                  CaptionInputField(
                    captionController: _captionController,
                    caption: widget.post.caption,
                    onSubmitted: _onEditSubmitted,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class CaptionInputField extends StatefulWidget {
  const CaptionInputField({
    required this.captionController,
    required this.caption,
    required this.onSubmitted,
    super.key,
  });

  final TextEditingController captionController;
  final String caption;
  final ValueSetter<String> onSubmitted;

  @override
  State<CaptionInputField> createState() => _CaptionInputFieldState();
}

class _CaptionInputFieldState extends State<CaptionInputField> {
  late String _initialCaption;

  @override
  void initState() {
    super.initState();
    _initialCaption = widget.caption;
  }

  @override
  void didUpdateWidget(covariant CaptionInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.caption != _initialCaption) {
      setState(() => _initialCaption = widget.caption);
    }
  }

  String _effectiveValue(String? value) =>
      value ?? widget.captionController.text.trim();

  bool _equals(String? value) => _initialCaption == _effectiveValue(value);

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      border: InputBorder.none,
      textController: widget.captionController,
      contentPadding: EdgeInsets.zero,
      textInputType: TextInputType.text,
      textInputAction: TextInputAction.newline,
      textCapitalization: TextCapitalization.sentences,
      hintText: context.l10n.writeCaptionText,
      onFieldSubmitted: (value) =>
          _equals(value) ? null : widget.onSubmitted(_effectiveValue(value)),
    );
  }
}
