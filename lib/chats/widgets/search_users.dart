import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
import 'package:flutter_instagram_offline_first_clone/stories/user_stories/user_stories.dart';
import 'package:go_router/go_router.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
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
  final _debouncer = Debouncer(milliseconds: 250);

  var _users = <User>[];

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController();
    context
        .read<AppBloc>()
        .searchUsers()
        .then((users) => safeSetState(() => _users = users));
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: AppTextField(
          textController: _queryController,
          onChanged: (query) => _debouncer.run(() async {
            safeSetState(() => _queryController.text = query);
            final users =
                await context.read<AppBloc>().searchUsers(query: query);
            safeSetState(() => _users = users);
          }),
        ),
      ),
      body: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
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
      ),
    );
  }
}
