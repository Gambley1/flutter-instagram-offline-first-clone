import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/auth/components/login/cubit/login_cubit.dart';
import 'package:shared/shared.dart';

class PasswordTextField extends StatefulWidget {
  const PasswordTextField({
    super.key,
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  final _debouncer = Debouncer();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final cubit = context.read<LoginCubit>()..resetState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        cubit.onPasswordUnfocused();
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
    final passwordError = context.select<LoginCubit, String?>(
      (b) => b.state.passwordError,
    );
    final showPassword = context.select<LoginCubit, bool>(
      (b) => b.state.showPassword,
    );
    final isLoading = context.select<LoginCubit, bool>(
      (b) => b.state.status.isLoading,
    );
    return AppTextField(
      key: const ValueKey('loginPasswordTextField'),
      filled: true,
      border: outlinedBorder(
        borderSide: BorderSide.none,
        borderRadius: 4,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      focusNode: _focusNode,
      hintText: 'Password',
      enabled: !isLoading,
      obscureText: !showPassword,
      textInputType: TextInputType.visiblePassword,
      autofillHints: const [AutofillHints.password],
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => context.read<LoginCubit>().onSubmit(),
      onChanged: (v) => _debouncer.run(
        () => context.read<LoginCubit>().onPasswordChanged(v),
      ),
      errorText: passwordError,
      suffixIcon: Tappable(
        color: Colors.transparent,
        onTap: context.read<LoginCubit>().changePasswordVisibility,
        child: Icon(
          !showPassword ? Icons.visibility : Icons.visibility_off,
          color: context.customAdaptiveColor(light: Colors.white60),
        ),
      ),
    );
  }
}
