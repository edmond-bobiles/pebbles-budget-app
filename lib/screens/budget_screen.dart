// lib/screens/budget_screen.dart
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../models/budget.dart';
import 'add_budget_screen.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final StorageService _storage = StorageService.instance;

  void _openCreateBudget() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddBudgetScreen()),
    );
  }

  void _editBudget(Budget b) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddBudgetScreen(budget: b)),
    );
  }

  void _confirmDelete(Budget b) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete budget?'),
        content: Text('Are you sure you want to delete the budget "${b.category}" for ${b.month}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed == true) {
      StorageService.instance.deleteBudget(b.id);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Budget deleted')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: _openCreateBudget,
              child: const Text("Create Budget"),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: ValueListenableBuilder<List<Budget>>(
                valueListenable: _storage.budgetsNotifier,
                builder: (context, budgets, _) {
                  if (budgets.isEmpty) {
                    return const Center(child: Text("No budgets created yet"));
                  }

                  return ListView.builder(
                    itemCount: budgets.length,
                    itemBuilder: (context, index) {
                      final b = budgets[index];
                      final remaining = b.limit - b.spent;
                      final pctUsed = b.limit > 0 ? (b.spent / b.limit).clamp(0.0, 1.0) : 0.0;

                      return Card(
                        child: ListTile(
                          title: Text(b.category),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Month: ${b.month}"),
                              const SizedBox(height: 6),
                              LinearProgressIndicator(
                                value: pctUsed,
                                minHeight: 8,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    pctUsed >= 1.0 ? Colors.red : Colors.green),
                              ),
                            ],
                          ),
                          trailing: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Limit: ₱${b.limit.toStringAsFixed(2)}"),
                              Text("Spent: ₱${b.spent.toStringAsFixed(2)}"),
                              Text(
                                "Remaining: ₱${remaining.toStringAsFixed(2)}",
                                style: TextStyle(
                                  color: remaining < 0 ? Colors.red : Colors.green,
                                ),
                              ),
                            ],
                          ),
                          // show edit/delete menu
                          onTap: () => _editBudget(b),
                          onLongPress: () => _confirmDelete(b),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
