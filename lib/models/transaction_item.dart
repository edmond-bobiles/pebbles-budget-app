class TransactionItem {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final bool isExpense; // true = expense, false = income

  TransactionItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.isExpense,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'amount': amount,
    'category': category,
    'date': date.toIso8601String(),
    'isExpense': isExpense,
  };

  factory TransactionItem.fromMap(Map<String, dynamic> m) => TransactionItem(
    id: m['id'],
    title: m['title'],
    amount: (m['amount'] as num).toDouble(),
    category: m['category'],
    date: DateTime.parse(m['date']),
    isExpense: m['isExpense'],
  );
}
