import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../localization/app_localizations.dart';

class MainNavigationScreen extends StatefulWidget {
  final Widget child;
  const MainNavigationScreen({super.key, required this.child});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/dashboard');
        break;
      case 2:
        context.go('/track');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final currentPath = GoRouterState.of(context).uri.path;

    int selectedIndex = 0;
    if (currentPath == '/track') {
      selectedIndex = 2;
    } else if (currentPath == '/profile') {
      selectedIndex = 3;
    } else if (currentPath == '/dashboard') {
      selectedIndex = 1;
    } else if (currentPath == '/') {
      selectedIndex = 0;
    }

    final showBottomNav = currentPath == '/' || 
                         currentPath == '/dashboard' ||
                         currentPath == '/track' || 
                         currentPath == '/profile';

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: showBottomNav
          ? NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: _onItemTapped,
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon: const Icon(Icons.home),
                  label: loc.t('home'),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.grid_view_outlined),
                  selectedIcon: const Icon(Icons.grid_view),
                  label: loc.t('dashboard'),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.monitor_heart_outlined),
                  selectedIcon: const Icon(Icons.monitor_heart),
                  label: loc.t('track'),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.person_outline),
                  selectedIcon: const Icon(Icons.person),
                  label: loc.t('profile'),
                ),
              ],
            )
          : null,
    );
  }
}

