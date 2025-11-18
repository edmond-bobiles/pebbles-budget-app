// lib/screens/transactions_screen.dart
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../models/transaction_item.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final StorageService _storage = StorageService.instance;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<TransactionItem>>(
      valueListenable: _storage.transactionsNotifier,
      builder: (context, list, _) {
        if (list.isEmpty) {
          return const Center(child: Text('No transactions yet'));
        }

        // show newest first
        final sorted = List<TransactionItem>.from(list)..sort((a, b) => b.date.compareTo(a.date));

        return ListView.separated(
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, idx) {
            final t = sorted[idx];
            // show type (title) explicitly and category + date as subtitle
            return Dismissible(
              key: Key(t.id),
              background: Container(
                  color: Colors.red,
                  padding: const EdgeInsets.only(left: 16),
                  alignment: Alignment.centerLeft,
                  child: const Icon(Icons.delete, color: Colors.white)),
              direction: DismissDirection.startToEnd,
              onDismissed: (_) {
                _storage.deleteTransaction(t.id);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaction deleted')));
              },
              child: ListTile(
                leading: Icon(t.isExpense ? Icons.arrow_upward : Icons.arrow_downward,
                    color: t.isExpense ? Colors.red : Colors.green),
                title: Text(t.title), // will be "Expense" or "Income"
                subtitle: Text('${t.category} • ${t.date.toLocal().toIso8601String().split('T').first}'),
                trailing: Text(
                  (t.isExpense ? '- ' : '+ ') + t.amount.toStringAsFixed(2),
                  style: TextStyle(color: t.isExpense ? Colors.red : Colors.green),
                ),
              ),
            );
          },
          separatorBuilder: (_, __) => const Divider(),
          itemCount: sorted.length,
        );
      },
    );
  }
}
