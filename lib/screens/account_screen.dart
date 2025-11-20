import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import 'login_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  String _formatCurrency(double v) => '₱ ${v.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final storage = StorageService.instance;
    final username = storage.user['username'] ?? 'budget';
    final colorScheme = Theme.of(context).colorScheme;

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
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Text(
                        '👤',
                        style: TextStyle(fontSize: 22),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Account',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Username
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            username.isNotEmpty
                                ? username[0].toUpperCase()
                                : 'B',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        username,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Wallet balance
                ValueListenableBuilder(
                  valueListenable: storage.walletNotifier,
                  builder: (context, wallet, _) {
                    final bal = (wallet?.balance ?? 0.0) as double;

                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 14.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.account_balance_wallet_outlined,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Total Balance',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            Text(
                              bal >= 0
                                  ? _formatCurrency(bal)
                                  : '- ${_formatCurrency(bal.abs())}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: bal < 0
                                    ? Colors.red.shade700
                                    : colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Transactions count and budgets count
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ValueListenableBuilder<List>(
                      valueListenable: storage.transactionsNotifier,
                      builder: (context, txs, _) {
                        return _StatTile(
                          label: 'Transactions',
                          value: txs.length.toString(),
                          color: colorScheme.primary,
                        );
                      },
                    ),
                    ValueListenableBuilder<List>(
                      valueListenable: storage.budgetsNotifier,
                      builder: (context, bgs, _) {
                        return _StatTile(
                          label: 'Budgets',
                          value: bgs.length.toString(),
                          color: colorScheme.primaryContainer,
                        );
                      },
                    ),
                  ],
                ),

                const Spacer(),

                // Logout button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _logout(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatTile({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: onSurface,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}
