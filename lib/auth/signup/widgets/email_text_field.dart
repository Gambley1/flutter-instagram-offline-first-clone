import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/auth/signup/cubit/sign_up_cubit.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:shared/shared.dart';

class EmailTextField extends StatefulWidget {
  const EmailTextField({super.key});

  @override
  State<EmailTextField> createState() => _EmailTextFieldState();
}

class _EmailTextFieldState extends State<EmailTextField> {
  final _debouncer = Debouncer();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final cubit = context.read<SignUpCubit>();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        cubit.onEmailUnfocused();
      }
    });
  }

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context
        .select((SignUpCubit cubit) => cubit.state.submissionStatus.isLoading);
    final emailError =
        context.select((SignUpCubit cubit) => cubit.state.email.errorMessage);
    return AppTextField(
      filled: true,
      focusNode: _focusNode,
      hintText: context.l10n.emailText,
      enabled: !isLoading,
      textInputType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.email],
      onChanged: (v) => _debouncer.run(
        () => context.read<SignUpCubit>().onEmailChanged(v),
      ),
      errorText: emailError,
    );
  }
}
