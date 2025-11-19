// lib/screens/add_budget_screen.dart
import 'package:flutter/material.dart';
import '../models/budget.dart';
import '../services/storage_service.dart';

class AddBudgetScreen extends StatefulWidget {
  // optional budget to edit; if null -> create new
  final Budget? budget;
  const AddBudgetScreen({super.key, this.budget});

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final _amountController = TextEditingController();

  final List<String> _categories = [
    'Bills & Utilities',
    'Education',
    'Shopping',
    'Transportation',
    'Family',
    'Food & Beverage',
    'Health & Fitness',
    'Others'
  ];

  late String _selectedCategory;
  late String _currentMonth;
  bool get isEditMode => widget.budget != null;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = "${now.year}-${now.month.toString().padLeft(2, '0')}";

    if (isEditMode) {
      final b = widget.budget!;
      _selectedCategory = b.category;
      _amountController.text = b.limit.toString();
      _currentMonth = b.month; // keep existing month
    } else {
      _selectedCategory = _categories.first;
    }
  }

  void _submit() {
    final amountText = _amountController.text.trim();

    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Enter a limit amount")));
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Enter a valid amount")));
      return;
    }

    if (isEditMode) {
      final existing = widget.budget!;
      final updated = Budget(
        id: existing.id,
        category: _selectedCategory,
        limit: amount,
        month: existing.month,
        spent: existing.spent, // preserve spent
      );
      StorageService.instance.updateBudget(updated);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Budget updated')));
    } else {
      final newBudget = Budget(
        id: "b-${DateTime.now().millisecondsSinceEpoch}",
        category: _selectedCategory,
        limit: amount,
        month: _currentMonth,
        spent: 0.0,
      );
      StorageService.instance.addBudget(newBudget);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Budget created')));
    }

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Budget' : 'Create Budget'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedCategory = v);
              },
              decoration: const InputDecoration(labelText: "Category"),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Budget Limit (Amount)"),
            ),
            const SizedBox(height: 16),

            // show month but don't allow editing here to keep things simple
            Text("Month: $_currentMonth"),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: Text(isEditMode ? 'Save changes' : 'Save Budget'),
            ),
          ],
        ),
      ),
    );
  }
}
