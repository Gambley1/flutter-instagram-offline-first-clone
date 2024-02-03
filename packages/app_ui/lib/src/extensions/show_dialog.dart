import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/shared.dart';

/// {@template show_dialog_extension}
/// Dialog extension that shows dialog with optionaly provided `title`,
/// `content` and `actions`.
/// {@endtemplate}
extension DialogExtension on BuildContext {
  /// Shows the bottom sheet with the confirmation of the `action`.
  Future<bool?> showConfirmationBottomSheet({
    required String title,
    required String okText,
    Widget? icon,
    String? question,
    String? cancelText,
  }) {
    return showModalBottomSheet(
      context: this,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 26),
            if (icon != null) icon,
            const SizedBox(height: 26),
            Text(
              title,
              style: context.headlineLarge
                  ?.copyWith(fontWeight: AppFontWeight.bold),
            ),
            const SizedBox(height: 7),
            if (question != null)
              Text(
                question,
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 36),
            Container(
              color: context.customReversedAdaptiveColor(
                dark: Colors.grey[900],
                light: Colors.grey[300],
              ),
              height: 1,
            ),
            Row(
              children: [
                if (cancelText != null)
                  Flexible(
                    child: Container(
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: () {
                          pop(false);
                        },
                        child: Text(
                          cancelText,
                          style: context.bodyLarge
                              ?.copyWith(color: context.adaptiveColor),
                        ),
                      ),
                    ),
                  ),
                Flexible(
                  child: Container(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () => pop(true),
                      child: Text(
                        okText,
                        style: context.bodyLarge?.copyWith(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  /// Shows dialog with provided `title`, `content` and `actions` (if provided).
  /// If `barrierDismissible` is `true` (default), dialog can't be dismissed by
  /// tapping outside of the dialog.
  Future<T?> showAdaptiveDialog<T>({
    required Widget content,
    String? title,
    List<Widget> actions = const [],
    bool barrierDismissible = true,
    Widget Function(BuildContext)? builder,
    TextStyle? titleTextStyle,
  }) =>
      showDialog<T>(
        context: this,
        barrierDismissible: barrierDismissible,
        builder: builder ??
            (context) {
              return AlertDialog.adaptive(
                title: title == null
                    ? null
                    : Text(
                        title,
                        textAlign: TextAlign.center,
                      ),
                titleTextStyle: titleTextStyle ?? context.headlineMedium,
                content: content,
                actionsAlignment: MainAxisAlignment.end,
                actions: actions,
              );
            },
      );

  /// Shows bottom modal.
  Future<T?> showBottomModal<T>({
    Widget Function(BuildContext context)? builder,
    String? title,
    Color? titleColor,
    Widget? content,
    Color? backgroundColor,
    Color? barrierColor,
    ShapeBorder? border,
    bool rounded = true,
    bool isDismissible = true,
    bool isScrollControlled = false,
    bool enalbeDrag = true,
    bool useSafeArea = true,
    bool showDragHandle = true,
  }) =>
      showModalBottomSheet(
        context: this,
        shape: border ??
            (!rounded
                ? null
                : const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  )),
        showDragHandle: showDragHandle,
        backgroundColor: backgroundColor,
        barrierColor: barrierColor,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        isDismissible: isDismissible,
        enableDrag: enalbeDrag,
        useSafeArea: useSafeArea,
        isScrollControlled: isScrollControlled,
        useRootNavigator: true,
        builder: builder ??
            (context) {
              return Material(
                type: MaterialType.transparency,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (title != null) ...[
                      Text(
                        title,
                        style: context.titleLarge?.copyWith(color: titleColor),
                      ),
                      const Divider(),
                    ],
                    content!,
                  ],
                ),
              );
            },
      );

  /// Shows bottom modal with a `list` of [ModalOption]s
  Future<ModalOption?> showListOptionsModal({
    required List<ModalOption> options,
    String? title,
  }) =>
      showBottomModal<ModalOption>(
        isScrollControlled: true,
        title: title,
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: options
                .map(
                  (option) => Tappable(
                    animationEffect: TappableAnimationEffect.none,
                    onTap: () => pop<ModalOption>(option),
                    child: ListTile(
                      title: Text(
                        option.name,
                        style: bodyLarge?.copyWith(
                          color: option.nameColor ?? option.distractiveColor,
                        ),
                      ),
                      leading: option.child ??
                          Icon(
                            option.icon,
                            color: option.distractiveColor,
                          ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      );

  /// Opens the modal bottom sheet for a comments page builder.
  Future<void> showCommentsModal({
    required Widget Function(
      ScrollController scrollController,
      DraggableScrollableController draggableScrollController,
    ) pageBuilder,
    bool showFullSized = false,
  }) =>
      showBottomModal<void>(
        isScrollControlled: true,
        enalbeDrag: false,
        showDragHandle: false,
        builder: (context) {
          final controller = DraggableScrollableController();
          return DraggableScrollableSheet(
            controller: controller,
            expand: false,
            snap: true,
            snapSizes: const [.6, 1],
            initialChildSize: showFullSized ? 1.0 : .7,
            minChildSize: .4,
            builder: (context, scrollController) =>
                pageBuilder.call(scrollController, controller),
          );
        },
      );

  /// Opens a dialog where shows a preview of an image in a circular avatar.
  Future<void> showImagePreview(String imageUrl) => showDialog<void>(
        context: this,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 3,
                    strokeAlign: BorderSide.strokeAlignOutside,
                  ),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          );
        },
      );

  /// Shows the confirmation dialog and upon confirmation executes provided
  /// [fn].
  Future<void> confirmAction({
    required FutureOr<void> Function() fn,
    required String noText,
    required String yesText,
    required String title,
    ValueSetter<BuildContext>? noAction,
    ValueSetter<BuildContext>? yesAction,
  }) async {
    final isConfimred = await showConfirmationDialog(
      noText: noText,
      yesText: yesText,
      title: title,
      noAction: noAction,
      yesAction: yesAction,
    );
    if (isConfimred == null || !isConfimred) return;
    await Future(() => fn.call());
  }

  /// Shows a dialog that alerts user that they are about to do distractive
  /// action.
  Future<bool?> showConfirmationDialog({
    required String noText,
    required String yesText,
    String? title,
    String? subtitle,
    ValueSetter<BuildContext>? noAction,
    ValueSetter<BuildContext>? yesAction,
    TextStyle? noTextStyle,
    TextStyle? yesTextStyle,
    bool distractiveAction = true,
    bool barrierDismissible = true,
  }) =>
      showAdaptiveDialog<bool?>(
        title: title ?? 'Are you sure?',
        barrierDismissible: barrierDismissible,
        content: subtitle == null
            ? const SizedBox.shrink()
            : Text(
                subtitle,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium,
              ),
        actions: theme.platform == TargetPlatform.android
            ? [
                TextButton(
                  onPressed: () =>
                      noAction == null ? pop(false) : noAction.call(this),
                  child: Text(
                    noText,
                    style: noTextStyle ??
                        textTheme.bodyMedium?.copyWith(
                          color: adaptiveColor,
                        ),
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      yesAction == null ? pop(true) : yesAction.call(this),
                  child: Text(
                    yesText,
                    style: yesTextStyle ??
                        textTheme.bodyMedium?.copyWith(
                          color: distractiveAction ? Colors.red : adaptiveColor,
                        ),
                  ),
                ),
              ]
            : [
                AppButton(
                  isDialogButton: true,
                  isDefaultAction: true,
                  onPressed: () => noAction == null
                      ? (canPop() ? pop(false) : null)
                      : noAction.call(this),
                  text: noText,
                  textStyle: noTextStyle ??
                      textTheme.bodyMedium?.copyWith(
                        color: adaptiveColor,
                      ),
                ),
                AppButton(
                  isDialogButton: true,
                  isDestructiveAction: true,
                  onPressed: () => yesAction == null
                      ? (canPop() ? pop(true) : null)
                      : yesAction.call(this),
                  text: yesText,
                  textStyle: yesTextStyle ??
                      textTheme.bodyMedium?.copyWith(
                        color: distractiveAction ? Colors.red : adaptiveColor,
                      ),
                ),
              ],
      );
}
