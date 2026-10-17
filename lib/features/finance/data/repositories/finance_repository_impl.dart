import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';
import 'package:vestwise/core/constants/app_colors.dart';
import 'package:vestwise/core/errors/result.dart';
import 'package:vestwise/core/errors/result_guard.dart';
import 'package:vestwise/features/finance/data/models/category_model.dart';
import 'package:vestwise/features/finance/data/models/transaction_model.dart';
import 'package:vestwise/features/finance/domain/repositories/finance_repository.dart';

class FinanceRepositoryImpl implements FinanceRepository {
  FinanceRepositoryImpl(this._isar);

  final Isar _isar;

  IsarCollection<TransactionModel> get _transactions => _isar.transactionModels;
  IsarCollection<CategoryModel> get _categories => _isar.categoryModels;

  @override
  Stream<List<TransactionModel>> watchAllTransactions() => _transactions
      .where()
      .sortByDateDesc()
      .thenByIdDesc()
      .watch(fireImmediately: true)
      .asyncMap(_withLoadedCategories);

  @override
  Stream<List<TransactionModel>> watchTransactionsInRange(
    DateTime start,
    DateTime end,
  ) =>
      _transactions
          .where()
          .dateBetween(start, end)
          .sortByDateDesc()
          .watch(fireImmediately: true)
          .asyncMap(_withLoadedCategories);

  /// Eagerly loads each transaction's category link so the UI can render the
  /// category icon/color without an extra async hop per list row.
  Future<List<TransactionModel>> _withLoadedCategories(
    List<TransactionModel> transactions,
  ) async {
    await Future.wait(
      transactions.map((TransactionModel t) => t.category.load()),
    );
    return transactions;
  }

  @override
  Future<Result<TransactionModel>> getTransactionById(int id) => resultGuard(
        () async {
          final TransactionModel? transaction = await _transactions.get(id);
          if (transaction == null) {
            throw StateError('Transaction $id not found');
          }
          return transaction;
        },
        operation: 'getTransactionById',
      );

  @override
  Future<Result<int>> createTransaction(TransactionModel transaction) =>
      resultGuard(
        () async {
          await _isar.writeTxn(() async {
            transaction.id = await _transactions.put(transaction);
            await transaction.category.save();
          });
          return transaction.id;
        },
        operation: 'createTransaction',
      );

  @override
  Future<Result<void>> updateTransaction(TransactionModel transaction) =>
      resultGuard(
        () async {
          await _isar.writeTxn(() async {
            await _transactions.put(transaction);
            await transaction.category.save();
          });
        },
        operation: 'updateTransaction',
      );

  @override
  Future<Result<void>> deleteTransaction(int id) => resultGuard(
        () async {
          await _isar.writeTxn(() => _transactions.delete(id));
        },
        operation: 'deleteTransaction',
      );

  @override
  Future<Result<double>> getBalance() => resultGuard(
        () async {
          final double income = await _transactions
              .filter()
              .typeEqualTo(TransactionType.income)
              .amountProperty()
              .sum();
          final double expense = await _transactions
              .filter()
              .typeEqualTo(TransactionType.expense)
              .amountProperty()
              .sum();
          return income - expense;
        },
        operation: 'getBalance',
      );

  @override
  Stream<List<CategoryModel>> watchCategories({TransactionType? type}) {
    if (type == null) {
      return _categories.where().sortByName().watch(fireImmediately: true);
    }
    return _categories
        .filter()
        .typeEqualTo(type)
        .sortByName()
        .watch(fireImmediately: true);
  }

  @override
  Future<Result<List<CategoryModel>>> getAllCategories() => resultGuard(
        _categories.where().sortByName().findAll,
        operation: 'getAllCategories',
      );

  @override
  Future<Result<int>> createCategory(CategoryModel category) => resultGuard(
        () async {
          await _isar.writeTxn(() async {
            category.id = await _categories.put(category);
          });
          return category.id;
        },
        operation: 'createCategory',
      );

  @override
  Future<Result<void>> seedDefaultCategories() => resultGuard(
        () async {
          final int existing = await _categories.count();
          if (existing > 0) {
            return;
          }
          await _isar.writeTxn(() async {
            await _categories.putAll(_defaultCategories());
          });
        },
        operation: 'seedDefaultCategories',
      );

  List<CategoryModel> _defaultCategories() {
    final int incomeColor = AppColors.incomeGreen.toARGB32();

    return <CategoryModel>[
      _category('Salary', Icons.work_outline, TransactionType.income, incomeColor),
      _category('Allowance', Icons.savings_outlined, TransactionType.income, incomeColor),
      _category('Gift', Icons.card_giftcard, TransactionType.income, incomeColor),
      _category('Other Income', Icons.attach_money, TransactionType.income, incomeColor),
      _category('Food', Icons.restaurant, TransactionType.expense, Colors.orange.toARGB32()),
      _category('Transport', Icons.directions_bus, TransactionType.expense, Colors.blue.toARGB32()),
      _category('Shopping', Icons.shopping_bag_outlined, TransactionType.expense, Colors.purple.toARGB32()),
      _category('Bills', Icons.receipt_long, TransactionType.expense, Colors.teal.toARGB32()),
      _category('Education', Icons.school_outlined, TransactionType.expense, Colors.indigo.toARGB32()),
      _category('Entertainment', Icons.movie_outlined, TransactionType.expense, Colors.pink.toARGB32()),
      _category('Health', Icons.favorite_border, TransactionType.expense, Colors.red.toARGB32()),
      _category('Other', Icons.category_outlined, TransactionType.expense, Colors.blueGrey.toARGB32()),
    ];
  }

  CategoryModel _category(
    String name,
    IconData icon,
    TransactionType type,
    int color,
  ) =>
      CategoryModel()
        ..name = name
        ..iconCodePoint = icon.codePoint
        ..colorValue = color
        ..type = type
        ..isDefault = true;
}
