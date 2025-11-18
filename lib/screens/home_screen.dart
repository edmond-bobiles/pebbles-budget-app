import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../models/transaction_item.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _formatCurrency(double value) {
    // simple PH peso format
    return '₱ ${value.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final storage = StorageService.instance;
    final now = DateTime.now();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          // Listen to transactions so UI rebuilds when transactions/budgets change
          child: ValueListenableBuilder<List<TransactionItem>>(
            valueListenable: storage.transactionsNotifier,
            builder: (context, txList, _) {
              // compute month totals
              final year = now.year;
              final month = now.month;

              final incomeTotal = storage.totalIncomeForMonth(year, month);
              final expenseTotal = storage.totalExpensesForMonth(year, month);
              final netIncome = incomeTotal - expenseTotal;

              final totalActivity = (incomeTotal.abs() + expenseTotal.abs());
              final incomePercent = totalActivity > 0 ? (incomeTotal / totalActivity).clamp(0.0, 1.0) : 0.0;
              final expensePercent = totalActivity > 0 ? (expenseTotal / totalActivity).clamp(0.0, 1.0) : 0.0;

              // top spending categories (only expenses)
              final categoryTotals = storage.categoryTotalsForMonth(year, month);
              final sortedCategories = categoryTotals.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value));
              final topThree = sortedCategories.take(3).toList();

              // recent transactions (latest 5)
              final recent = List<TransactionItem>.from(txList)
                ..sort((a, b) => b.date.compareTo(a.date));
              final recentFive = recent.take(5).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Balance Row ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Balance', style: TextStyle(fontSize: 16)),
                      // show wallet balance from walletNotifier for accuracy
                      ValueListenableBuilder(
                        valueListenable: storage.walletNotifier,
                        builder: (context, wallet, _) {
                          final bal = wallet.balance as double;
                          final balText = _formatCurrency(bal);
                          return Text(
                            bal >= 0 ? balText : '- ${_formatCurrency(bal.abs())}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: bal < 0 ? Colors.red : Colors.black,
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // --- Net Income and progress bars ---
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Net Income', style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          Text(
                            (netIncome >= 0 ? '+ ' : '- ') + _formatCurrency(netIncome.abs()),
                            style: TextStyle(
                              fontSize: 18,
                              color: netIncome >= 0 ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Income bar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Income'),
                              Text(_formatCurrency(incomeTotal)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          LinearProgressIndicator(
                            value: incomePercent,
                            minHeight: 8,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                          ),

                          const SizedBox(height: 12),

                          // Expense bar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Expense'),
                              Text(_formatCurrency(expenseTotal)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          LinearProgressIndicator(
                            value: expensePercent,
                            minHeight: 8,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --- Top Spending ---
                  const Text('Top spending', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  if (topThree.isEmpty)
                    const Text('No expense data yet')
                  else
                    Column(
                      children: topThree.map((e) {
                        final cat = e.key;
                        final amt = e.value;
                        final pct = (expenseTotal > 0) ? (amt / expenseTotal) * 100 : 0.0;
                        return ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(cat),
                          subtitle: Text('${pct.toStringAsFixed(0)}%'),
                          trailing: Text(_formatCurrency(amt), style: const TextStyle(fontWeight: FontWeight.w600)),
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 12),

                  // --- Recent transactions header ---
                  const Text('Recent transactions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),

                  // Recent transactions list
                  Expanded(
                    child: recentFive.isEmpty
                        ? const Center(child: Text('No transactions yet'))
                        : ListView.separated(
                      itemCount: recentFive.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final t = recentFive[index];
                        return ListTile(
                          leading: Icon(
                            t.isExpense ? Icons.arrow_upward : Icons.arrow_downward,
                            color: t.isExpense ? Colors.red : Colors.green,
                          ),
                          title: Text(t.category),
                          subtitle: Text(t.date.toLocal().toIso8601String().split('T').first),
                          trailing: Text(
                            (t.isExpense ? '- ' : '+ ') + t.amount.toStringAsFixed(2),
                            style: TextStyle(color: t.isExpense ? Colors.red : Colors.green),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
