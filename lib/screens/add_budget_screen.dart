// lib/screens/add_budget_screen.dart
import 'package:flutter/material.dart';
import '../models/budget.dart';
import '../services/storage_service.dart';

class AddBudgetScreen extends StatefulWidget {
  // Optional budget to edit; if null -> create new
  final Budget? budget;
  const AddBudgetScreen({super.key, this.budget});

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final TextEditingController _amountController = TextEditingController();

  final List<String> _categories = const [
    'Bills & Utilities',
    'Education',
    'Shopping',
    'Transportation',
    'Family',
    'Food & Beverage',
    'Health & Fitness',
    'Others',
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
        const SnackBar(content: Text("Enter a limit amount")),
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid amount")),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Budget updated')),
      );
    } else {
      final newBudget = Budget(
        id: "b-${DateTime.now().millisecondsSinceEpoch}",
        category: _selectedCategory,
        limit: amount,
        month: _currentMonth,
        spent: 0.0,
      );
      StorageService.instance.addBudget(newBudget);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Budget created')),
      );
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primaryContainer.withOpacity(0.3),
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(height: 12),

                // Header (matches Add / Home style)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.pie_chart_rounded,
                        color: colorScheme.onPrimary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isEditMode ? 'Edit Budget' : 'Create Budget',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Category card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.surface,
                          colorScheme.primaryContainer.withOpacity(0.3),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.category_rounded, size: 22),
                              const SizedBox(width: 8),
                              Text(
                                'Category',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            items: _categories
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _selectedCategory = value);
                              }
                            },
                            decoration: InputDecoration(
                              labelText: "Select category",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Amount card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.surface,
                          colorScheme.primaryContainer.withOpacity(0.3),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.savings_rounded, size: 22),
                              const SizedBox(width: 8),
                              Text(
                                'Budget Limit',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _amountController,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              labelText: "Budget Limit (Amount)",
                              prefixText: '₱ ',
                              prefixStyle: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                              border: const UnderlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Month info card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: colorScheme.primaryContainer.withOpacity(0.4),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Month:",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _currentMonth,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Save button
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      isEditMode ? 'Save Changes' : 'Save Budget',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
