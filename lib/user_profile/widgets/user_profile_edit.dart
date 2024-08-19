import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/app/app.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:flutter_instagram_offline_first_clone/user_profile/user_profile.dart';
import 'package:go_router/go_router.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:shared/shared.dart';
import 'package:user_repository/user_repository.dart';

class UserProfileEdit extends StatelessWidget {
  const UserProfileEdit({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserProfileBloc(
        userRepository: context.read<UserRepository>(),
        postsRepository: context.read<PostsRepository>(),
      ),
      child: const UserProfileEditView(),
    );
  }
}

class UserProfileEditView extends StatefulWidget {
  const UserProfileEditView({super.key});

  @override
  State<UserProfileEditView> createState() => _UserProfileEditViewState();
}

class _UserProfileEditViewState extends State<UserProfileEditView> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select((AppBloc bloc) => bloc.state.user);

    return AppScaffold(
      releaseFocus: true,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 0,
        title: Text(context.l10n.editProfileText),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: AppConstrainedScrollView(
          withScrollBar: true,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            children: [
              UserProfileAvatar(
                avatarUrl: user.avatarUrl,
                onTapPickImage: true,
                tappableVariant: TappableVariant.scaled,
                scaleStrength: ScaleStrength.xxs,
                onImagePick: (imageUrl) {
                  context.read<UserProfileBloc>().add(
                        UserProfileUpdateRequested(avatarUrl: imageUrl),
                      );
                },
              ),
              const Gap.v(AppSpacing.md),
              Text(
                context.l10n.changePhotoText,
                style: context.bodyLarge?.apply(color: AppColors.blue),
              ),
              const Gap.v(AppSpacing.md),
              Column(
                children: <Widget>[
                  ProfileInfoInput(
                    value: user.fullName,
                    label: context.l10n.nameText,
                    description: context.l10n.fullNameEditDescription,
                    infoType: ProfileEditInfoType.fullName,
                  ),
                  ProfileInfoInput(
                    value: user.username,
                    label: context.l10n.usernameText,
                    description: context.l10n.usernameEditDescription(
                      user.username ?? '',
                    ),
                    infoType: ProfileEditInfoType.username,
                  ),
                  ProfileInfoInput(
                    value: '',
                    label: context.l10n.bioText,
                    infoType: ProfileEditInfoType.bio,
                    onTap: () {},
                  ),
                ].spacerBetween(height: AppSpacing.md),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileInfoInput extends StatefulWidget {
  const ProfileInfoInput({
    required this.value,
    required this.label,
    this.infoType,
    this.description,
    this.readOnly = true,
    this.autofocus = false,
    this.onTap,
    this.onFieldSubmitted,
    this.onChanged,
    this.inputType = TextInputType.name,
    this.textController,
    super.key,
  });

  final String? value;
  final String? description;
  final String label;
  final bool readOnly;
  final bool autofocus;
  final VoidCallback? onTap;
  final ValueSetter<String>? onChanged;
  final ValueSetter<String?>? onFieldSubmitted;
  final TextInputType inputType;
  final TextEditingController? textController;
  final ProfileEditInfoType? infoType;

  @override
  State<ProfileInfoInput> createState() => _ProfileInfoInputState();
}

class _ProfileInfoInputState extends State<ProfileInfoInput> {
  late TextEditingController _textController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _textController = (widget.textController?..text = widget.value ?? '') ??
        TextEditingController(text: widget.value);
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant ProfileInfoInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && widget.value != null) {
      _textController.text = widget.value!;
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField.underlineBorder(
      textController: _textController,
      focusNode: _focusNode,
      filled: false,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      textInputAction: TextInputAction.done,
      textInputType: widget.readOnly ? null : widget.inputType,
      autofillHints: const [AutofillHints.nickname],
      onFieldSubmitted: widget.onFieldSubmitted,
      maxLength: widget.readOnly
          ? null
          : widget.infoType == ProfileEditInfoType.fullName
              ? 40
              : 16,
      onTap: !widget.readOnly
          ? null
          : () => context.pushNamed(
                AppRoutes.editProfileInfo.name,
                pathParameters: {'label': widget.label},
                queryParameters: {
                  'title': widget.label,
                  'value': widget.value,
                  'description': widget.description,
                },
                extra: widget.infoType,
              ),
      labelText: widget.label,
      labelStyle: context.bodyLarge?.apply(color: AppColors.grey),
      contentPadding: EdgeInsets.zero,
      onChanged: widget.onChanged,
      floatingLabelBehaviour: FloatingLabelBehavior.auto,
    );
  }
}

enum ProfileEditInfoType { username, fullName, bio }

class ProfileInfoEditPage extends StatelessWidget {
  const ProfileInfoEditPage({
    required this.appBarTitle,
    required this.infoLabel,
    required this.infoType,
    super.key,
    this.description,
    this.infoValue,
  });

  final String appBarTitle;
  final String? description;
  final String? infoValue;
  final String infoLabel;
  final ProfileEditInfoType infoType;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserProfileBloc(
        userRepository: context.read<UserRepository>(),
        postsRepository: context.read<PostsRepository>(),
      ),
      child: ProfileInfoEditView(
        appBarTitle: appBarTitle,
        infoLabel: infoLabel,
        infoType: infoType,
        infoValue: infoValue,
        description: description,
      ),
    );
  }
}

class ProfileInfoEditView extends StatefulWidget {
  const ProfileInfoEditView({
    required this.appBarTitle,
    required this.infoValue,
    required this.infoLabel,
    required this.infoType,
    this.description,
    super.key,
  });

  final String appBarTitle;
  final String? description;
  final String? infoValue;
  final String infoLabel;
  final ProfileEditInfoType infoType;

  @override
  State<ProfileInfoEditView> createState() => _ProfileInfoEditViewState();
}

class _ProfileInfoEditViewState extends State<ProfileInfoEditView> {
  late ValueNotifier<String> _initialValue;
  late TextEditingController _valueController;

  late String _infoChangeType;

  @override
  void initState() {
    super.initState();
    _initialValue = ValueNotifier(widget.infoValue ?? '');
    _valueController = TextEditingController(text: widget.infoValue);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _infoChangeType = widget.infoType == ProfileEditInfoType.fullName
          ? context.l10n.nameText.toLowerCase()
          : context.l10n.usernameText.toLowerCase();
    });
  }

  @override
  void dispose() {
    _initialValue.dispose();
    _valueController.dispose();
    super.dispose();
  }

  void _confirmInfoEditing() {
    late VoidCallback fn;
    late final value = _valueController.text.trim();
    if (value.isEmpty) return;
    if (widget.infoType == ProfileEditInfoType.fullName) {
      fn = () => context.read<UserProfileBloc>().add(
            UserProfileUpdateRequested(fullName: value),
          );
    } else if (widget.infoType == ProfileEditInfoType.username) {
      fn = () => context.read<UserProfileBloc>().add(
            UserProfileUpdateRequested(username: value),
          );
    }
    context.confirmAction(
      fn: () {
        fn();
        context.pop();
      },
      title:
          context.l10n.profileInfoEditConfirmationText(value, _infoChangeType),
      content: context.l10n.profileInfoChangePeriodText(_infoChangeType, 14),
      yesText: context.l10n.changeText,
      noText: context.l10n.cancelText,
      yesTextStyle: context.labelLarge?.apply(color: AppColors.blue),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text(widget.appBarTitle),
        centerTitle: false,
        elevation: 0,
        actions: [
          AnimatedBuilder(
            animation: Listenable.merge([_initialValue, _valueController]),
            builder: (context, _) {
              final empty = _valueController.text.trim().isEmpty;

              return IconButton(
                icon: const Icon(Icons.check, size: AppSize.iconSize),
                onPressed: empty
                    ? null
                    : _valueController.text.trim() == _initialValue.value
                        ? () => context.pop()
                        : _confirmInfoEditing,
                color: AppColors.blue,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: AppConstrainedScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            children: <Widget>[
              ProfileInfoInput(
                autofocus: true,
                readOnly: false,
                value: widget.infoValue,
                label: widget.infoLabel,
                infoType: widget.infoType,
                textController: _valueController,
              ),
              if (widget.description != null)
                Text(
                  widget.description!,
                  style: context.bodySmall?.apply(color: AppColors.grey),
                ),
            ].spacerBetween(height: AppSpacing.md),
          ),
        ),
      ),
    );
  }
}
