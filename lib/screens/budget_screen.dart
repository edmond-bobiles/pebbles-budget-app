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
  final ScrollController _scrollController = ScrollController();

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
    final theme = Theme.of(context);
    final blueScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            blueScheme.primaryContainer.withOpacity(0.3),
            blueScheme.surface,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),

            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              radius: const Radius.circular(12),
              thickness: 6,

              child: SingleChildScrollView(
                controller: _scrollController,

                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // HEADER
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: blueScheme.primary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text('📊', style: TextStyle(fontSize: 24)),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Budgets',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: blueScheme.primary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // CREATE BUDGET BUTTON
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: blueScheme.primary.withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _openCreateBudget,
                        icon: const Icon(Icons.add_circle_outline, size: 24),
                        label: const Text(
                          "Create Budget",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: blueScheme.primary,
                          foregroundColor: blueScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // LIST AREA
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.73,

                      child: ValueListenableBuilder<List<Budget>>(
                        valueListenable: _storage.budgetsNotifier,
                        builder: (context, budgets, _) {
                          if (budgets.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('📝', style: TextStyle(fontSize: 64)),
                                  const SizedBox(height: 16),
                                  Text(
                                    "No budgets created yet",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: blueScheme.onSurface.withOpacity(0.6),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Create your first budget! 🎯",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: blueScheme.onSurface.withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: budgets.length,
                            itemBuilder: (context, index) {
                              final b = budgets[index];
                              final remaining = b.limit - b.spent;
                              final pctUsed =
                              b.limit > 0 ? (b.spent / b.limit).clamp(0.0, 1.0) : 0.0;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: InkWell(
                                    onTap: () => _editBudget(b),
                                    onLongPress: () => _confirmDelete(b),
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        gradient: LinearGradient(
                                          colors: [
                                            blueScheme.surface,
                                            blueScheme.primaryContainer.withOpacity(0.3),
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
                                                Container(
                                                  padding: const EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                    color: blueScheme.primaryContainer,
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: const Text('📦',
                                                      style: TextStyle(fontSize: 24)),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        b.category,
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.bold,
                                                          color: blueScheme.primary,
                                                        ),
                                                      ),
                                                      Text(
                                                        "Month: ${b.month}",
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: blueScheme.onSurface
                                                              .withOpacity(0.6),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),

                                            const SizedBox(height: 16),

                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: LinearProgressIndicator(
                                                value: pctUsed,
                                                minHeight: 14,
                                                backgroundColor: Colors.grey[200],
                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                  pctUsed >= 1.0
                                                      ? Colors.red.shade400
                                                      : Colors.green.shade400,
                                                ),
                                              ),
                                            ),

                                            const SizedBox(height: 12),

                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Limit",
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: blueScheme.onSurface
                                                            .withOpacity(0.6),
                                                      ),
                                                    ),
                                                    Text(
                                                      "₱${b.limit.toStringAsFixed(2)}",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                        color: blueScheme.primary,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Column(
                                                  children: [
                                                    Text(
                                                      "Spent",
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: blueScheme.onSurface
                                                            .withOpacity(0.6),
                                                      ),
                                                    ),
                                                    Text(
                                                      "₱${b.spent.toStringAsFixed(2)}",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      "Remaining",
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: blueScheme.onSurface
                                                            .withOpacity(0.6),
                                                      ),
                                                    ),
                                                    Text(
                                                      "₱${remaining.toStringAsFixed(2)}",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                        color: remaining < 0
                                                            ? Colors.red.shade700
                                                            : Colors.green.shade700,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),

                                            const SizedBox(height: 8),
                                            Text(
                                              "Tap to edit • Long press to delete",
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: blueScheme.onSurface
                                                    .withOpacity(0.4),
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
