import 'package:flutter/material.dart';
import 'package:vestwise/core/widgets/icon_data_from_code_point.dart';
import 'package:vestwise/core/widgets/vw_category_chip.dart';
import 'package:vestwise/features/finance/data/models/category_model.dart';

/// A [CategoryModel] rendered as a chip (plan2.md P10-FIN-1).
///
/// The only place a category becomes a chip, so the list row, the picker in the
/// add-transaction form and the summary breakdown cannot drift apart. The
/// visuals live in [VWCategoryChip] in `core/widgets` — this just maps the
/// stored model onto it.
class CategoryChip extends StatelessWidget {
  const CategoryChip({
    required this.category,
    this.showLabel = true,
    this.onTap,
    this.selected = false,
    this.dense = false,
    super.key,
  });

  final CategoryModel category;

  /// Whether to show the name. List rows use icon-only, where the row already
  /// says the category's name.
  final bool showLabel;

  final VoidCallback? onTap;
  final bool selected;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return VWCategoryChip(
      icon: iconDataFromCodePoint(category.iconCodePoint),
      label: showLabel ? category.name : null,
      onTap: onTap,
      selected: selected,
      dense: dense,
    );
  }
}
