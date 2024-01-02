import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/user_profile/user_profile.dart';

class UserProfileFollowers extends StatelessWidget {
  const UserProfileFollowers({super.key});

  @override
  Widget build(BuildContext context) {
    final subscribers =
        context.select((UserProfileBloc b) => b.state.followers);

    return CustomScrollView(
      slivers: [
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        SliverList.builder(
          itemCount: subscribers.length,
          itemBuilder: (context, index) {
            final subscriber = subscribers[index];
            final name = subscriber.username;
            return Text(name ?? '');
          },
        ),
      ],
    );
  }
}
