import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

class UserProfileEdit extends StatelessWidget {
  const UserProfileEdit({super.key});

  @override
  Widget build(BuildContext context) {
    return const UserProfileEditView();
  }
}

class UserProfileEditView extends StatelessWidget {
  const UserProfileEditView({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(body: CustomScrollView());
  }
}
