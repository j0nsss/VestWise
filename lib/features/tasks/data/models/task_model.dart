import 'package:isar_community/isar.dart';

part 'task_model.g.dart';

enum TaskPriority {
  low,
  medium,
  high,
}

@embedded
class SubTask {
  late String localId; // uuid, generated client-side
  late String title;
  bool isDone = false;
}

@collection
class TaskModel {
  Id id = Isar.autoIncrement;

  late String title;

  String? description;

  @enumerated
  late TaskPriority priority;

  @Index()
  DateTime? dueDate;

  @Index()
  bool isCompleted = false;

  List<SubTask> subTasks = [];

  /// id returned by flutter_local_notifications when a reminder is scheduled;
  /// null if no reminder is set. Used to cancel on edit/delete/complete.
  int? notificationId;

  @Index()
  late DateTime createdAt;

  DateTime? completedAt;
}
