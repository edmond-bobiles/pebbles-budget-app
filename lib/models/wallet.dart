class Wallet {
  double balance;
  final String currency;

  Wallet({required this.balance, this.currency = 'PHP'});

  Map<String, dynamic> toMap() => {'balance': balance, 'currency': currency};
  factory Wallet.fromMap(Map<String, dynamic> m) =>
      Wallet(balance: (m['balance'] as num).toDouble(), currency: m['currency']);
}
