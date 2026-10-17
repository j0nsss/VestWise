import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:vestwise/core/constants/app_spacing.dart';
import 'package:vestwise/core/errors/failure.dart';
import 'package:vestwise/core/errors/result.dart';
import 'package:vestwise/core/widgets/vw_app_bar.dart';
import 'package:vestwise/core/widgets/vw_button.dart';
import 'package:vestwise/core/widgets/vw_loading_indicator.dart';
import 'package:vestwise/core/widgets/vw_text_field.dart';
import 'package:vestwise/features/finance/data/models/category_model.dart';
import 'package:vestwise/features/finance/data/models/transaction_model.dart';
import 'package:vestwise/features/finance/presentation/providers/finance_providers.dart';

/// Add/edit transaction form (plan P3-FIN-3). A non-null [transactionId]
/// switches the screen into edit mode.
class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({this.transactionId, super.key});

  final String? transactionId;

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  TransactionType _type = TransactionType.expense;
  DateTime _date = DateTime.now();
  CategoryModel? _selectedCategory;

  int? _transactionId;
  bool _loading = true;
  bool _saving = false;

  bool get _isEditing => _transactionId != null;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final String? raw = widget.transactionId;
    final int? id = raw == null ? null : int.tryParse(raw);
    if (id == null) {
      setState(() => _loading = false);
      return;
    }

    final TransactionModel? transaction =
        (await ref.read(financeRepositoryProvider).getTransactionById(id))
            .dataOrNull;
    if (transaction != null) {
      await transaction.category.load();
      _transactionId = transaction.id;
      _type = transaction.type;
      _date = transaction.date;
      _selectedCategory = transaction.category.value;
      _amountController.text = transaction.amount.toString();
      _noteController.text = transaction.note ?? '';
    }
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: VWAppBar(
        title: _isEditing ? 'Edit transaction' : 'Add transaction',
        actions: <Widget>[
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _loading ? null : _confirmDelete,
            ),
        ],
      ),
      body: _loading
          ? const VWLoadingIndicator()
          : Form(key: _formKey, child: _buildForm(context)),
    );
  }

  Widget _buildForm(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AsyncValue<List<CategoryModel>> categoriesAsync =
        ref.watch(watchCategoriesProvider(_type));

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: <Widget>[
        SegmentedButton<TransactionType>(
          segments: const <ButtonSegment<TransactionType>>[
            ButtonSegment<TransactionType>(
              value: TransactionType.expense,
              label: Text('Expense'),
              icon: Icon(Icons.arrow_downward),
            ),
            ButtonSegment<TransactionType>(
              value: TransactionType.income,
              label: Text('Income'),
              icon: Icon(Icons.arrow_upward),
            ),
          ],
          selected: <TransactionType>{_type},
          onSelectionChanged: (Set<TransactionType> selection) {
            setState(() {
              _type = selection.first;
              _selectedCategory = null;
            });
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        VWTextField(
          controller: _amountController,
          label: 'Amount',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (String? value) {
            final double? parsed = double.tryParse((value ?? '').trim());
            if (parsed == null || parsed <= 0) {
              return 'Enter an amount greater than 0';
            }
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        categoriesAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: VWLoadingIndicator(),
          ),
          error: (Object error, StackTrace stack) =>
              Text('Could not load categories', style: theme.textTheme.bodySmall),
          data: (List<CategoryModel> categories) => DropdownButtonFormField<int>(
            key: ValueKey<TransactionType>(_type),
            initialValue: _selectedCategory?.id,
            decoration: const InputDecoration(labelText: 'Category'),
            validator: (int? value) =>
                value == null ? 'Select a category' : null,
            items: categories
                .map(
                  (CategoryModel c) => DropdownMenuItem<int>(
                    value: c.id,
                    child: Text(c.name),
                  ),
                )
                .toList(),
            onChanged: (int? value) => setState(() {
              _selectedCategory = value == null
                  ? null
                  : categories.firstWhere(
                      (CategoryModel c) => c.id == value,
                    );
            }),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Date', style: theme.textTheme.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(
          icon: const Icon(Icons.event),
          label: Text(DateFormat.yMMMd().format(_date)),
          onPressed: _pickDate,
        ),
        const SizedBox(height: AppSpacing.lg),
        VWTextField(
          controller: _noteController,
          label: 'Note (optional)',
          maxLines: 2,
        ),
        const SizedBox(height: AppSpacing.xxl),
        VWButton(
          label: _isEditing ? 'Save changes' : 'Add transaction',
          expand: true,
          isLoading: _saving,
          onPressed: _save,
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null && mounted) {
      setState(() => _date = picked);
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() => _saving = true);

    final String note = _noteController.text.trim();
    final TransactionModel transaction = TransactionModel()
      ..date = _date
      ..amount = double.parse(_amountController.text.trim())
      ..type = _type
      ..note = note.isEmpty ? null : note
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();
    final CategoryModel? category = _selectedCategory;
    if (category != null) {
      transaction.category.value = category;
    }

    if (_isEditing) {
      transaction.id = _transactionId!;
      final Result<void> result =
          await ref.read(financeRepositoryProvider).updateTransaction(transaction);
      if (!mounted) {
        return;
      }
      result.fold(
        onSuccess: (_) => context.pop(),
        onError: (Failure f) => _onSaveFailed(f),
      );
    } else {
      final Result<int> result =
          await ref.read(financeRepositoryProvider).createTransaction(transaction);
      if (!mounted) {
        return;
      }
      result.fold(
        onSuccess: (_) => context.pop(),
        onError: (Failure f) => _onSaveFailed(f),
      );
    }
  }

  void _onSaveFailed(Failure failure) {
    setState(() => _saving = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(failure.message)));
  }

  Future<void> _confirmDelete() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete transaction?'),
        content: const Text('This cannot be undone.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }
    await ref.read(financeRepositoryProvider).deleteTransaction(_transactionId!);
    if (mounted) {
      context.pop();
    }
  }
}
