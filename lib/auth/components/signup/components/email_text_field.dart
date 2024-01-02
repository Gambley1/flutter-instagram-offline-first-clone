import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/auth/components/signup/cubit/signup_cubit.dart';
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
    final cubit = context.read<SignupCubit>();
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
    final isLoading =
        context.select<SignupCubit, bool>((c) => c.state.isLoading);
    final emailError =
        context.select<SignupCubit, String?>((c) => c.state.emailError);
    return AppTextField(
      filled: true,
      focusNode: _focusNode,
      hintText: 'Email',
      enabled: !isLoading,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      textInputType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.email],
      border: outlinedBorder(
        borderRadius: 4,
        borderSide: BorderSide.none,
      ),
      onChanged: (v) => _debouncer.run(
        () => context.read<SignupCubit>().onEmailChanged(v),
      ),
      errorText: emailError,
    );
  }
}
