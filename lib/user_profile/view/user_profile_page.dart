import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/user_profile/user_profile.dart';
import 'package:insta_blocks/insta_blocks.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:user_repository/user_repository.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({
    super.key,
    this.userId,
    this.isSponsored = false,
    this.promoBlockAction,
  });

  final String? userId;
  final bool isSponsored;
  final BlockAction? promoBlockAction;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserProfileBloc(
        postsRepository: context.read<PostsRepository>(),
        userRepository: context.read<UserRepository>(),
        userId: userId,
      ),
      child: UserProfileView(
        userId: userId,
        isSponsored: isSponsored,
        promoBlockAction: promoBlockAction,
      ),
    );
  }
}
