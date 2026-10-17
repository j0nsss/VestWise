import 'package:isar_community/isar.dart';
import 'package:vestwise/features/finance/data/models/category_model.dart';

part 'transaction_model.g.dart';

@collection
class TransactionModel {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime date;

  /// Always stored as a positive value; sign is derived from [type].
  late double amount;

  @enumerated
  late TransactionType type;

  final category = IsarLink<CategoryModel>();

  String? note;

  @Index()
  late DateTime createdAt;

  DateTime? updatedAt;
}
