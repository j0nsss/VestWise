import 'package:vestwise/core/errors/result.dart';
import 'package:vestwise/features/finance/data/models/category_model.dart';
import 'package:vestwise/features/finance/data/models/transaction_model.dart';
import 'package:vestwise/features/finance/domain/models/daily_net.dart';

/// Data-access boundary for finance (plan P2-T2).
abstract interface class FinanceRepository {
  Stream<List<TransactionModel>> watchAllTransactions();

  /// The newest [limit] transactions, most recent first.
  ///
  /// The finance home uses this instead of [watchAllTransactions] so a long
  /// history never has to be held in memory at once (plan P5-T5); the caller
  /// asks for the next window when the user reaches the end of the list.
  Stream<List<TransactionModel>> watchRecentTransactions({required int limit});

  Stream<List<TransactionModel>> watchTransactionsInRange(
    DateTime start,
    DateTime end,
  );

  /// Net per day for the seven days ending today, oldest first (plan2.md
  /// P10-FIN-2).
  ///
  /// Additive: the dashboard's sparkline needs a week of daily deltas, and
  /// neither [watchRecentTransactions] (a row window) nor
  /// [watchTransactionsInRange] (whole transactions) gives that. It stays
  /// bounded the same way they do — an indexed range on `date`, at most a
  /// week of rows, no full-table scan. Days with no transactions are included
  /// as zero rather than omitted, so the sparkline always has seven points.
  Stream<List<DailyNet>> watchLast7DaysNet();

  Future<Result<TransactionModel>> getTransactionById(int id);

  Future<Result<int>> createTransaction(TransactionModel transaction);

  Future<Result<void>> updateTransaction(TransactionModel transaction);

  Future<Result<void>> deleteTransaction(int id);

  /// Current balance = sum(income) − sum(expense) over all transactions.
  Future<Result<double>> getBalance();

  Stream<List<CategoryModel>> watchCategories({TransactionType? type});

  Future<Result<List<CategoryModel>>> getAllCategories();

  Future<Result<int>> createCategory(CategoryModel category);

  /// Inserts the default income/expense categories once (plan P3-FIN-1).
  /// No-op if categories are already present.
  Future<Result<void>> seedDefaultCategories();
}
