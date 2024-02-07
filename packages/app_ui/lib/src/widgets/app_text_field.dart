// ignore_for_file: avoid_multiple_declarations_per_line, inference_failure_on_untyped_parameter, lines_longer_than_80_chars, public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show MaxLengthEnforcement, TextInputFormatter;

/// {@template app_text_field}
/// Custom text field that contains text field with custom decoration.
/// {@endtemplate}
class AppTextField extends StatelessWidget {
  /// {@macro app_text_field}
  const AppTextField({
    this.textDirection = TextDirection.ltr,
    this.cursorWidth = 2.0,
    this.enableSuggestion = true,
    this.expands = false,
    this.obscuringCharacter = '•',
    this.scrollPadding = const EdgeInsets.all(20),
    this.textAlign = TextAlign.start,
    super.key,
    this.hintText,
    this.textController,
    this.errorText,
    this.onTap,
    this.focusNode,
    this.onChanged,
    this.textInputAction,
    this.obscureText = false,
    this.autoCorrect = true,
    this.enabled = true,
    this.suffixIcon,
    this.prefixIcon,
    this.prefix,
    this.focusedBorder,
    this.enabledBorder,
    this.disabledBorder,
    this.textInputType,
    this.inputFormatters,
    this.validator,
    this.floatingLabelBehaviour,
    this.labelText,
    this.autofocus = false,
    this.border,
    this.contentPadding,
    this.initialValue,
    this.readOnly = false,
    this.textCapitalization = TextCapitalization.none,
    this.suffixText,
    this.filled,
    this.onFieldSubmitted,
    this.onEditingComplete,
    this.cursorColor,
    this.cursorHeight,
    this.cursorRadius,
    this.autovalidateMode,
    this.keyboardAppearance,
    this.magnifierConfiguration,
    this.maxLines = 1,
    this.maxLength,
    this.minLength,
    this.minLines,
    this.maxLengthEnforcement,
    this.mouseCursor,
    this.onSaved,
    this.onTapOutside,
    this.restorationId,
    this.scrollController,
    this.scrollPhysics,
    this.showCursor,
    this.selectionsControls,
    this.smartDashesType,
    this.smartQuotesType,
    this.strutStyle,
    this.style,
    this.spellCheckConfiguration,
    this.textAlignVertical,
    this.autofillHints,
    this.errorMaxLines,
  });

  /// Creates a new [AppTextField] with a filled border.
  const AppTextField.underlineBorder({
    Key? key,
    String? hintText,
    String? labelText,
    String? errorText,
    String? initialValue,
    TextEditingController? textController,
    VoidCallback? onTap,
    FocusNode? focusNode,
    void Function(String)? onChanged,
    TextInputAction? textInputAction,
    bool obscureText = false,
    bool autoCorrect = false,
    bool enabled = true,
    bool autofocus = false,
    Widget? suffixIcon,
    Icon? prefixIcon,
    Widget? prefix,
    TextInputType? textInputType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    FloatingLabelBehavior? floatingLabelBehaviour,
    bool readOnly = false,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? suffixText,
    EdgeInsetsGeometry? contentPadding,
    bool? filled,
    ValueSetter<String?>? onFieldSubmitted,
    void Function()? onEditingComplete,
    Color? cursorColor,
    double? cursorHeight,
    Radius? cursorRadius,
    double cursorWidth = 2,
    bool enableSuggestion = true,
    AutovalidateMode? autovalidateMode,
    bool expands = false,
    Brightness? keyboardAppearance,
    TextMagnifierConfiguration? magnifierConfiguration,
    int maxLines = 1,
    int? maxLength,
    int? minLength,
    int? minLines,
    MaxLengthEnforcement? maxLengthEnforcement,
    MouseCursor? mouseCursor,
    ValueSetter<String?>? onSaved,
    String obscuringCharacter = '•',
    ValueSetter<PointerDownEvent>? onTapOutside,
    String? restorationId,
    ScrollController? scrollController,
    EdgeInsets scrollPadding = const EdgeInsets.all(20),
    ScrollPhysics? scrollPhysics,
    bool? showCursor,
    TextSelectionControls? selectionsControls,
    SmartDashesType? smartDashesType,
    SmartQuotesType? smartQuotesType,
    StrutStyle? strutStyle,
    TextStyle? style,
    TextAlign textAlign = TextAlign.start,
    SpellCheckConfiguration? spellCheckConfiguration,
    TextAlignVertical? textAlignVertical,
    TextDirection textDirection = TextDirection.ltr,
    InputBorder? focusedBorder,
    InputBorder? enabledBorder,
    InputBorder? disabledBorder,
    Iterable<String>? autofillHints,
    int? errorMaxLines,
  }) : this(
          key: key,
          autofillHints: autofillHints,
          autovalidateMode: autovalidateMode,
          cursorColor: cursorColor,
          cursorHeight: cursorHeight,
          cursorRadius: cursorRadius,
          cursorWidth: cursorWidth,
          disabledBorder: disabledBorder,
          enableSuggestion: enableSuggestion,
          enabledBorder: enabledBorder,
          expands: expands,
          focusedBorder: focusedBorder,
          keyboardAppearance: keyboardAppearance,
          magnifierConfiguration: magnifierConfiguration,
          maxLength: maxLength,
          maxLengthEnforcement: maxLengthEnforcement,
          maxLines: maxLines,
          minLength: minLength,
          minLines: minLines,
          mouseCursor: mouseCursor,
          obscuringCharacter: obscuringCharacter,
          onEditingComplete: onEditingComplete,
          onFieldSubmitted: onFieldSubmitted,
          onSaved: onSaved,
          onTapOutside: onTapOutside,
          restorationId: restorationId,
          scrollController: scrollController,
          scrollPadding: scrollPadding,
          scrollPhysics: scrollPhysics,
          selectionsControls: selectionsControls,
          showCursor: showCursor,
          smartDashesType: smartDashesType,
          smartQuotesType: smartQuotesType,
          spellCheckConfiguration: spellCheckConfiguration,
          strutStyle: strutStyle,
          style: style,
          textAlign: textAlign,
          textAlignVertical: textAlignVertical,
          textDirection: textDirection,
          contentPadding: contentPadding,
          textController: textController,
          initialValue: initialValue,
          focusNode: focusNode,
          textInputType: textInputType,
          inputFormatters: inputFormatters,
          onTap: onTap,
          onChanged: onChanged,
          readOnly: readOnly,
          autoCorrect: autoCorrect,
          textInputAction: textInputAction,
          obscureText: obscureText,
          validator: validator,
          autofocus: autofocus,
          textCapitalization: textCapitalization,
          floatingLabelBehaviour: floatingLabelBehaviour,
          labelText: labelText,
          hintText: hintText,
          errorText: errorText,
          suffixText: suffixText,
          prefixIcon: prefixIcon,
          prefix: prefix,
          suffixIcon: suffixIcon,
          enabled: enabled,
          filled: filled,
          border: const UnderlineInputBorder(),
          errorMaxLines: errorMaxLines,
        );

  final String? hintText, labelText, errorText, initialValue;
  final TextEditingController? textController;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final void Function(String)? onChanged;
  final TextInputAction? textInputAction;
  final bool obscureText, autoCorrect, enabled, autofocus, readOnly;
  final Widget? suffixIcon;
  final Icon? prefixIcon;
  final Widget? prefix;
  final InputBorder? focusedBorder, enabledBorder, disabledBorder, border;
  final TextInputType? textInputType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final FloatingLabelBehavior? floatingLabelBehaviour;
  final EdgeInsetsGeometry? contentPadding;
  final TextCapitalization textCapitalization;
  final String? suffixText;
  final bool? filled;
  final ValueSetter<String?>? onFieldSubmitted;
  final void Function()? onEditingComplete;
  final Color? cursorColor;
  final double? cursorHeight;
  final Radius? cursorRadius;
  final double cursorWidth;
  final bool enableSuggestion;
  final AutovalidateMode? autovalidateMode;
  final bool expands;
  final Brightness? keyboardAppearance;
  final TextMagnifierConfiguration? magnifierConfiguration;
  final int maxLines;
  final int? maxLength;
  final int? minLength;
  final int? minLines;
  final MaxLengthEnforcement? maxLengthEnforcement;
  final MouseCursor? mouseCursor;
  final ValueSetter<String?>? onSaved;
  final String obscuringCharacter;
  final ValueSetter<PointerDownEvent>? onTapOutside;
  final String? restorationId;
  final ScrollController? scrollController;
  final EdgeInsets scrollPadding;
  final ScrollPhysics? scrollPhysics;
  final bool? showCursor;
  final TextSelectionControls? selectionsControls;
  final SmartDashesType? smartDashesType;
  final SmartQuotesType? smartQuotesType;
  final StrutStyle? strutStyle;
  final TextStyle? style;
  final TextAlign textAlign;
  final SpellCheckConfiguration? spellCheckConfiguration;
  final TextAlignVertical? textAlignVertical;
  final TextDirection textDirection;
  final Iterable<String>? autofillHints;
  final int? errorMaxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      contextMenuBuilder: (context, editableTextState) {
        return AdaptiveTextSelectionToolbar.buttonItems(
          anchors: editableTextState.contextMenuAnchors,
          buttonItems: [
            ...editableTextState.contextMenuButtonItems,
          ],
        );
      },
      autofillHints: autofillHints,
      controller: textController,
      initialValue: initialValue,
      focusNode: focusNode,
      keyboardType: textInputType,
      inputFormatters: inputFormatters,
      onTap: onTap,
      onFieldSubmitted: onFieldSubmitted,
      onEditingComplete: onEditingComplete,
      cursorColor: cursorColor,
      cursorHeight: cursorHeight,
      cursorRadius: cursorRadius,
      cursorWidth: cursorWidth,
      enableSuggestions: enableSuggestion,
      autovalidateMode: autovalidateMode,
      enabled: enabled,
      expands: expands,
      keyboardAppearance: keyboardAppearance,
      magnifierConfiguration: magnifierConfiguration,
      maxLength: maxLength,
      maxLengthEnforcement: maxLengthEnforcement,
      maxLines: maxLines,
      minLines: minLines,
      mouseCursor: mouseCursor,
      onSaved: onSaved,
      obscuringCharacter: obscuringCharacter,
      onTapOutside: onTapOutside,
      restorationId: restorationId,
      scrollController: scrollController,
      scrollPadding: scrollPadding,
      scrollPhysics: scrollPhysics,
      showCursor: showCursor,
      selectionControls: selectionsControls,
      smartDashesType: smartDashesType,
      smartQuotesType: smartQuotesType,
      strutStyle: strutStyle,
      style: style,
      textAlign: textAlign,
      spellCheckConfiguration: spellCheckConfiguration,
      textAlignVertical: textAlignVertical,
      textDirection: textDirection,
      readOnly: readOnly,
      onChanged: onChanged,
      autocorrect: autoCorrect,
      textInputAction: textInputAction,
      obscureText: obscureText,
      validator: validator,
      autofocus: autofocus,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
        suffixText: suffixText,
        floatingLabelAlignment: FloatingLabelAlignment.start,
        floatingLabelBehavior: floatingLabelBehaviour,
        labelText: labelText,
        hintText: hintText,
        errorText: errorText,
        errorMaxLines: errorMaxLines,
        enabledBorder: enabledBorder,
        disabledBorder: disabledBorder,
        focusedBorder: focusedBorder,
        prefixIcon: prefixIcon,
        prefix: prefix,
        suffixIcon: suffixIcon,
        filled: filled,
        enabled: enabled,
        border: border,
        contentPadding: contentPadding,
      ),
    );
  }
}
