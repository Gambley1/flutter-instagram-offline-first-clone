import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
import 'package:flutter_instagram_offline_first_clone/feed/post/post.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:flutter_instagram_offline_first_clone/user_profile/user_profile.dart';
import 'package:go_router/go_router.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:search_repository/search_repository.dart';
import 'package:shared/shared.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:user_repository/user_repository.dart';

class SharePost extends StatelessWidget {
  const SharePost({
    required this.block,
    required this.scrollController,
    required this.draggableScrollController,
    super.key,
  });

  final PostBlock block;
  final ScrollController scrollController;
  final DraggableScrollableController draggableScrollController;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => UserProfileBloc(
            userRepository: context.read<UserRepository>(),
            postsRepository: context.read<PostsRepository>(),
          )
            ..add(const UserProfileFetchFollowersRequested())
            ..add(const UserProfileFetchFollowingsRequested()),
        ),
        BlocProvider(
          create: (context) => PostBloc(
            postId: block.id,
            postsRepository: context.read<PostsRepository>(),
            userRepository: context.read<UserRepository>(),
          ),
        ),
      ],
      child: SharePostView(
        block: block,
        scrollController: scrollController,
        draggableScrollController: draggableScrollController,
      ),
    );
  }
}

class SharePostView extends StatefulWidget {
  const SharePostView({
    required this.block,
    required this.scrollController,
    required this.draggableScrollController,
    super.key,
  });

  final PostBlock block;
  final ScrollController scrollController;
  final DraggableScrollableController draggableScrollController;

  @override
  State<SharePostView> createState() => _SharPostState();
}

class _SharPostState extends State<SharePostView> with SafeSetStateMixin {
  late TextEditingController _searchController;
  late FocusNode _focusNode;

  final _selectedUsers = ValueNotifier(<User>{});
  final _foundUsers = ValueNotifier(<User>{});

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _focusNode = FocusNode()..addListener(_focusListener);
  }

  void _focusListener() {
    if (_focusNode.hasFocus) {
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
    _searchController.dispose();
    _focusNode
      ..removeListener(_focusListener)
      ..dispose();
    _selectedUsers.dispose();
    _foundUsers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final followers =
        context.select((UserProfileBloc bloc) => bloc.state.followers);
    final followings =
        context.select((UserProfileBloc bloc) => bloc.state.followings);

    final followersAndFollowings = {...followers, ...followings};
    final backgroundColor = context.customReversedAdaptiveColor(
      dark: AppColors.background,
      light: AppColors.white,
    );

    return Theme(
      data: context.theme.copyWith(
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: AppBarTheme(
          backgroundColor: backgroundColor,
          surfaceTintColor: backgroundColor,
        ),
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: backgroundColor,
          surfaceTintColor: backgroundColor,
        ),
      ),
      child: AppScaffold(
        releaseFocus: true,
        resizeToAvoidBottomInset: true,
        appBar: SearchAppBar(
          followersAndFollowings: followersAndFollowings,
          searchController: _searchController,
          focusNode: _focusNode,
          onUsersFound: (users) => _foundUsers.value = users,
        ),
        bottomNavigationBar: _selectedUsers.value.isEmpty
            ? null
            : SharePostButton(
                block: widget.block,
                selectedUsers: _selectedUsers.value.toList(),
                draggableScrollableController: widget.draggableScrollController,
              ),
        body: AnimatedBuilder(
          animation: Listenable.merge([_foundUsers, _selectedUsers]),
          builder: (context, _) {
            return UsersListView(
              users:
                  {..._selectedUsers.value, ...followersAndFollowings}.toList(),
              foundUsers: _foundUsers.value.toList(),
              scrollController: widget.scrollController,
              draggableScrollController: widget.draggableScrollController,
              selectedUsers: _selectedUsers.value.toList(),
              onUserSelected: (user, {clearQuery}) => safeSetState(() {
                if (clearQuery ?? false) {
                  _searchController.clear();
                  _foundUsers.value.clear();
                }
                if (_selectedUsers.value.contains(user)) {
                  _selectedUsers.value.remove(user);
                } else {
                  _selectedUsers.value.add(user);
                }
              }),
            );
          },
        ),
      ),
    );
  }
}

class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SearchAppBar({
    required this.followersAndFollowings,
    required this.searchController,
    required this.focusNode,
    required this.onUsersFound,
    super.key,
  });

  final Set<User> followersAndFollowings;
  final TextEditingController searchController;
  final FocusNode focusNode;
  final ValueSetter<Set<User>> onUsersFound;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: UserSearchField(
        users: followersAndFollowings.toList(),
        searchController: searchController,
        focusNode: focusNode,
        onUsersFound: (users, query) {
          final existedUsers = query.trim().isEmpty
              ? <User>[]
              : followersAndFollowings
                  .where(
                    (user) => user.displayUsername
                        .toLowerCase()
                        .trim()
                        .contains(query.toLowerCase().trim()),
                  )
                  .toList();
          if (existedUsers.isNotEmpty) {
            final foundUsers = <User>[];
            for (final user in users) {
              if (existedUsers.any((existed) => existed.id == user.id)) {
                continue;
              }
              foundUsers.add(user);
            }
            onUsersFound.call({...existedUsers, ...foundUsers});
          } else {
            onUsersFound.call({...users});
          }
        },
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class SharePostButton extends StatefulWidget {
  const SharePostButton({
    required this.block,
    required this.selectedUsers,
    required this.draggableScrollableController,
    super.key,
  });

  final PostBlock block;
  final List<User> selectedUsers;
  final DraggableScrollableController draggableScrollableController;

  @override
  State<SharePostButton> createState() => _SharePostButtonState();
}

class _SharePostButtonState extends State<SharePostButton> {
  late FocusNode _focusNode;
  late TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_focusListener);
    _messageController = TextEditingController();
  }

  void _focusListener() {
    if (_focusNode.hasFocus) {
      if (widget.draggableScrollableController.isAttached) {
        widget.draggableScrollableController
            .animateTo(1, duration: 150.ms, curve: Curves.ease);
      }
    }
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_focusListener)
      ..dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _onPostShareTap() async {
    final user = context.read<AppBloc>().state.user;
    final sender = PostAuthor(
      id: user.id,
      avatarUrl: user.avatarUrl ?? '',
      username: user.displayUsername,
    );
    void pop() => context.pop();

    toggleLoadingIndeterminate();
    final postShareFutures = widget.selectedUsers.map(
      (receiver) => Future.microtask(
        () => context.read<PostBloc>().add(
              PostShareRequested(
                sender: user,
                receiver: receiver,
                postAuthor: widget.block.author,
                sharedPostMessage: Message(sender: sender),
                message: _messageController.text.trim().isEmpty
                    ? null
                    : Message(
                        message: _messageController.text,
                        sender: sender,
                      ),
              ),
            ),
      ),
    );
    try {
      await Future.wait(postShareFutures);
      pop.call();
      openSnackbar(
        const SnackbarMessage.success(
          title: 'Successfully shared post!',
        ),
      );
      toggleLoadingIndeterminate(enable: false);
    } catch (error, stackTrace) {
      logE(
        'Failed to share post.',
        error: error,
        stackTrace: stackTrace,
      );
      openSnackbar(
        const SnackbarMessage.error(
          title: 'Failed to share post.',
        ),
      );
      toggleLoadingIndeterminate(enable: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.viewInsets.bottom),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const AppDivider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: AppTextField(
                focusNode: _focusNode,
                textController: _messageController,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                filled: false,
                textInputType: TextInputType.text,
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.sentences,
                hintText: context.l10n.sharePostCaptionHintText,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                bottom: AppSpacing.md,
              ),
              child: Tappable(
                onTap: _onPostShareTap,
                color: AppColors.blue,
                borderRadius: 6,
                child: Align(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md,
                    ),
                    child: Text(
                      widget.selectedUsers.length == 1
                          ? context.l10n.sendText
                          : context.l10n.sendSeparatelyText,
                      style: context.labelLarge?.apply(color: AppColors.white),
                    ),
                  ),
                ),
              ),
            ),
          ].spacerBetween(height: AppSpacing.md),
        ),
      ),
    );
  }
}

class UserSearchField extends StatefulWidget {
  const UserSearchField({
    required this.users,
    required this.searchController,
    required this.focusNode,
    required this.onUsersFound,
    super.key,
  });

  final List<User> users;
  final TextEditingController searchController;
  final FocusNode focusNode;
  final void Function(List<User> users, String query) onUsersFound;

  @override
  State<UserSearchField> createState() => _UserSearchFieldState();
}

class _UserSearchFieldState extends State<UserSearchField> {
  late Debouncer _debouncer;

  final _inactiveIconColor = AppColors.grey;
  final _activeIconColor = AppColors.white;

  late final _iconColor = ValueNotifier(_inactiveIconColor);

  @override
  void initState() {
    super.initState();
    _debouncer = Debouncer();

    widget.focusNode.addListener(_focusListener);
  }

  void _focusListener() {
    if (widget.focusNode.hasFocus) {
      _iconColor.value = _activeIconColor;
    } else {
      _iconColor.value = _inactiveIconColor;
    }
  }

  void _noUsersFound() => widget.onUsersFound.call([], '');

  @override
  void dispose() {
    widget.focusNode.removeListener(_focusListener);
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchRepository = context.read<SearchRepository>();
    final searchController = widget.searchController;

    return AnimatedBuilder(
      animation: Listenable.merge([_iconColor, searchController]),
      builder: (context, _) {
        return AppTextField(
          textController: searchController,
          focusNode: widget.focusNode,
          onChanged: (query) => _debouncer.run(() async {
            if (query.trim().isEmpty) {
              _noUsersFound();
              return;
            }
            final users = await searchRepository.searchUsers(query: query);
            widget.onUsersFound.call(users, query);
          }),
          filled: true,
          hintText: context.l10n.searchText,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
          ),
          prefixIcon: Icon(Icons.search, color: _iconColor.value),
          suffixIcon: searchController.text.trim().isEmpty
              ? null
              : Tappable(
                  onTap: () {
                    searchController.clear();
                    _noUsersFound();
                  },
                  child: Icon(Icons.clear, color: _iconColor.value),
                ),
          border: outlinedBorder(borderRadius: 10),
        );
      },
    );
  }
}

class UsersListView extends StatelessWidget {
  const UsersListView({
    required this.users,
    required this.foundUsers,
    required this.scrollController,
    required this.draggableScrollController,
    required this.selectedUsers,
    required this.onUserSelected,
    super.key,
  });

  final List<User> users;
  final List<User> foundUsers;
  final ScrollController scrollController;
  final DraggableScrollableController draggableScrollController;
  final List<User> selectedUsers;
  final void Function(User user, {bool? clearQuery}) onUserSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      child: CustomScrollView(
        controller: scrollController,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverAnimatedSwitcher(
            duration: 150.ms,
            child: foundUsers.isEmpty
                ? SliverGrid.builder(
                    itemCount: users.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisExtent: 160,
                      crossAxisSpacing: AppSpacing.xlg,
                      mainAxisSpacing: AppSpacing.lg,
                    ),
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return Tappable(
                        onTap: () => onUserSelected.call(user),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                UserProfileAvatar(
                                  avatarUrl: user.avatarUrl,
                                  enableBorder: false,
                                ),
                                if (selectedUsers.contains(user))
                                  Positioned(
                                    right: 1,
                                    bottom: 1,
                                    child: Container(
                                      height: 32,
                                      width: 32,
                                      decoration: BoxDecoration(
                                        color: AppColors.blue,
                                        shape: BoxShape.circle,
                                        border: Border.all(width: 2),
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        size: 22,
                                        color: AppColors.black,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              user.displayFullName,
                              style: context.bodyMedium,
                              textAlign: TextAlign.center,
                              maxLines: 3,
                            ),
                          ],
                        ),
                      );
                    },
                  )
                : SliverList.builder(
                    itemCount: foundUsers.length,
                    itemBuilder: (context, index) {
                      final user = foundUsers[index];
                      final isSelected = selectedUsers.contains(user);

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        horizontalTitleGap: AppSpacing.lg,
                        visualDensity: VisualDensity.comfortable,
                        onTap: () =>
                            onUserSelected.call(user, clearQuery: true),
                        leading: UserProfileAvatar(
                          avatarUrl: user.avatarUrl,
                          isLarge: false,
                        ),
                        title: Text(
                          user.displayFullName,
                          style: context.bodyLarge,
                        ),
                        subtitle: Text(
                          user.displayUsername,
                          style:
                              context.bodyLarge?.apply(color: AppColors.grey),
                        ),
                        trailing: Checkbox.adaptive(
                          value: isSelected,
                          shape: const CircleBorder(),
                          onChanged: (value) {},
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
