import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:vestwise/core/constants/app_spacing.dart';

/// The note editor's formatting bar (plan P10-NOTES-4).
///
/// A restyle of [`QuillSimpleToolbar`], not a rebuild: every button keeps its
/// stock behaviour, and only the chrome around them changes.
///
/// - Flat: `showDividers: false` and no `color`/`decoration`, so the page
///   background shows through instead of a raised panel.
/// - Icon-only: the font-family and font-size dropdowns are the only controls
///   in the stock toolbar that render *words* rather than a glyph, so they are
///   off. Everything else — bold, italic, underline, strikethrough, inline
///   code, colours, clear-format, headings, lists, quote, code block, indent,
///   links, undo/redo, search — is untouched.
/// - Tighter: the gaps between buttons are zero, while each button's own size
///   (and therefore its ≥48px touch target, plan P5-T2) is left alone. Shrinking
///   the buttons would buy visual density at the cost of accessibility.
///
/// Icon colour is not set here at all. Material 3 already paints an unselected
/// `IconButton` glyph in `onSurfaceVariant` and a selected one as an
/// `onPrimary` glyph on a `primary` circle, which is exactly the muted/flat
/// look this wants — and the one place a hand-picked colour would break it is
/// the selected state, where a custom foreground would vanish into its own fill.
class NoteEditorToolbar extends StatelessWidget {
  const NoteEditorToolbar({required this.controller, super.key});

  final QuillController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: QuillSimpleToolbar(
        controller: controller,
        config: const QuillSimpleToolbarConfig(
          showDividers: false,
          showFontFamily: false,
          showFontSize: false,
          toolbarRunSpacing: 0,
          toolbarSectionSpacing: 0,
          sectionDividerSpace: 0,
        ),
      ),
    );
  }
}
