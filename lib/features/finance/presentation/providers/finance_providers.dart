import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vestwise/core/database/isar_provider.dart';
import 'package:vestwise/features/finance/data/models/category_model.dart';
import 'package:vestwise/features/finance/data/models/transaction_model.dart';
import 'package:vestwise/features/finance/data/repositories/finance_repository_impl.dart';
import 'package:vestwise/features/finance/domain/repositories/finance_repository.dart';

part 'finance_providers.g.dart';

@riverpod
FinanceRepository financeRepository(Ref ref) {
  return FinanceRepositoryImpl(ref.watch(isarProvider).requireValue);
}

@riverpod
Stream<List<TransactionModel>> watchAllTransactions(Ref ref) =>
    ref.watch(financeRepositoryProvider).watchAllTransactions();

@riverpod
Stream<List<TransactionModel>> watchTransactionsInRange(
  Ref ref,
  DateTime start,
  DateTime end,
) =>
    ref.watch(financeRepositoryProvider).watchTransactionsInRange(start, end);

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
