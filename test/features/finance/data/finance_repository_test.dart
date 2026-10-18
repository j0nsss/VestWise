import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:vestwise/core/errors/result.dart';
import 'package:vestwise/features/finance/data/models/category_model.dart';
import 'package:vestwise/features/finance/data/models/transaction_model.dart';
import 'package:vestwise/features/finance/data/repositories/finance_repository_impl.dart';
import 'package:vestwise/features/finance/domain/models/daily_net.dart';
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

  test('watchRecentTransactions caps the window at the newest rows', () async {
    for (int i = 0; i < 5; i++) {
      await repo.createTransaction(
        _txn(10.0 + i, TransactionType.expense, date: DateTime(2026, 1, 1 + i)),
      );
    }

    final List<TransactionModel> recent =
        await repo.watchRecentTransactions(limit: 2).first;

    expect(recent, hasLength(2));
    // Newest first: 1 Jan + 4 days, then the day before.
    expect(recent.first.amount, 14);
    expect(recent.last.amount, 13);
  });

  group('watchLast7DaysNet (P10-FIN-2)', () {
    /// Local midnight, `daysAgo` days before today.
    DateTime todayMinus(int daysAgo) {
      final DateTime now = DateTime.now();
      return DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: daysAgo));
    }

    test('always returns seven days, oldest first, including empty ones',
        () async {
      final List<DailyNet> week = await repo.watchLast7DaysNet().first;

      expect(week, hasLength(7));
      expect(week.first.day, todayMinus(6));
      expect(week.last.day, todayMinus(0));
      for (final DailyNet day in week) {
        expect(day.net, 0, reason: 'a day with no activity is a zero, not a gap');
      }
    });

    test('nets income against expense per day', () async {
      await repo.createTransaction(
        _txn(300, TransactionType.income, date: todayMinus(0)),
      );
      await repo.createTransaction(
        _txn(50, TransactionType.expense, date: todayMinus(0)),
      );
      await repo.createTransaction(
        _txn(20, TransactionType.expense, date: todayMinus(3)),
      );
      await repo.createTransaction(
        _txn(500, TransactionType.income, date: todayMinus(6)),
      );

      final List<DailyNet> week = await repo.watchLast7DaysNet().first;

      expect(week.last.net, 250);
      expect(week[3].net, -20);
      expect(week.first.net, 500);
      expect(
        week.where((DailyNet d) => d.net == 0),
        hasLength(4),
      );
    });

    test('ignores anything older than the window', () async {
      await repo.createTransaction(
        _txn(999, TransactionType.income, date: todayMinus(30)),
      );
      await repo.createTransaction(
        _txn(11, TransactionType.income, date: todayMinus(7)),
      );
      await repo.createTransaction(
        _txn(12, TransactionType.income, date: todayMinus(6)),
      );

      final List<DailyNet> week = await repo.watchLast7DaysNet().first;

      expect(week, hasLength(7));
      expect(week.first.net, 12);
      expect(
        week.fold<double>(0, (double sum, DailyNet d) => sum + d.net),
        12,
        reason: 'day -7 and day -30 must not leak in',
      );
    });

    test('re-emits when a transaction lands in the window', () async {
      final List<DailyNet> week = await repo.watchLast7DaysNet().first;
      expect(week.last.net, 0);

      await repo.createTransaction(
        _txn(75, TransactionType.income, date: todayMinus(0)),
      );

      final List<DailyNet> updated = await repo.watchLast7DaysNet().first;
      expect(updated.last.net, 75);
    });
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
