import 'package:isar_community/isar.dart';

part 'category_model.g.dart';

enum TransactionType { income, expense }

@collection
class CategoryModel {
  Id id = Isar.autoIncrement;

  late String name;

  /// Material icon codePoint, rendered via IconData(iconCodePoint, fontFamily: ...)
  late int iconCodePoint;

  /// ARGB color value, e.g. Colors.teal.value
  late int colorValue;

  @enumerated
  late TransactionType type;

  bool isDefault = false;
}
