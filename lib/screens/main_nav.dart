import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'transactions_screen.dart';
import 'add_transaction_screen.dart';
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: _pages[_index],

      // --- Styled Bottom Nav ---
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.surface,
              colorScheme.primaryContainer.withOpacity(0.2),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.15),
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(26),
            topRight: Radius.circular(26),
          ),
          child: BottomNavigationBar(
            currentIndex: _index,
            onTap: (i) => setState(() => _index = i),
            type: BottomNavigationBarType.fixed,
            backgroundColor: colorScheme.surface.withOpacity(0.9),
            elevation: 0,

            selectedItemColor: colorScheme.primary,
            unselectedItemColor: colorScheme.onSurface.withOpacity(0.5),

            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),

            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: "Home",
              ),

              const BottomNavigationBarItem(
                icon: Icon(Icons.list_alt_rounded),
                label: "Transactions",
              ),

              // 💡 Styled Add button (floating look)
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.add,
                    color: colorScheme.onPrimary,
                    size: 26,
                  ),
                ),
                label: "Add",
              ),

              const BottomNavigationBarItem(
                icon: Icon(Icons.pie_chart_rounded),
                label: "Budgets",
              ),

              const BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                label: "Account",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
