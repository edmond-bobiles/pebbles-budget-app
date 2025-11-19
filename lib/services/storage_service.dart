// lib/services/storage_service.dart
import 'package:flutter/foundation.dart';
import '../models/transaction_item.dart';
import '../models/budget.dart';
import '../models/wallet.dart';

class StorageService {
  // singleton
  StorageService._private();
  static final StorageService instance = StorageService._private();

  // Wallet
  Wallet wallet = Wallet(balance: 0.0);

  // Data lists
  final List<TransactionItem> _transactions = [];
  final List<Budget> _budgets = [];

  // Notifiers so UI can react
  final ValueNotifier<List<TransactionItem>> transactionsNotifier = ValueNotifier([]);
  final ValueNotifier<Wallet> walletNotifier = ValueNotifier(Wallet(balance: 0.0));
  final ValueNotifier<List<Budget>> budgetsNotifier = ValueNotifier([]);

  // User
  final Map<String, String> user = {
    "username": "budget",
    "password": "pebbles"
  };

  // Wallet
  void updateWallet(Wallet w) {
    wallet = w;
    walletNotifier.value = wallet;
  }

  Wallet getWallet() => wallet;

  // Transactions
  void addTransaction(TransactionItem t) {
    _transactions.add(t);

    // update wallet balance
    if (t.isExpense) {
      wallet.balance -= t.amount;
    } else {
      wallet.balance += t.amount;
    }
    walletNotifier.value = wallet;

    // update budgets spent if applicable
    for (var b in _budgets) {
      final sameMonth = t.date.year.toString() + "-" + t.date.month.toString().padLeft(2, '0');
      if (b.category == t.category && b.month == sameMonth && t.isExpense) {
        b.spent += t.amount;
      }
    }
    budgetsNotifier.value = List<Budget>.from(_budgets);

    // refresh transactions notifier
    transactionsNotifier.value = List<TransactionItem>.from(_transactions);
  }

  void deleteTransaction(String id) {
    final index = _transactions.indexWhere((x) => x.id == id);
    if (index == -1) return;
    final t = _transactions[index];
    _transactions.removeAt(index);

    // reverse wallet effect
    if (t.isExpense) {
      wallet.balance += t.amount;
    } else {
      wallet.balance -= t.amount;
    }
    walletNotifier.value = wallet;

    // reverse budget spent
    for (var b in _budgets) {
      final sameMonth = t.date.year.toString() + "-" + t.date.month.toString().padLeft(2, '0');
      if (b.category == t.category && b.month == sameMonth && t.isExpense) {
        b.spent -= t.amount;
      }
    }
    budgetsNotifier.value = List<Budget>.from(_budgets);

    // refresh transactions notifier
    transactionsNotifier.value = List<TransactionItem>.from(_transactions);
  }

  List<TransactionItem> getAllTransactions() => List.unmodifiable(_transactions);

  List<TransactionItem> getTransactionsForMonth(int year, int month) {
    return _transactions
        .where((t) => t.date.year == year && t.date.month == month)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Map<String, double> categoryTotalsForMonth(int year, int month) {
    final items = getTransactionsForMonth(year, month);
    final Map<String, double> map = {};
    for (var t in items.where((x) => x.isExpense)) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    return map;
  }

  // budgets
  void addBudget(Budget b) {
    _budgets.add(b);
    budgetsNotifier.value = List<Budget>.from(_budgets);
  }

  // Replace existing budget with updatedBudget.
  void updateBudget(Budget updatedBudget) {
    final idx = _budgets.indexWhere((b) => b.id == updatedBudget.id);
    if (idx == -1) return;
    final existing = _budgets[idx];
    final newBudget = Budget(
      id: updatedBudget.id,
      category: updatedBudget.category,
      limit: updatedBudget.limit,
      month: updatedBudget.month,
      spent: updatedBudget.spent,
    );
    _budgets[idx] = newBudget;
    budgetsNotifier.value = List<Budget>.from(_budgets);
  }

  void deleteBudget(String id) {
    _budgets.removeWhere((b) => b.id == id);
    budgetsNotifier.value = List<Budget>.from(_budgets);
  }

  List<Budget> getAllBudgets() => List.unmodifiable(_budgets);

  // Monthly totals
  double totalExpensesForMonth(int year, int month) {
    return getTransactionsForMonth(year, month)
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double totalIncomeForMonth(int year, int month) {
    return getTransactionsForMonth(year, month)
        .where((t) => !t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }
}
