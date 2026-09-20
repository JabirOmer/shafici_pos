import 'package:flutter/material.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/helpers/helper_functions.dart';

class UiTextFieldWidget extends StatelessWidget {
  final GlobalKey? textFieldKey;
  final TextEditingController? textController;
  final String? label;
  final String? hint;
  final TextInputType keyboardType;
  final String? Function(String? value)? validator;
  final void Function(String value)? onChange;
  final void Function(String? value)? fieldSubmit;
  final bool capitalize;
  final bool obscureText;
  final String? initialValue;
  final bool readOnly;
  final bool enabled;
  final bool autoFocus;
  final FocusNode? focusNode;
  final void Function()? onTap;
  final bool isDisabled;
  final bool defaultLabel;

  const UiTextFieldWidget({
    super.key,
    this.textFieldKey,
    this.textController,
    this.label,
    this.hint,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChange,
    this.fieldSubmit,
    this.capitalize = true,
    this.obscureText = false,
    this.initialValue,
    this.readOnly = false,
    this.enabled = true,
    this.autoFocus = false,
    this.focusNode,
    this.onTap,
    this.isDisabled = false,
    this.defaultLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: textFieldKey,
      controller: textController,
      decoration: InputDecoration(
        hintText: hint,
        labelText: label != null ? defaultLabel ? label : CHelperFunctions.capitalize(label!) : null,
        filled: true,
        fillColor: enabled ? CColors.transparent : CColors.whiteShade2,
        hoverColor: CColors.transparent,
        focusColor: CColors.transparent
      ),
      keyboardType: keyboardType,
      validator: validator,
      obscureText: obscureText,
      textCapitalization: obscureText ? TextCapitalization.none : (capitalize ? TextCapitalization.words : TextCapitalization.none),
      initialValue: initialValue,
      readOnly: readOnly,
      enabled: enabled,
      enableInteractiveSelection: enabled,
      onChanged: onChange,
      onFieldSubmitted: fieldSubmit,
      autofocus: autoFocus,
      focusNode: focusNode,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onTap: onTap,
    );
  }
}