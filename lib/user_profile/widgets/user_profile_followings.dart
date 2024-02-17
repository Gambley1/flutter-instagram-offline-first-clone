import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/user_profile/user_profile.dart';

class UserProfileFollowings extends StatefulWidget {
  const UserProfileFollowings({super.key});

  @override
  State<UserProfileFollowings> createState() => _UserProfileFollowingsState();
}

class _UserProfileFollowingsState extends State<UserProfileFollowings>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    context
        .read<UserProfileBloc>()
        .add(const UserProfileFetchFollowingsRequested());
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final followings =
        context.select((UserProfileBloc bloc) => bloc.state.followings);

    return CustomScrollView(
      cacheExtent: 2760,
      slivers: [
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        SliverList.builder(
          itemCount: followings.length,
          itemBuilder: (context, index) {
            final user = followings[index];
            return UserProfileListTile(user: user, follower: false);
          },
        ),
      ],
    );
  }
}
