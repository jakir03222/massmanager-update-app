import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/mess_controller.dart';
import 'home_tab.dart';
import 'bazar_tab.dart';
import 'daily_report_tab.dart';
import 'profile_tab.dart';

class MainShell extends StatefulWidget {
  final AuthController authController;
  const MainShell({super.key, required this.authController});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  late final MessController _messController;

  @override
  void initState() {
    super.initState();
    _messController = MessController(authController: widget.authController);
  }

  @override
  void dispose() {
    _messController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      HomeTab(messController: _messController),
      BazarTab(messController: _messController),
      DailyReportTab(messController: _messController),
      ProfileTab(authController: widget.authController),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu),
            label: 'Meal',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart),
            label: 'Bazar',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Report',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
