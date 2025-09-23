import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocery_app/providers/color_provider.dart';
import 'package:grocery_app/providers/font_provider.dart';
import 'package:grocery_app/screens/cartScreens/cart_screen.dart';
import 'package:grocery_app/screens/connectivity_aware_wrapper.dart';
import 'package:grocery_app/screens/home/bottom_navigation_screen.dart';
import 'package:grocery_app/screens/home/category_products_screen.dart';
import 'package:grocery_app/screens/home/home_screen_body.dart';
import 'package:grocery_app/screens/loginScreens/login_screen.dart';
import 'package:grocery_app/screens/loginScreens/signup_screen.dart';
import 'package:grocery_app/screens/splash_screen.dart';
import 'package:grocery_app/utils/font_utils.dart';

void main() => runApp(const ProviderScope(child: MyApp()));

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFontName = ref.watch(fontProvider);
    final selectedColor = ref.watch(colorProvider);

    final fontThemeFunction = getFontTheme(selectedFontName);

    // --- REFACTORED THEME BUILDER TO FIX INTERPOLATION ERROR ---
    ThemeData _buildTheme() {
      // (Your existing _buildTheme function remains unchanged)
      final brightness = (selectedColor.value == Colors.black.value)
          ? Brightness.dark
          : Brightness.light;
      final baseTextTheme = (brightness == Brightness.dark)
          ? ThemeData.dark().textTheme
          : ThemeData.light().textTheme;
      final themedTextTheme = fontThemeFunction(baseTextTheme);
      late final ColorScheme colorScheme;
      if (selectedColor.value == Colors.black.value) {
        colorScheme = ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.dark,
        );
      } else if (selectedColor.value == Colors.white.value) {
        colorScheme = ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        );
      } else {
        colorScheme = ColorScheme.fromSeed(
          seedColor: selectedColor,
          brightness: Brightness.light,
        );
      }
      return ThemeData(
        useMaterial3: true,
        brightness: brightness,
        colorScheme: colorScheme,
        textTheme: themedTextTheme,
        scaffoldBackgroundColor: (selectedColor.value == Colors.white.value)
            ? Colors.white
            : null,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
      );
    }

    return MaterialApp(
      title: 'Maha Mart',
      theme: _buildTheme(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      
      // --- ADD THE BUILDER PROPERTY HERE ---
      builder: (context, child) {
        // Wrap the navigator's child with our connectivity-aware widget.
        // The child here is the widget for the current route.
        return ConnectivityAwareWrapper(child: child!);
      },
      // ------------------------------------

      onGenerateRoute: (settings) {
        switch (settings.name) {
          case CategoryProductsScreen.routeName:
            final categoryName = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) =>
                  CategoryProductsScreen(categoryName: categoryName),
            );
          default:
            return null;
        }
      },
      routes: {
        '/splash': (context) => const SplashWrapper(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/main': (context) => const BottomNavigationScreen(),
        '/home': (context) => const HomeScreenBody(),
        '/cart': (context) => const CartScreen(),
      },
    );
  }
}