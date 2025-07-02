import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocery_app/providers/color_provider.dart';
import 'package:grocery_app/providers/font_provider.dart';
import 'package:grocery_app/screens/cartScreens/cart_screen.dart';
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
      // 1. Determine the target brightness first. This is the most important step.
      final brightness = (selectedColor.value == Colors.black.value)
          ? Brightness.dark
          : Brightness.light;

      // 2. Get the correct, consistent base text theme based on the brightness.
      // This avoids using the problematic `Theme.of(context)`.
      final baseTextTheme = (brightness == Brightness.dark)
          ? ThemeData.dark().textTheme
          : ThemeData.light().textTheme;
          
      // 3. Apply the custom font to this consistent base theme.
      final themedTextTheme = fontThemeFunction(baseTextTheme);

      // 4. Build the ColorScheme based on the selected color.
      late final ColorScheme colorScheme;
      if (selectedColor.value == Colors.black.value) {
        colorScheme = ColorScheme.fromSeed(
          seedColor: Colors.blueGrey, // A neutral seed for a balanced dark theme
          brightness: Brightness.dark,
        );
      } else if (selectedColor.value == Colors.white.value) {
        colorScheme = ColorScheme.fromSeed(
          seedColor: Colors.blue, // A standard seed for a clean light theme
          brightness: Brightness.light,
        );
      } else {
        // For all other colors, use the fromSeed logic with a light brightness.
        colorScheme = ColorScheme.fromSeed(
          seedColor: selectedColor,
          brightness: Brightness.light,
        );
      }

      // 5. Assemble the final theme with consistent parts.
      return ThemeData(
        useMaterial3: true,
        brightness: brightness,
        colorScheme: colorScheme,
        textTheme: themedTextTheme,
        scaffoldBackgroundColor: (selectedColor.value == Colors.white.value)
            ? Colors.white // Special case for pure white background
            : null, // Let the theme handle other backgrounds
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
      );
    }

    return MaterialApp(
      title: 'Grocery Shop',
      theme: _buildTheme(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
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