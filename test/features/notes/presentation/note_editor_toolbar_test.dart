import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' show Attribute;
// ignore_for_file: experimental_member_use
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_test/flutter_test.dart';
import 'package:vestwise/core/theme/app_theme.dart';
import 'package:vestwise/features/notes/presentation/widgets/note_editor_toolbar.dart';

Future<quill.QuillController> _pumpToolbar(WidgetTester tester) async {
  final quill.QuillController controller = quill.QuillController(
    document: quill.Document()..insert(0, 'Hello'),
    selection: const TextSelection.collapsed(offset: 0),
  );
  addTearDown(controller.dispose);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: const <LocalizationsDelegate<Object>>[
        quill.FlutterQuillLocalizations.delegate,
      ],
      home: Scaffold(body: NoteEditorToolbar(controller: controller)),
    ),
  );
  await tester.pumpAndSettle();

  return controller;
}

void main() {
  group('NoteEditorToolbar (P10-NOTES-4)', () {
    testWidgets('is flat: no dividers, no panel colour', (
      WidgetTester tester,
    ) async {
      await _pumpToolbar(tester);

      final quill.QuillSimpleToolbar toolbar = tester
          .widget<quill.QuillSimpleToolbar>(
            find.byType(quill.QuillSimpleToolbar),
          );

      expect(toolbar.config.showDividers, isFalse);
      expect(toolbar.config.color, isNull);
      expect(toolbar.config.decoration, isNull);
    });

    testWidgets('drops the two label-bearing dropdowns', (
      WidgetTester tester,
    ) async {
      await _pumpToolbar(tester);

      final quill.QuillSimpleToolbar toolbar = tester
          .widget<quill.QuillSimpleToolbar>(
            find.byType(quill.QuillSimpleToolbar),
          );

      expect(toolbar.config.showFontFamily, isFalse);
      expect(toolbar.config.showFontSize, isFalse);
      // ...while the formatting actions the plan names are all still there.
      expect(toolbar.config.showBoldButton, isTrue);
      expect(toolbar.config.showItalicButton, isTrue);
      expect(toolbar.config.showUnderLineButton, isTrue);
      expect(toolbar.config.showListNumbers, isTrue);
      expect(toolbar.config.showListBullets, isTrue);
      expect(toolbar.config.showHeaderStyle, isTrue);
    });

    testWidgets('tightens the spacing between buttons, not their size', (
      WidgetTester tester,
    ) async {
      await _pumpToolbar(tester);

      final quill.QuillSimpleToolbar toolbar = tester
          .widget<quill.QuillSimpleToolbar>(
            find.byType(quill.QuillSimpleToolbar),
          );

      expect(toolbar.config.toolbarRunSpacing, 0);
      expect(toolbar.config.toolbarSectionSpacing, 0);
      // No icon theme is set at all: sizes and colours come from the Material
      // theme, so the ≥48px touch target and the M3 selected-state fill are
      // not overridden by this widget.
      expect(toolbar.config.iconTheme, isNull);
      expect(
        tester.widget<Icon>(find.byIcon(Icons.format_bold).first).color,
        isNull,
        reason: 'the glyph inherits its colour rather than being hand-tinted',
      );
    });

    testWidgets('the formatting actions still work', (
      WidgetTester tester,
    ) async {
      final quill.QuillController controller = await _pumpToolbar(tester);

      controller.updateSelection(
        const TextSelection(baseOffset: 0, extentOffset: 5),
        quill.ChangeSource.local,
      );
      await tester.pumpAndSettle();

      for (final (IconData icon, Attribute<dynamic> attribute)
          in <(IconData, Attribute<dynamic>)>[
            (Icons.format_bold, Attribute.bold),
            (Icons.format_italic, Attribute.italic),
            (Icons.format_underlined, Attribute.underline),
            (Icons.format_strikethrough, Attribute.strikeThrough),
          ]) {
        await tester.tap(find.byIcon(icon).first);
        await tester.pumpAndSettle();
        expect(
          controller.getSelectionStyle().attributes.containsKey(attribute.key),
          isTrue,
          reason: '${attribute.key} did not apply',
        );
        await tester.tap(find.byIcon(icon).first);
        await tester.pumpAndSettle();
      }
    });
  });
}
