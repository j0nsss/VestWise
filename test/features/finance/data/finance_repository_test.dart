import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:vestwise/core/errors/result.dart';
import 'package:vestwise/features/finance/data/models/category_model.dart';
import 'package:vestwise/features/finance/data/models/transaction_model.dart';
import 'package:vestwise/features/finance/data/repositories/finance_repository_impl.dart';
import 'package:vestwise/features/finance/domain/repositories/finance_repository.dart';

import '../../../helpers/isar_test_harness.dart';

TransactionModel _txn(
  double amount,
  TransactionType type, {
  DateTime? date,
}) =>
    TransactionModel()
      ..amount = amount
      ..type = type
      ..date = date ?? DateTime.now()
      ..createdAt = DateTime.now();

void main() {
  late IsarTestHarness harness;
  late FinanceRepository repo;

  setUp(() async {
    harness = await IsarTestHarness.create();
    repo = FinanceRepositoryImpl(harness.isar);
  });

  tearDown(() => harness.dispose());

  test('seedDefaultCategories seeds once and is idempotent', () async {
    await repo.seedDefaultCategories();
    final List<CategoryModel> first =
        (await repo.getAllCategories()).dataOrNull!;
    expect(first, isNotEmpty);
    expect(first.where((CategoryModel c) => c.isDefault), hasLength(first.length));

    await repo.seedDefaultCategories();
    final List<CategoryModel> second =
        (await repo.getAllCategories()).dataOrNull!;
    expect(second, hasLength(first.length));
  });

  test('getBalance is income minus expense', () async {
    await repo.createTransaction(_txn(1000, TransactionType.income));
    await repo.createTransaction(_txn(400, TransactionType.expense));

    final Result<double> balance = await repo.getBalance();
    expect(balance.dataOrNull, 600);
  });

  test('watchCategories filters by transaction type', () async {
    await repo.seedDefaultCategories();

    final List<CategoryModel> income =
        await repo.watchCategories(type: TransactionType.income).first;
    expect(income, isNotEmpty);
    expect(
      income.every((CategoryModel c) => c.type == TransactionType.income),
      isTrue,
    );

    final List<CategoryModel> all = await repo.watchCategories().first;
    expect(all.length, greaterThan(income.length));
  });

  test('watchTransactionsInRange only returns transactions within the range',
      () async {
    final DateTime day1 = DateTime(2026, 1, 1, 10);
    final DateTime day3 = DateTime(2026, 1, 3, 10);
    await repo.createTransaction(_txn(10, TransactionType.expense, date: day1));
    await repo.createTransaction(_txn(20, TransactionType.expense, date: day3));

    final List<TransactionModel> inRange = await repo
        .watchTransactionsInRange(DateTime(2026, 1, 1), DateTime(2026, 1, 2))
        .first;
    expect(inRange, hasLength(1));
    expect(inRange.single.amount, 10);
  });

  test('watchAllTransactions emits linked transactions without error', () async {
    await repo.seedDefaultCategories();
    final List<CategoryModel> categories =
        (await repo.getAllCategories()).dataOrNull!;
    final CategoryModel food =
        categories.firstWhere((CategoryModel c) => c.name == 'Food');

    final TransactionModel txn = _txn(100, TransactionType.expense)
      ..category.value = food;
    await repo.createTransaction(txn);

    final List<Object> errors = <Object>[];
    final List<List<TransactionModel>> emissions = <List<TransactionModel>>[];
    final StreamSubscription<List<TransactionModel>> sub = repo
        .watchAllTransactions()
        .listen(emissions.add, onError: errors.add);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    await sub.cancel();

    expect(errors, isEmpty, reason: 'stream errored: $errors');
    expect(emissions.last, hasLength(1));
    expect(emissions.last.single.category.value?.name, 'Food');
  });
}
