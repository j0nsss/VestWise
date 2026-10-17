// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notes_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(notesRepository)
final notesRepositoryProvider = NotesRepositoryProvider._();

final class NotesRepositoryProvider
    extends
        $FunctionalProvider<NotesRepository, NotesRepository, NotesRepository>
    with $Provider<NotesRepository> {
  NotesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notesRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notesRepositoryHash();

  @$internal
  @override
  $ProviderElement<NotesRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NotesRepository create(Ref ref) {
    return notesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotesRepository>(value),
    );
  }
}

String _$notesRepositoryHash() => r'946186507d25585b7e7be33f8688ffa6d23a32ef';

@ProviderFor(watchAllNotes)
final watchAllNotesProvider = WatchAllNotesProvider._();

final class WatchAllNotesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<NoteModel>>,
          List<NoteModel>,
          Stream<List<NoteModel>>
        >
    with $FutureModifier<List<NoteModel>>, $StreamProvider<List<NoteModel>> {
  WatchAllNotesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchAllNotesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchAllNotesHash();

  @$internal
  @override
  $StreamProviderElement<List<NoteModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<NoteModel>> create(Ref ref) {
    return watchAllNotes(ref);
  }
}

String _$watchAllNotesHash() => r'baf1d32b54134d1e0a6dfce45cf203fbf6f9810f';

@ProviderFor(watchNotesMatching)
final watchNotesMatchingProvider = WatchNotesMatchingFamily._();

final class WatchNotesMatchingProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<NoteModel>>,
          List<NoteModel>,
          Stream<List<NoteModel>>
        >
    with $FutureModifier<List<NoteModel>>, $StreamProvider<List<NoteModel>> {
  WatchNotesMatchingProvider._({
    required WatchNotesMatchingFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'watchNotesMatchingProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchNotesMatchingHash();

  @override
  String toString() {
    return r'watchNotesMatchingProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<NoteModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<NoteModel>> create(Ref ref) {
    final argument = this.argument as String;
    return watchNotesMatching(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchNotesMatchingProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchNotesMatchingHash() =>
    r'71ba3155df75043ce941116d3797ce2af5582f92';

final class WatchNotesMatchingFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<NoteModel>>, String> {
  WatchNotesMatchingFamily._()
    : super(
        retry: null,
        name: r'watchNotesMatchingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchNotesMatchingProvider call(String query) =>
      WatchNotesMatchingProvider._(argument: query, from: this);

  @override
  String toString() => r'watchNotesMatchingProvider';
}

@ProviderFor(watchImportedDocuments)
final watchImportedDocumentsProvider = WatchImportedDocumentsProvider._();

final class WatchImportedDocumentsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ImportedDocumentModel>>,
          List<ImportedDocumentModel>,
          Stream<List<ImportedDocumentModel>>
        >
    with
        $FutureModifier<List<ImportedDocumentModel>>,
        $StreamProvider<List<ImportedDocumentModel>> {
  WatchImportedDocumentsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchImportedDocumentsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchImportedDocumentsHash();

  @$internal
  @override
  $StreamProviderElement<List<ImportedDocumentModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ImportedDocumentModel>> create(Ref ref) {
    return watchImportedDocuments(ref);
  }
}

String _$watchImportedDocumentsHash() =>
    r'4be0b281105824e686b4136788218a55eb9b06c9';
