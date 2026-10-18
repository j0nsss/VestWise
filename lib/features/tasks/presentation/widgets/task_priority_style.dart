import 'package:flutter/material.dart';
import 'package:vestwise/core/constants/app_colors.dart';
import 'package:vestwise/features/tasks/data/models/task_model.dart';

/// Maps a [TaskPriority] to its semantic accent color (plan §1.5).
Color taskPriorityColor(TaskPriority priority) => switch (priority) {
  TaskPriority.high => AppColors.priorityHigh,
  TaskPriority.medium => AppColors.priorityMedium,
  TaskPriority.low => AppColors.priorityLow,
};

/// Human-readable label for a [TaskPriority].
String taskPriorityLabel(TaskPriority priority) => switch (priority) {
  TaskPriority.high => 'High',
  TaskPriority.medium => 'Medium',
  TaskPriority.low => 'Low',
};
