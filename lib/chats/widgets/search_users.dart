import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/stories/user_stories/user_stories.dart';
import 'package:go_router/go_router.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:search_repository/search_repository.dart';
import 'package:shared/shared.dart';
import 'package:user_repository/user_repository.dart';

class SearchUsers extends StatefulWidget {
  const SearchUsers({this.returnUser = false, super.key});

  final bool returnUser;

  @override
  State<SearchUsers> createState() => _SearchUsersState();
}

class _SearchUsersState extends State<SearchUsers> with SafeSetStateMixin {
  late TextEditingController _queryController;
  late Debouncer _debouncer;

  late ValueNotifier<List<User>> _users;

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController();
    _debouncer = Debouncer(milliseconds: 250);

    _users = ValueNotifier(<User>[]);
  }

  @override
  void dispose() {
    _queryController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchRepository = context.read<SearchRepository>();

    return AppScaffold(
      appBar: AppBar(
        title: AppTextField(
          textController: _queryController,
          onChanged: (query) {
            _queryController.text = query;
            _debouncer.run(() async {
              final users = await searchRepository.searchUsers(query: query);
              _users.value = users;
            });
          },
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: _users,
        builder: (context, users, _) {
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xxs,
                ),
                horizontalTitleGap: AppSpacing.md,
                onTap: () =>
                    context.pop(widget.returnUser ? user.toJson() : user.id),
                leading: UserStoriesAvatar(
                  author: user,
                  enableUnactiveBorder: false,
                  withAdaptiveBorder: false,
                  radius: 14,
                ),
                title: Text(user.displayFullName),
              );
            },
          );
        },
      ),
    );
  }
}
