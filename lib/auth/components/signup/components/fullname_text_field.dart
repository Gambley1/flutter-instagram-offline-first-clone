import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/auth/components/signup/cubit/signup_cubit.dart';
import 'package:shared/shared.dart';

class FullNameTextField extends StatefulWidget {
  const FullNameTextField({super.key});

  @override
  State<FullNameTextField> createState() => _FullNameTextFieldState();
}

class _FullNameTextFieldState extends State<FullNameTextField> {
  final _debouncer = Debouncer();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final cubit = context.read<SignupCubit>();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        cubit.onFullNameUnfocused();
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
    final fullNameError =
        context.select<SignupCubit, String?>((c) => c.state.fullNameError);
    return AppTextField(
      filled: true,
      focusNode: _focusNode,
      hintText: 'Full name',
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.words,
      // textInputType: TextInputType.name,
      autofillHints: const [AutofillHints.givenName],
      enabled: !isLoading,
      border: outlinedBorder(
        borderRadius: 4,
        borderSide: BorderSide.none,
      ),
      onChanged: (v) => _debouncer.run(
        () => context.read<SignupCubit>().onFullNameChanged(v),
      ),
      errorText: fullNameError,
      errorMaxLines: 3,
    );
  }
}
