import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vestwise/core/database/isar_provider.dart';
import 'package:vestwise/features/finance/data/models/category_model.dart';
import 'package:vestwise/features/finance/data/models/transaction_model.dart';
import 'package:vestwise/features/finance/data/repositories/finance_repository_impl.dart';
import 'package:vestwise/features/finance/domain/models/daily_net.dart';
import 'package:vestwise/features/finance/domain/repositories/finance_repository.dart';

part 'finance_providers.g.dart';

/// How many transactions the finance home loads at a time. Older rows are
/// pulled in only when the user asks for them, so a long history stays cheap
/// to render (plan P5-T5).
const int financeHistoryPageSize = 50;

@riverpod
FinanceRepository financeRepository(Ref ref) {
  return FinanceRepositoryImpl(ref.watch(isarProvider).requireValue);
}

@riverpod
Stream<List<TransactionModel>> watchAllTransactions(Ref ref) =>
    ref.watch(financeRepositoryProvider).watchAllTransactions();

@riverpod
Stream<List<TransactionModel>> watchRecentTransactions(Ref ref, int limit) =>
    ref.watch(financeRepositoryProvider).watchRecentTransactions(limit: limit);

@riverpod
Stream<List<TransactionModel>> watchTransactionsInRange(
  Ref ref,
  DateTime start,
  DateTime end,
) =>
    ref.watch(financeRepositoryProvider).watchTransactionsInRange(start, end);

/// Seven days of daily net for the dashboard sparkline (plan2.md P10-FIN-2).
@riverpod
Stream<List<DailyNet>> watchLast7DaysNet(Ref ref) =>
    ref.watch(financeRepositoryProvider).watchLast7DaysNet();

@riverpod
Future<double> balance(Ref ref) async {
  final result = await ref.watch(financeRepositoryProvider).getBalance();
  return result.fold(
    onSuccess: (double value) => value,
    onError: (failure) => throw StateError(failure.message),
  );
}

@riverpod
Stream<List<CategoryModel>> watchCategories(
  Ref ref,
  TransactionType? type,
) =>
    ref.watch(financeRepositoryProvider).watchCategories(type: type);
