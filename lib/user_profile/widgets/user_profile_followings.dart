import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/user_profile/user_profile.dart';

class UserProfileFollowings extends StatelessWidget {
  const UserProfileFollowings({super.key});

  @override
  Widget build(BuildContext context) {
    final followings =
        context.select((UserProfileBloc b) => b.state.followings);

    return CustomScrollView(
      slivers: [
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        SliverList.builder(
          itemCount: followings.length,
          itemBuilder: (context, index) {
            final following = followings[index];
            final name = following.username;
            return Text(name ?? '');
          },
        ),
      ],
    );
  }
}
