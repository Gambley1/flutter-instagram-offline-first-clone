import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
import 'package:flutter_instagram_offline_first_clone/stories/view/view.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/shared.dart';
import 'package:user_repository/user_repository.dart';

class SearchUsers extends StatefulWidget {
  const SearchUsers({this.returnUser = false, super.key});

  final bool returnUser;

  @override
  State<SearchUsers> createState() => _SearchUsersState();
}

class _SearchUsersState extends State<SearchUsers> {
  late TextEditingController _queryController;
  final _debouncer = Debouncer(milliseconds: 450);

  var _users = <User>[];

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController();
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select((AppBloc bloc) => bloc.state.user);
    return AppScaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: AppTextField(
          textController: _queryController,
          onChanged: (val) => _debouncer.run(() async {
            setState(() => _queryController.text = val);
            final users = await context
                .read<AppBloc>()
                .searchUsers(query: val, userId: user.id);
            setState(() => _users = users);
          }),
        ),
      ),
      body: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return ListTile(
            contentPadding: EdgeInsets.zero,
            onTap: () =>
                context.pop(widget.returnUser ? user.toJson() : user.id),
            leading: UserStoriesAvatar(author: user),
            title: Text(user.fullName!),
          );
        },
      ),
    );
  }
}
