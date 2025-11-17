import '../models/transaction_item.dart';
import '../models/budget.dart';
import '../models/wallet.dart';

class StorageService {

  Wallet wallet = Wallet(balance: 0.0);

  List<TransactionItem> transactions = [];
  List<Budget> budgets = [];

  final Map<String, String> user = {
    "username": "budget",
    "password": "pebbles"
  };

  void updateWallet(Wallet w) {
    wallet = w;
  }

  Wallet getWallet() {
    return wallet;
  }

  // Transactions
  void addTransaction(TransactionItem t) {
    transactions.add(t);
  }

  List<TransactionItem> getAllTransactions() {
    return transactions;
  }

  List<TransactionItem> getTransactionsForMonth(int year, int month) {
    return transactions .where((t) => t.date.year == year && t.date.month == month).toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  Map<String, double> categoryTotalsForMonth(int year, int month) {
    final items = getTransactionsForMonth(year, month);
    final Map<String, double> map = {};

    for (var t in items.where((x) => x.isExpense)) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    return map;
  }

  // Budgets
  void addBudget(Budget b) {
    budgets.add(b);
  }

  List<Budget> getAllBudgets() {
    return budgets;
  }
}
