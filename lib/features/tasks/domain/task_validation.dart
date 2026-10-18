/// The one rule a task title has to satisfy.
///
/// Shared so the detailed form (plan P3-TASK-2) and the quick-add row
/// (P10-TASKS-2) cannot disagree about what "empty" means — the quick-add row
/// reuses this rather than re-deriving it.
String? validateTaskTitle(String? value) =>
    (value == null || value.trim().isEmpty) ? 'Title is required' : null;
