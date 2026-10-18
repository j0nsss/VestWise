// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finance_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(financeRepository)
final financeRepositoryProvider = FinanceRepositoryProvider._();

final class FinanceRepositoryProvider
    extends
        $FunctionalProvider<
          FinanceRepository,
          FinanceRepository,
          FinanceRepository
        >
    with $Provider<FinanceRepository> {
  FinanceRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'financeRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$financeRepositoryHash();

  @$internal
  @override
  $ProviderElement<FinanceRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FinanceRepository create(Ref ref) {
    return financeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FinanceRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FinanceRepository>(value),
    );
  }
}

String _$financeRepositoryHash() => r'1426e2f84926e712afc03c26c7e48a751b257029';

@ProviderFor(watchAllTransactions)
final watchAllTransactionsProvider = WatchAllTransactionsProvider._();

final class WatchAllTransactionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TransactionModel>>,
          List<TransactionModel>,
          Stream<List<TransactionModel>>
        >
    with
        $FutureModifier<List<TransactionModel>>,
        $StreamProvider<List<TransactionModel>> {
  WatchAllTransactionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchAllTransactionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchAllTransactionsHash();

  @$internal
  @override
  $StreamProviderElement<List<TransactionModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TransactionModel>> create(Ref ref) {
    return watchAllTransactions(ref);
  }
}

String _$watchAllTransactionsHash() =>
    r'41695620626102450d14d0f84c024a24b4c6b5fb';

@ProviderFor(watchRecentTransactions)
final watchRecentTransactionsProvider = WatchRecentTransactionsFamily._();

final class WatchRecentTransactionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TransactionModel>>,
          List<TransactionModel>,
          Stream<List<TransactionModel>>
        >
    with
        $FutureModifier<List<TransactionModel>>,
        $StreamProvider<List<TransactionModel>> {
  WatchRecentTransactionsProvider._({
    required WatchRecentTransactionsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'watchRecentTransactionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchRecentTransactionsHash();

  @override
  String toString() {
    return r'watchRecentTransactionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<TransactionModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TransactionModel>> create(Ref ref) {
    final argument = this.argument as int;
    return watchRecentTransactions(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchRecentTransactionsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchRecentTransactionsHash() =>
    r'e7aa339804252e5a6cf557b011125f02e5db6498';

final class WatchRecentTransactionsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<TransactionModel>>, int> {
  WatchRecentTransactionsFamily._()
    : super(
        retry: null,
        name: r'watchRecentTransactionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchRecentTransactionsProvider call(int limit) =>
      WatchRecentTransactionsProvider._(argument: limit, from: this);

  @override
  String toString() => r'watchRecentTransactionsProvider';
}

@ProviderFor(watchTransactionsInRange)
final watchTransactionsInRangeProvider = WatchTransactionsInRangeFamily._();

final class WatchTransactionsInRangeProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TransactionModel>>,
          List<TransactionModel>,
          Stream<List<TransactionModel>>
        >
    with
        $FutureModifier<List<TransactionModel>>,
        $StreamProvider<List<TransactionModel>> {
  WatchTransactionsInRangeProvider._({
    required WatchTransactionsInRangeFamily super.from,
    required (DateTime, DateTime) super.argument,
  }) : super(
         retry: null,
         name: r'watchTransactionsInRangeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchTransactionsInRangeHash();

  @override
  String toString() {
    return r'watchTransactionsInRangeProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<TransactionModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TransactionModel>> create(Ref ref) {
    final argument = this.argument as (DateTime, DateTime);
    return watchTransactionsInRange(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchTransactionsInRangeProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchTransactionsInRangeHash() =>
    r'3ba797bc435d464eff975bc5edeaba3369258a64';

final class WatchTransactionsInRangeFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<TransactionModel>>,
          (DateTime, DateTime)
        > {
  WatchTransactionsInRangeFamily._()
    : super(
        retry: null,
        name: r'watchTransactionsInRangeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchTransactionsInRangeProvider call(DateTime start, DateTime end) =>
      WatchTransactionsInRangeProvider._(argument: (start, end), from: this);

  @override
  String toString() => r'watchTransactionsInRangeProvider';
}

@ProviderFor(balance)
final balanceProvider = BalanceProvider._();

final class BalanceProvider
    extends $FunctionalProvider<AsyncValue<double>, double, FutureOr<double>>
    with $FutureModifier<double>, $FutureProvider<double> {
  BalanceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'balanceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$balanceHash();

  @$internal
  @override
  $FutureProviderElement<double> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<double> create(Ref ref) {
    return balance(ref);
  }
}

String _$balanceHash() => r'fe528225c05ff934e6b169fdaa053da5d32c329e';

@ProviderFor(watchCategories)
final watchCategoriesProvider = WatchCategoriesFamily._();

final class WatchCategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CategoryModel>>,
          List<CategoryModel>,
          Stream<List<CategoryModel>>
        >
    with
        $FutureModifier<List<CategoryModel>>,
        $StreamProvider<List<CategoryModel>> {
  WatchCategoriesProvider._({
    required WatchCategoriesFamily super.from,
    required TransactionType? super.argument,
  }) : super(
         retry: null,
         name: r'watchCategoriesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchCategoriesHash();

  @override
  String toString() {
    return r'watchCategoriesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<CategoryModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<CategoryModel>> create(Ref ref) {
    final argument = this.argument as TransactionType?;
    return watchCategories(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchCategoriesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchCategoriesHash() => r'b31ea26cd6fedde3f3dbfb3fc86afc6fdafdcff7';

final class WatchCategoriesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<CategoryModel>>,
          TransactionType?
        > {
  WatchCategoriesFamily._()
    : super(
        retry: null,
        name: r'watchCategoriesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchCategoriesProvider call(TransactionType? type) =>
      WatchCategoriesProvider._(argument: type, from: this);

  @override
  String toString() => r'watchCategoriesProvider';
}
