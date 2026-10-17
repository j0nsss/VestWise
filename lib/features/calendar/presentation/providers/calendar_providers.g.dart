// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(calendarRepository)
final calendarRepositoryProvider = CalendarRepositoryProvider._();

final class CalendarRepositoryProvider
    extends
        $FunctionalProvider<
          CalendarRepository,
          CalendarRepository,
          CalendarRepository
        >
    with $Provider<CalendarRepository> {
  CalendarRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'calendarRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$calendarRepositoryHash();

  @$internal
  @override
  $ProviderElement<CalendarRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CalendarRepository create(Ref ref) {
    return calendarRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CalendarRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CalendarRepository>(value),
    );
  }
}

String _$calendarRepositoryHash() =>
    r'73df159049189513f1589213d3328dccdcf07aba';

@ProviderFor(watchAllEvents)
final watchAllEventsProvider = WatchAllEventsProvider._();

final class WatchAllEventsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CalendarEventModel>>,
          List<CalendarEventModel>,
          Stream<List<CalendarEventModel>>
        >
    with
        $FutureModifier<List<CalendarEventModel>>,
        $StreamProvider<List<CalendarEventModel>> {
  WatchAllEventsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchAllEventsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchAllEventsHash();

  @$internal
  @override
  $StreamProviderElement<List<CalendarEventModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<CalendarEventModel>> create(Ref ref) {
    return watchAllEvents(ref);
  }
}

String _$watchAllEventsHash() => r'76df9b21776621a371250a777694cd35691941f9';

@ProviderFor(watchEventsForDay)
final watchEventsForDayProvider = WatchEventsForDayFamily._();

final class WatchEventsForDayProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CalendarEventModel>>,
          List<CalendarEventModel>,
          Stream<List<CalendarEventModel>>
        >
    with
        $FutureModifier<List<CalendarEventModel>>,
        $StreamProvider<List<CalendarEventModel>> {
  WatchEventsForDayProvider._({
    required WatchEventsForDayFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'watchEventsForDayProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchEventsForDayHash();

  @override
  String toString() {
    return r'watchEventsForDayProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<CalendarEventModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<CalendarEventModel>> create(Ref ref) {
    final argument = this.argument as DateTime;
    return watchEventsForDay(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchEventsForDayProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchEventsForDayHash() => r'c317f9467a8069eb3beeeefcf7b8150957755a15';

final class WatchEventsForDayFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<CalendarEventModel>>, DateTime> {
  WatchEventsForDayFamily._()
    : super(
        retry: null,
        name: r'watchEventsForDayProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchEventsForDayProvider call(DateTime day) =>
      WatchEventsForDayProvider._(argument: day, from: this);

  @override
  String toString() => r'watchEventsForDayProvider';
}

@ProviderFor(watchUpcomingEvents)
final watchUpcomingEventsProvider = WatchUpcomingEventsProvider._();

final class WatchUpcomingEventsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CalendarEventModel>>,
          List<CalendarEventModel>,
          Stream<List<CalendarEventModel>>
        >
    with
        $FutureModifier<List<CalendarEventModel>>,
        $StreamProvider<List<CalendarEventModel>> {
  WatchUpcomingEventsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchUpcomingEventsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchUpcomingEventsHash();

  @$internal
  @override
  $StreamProviderElement<List<CalendarEventModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<CalendarEventModel>> create(Ref ref) {
    return watchUpcomingEvents(ref);
  }
}

String _$watchUpcomingEventsHash() =>
    r'64ba23388df2f9e791480a493110f0ef77b5e245';
