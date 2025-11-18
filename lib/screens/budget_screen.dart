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

                      return Card(
                        child: ListTile(
                          title: Text(b.category),
                          subtitle: Text("Month: ${b.month}"),
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
