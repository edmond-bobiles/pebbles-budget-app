import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_item.dart';
import '../models/budget.dart';
import '../models/wallet.dart';

class StorageService {
  static const _kWalletKey = 'wallet';
  static const _kTransactionsKey = 'transactions';
  static const _kBudgetsKey = 'budgets';
  static const _kUserKey = 'user';

  // --- Wallet ---
  Future<void> saveWallet(Wallet w) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_kWalletKey, jsonEncode(w.toMap()));
  }

  Future<Wallet> loadWallet() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_kWalletKey);
    if (s == null) return Wallet(balance: 0.0);
    return Wallet.fromMap(jsonDecode(s));
  }

  // --- Transactions ---
  Future<void> saveAllTransactions(List<TransactionItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final list = items.map((e) => e.toMap()).toList();
    prefs.setString(_kTransactionsKey, jsonEncode(list));
  }

  Future<List<TransactionItem>> loadAllTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_kTransactionsKey);
    if (s == null) return [];
    final List decoded = jsonDecode(s);
    return decoded.map((m) => TransactionItem.fromMap(Map<String, dynamic>.from(m))).toList();
  }

  Future<void> addTransaction(TransactionItem t) async {
    final all = await loadAllTransactions();
    all.add(t);
    await saveAllTransactions(all);
  }

  // get transactions for a specific month (year-month string)
  Future<List<TransactionItem>> loadTransactionsForMonth(int year, int month) async {
    final all = await loadAllTransactions();
    return all.where((t) => t.date.year == year && t.date.month == month).toList()
      ..sort((a,b)=> b.date.compareTo(a.date));
  }

  // totals for pie chart (category -> total)
  Future<Map<String,double>> categoryTotalsForMonth(int year, int month) async {
    final items = await loadTransactionsForMonth(year, month);
    final Map<String,double> map = {};
    for (final t in items.where((t)=> t.isExpense)) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    return map;
  }

  // --- Budgets ---
  Future<void> saveAllBudgets(List<Budget> budgets) async {
    final prefs = await SharedPreferences.getInstance();
    final list = budgets.map((b) => b.toMap()).toList();
    prefs.setString(_kBudgetsKey, jsonEncode(list));
  }

  Future<List<Budget>> loadAllBudgets() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_kBudgetsKey);
    if (s == null) return [];
    final List decoded = jsonDecode(s);
    return decoded.map((m) => Budget.fromMap(Map<String, dynamic>.from(m))).toList();
  }

  Future<void> addBudget(Budget b) async {
    final all = await loadAllBudgets();
    all.add(b);
    await saveAllBudgets(all);
  }

  // --- User (simple local auth) ---
  Future<void> saveUser(Map<String,String> userMap) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_kUserKey, jsonEncode(userMap));
  }
  Future<Map<String,String>?> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_kUserKey);
    if (s == null) return null;
    final Map m = jsonDecode(s);
    return Map<String,String>.from(m);
  }
}
