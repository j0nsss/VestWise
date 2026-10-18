import 'package:flutter/material.dart';
import 'package:vestwise/core/constants/app_colors.dart';

/// A note's title, styled as a document heading rather than a form field
/// (plan P10-NOTES-1): no border while writing, a hairline underline only
/// while focused, and it grows to as many lines as the title needs.
///
/// Deliberately not [VWTextField] — that widget is the app's *form* field,
/// with a label and a boxed border, which is exactly the wrong signal for a
/// title that should read as part of the page.
class DocumentTitleField extends StatelessWidget {
  const DocumentTitleField({
    required this.controller,
    this.onChanged,
    this.autofocus = false,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color muted = theme.colorScheme.onSurfaceVariant;

    return Semantics(
      header: true,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        autofocus: autofocus,
        maxLines: null,
        textCapitalization: TextCapitalization.sentences,
        style: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          hintText: 'Untitled',
          hintStyle: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: muted,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          // Only while the field has focus: a quiet cue that you are editing
          // the title, not a box competing with the document body.
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.borderSubtle(context)),
          ),
          contentPadding: EdgeInsets.zero,
          isDense: true,
        ),
      ),
    );
  }
}
