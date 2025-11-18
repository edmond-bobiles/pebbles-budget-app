import 'package:flutter/material.dart';
import '../models/budget.dart';
import '../services/storage_service.dart';

class AddBudgetScreen extends StatefulWidget {
  const AddBudgetScreen({super.key});

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

  String _selectedCategory = 'Bills & Utilities';

  late String _currentMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = "${now.year}-${now.month.toString().padLeft(2, '0')}";
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

    final newBudget = Budget(
      id: "b-${DateTime.now().millisecondsSinceEpoch}",
      category: _selectedCategory,
      limit: amount,
      month: _currentMonth,
      spent: 0.0,
    );

    StorageService.instance.addBudget(newBudget);

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
      appBar: AppBar(title: const Text("Create Budget")),
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

            Text("Month: $_currentMonth"),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: const Text("Save Budget"),
            ),
          ],
        ),
      ),
    );
  }
}
