import 'package:flutter/material.dart';
import 'package:recycleorigindriver/core/theme/theme_context.dart';

/// Material 3 text field used on profile edit screens.
class ProfileFormField extends StatelessWidget {
  const ProfileFormField({
    super.key,
    required this.label,
    required this.controller,
    required this.focusNode,
    this.nextFocus,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.helperText,
    this.readOnly = false,
  });

  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode? nextFocus;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final String? helperText;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        readOnly: readOnly,
        keyboardType: keyboardType,
        textInputAction: textInputAction ??
            (nextFocus != null ? TextInputAction.next : TextInputAction.done),
        onFieldSubmitted: (_) {
          if (nextFocus != null) {
            FocusScope.of(context).requestFocus(nextFocus);
          }
        },
        validator: validator,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: context.primaryText,
            ),
        decoration: InputDecoration(
          labelText: label,
          helperText: helperText,
          filled: true,
          fillColor: readOnly ? scheme.surfaceContainerHighest : scheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: scheme.outlineVariant,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
