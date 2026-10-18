import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vestwise/core/theme/app_theme.dart';
import 'package:vestwise/features/tasks/data/models/task_model.dart';
import 'package:vestwise/features/tasks/presentation/widgets/task_list_tile.dart';
import 'package:vestwise/features/tasks/presentation/widgets/task_row_skeleton.dart';

import '../../../helpers/scroll_contexts.dart';

TaskModel _task() => TaskModel()
  ..id = 1
  ..title = 'Write the report'
  ..priority = TaskPriority.medium
  ..createdAt = DateTime(2026, 3, 1);

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: child),
  ),
);

void main() {
  group('TaskRowSkeleton (P11-T1)', () {
    testWidgets('occupies the same row the real task will', (
      WidgetTester tester,
    ) async {
      await _pump(tester, TaskListTile(task: _task(), onToggle: () {}));
      final double real = tester.getSize(find.byType(TaskListTile)).height;

      await _pump(tester, const TaskRowSkeleton());
      final double skeleton = tester
          .getSize(find.byType(TaskRowSkeleton))
          .height;

      expect(
        (real - skeleton).abs(),
        lessThanOrEqualTo(3),
        reason:
            'real $real vs skeleton $skeleton — a list must not jump when '
            'its data lands',
      );
    });

    testWidgets('survives the scroll contexts that bit this project once', (
      WidgetTester tester,
    ) async {
      await expectSurvivesScrollContexts(
        tester,
        const TaskRowSkeleton(),
        TaskRowSkeleton,
      );
    });
  });
}
