class Budget {
  final String id;
  final String category;
  final double limit;
  final String month; // e.g. "2025-11"
  double spent;

  Budget({
    required this.id,
    required this.category,
    required this.limit,
    required this.month,
    this.spent = 0.0,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'category': category,
    'limit': limit,
    'month': month,
    'spent': spent,
  };

  factory Budget.fromMap(Map<String, dynamic> m) => Budget(
    id: m['id'],
    category: m['category'],
    limit: (m['limit'] as num).toDouble(),
    month: m['month'],
    spent: (m['spent'] as num).toDouble(),
  );
}
