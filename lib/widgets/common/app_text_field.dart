import 'package:flutter/material.dart';

/// Thin wrapper around [TextFormField] so every form field in the app
/// (login, add expense, create household, ...) shares label placement,
/// spacing and error presentation.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.prefixIcon,
    this.prefixText,
    this.errorText,
    this.onChanged,
    this.validator,
    this.textInputAction,
    this.autofocus = false,
    this.enabled = true,
    this.maxLines = 1,
    this.hintText,
  });

  final String label;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final String? prefixText;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final bool autofocus;
  final bool enabled;
  final int maxLines;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: validator,
      textInputAction: textInputAction,
      autofocus: autofocus,
      enabled: enabled,
      maxLines: obscureText ? 1 : maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: prefixIcon,
        prefixText: prefixText,
        suffixIcon: suffixIcon,
        errorText: errorText,
      ),
    );
  }
}
