import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'transactions_screen.dart';
import 'add_screen.dart';
import 'budget_screen.dart';
import 'account_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    TransactionsScreen(),
    AddScreen(),
    BudgetScreen(),
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Transactions"),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: "Add"),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart_outline), label: "Budgets"),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: "Accounts"),
        ],
      ),
    );
  }
}
