import 'package:firebase_notifications_client/firebase_notifications_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/auth/components/signup/cubit/signup_cubit.dart';
import 'package:flutter_instagram_offline_first_clone/auth/components/signup/view/view.dart';
import 'package:user_repository/user_repository.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignupCubit(
        userRepository: context.read<UserRepository>(),
        notificationsClient: context.read<FirebaseNotificationsClient>(),
      ),
      child: const SignupView(),
    );
  }
}
