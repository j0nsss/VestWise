// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tasks_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(tasksRepository)
final tasksRepositoryProvider = TasksRepositoryProvider._();

final class TasksRepositoryProvider
    extends
        $FunctionalProvider<TasksRepository, TasksRepository, TasksRepository>
    with $Provider<TasksRepository> {
  TasksRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tasksRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tasksRepositoryHash();

  @$internal
  @override
  $ProviderElement<TasksRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TasksRepository create(Ref ref) {
    return tasksRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TasksRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TasksRepository>(value),
    );
  }
}

String _$tasksRepositoryHash() => r'051756cf631b365ae346dbefdf5dcb001371157a';

@ProviderFor(watchAllTasks)
final watchAllTasksProvider = WatchAllTasksProvider._();

final class WatchAllTasksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TaskModel>>,
          List<TaskModel>,
          Stream<List<TaskModel>>
        >
    with $FutureModifier<List<TaskModel>>, $StreamProvider<List<TaskModel>> {
  WatchAllTasksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchAllTasksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchAllTasksHash();

  @$internal
  @override
  $StreamProviderElement<List<TaskModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TaskModel>> create(Ref ref) {
    return watchAllTasks(ref);
  }
}

String _$watchAllTasksHash() => r'136d7a3392da63ec9dc10a1ec97a936cdfc7b0f0';

@ProviderFor(watchTasksDueToday)
final watchTasksDueTodayProvider = WatchTasksDueTodayProvider._();

final class WatchTasksDueTodayProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TaskModel>>,
          List<TaskModel>,
          Stream<List<TaskModel>>
        >
    with $FutureModifier<List<TaskModel>>, $StreamProvider<List<TaskModel>> {
  WatchTasksDueTodayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchTasksDueTodayProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchTasksDueTodayHash();

  @$internal
  @override
  $StreamProviderElement<List<TaskModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TaskModel>> create(Ref ref) {
    return watchTasksDueToday(ref);
  }
}

String _$watchTasksDueTodayHash() =>
    r'8dc0ad4e7b9efe4bdbd1801ec620f228080ee9f7';
