import 'package:flutter/material.dart';
import '../models/transaction_item.dart';
import '../services/storage_service.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final TextEditingController _amountController = TextEditingController();

  String _selectedType = 'Expense'; // "Expense" or "Income"
  DateTime _selectedDate = DateTime.now();

  // Expense categories (match budget categories)
  final List<String> _expenseCategories = const [
    'Bills & Utilities',
    'Education',
    'Shopping',
    'Transportation',
    'Family',
    'Food & Beverage',
    'Health & Fitness',
    'Others',
  ];

  // Income categories
  final List<String> _incomeCategories = const [
    'Salary',
    'Incoming Transfer',
    'Interest',
    'Other Income',
  ];

  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = _expenseCategories.first;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submit() {
    final amountText = _amountController.text.trim();

    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount')),
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount')),
      );
      return;
    }

    final categories =
        _selectedType == 'Expense' ? _expenseCategories : _incomeCategories;
    final effectiveCategory = categories.contains(_selectedCategory)
        ? _selectedCategory
        : categories.first;

    final id = 't-${DateTime.now().millisecondsSinceEpoch}';
    final isExpense = _selectedType == 'Expense';

    final tx = TransactionItem(
      id: id,
      title: _selectedType,
      amount: amount,
      category: effectiveCategory,
      date: _selectedDate,
      isExpense: isExpense,
    );

    StorageService.instance.addTransaction(tx);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaction added')),
    );

    // Clear form (reset to defaults)
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
    final colorScheme = Theme.of(context).colorScheme;

    // Pick correct category list based on type
    final categories =
        _selectedType == 'Expense' ? _expenseCategories : _incomeCategories;

    // Ensure selected category is valid for the current list (local only)
    final effectiveCategory = categories.contains(_selectedCategory)
        ? _selectedCategory
        : categories.first;

    return Container
    (
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
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Header
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
                    const SizedBox(width: 12),
                    Text(
                      'Add Transaction',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Type selector
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
                            const Text('📝', style: TextStyle(fontSize: 20)),
                            const SizedBox(width: 8),
                            Text(
                              'Type',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: colorScheme.primary.withOpacity(0.3),
                            ),
                          ),
                          child: DropdownButton<String>(
                            value: _selectedType,
                            isExpanded: true,
                            underline: const SizedBox(),
                            icon: Icon(
                              Icons.arrow_drop_down,
                              color: colorScheme.primary,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Expense',
                                child: Row(
                                  children: [
                                    Text('💸'),
                                    SizedBox(width: 8),
                                    Text('Expense'),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'Income',
                                child: Row(
                                  children: [
                                    Text('💰'),
                                    SizedBox(width: 8),
                                    Text('Income'),
                                  ],
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() {
                                _selectedType = value;
                                _selectedCategory =
                                    value == 'Expense'
                                        ? _expenseCategories.first
                                        : _incomeCategories.first;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Amount
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
                            const Text('💵', style: TextStyle(fontSize: 20)),
                            const SizedBox(width: 8),
                            Text(
                              'Amount',
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
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Enter amount',
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

              // Category
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
                            const Text('📂', style: TextStyle(fontSize: 20)),
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
                          value: effectiveCategory,
                          items: categories
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
                            labelText: 'Select category',
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

              // Date
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
                            const Text('📅', style: TextStyle(fontSize: 20)),
                            const SizedBox(width: 8),
                            Text(
                              'Date',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: colorScheme.primary.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedDate
                                    .toLocal()
                                    .toIso8601String()
                                    .split('T')
                                    .first,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.primary,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: _pickDate,
                                icon: const Icon(
                                  Icons.calendar_today,
                                  size: 18,
                                ),
                                label: const Text('Pick Date'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.primary,
                                  foregroundColor: colorScheme.onPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Submit button
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
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Add Transaction',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
