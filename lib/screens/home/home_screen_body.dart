export 'package:grocery_app/screens/home/home_screen_body.dart'
    show ProductCard, ProductCardShimmer;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocery_app/providers/auth_provider.dart';
import 'package:grocery_app/providers/cart_provider.dart';
import 'package:grocery_app/providers/product_provider.dart';
import 'package:grocery_app/screens/cartScreens/cart_screen.dart';
import 'package:grocery_app/screens/home/category_products_screen.dart';
import 'package:grocery_app/screens/home/product_screen.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreenBody extends ConsumerWidget {
  const HomeScreenBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);

    // --- 1. WATCH THE CART AND TOTAL PROVIDERS ---
    final cart = ref.watch(cartProvider);
    final cartTotal = ref.watch(cartTotalProvider);
    final totalItemCount = cart.fold<int>(
      0,
      (sum, item) => sum + (item['quantity'] as int),
    );

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, ${authState.name?.split(' ').first ?? 'User'}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'What would you like today?',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Badge(
              label: Text(totalItemCount.toString()),
              isLabelVisible: totalItemCount > 0,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      // --- 2. ADD THE FLOATING ACTION BUTTON ---
      floatingActionButton:
          cart.isEmpty
              ? null // Hide the button if the cart is empty
              : FloatingActionButton.extended(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const CartScreen()),
                  );
                },
                label: Text(
                  'Go to Cart ($totalItemCount) • \$${cartTotal.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                icon: const Icon(Icons.shopping_cart),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
      body: SingleChildScrollView(
        // Add padding to the bottom to ensure the FAB doesn't hide content
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            16,
            16,
            80,
          ), // Added bottom padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _CategoriesList(),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Featured Products',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ProductScreen(),
                        ),
                      );
                    },
                    child: const Text('See All'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const _FeaturedProductsGrid(),
              const SizedBox(height: 20),
              const Text(
                'Special Offers',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const _SpecialOfferCard(),
            ],
          ),
        ),
      ),
    );
  }
}

// ... (_CategoriesList, _FeaturedProductsGrid, _SpecialOfferCard, _CategoryItem widgets remain unchanged) ...

// All the helper widgets for the home screen remain in this file.

// Widget for Categories List
class _CategoriesList extends ConsumerWidget {
  const _CategoriesList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categories',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return _CategoryItem(
                icon: category['icon'] as IconData,
                label: category['label'] as String,
              );
            },
          ),
        ),
      ],
    );
  }
}

// Widget for Featured Products Grid with loading/error/data states
class _FeaturedProductsGrid extends ConsumerWidget {
  const _FeaturedProductsGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(featuredProductsProvider);

    return productsAsync.when(
      data:
          (products) => GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
            itemCount: products.length,
            itemBuilder:
                (context, index) => ProductCard(productData: products[index]),
          ),
      loading:
          () => GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
            itemCount: 4,
            itemBuilder: (context, index) => const ProductCardShimmer(),
          ),
      error:
          (err, stack) => Center(
            child: Text(
              'Could not load products: $err',
              textAlign: TextAlign.center,
            ),
          ),
    );
  }
}

// The "Special Offer" card extracted into its own widget
class _SpecialOfferCard extends StatelessWidget {
  const _SpecialOfferCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: const CachedNetworkImageProvider(
            'https://images.pexels.com/photos/1435904/pexels-photo-1435904.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
          ),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.4),
            BlendMode.darken,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '30% OFF',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'On all fruits and vegetables',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.onPrimary,
                foregroundColor: theme.colorScheme.primary,
              ),
              onPressed: () {},
              child: const Text('Shop Now'),
            ),
          ],
        ),
      ),
    );
  }
}

// _CategoryItem widget
class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _CategoryItem({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Wrap the Container with InkWell to make it tappable
    return InkWell(
      onTap: () {
        // Navigate to the new screen, passing the category label
        // Navigator.of(context).push(
        //   MaterialPageRoute(
        //     builder: (context) => CategoryProductsScreen(categoryName: label),
        //   ),
        // );
        Navigator.of(
          context,
        ).pushNamed(CategoryProductsScreen.routeName, arguments: label);
      },
      borderRadius: BorderRadius.circular(12), // For ripple effect
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                // color: Colors.white,
                // color: theme.colorScheme.surface.withOpacity(0.9),
                color: theme.colorScheme.onPrimaryContainer,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 6,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.green),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 3. REVERT ProductCard to use THE QUANTITY CONTROLLER ---
class ProductCard extends ConsumerWidget {
  final Map<String, dynamic> productData;
  const ProductCard({required this.productData, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cart = ref.watch(cartProvider);
    final itemIndex = cart.indexWhere(
      (item) => item['id'] == productData['id'],
    );
    final isInCart = itemIndex != -1;
    final cartItem = isInCart ? cart[itemIndex] : null;

    return Container(
      decoration: BoxDecoration(
        // color: Colors.white,
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // color: Colors.grey.withOpacity(0.1),
            color: theme.colorScheme.shadow.withOpacity(0.05),
            blurRadius: 6,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),

                // color: Colors.grey[100],
                color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: CachedNetworkImage(
                  imageUrl: productData['image'] as String,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const ProductCardShimmer(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productData['name'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  productData['price'] as String,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child:
                      isInCart
                          // If in cart, show quantity controller
                          ? Container(
                            decoration: BoxDecoration(
                              // color: Colors.green[50],
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  iconSize: 18,
                                  icon: Icon(
                                    Icons.remove,
                                    // color: Colors.green,
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                  onPressed: () {
                                    ref
                                        .read(cartProvider.notifier)
                                        .decrementQuantity(productData['id']);
                                  },
                                ),
                                Text(
                                  cartItem!['quantity'].toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    // color: Colors.green,
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                                IconButton(
                                  iconSize: 18,
                                  icon: Icon(
                                    Icons.add,
                                    // color: Colors.green,
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                  onPressed: () {
                                    ref
                                        .read(cartProvider.notifier)
                                        .incrementQuantity(productData['id']);
                                  },
                                ),
                              ],
                            ),
                          )
                          // If not in cart, show "Add to Cart" button
                          : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              // backgroundColor: Colors.green[50],
                              // foregroundColor: Colors.green,
                              backgroundColor:
                                  theme.colorScheme.primaryContainer,
                              foregroundColor:
                                  theme.colorScheme.onPrimaryContainer,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              ref
                                  .read(cartProvider.notifier)
                                  .addItem(productData);
                              ScaffoldMessenger.of(
                                context,
                              ).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${productData['name']} added to cart!',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            child: const Text('Add to Cart'),
                          ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ... (ProductCardShimmer remains unchanged) ...
class ProductCardShimmer extends StatelessWidget {
  const ProductCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Shimmer.fromColors(
      // baseColor: Colors.grey[300]!,
      // highlightColor: Colors.grey[100]!,
      baseColor: theme.colorScheme.surfaceVariant,
      highlightColor: theme.colorScheme.surface,
      child: Container(
        decoration: BoxDecoration(
          // color: Colors.white,
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 100, height: 16, color: Colors.white),
                  const SizedBox(height: 4),
                  Container(width: 50, height: 16, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
