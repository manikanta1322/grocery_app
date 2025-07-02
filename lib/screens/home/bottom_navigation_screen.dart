import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocery_app/screens/cartScreens/cart_screen.dart';
import 'package:grocery_app/screens/home/home_screen_body.dart';
import 'package:grocery_app/screens/profileScreens/profile_screen.dart';
import 'package:grocery_app/screens/searchScreen.dart/search_screen.dart';

/// This is the main shell of the app. It holds the BottomNavigationBar
/// and manages the state for switching between the main screens.
class BottomNavigationScreen extends ConsumerStatefulWidget {
  const BottomNavigationScreen({super.key});

  @override
  ConsumerState<BottomNavigationScreen> createState() =>
      _BottomNavigationScreenState();
}

class _BottomNavigationScreenState
    extends ConsumerState<BottomNavigationScreen> {
  int _selectedIndex = 0;

  // List of the screens that will be displayed in the body.
  static const List<Widget> _screens = <Widget>[
    HomeScreenBody(),
    SearchScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,

        // This line is correct, as it dynamically uses the theme's primary color.
        selectedItemColor: theme.colorScheme.primary,

        // --- FIX ---
        // By removing the hard-coded colors below, the widget will now
        // use the correct colors provided by the global theme.
        //
        // REMOVED: unselectedItemColor: Colors.grey.shade600,
        // REMOVED: backgroundColor: Colors.white,

        elevation: 8.0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_basket_outlined),
            activeIcon: Icon(Icons.shopping_basket),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}