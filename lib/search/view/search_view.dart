import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/stories/user_stories/view/view.dart';
import 'package:go_router/go_router.dart';
import 'package:search_repository/search_repository.dart';
import 'package:shared/shared.dart';
import 'package:user_repository/user_repository.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({this.withResult, super.key});

  final bool? withResult;

  @override
  Widget build(BuildContext context) {
    return SearchView(withResult: withResult ?? false);
  }
}

class SearchView extends StatelessWidget {
  const SearchView({required this.withResult, super.key});

  final bool withResult;

  @override
  Widget build(BuildContext context) {
    final users = ValueNotifier(<User>[]);

    return AppScaffold(
      appBar:
          SearcAppBar(onUsersSearch: (foundUsers) => users.value = foundUsers),
      body: ValueListenableBuilder(
        valueListenable: users,
        builder: (context, users, _) {
          return CustomScrollView(
            cacheExtent: 2760,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverList.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return ListTile(
                    leading: UserStoriesAvatar(
                      author: user,
                      withAdaptiveBorder: false,
                      enableUnactiveBorder: false,
                    ),
                    title: Text(user.displayUsername),
                    subtitle: Text(
                      user.displayFullName,
                      style: context.labelLarge?.copyWith(
                        fontWeight: AppFontWeight.medium,
                        color: AppColors.grey,
                      ),
                    ),
                    trailing: const Icon(Icons.keyboard_arrow_right),
                    onTap: () => withResult
                        ? context.pop(user.id)
                        : context.pushNamed(
                            'user_profile',
                            pathParameters: {'user_id': user.id},
                          ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class SearcAppBar extends StatefulWidget implements PreferredSizeWidget {
  const SearcAppBar({required this.onUsersSearch, super.key});

  final ValueSetter<List<User>> onUsersSearch;

  @override
  State<SearcAppBar> createState() => _SearcAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SearcAppBarState extends State<SearcAppBar> {
  late FocusNode _focusNode;
  late TextEditingController _searchController;

  late Debouncer _debouncer;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _searchController = TextEditingController();

    _debouncer = Debouncer();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: SearchInputField(
        active: false,
        readOnly: false,
        focusNode: _focusNode,
        textController: _searchController,
        onChanged: (query) {
          _debouncer.run(
            () async => widget.onUsersSearch.call(
              await context.read<SearchRepository>().searchUsers(query: query),
            ),
          );
        },
      ),
    );
  }
}

class SearchInputField extends StatelessWidget {
  const SearchInputField({
    required this.active,
    required this.readOnly,
    this.textController,
    this.focusNode,
    this.onChanged,
    super.key,
  });

  final TextEditingController? textController;
  final FocusNode? focusNode;
  final ValueSetter<String>? onChanged;
  final bool active;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    const activeColor = AppColors.white;
    const unactiveColor = AppColors.darkGrey;

    final search = AppTextField(
      textController: textController,
      focusNode: focusNode,
      filled: true,
      readOnly: readOnly,
      autofocus: !readOnly,
      onChanged: textController == null
          ? null
          : (query) {
              onChanged?.call(query);
            },
      constraints: const BoxConstraints.tightFor(height: 40),
      onTap: !readOnly ? null : () => context.pushNamed('search'),
      hintText: 'Search',
      prefixIcon:
          Icon(Icons.search, color: active ? activeColor : unactiveColor),
      suffixIcon: textController?.text.trim().isEmpty ?? true
          ? null
          : Icon(
              Icons.clear,
              color: active ? activeColor : unactiveColor,
            ),
      border: outlinedBorder(borderRadius: 14),
    );
    if (textController != null) {
      return AnimatedBuilder(
        animation: Listenable.merge([textController]),
        builder: (context, child) => search,
      );
    }

    return search;
  }
}
