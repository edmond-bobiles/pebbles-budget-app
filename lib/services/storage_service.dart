import '../models/transaction_item.dart';
import '../models/budget.dart';
import '../models/wallet.dart';

class StorageService {
  // Wallet
  Wallet wallet = Wallet(balance: 0.0);

  // List of needed data
  List<TransactionItem> transactions = [];
  List<Budget> budgets = [];

  // User
  final Map<String, String> user = {
    "username": "budget",
    "password": "pebbles"
  };

  // Wallet update logic
  void updateWallet(Wallet w) {
    wallet = w;
  }

  Wallet getWallet() {
    return wallet;
  }

  // Add transaction logic
  void addTransaction(TransactionItem t) {
    transactions.add(t);

    // 1. update wallet balance
    if (t.isExpense) {
      wallet.balance -= t.amount; // subtracts the balance
    } else {
      wallet.balance += t.amount; // adds income to the balance
    }

    // 2. update budgets
    for (var b in budgets) {
      final sameMonth = t.date.year.toString() + "-" + t.date.month.toString().padLeft(2, '0');
      if (b.category == t.category && b.month == sameMonth && t.isExpense) {
        b.spent += t.amount;
      }
    }
  }

  // Delete transaction
  void deleteTransaction(String id) {
    final t = transactions.firstWhere((x) => x.id == id);
    transactions.removeWhere((x) => x.id == id);

    // Reverse effect on wallet
    if (t.isExpense) {
      wallet.balance += t.amount;
    } else {
      wallet.balance -= t.amount;
    }

    // Reverse budget spent
    for (var b in budgets) {
      final sameMonth = t.date.year.toString() + "-" + t.date.month.toString().padLeft(2, '0');
      if (b.category == t.category && b.month == sameMonth && t.isExpense) {
        b.spent -= t.amount;
      }
    }
  }

  List<TransactionItem> getAllTransactions() {
    return transactions;
  }

  // Gets monthly transaction
  List<TransactionItem> getTransactionsForMonth(int year, int month) {
    return transactions
        .where((t) => t.date.year == year && t.date.month == month)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Gets the category total for month
  Map<String, double> categoryTotalsForMonth(int year, int month) {
    final items = getTransactionsForMonth(year, month);
    final Map<String, double> map = {};

    for (var t in items.where((x) => x.isExpense)) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    return map;
  }

  // adds the budget
  void addBudget(Budget b) {
    budgets.add(b);
  }

  List<Budget> getAllBudgets() {
    return budgets;
  }

  // gets the total expense for month
  double totalExpensesForMonth(int year, int month) {
    return getTransactionsForMonth(year, month)
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // gets the total income for month
  double totalIncomeForMonth(int year, int month) {
    return getTransactionsForMonth(year, month)
        .where((t) => !t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }
}
