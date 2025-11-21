import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../models/transaction_item.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _formatCurrency(double value) {
    return '₱ ${value.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final storage = StorageService.instance;
    final now = DateTime.now();
    final colorScheme = Theme.of(context).colorScheme;

    final ScrollController _scrollController = ScrollController();

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
          child: Padding(
            padding: const EdgeInsets.all(16.0),

            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              radius: const Radius.circular(12),
              thickness: 6,

              child: SingleChildScrollView(
                controller: _scrollController,
                child: ValueListenableBuilder<List<TransactionItem>>(
                  valueListenable: storage.transactionsNotifier,
                  builder: (context, txList, _) {
                    final year = now.year;
                    final month = now.month;

                    final incomeTotal = storage.totalIncomeForMonth(year, month);
                    final expenseTotal = storage.totalExpensesForMonth(year, month);
                    final netIncome = incomeTotal - expenseTotal;

                    final totalActivity = incomeTotal.abs() + expenseTotal.abs();
                    final incomePercent =
                    totalActivity > 0 ? (incomeTotal / totalActivity).clamp(0.0, 1.0) : 0.0;
                    final expensePercent =
                    totalActivity > 0 ? (expenseTotal / totalActivity).clamp(0.0, 1.0) : 0.0;

                    final categoryTotals = storage.categoryTotalsForMonth(year, month);
                    final sortedCategories = categoryTotals.entries.toList()
                      ..sort((a, b) => b.value.compareTo(a.value));
                    final topThree = sortedCategories.take(3).toList();

                    final recent = List<TransactionItem>.from(txList)
                      ..sort((a, b) => b.date.compareTo(a.date));
                    final recentFive = recent.take(5).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Text('🏠', style: TextStyle(fontSize: 24)),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Home',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Balance Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                colorScheme.primary,
                                colorScheme.primaryContainer,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary.withOpacity(0.3),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Balance',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: colorScheme.onPrimary.withOpacity(0.9),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ValueListenableBuilder(
                                    valueListenable: storage.walletNotifier,
                                    builder: (context, wallet, _) {
                                      final bal = wallet.balance as double;
                                      final balText = _formatCurrency(bal);
                                      return Text(
                                        bal >= 0 ? balText : '- ${_formatCurrency(bal.abs())}',
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.onPrimary,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: colorScheme.onPrimary.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Text('💵', style: TextStyle(fontSize: 32)),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Net Income Card
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
                                      const Text('📊', style: TextStyle(fontSize: 20)),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Net Income',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    (netIncome >= 0 ? '+ ' : '- ') +
                                        _formatCurrency(netIncome.abs()),
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: netIncome >= 0
                                          ? Colors.green.shade700
                                          : Colors.red.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  // Income bar
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Income'),
                                      Text(
                                        _formatCurrency(incomeTotal),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(
                                      value: incomePercent,
                                      minHeight: 12,
                                      backgroundColor: Colors.grey[200],
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.green.shade400,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // Expense bar
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Expense'),
                                      Text(
                                        _formatCurrency(expenseTotal),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(
                                      value: expensePercent,
                                      minHeight: 12,
                                      backgroundColor: Colors.grey[200],
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.red.shade400,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Top Spending
                        Row(
                          children: [
                            const Text('⭐', style: TextStyle(fontSize: 20)),
                            const SizedBox(width: 8),
                            Text(
                              'Top Spending',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        if (topThree.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'No expense data yet',
                              style: TextStyle(
                                color: colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          )
                        else
                          ...topThree.map((e) {
                            final cat = e.key;
                            final amt = e.value;
                            final pct = expenseTotal > 0 ? (amt / expenseTotal) * 100 : 0.0;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: colorScheme.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: colorScheme.primary.withOpacity(0.2),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: colorScheme.primary.withOpacity(0.1),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child:
                                    const Text('📦', style: TextStyle(fontSize: 20)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          cat,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          '${pct.toStringAsFixed(0)}% of expenses',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color:
                                            colorScheme.onSurface.withOpacity(0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    _formatCurrency(amt),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),

                        const SizedBox(height: 20),

                        // Recent transactions
                        Row(
                          children: [
                            const Text('🕐', style: TextStyle(fontSize: 20)),
                            const SizedBox(width: 8),
                            Text(
                              'Recent Transactions',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        if (recentFive.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: Column(
                                children: [
                                  const Text('📝', style: TextStyle(fontSize: 48)),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No transactions yet',
                                    style: TextStyle(
                                      color: colorScheme.onSurface.withOpacity(0.6),
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          Column(
                            children: recentFive.map((t) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: colorScheme.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: colorScheme.primary.withOpacity(0.2),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                      colorScheme.primary.withOpacity(0.1),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: t.isExpense
                                            ? Colors.red.shade50
                                            : Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        t.isExpense
                                            ? Icons.arrow_upward
                                            : Icons.arrow_downward,
                                        color: t.isExpense
                                            ? Colors.red.shade700
                                            : Colors.green.shade700,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            t.category,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                            ),
                                          ),
                                          Text(
                                            t.date
                                                .toLocal()
                                                .toIso8601String()
                                                .split('T')
                                                .first,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: colorScheme.onSurface
                                                  .withOpacity(0.6),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      (t.isExpense ? '- ' : '+ ') +
                                          _formatCurrency(t.amount),
                                      style: TextStyle(
                                        color: t.isExpense
                                            ? Colors.red.shade700
                                            : Colors.green.shade700,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),

                        const SizedBox(height: 50),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
