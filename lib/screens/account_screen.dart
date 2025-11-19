import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import 'login_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  String _formatCurrency(double v) => '₱ ${v.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final storage = StorageService.instance;
    final username = storage.user['username'] ?? 'budget';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: const [
                  Text('Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                ],
              ),

              const SizedBox(height: 8),

              Center(
                child: Text(username, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),

              const SizedBox(height: 20),

              // Wallet balance
              ValueListenableBuilder(
                valueListenable: storage.walletNotifier,
                builder: (context, wallet, _) {
                  final bal = (wallet?.balance ?? 0.0) as double;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Balance', style: TextStyle(fontSize: 16)),
                          Text(
                            bal >= 0 ? _formatCurrency(bal) : '- ${_formatCurrency(bal.abs())}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: bal < 0 ? Colors.red : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Transactions count and budgets count
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ValueListenableBuilder(
                    valueListenable: storage.transactionsNotifier,
                    builder: (context, List txs, _) {
                      return Column(
                        children: [
                          Text('${txs.length}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          const Text('Transactions'),
                        ],
                      );
                    },
                  ),
                  ValueListenableBuilder(
                    valueListenable: storage.budgetsNotifier,
                    builder: (context, List bgs, _) {
                      return Column(
                        children: [
                          Text('${bgs.length}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          const Text('Budgets'),
                        ],
                      );
                    },
                  ),
                ],
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _logout(context),
                  child: const Text('Logout'),
                ),
              ),

              const SizedBox(height: 12),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
