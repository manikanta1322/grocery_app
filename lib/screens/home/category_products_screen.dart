import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocery_app/providers/cart_provider.dart';
import 'package:grocery_app/providers/product_provider.dart';
import 'package:grocery_app/screens/cartScreens/cart_screen.dart';
import 'package:grocery_app/screens/home/home_screen_body.dart';

class CategoryProductsScreen extends ConsumerWidget {

  static const routeName = '/category-products'; 
  final String categoryName;

  const CategoryProductsScreen({
    super.key,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsByCategoryProvider(categoryName));
    final cart = ref.watch(cartProvider);

    // <-- 1. WATCH THE CART TOTAL PROVIDER
    // This gives us the total price of all items in the cart.
    final cartTotal = ref.watch(cartTotalProvider);

    // <-- 2. CALCULATE THE TOTAL NUMBER OF ITEMS (NOT JUST UNIQUE PRODUCTS)
    // We use fold to sum up the quantity of each item in the cart.
    // Starts with an initial value of 0. For each 'item' in the 'cart',
    // it adds the item's quantity to the running 'sum'.
    final totalItemCount = cart.fold<int>(
      0,
      (sum, item) => sum + (item['quantity'] as int),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
      ),
      floatingActionButton: cart.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CartScreen(),
                  ),
                );
              },
              // <-- 3. UPDATE THE LABEL WITH CORRECT COUNT AND TOTAL PRICE
              // Use the new totalItemCount and the cartTotal from the provider.
              // We format the price to two decimal places.
              label: Text(
                'Go to Cart ($totalItemCount) • \$${cartTotal.toStringAsFixed(2)}',
              ),
              icon: const Icon(Icons.shopping_cart),
            ),
      body: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return const Center(
              child: Text('No products found in this category.'),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) =>
                ProductCard(productData: products[index]),
          );
        },
        loading: () => GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
          ),
          itemCount: 4,
          itemBuilder: (context, index) => const ProductCardShimmer(),
        ),
        error: (err, stack) => Center(
          child: Text(
            'Could not load products: $err',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}