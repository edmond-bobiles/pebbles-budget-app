// lib/screens/add_transaction_screen.dart
import 'package:flutter/material.dart';
import '../models/transaction_item.dart';
import '../services/storage_service.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final _amountController = TextEditingController();
  String _selectedType = 'Expense'; // "Expense" or "Income"
  DateTime _selectedDate = DateTime.now();

  // categories split by type
  final List<String> _expenseCategories = [
    'Food & Beverage',
    'Transport',
    'Shopping',
    'Bills',
    'Entertainment',
    'Other'
  ];

  final List<String> _incomeCategories = [
    'Salary',
    'Incoming Transfer',
    'Interest',
    'Other Income'
  ];

  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = _expenseCategories.first;
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _submit() {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter an amount')));
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid amount')));
      return;
    }

    final id = 't-${DateTime.now().millisecondsSinceEpoch}';
    final isExpense = _selectedType == 'Expense';
    final tx = TransactionItem(
      id: id,
      title: _selectedType, // Title is now either "Expense" or "Income"
      amount: amount,
      category: _selectedCategory,
      date: _selectedDate,
      isExpense: isExpense,
    );

    StorageService.instance.addTransaction(tx);

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaction added')));

    // clear form (reset to defaults)
    setState(() {
      _amountController.clear();
      _selectedType = 'Expense';
      _selectedCategory = _expenseCategories.first;
      _selectedDate = DateTime.now();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // determine category list based on type
    final categories = _selectedType == 'Expense' ? _expenseCategories : _incomeCategories;

    // ensure selected category valid for the new list
    if (!categories.contains(_selectedCategory)) {
      _selectedCategory = categories.first;
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 8),
            const Text('Add Transaction'),
            const SizedBox(height: 12),

            // Type selector (Expense / Income)
            Row(
              children: [
                const Text('Type: '),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedType,
                  items: const [
                    DropdownMenuItem(value: 'Expense', child: Text('Expense')),
                    DropdownMenuItem(value: 'Income', child: Text('Income')),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      setState(() {
                        _selectedType = v;
                        // change selectedCategory to first of the appropriate list
                        _selectedCategory = (_selectedType == 'Expense') ? _expenseCategories.first : _incomeCategories.first;
                      });
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 8),

            // amount
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            const SizedBox(height: 8),

            // category (depends on type)
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedCategory = v);
              },
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 8),

            // date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Date: ${_selectedDate.toLocal().toIso8601String().split('T').first}'),
                TextButton(onPressed: _pickDate, child: const Text('Pick'))
              ],
            ),

            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
