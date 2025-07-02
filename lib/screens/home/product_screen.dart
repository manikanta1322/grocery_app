import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocery_app/providers/cart_provider.dart';
import 'package:grocery_app/providers/product_provider.dart';
import 'package:grocery_app/screens/cartScreens/cart_screen.dart';

class ProductScreen extends ConsumerStatefulWidget {
  const ProductScreen({super.key});

  @override
  ConsumerState<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends ConsumerState<ProductScreen> {
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    // Safely initialize _selectedCategory
    final categories = ref.read(categoriesProvider);
    if (categories.isNotEmpty) {
      _selectedCategory = categories.first['label'];
    } else {
      _selectedCategory = ''; // Fallback for empty categories
    }
  }

  @override
  Widget build(BuildContext context) {
    final featuredProducts = ref.watch(featuredProductsProvider);
    final categories = ref.watch(categoriesProvider);
    final productsByCategory = ref.watch(
      productsByCategoryProvider(_selectedCategory),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grocery Store'),
        elevation: 0.5,
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final cartItemCount = ref.watch(cartProvider).length;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CartScreen(),
                      ),
                    ),
                  ),
                  if (cartItemCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          // Using primary color for consistency, but red is also fine for alerts
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$cartItemCount',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionHeader(title: 'Featured Products'),
                featuredProducts.when(
                  data: (products) => _FeaturedProductsList(products: products),
                  loading: () => const _LoadingShimmer(height: 200),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                ),
                const _SectionHeader(title: 'Categories'),
                _CategorySelector(
                  categories: categories,
                  selectedCategory: _selectedCategory,
                  onCategorySelected: (categoryName) {
                    setState(() {
                      _selectedCategory = categoryName;
                    });
                  },
                ),
                _SectionHeader(title: _selectedCategory),
                productsByCategory.when(
                  data: (products) => _ProductGrid(products: products),
                  loading: () => const _LoadingShimmer(height: 400),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                ),
                // Space at the bottom so summary bar doesn't hide content
                const SizedBox(height: 100),
              ],
            ),
          ),
          // Cart summary bar at the bottom
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _CartSummaryBar(),
          ),
        ],
      ),
    );
  }
}

// --- HELPER WIDGETS ---

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _FeaturedProductsList extends StatelessWidget {
  final List<Map<String, dynamic>> products;
  const _FeaturedProductsList({required this.products});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return SizedBox(
            width: 300,
            child: _ProductCard(product: products[index]),
          );
        },
      ),
    );
  }
}

class _CategorySelector extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const _CategorySelector({
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category['label'] == selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(category['label']),
              // --- FIX: Using dynamic colors for the icon to ensure visibility ---
              avatar: Icon(
                category['icon'],
                size: 18,
                color:
                    isSelected ? colorScheme.onPrimary : colorScheme.primary,
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onCategorySelected(category['label']);
                }
              },
              // --- FIX: Using dynamic colors for chip background and text ---
              selectedColor: colorScheme.primary,
              backgroundColor: colorScheme.primaryContainer.withOpacity(0.5),
              labelStyle: TextStyle(
                fontWeight: FontWeight.w600,
                color:
                    isSelected ? colorScheme.onPrimary : colorScheme.onPrimaryContainer,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  final List<Map<String, dynamic>> products;
  const _ProductGrid({required this.products});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12.0),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        childAspectRatio: 2 / 3,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) => _ProductCard(product: products[index]),
    );
  }
}

class _ProductCard extends ConsumerWidget {
  final Map<String, dynamic> product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cart = ref.watch(cartProvider);
    final itemInCart = cart.firstWhere((item) => item['id'] == product['id'],
        orElse: () => {});
    final quantity = itemInCart.isNotEmpty ? itemInCart['quantity'] : 0;

    return Card(
      elevation: 2,
      color: colorScheme.surface,
      shadowColor: colorScheme.shadow.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: CachedNetworkImage(
                imageUrl: product['image'],
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(color: colorScheme.surfaceContainer),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- CHANGE: Using theme text style ---
                Text(
                  product['name'],
                  style: theme.textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // --- CHANGE: Using theme text style ---
                    Text(
                      product['price'],
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (quantity == 0)
                      SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            ref
                                .read(cartProvider.notifier)
                                .addItem(product);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${product['name']} added to cart!',
                                ),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          // --- CHANGE: Added consistent text style ---
                          style: ElevatedButton.styleFrom(
                              shape: const StadiumBorder(),
                              textStyle: theme.textTheme.labelLarge
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          child: const Text('Add'),
                        ),
                      )
                    else
                      Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: Icon(
                                Icons.remove,
                                color: colorScheme.onPrimary,
                                size: 18,
                              ),
                              onPressed: () => ref
                                  .read(cartProvider.notifier)
                                  .decrementQuantity(product['id']),
                            ),
                            Text(
                              '$quantity',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: Icon(
                                Icons.add,
                                color: colorScheme.onPrimary,
                                size: 18,
                              ),
                              onPressed: () => ref
                                  .read(cartProvider.notifier)
                                  .incrementQuantity(product['id']),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CartSummaryBar extends ConsumerWidget {
  const _CartSummaryBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final total = ref.watch(cartTotalProvider);

    if (cartItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false, // We only need safe area for the bottom
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${cartItems.length} ${cartItems.length == 1 ? 'item' : 'items'}',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const CartScreen()),
                );
              },
              icon: const Icon(Icons.shopping_cart_checkout),
              label: const Text('Go to Cart'),
              // --- CHANGE: Added consistent styling ---
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: const StadiumBorder(),
                textStyle: theme.textTheme.labelLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingShimmer extends StatelessWidget {
  final double height;
  const _LoadingShimmer({required this.height});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      // --- CHANGE: Using a theme-aware color ---
      color: Theme.of(context).colorScheme.surfaceContainer,
      margin: const EdgeInsets.all(16),
    );
  }
}