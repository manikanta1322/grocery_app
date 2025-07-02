import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocery_app/providers/cart_provider.dart';
import 'package:grocery_app/providers/search_provider.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context); // Get the theme
    final searchController = TextEditingController();

    return Scaffold(
      // --- FIX: Remove hard-coded background color
      // backgroundColor: Colors.grey[50],

      appBar: AppBar(
        // --- FIX: Remove hard-coded background color
        // The AppBar will now use the theme's AppBarTheme.
        // backgroundColor: Colors.white,

        title: TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Search for products...',
            border: InputBorder.none,
            // --- FIX: Use a theme-aware color for icons
            prefixIcon: Icon(Icons.search, color: theme.hintColor),
            suffixIcon: IconButton(
              icon: Icon(Icons.clear, color: theme.hintColor),
              onPressed: () {
                searchController.clear();
                ref.read(searchQueryProvider.notifier).state = '';
              },
            ),
          ),
          onChanged: (value) {
            ref.read(searchQueryProvider.notifier).state = value;
          },
        ),
      ),
      body: const _SearchResults(),
    );
  }
}

// Widget to display the body content based on search state
class _SearchResults extends ConsumerWidget {
  const _SearchResults();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(searchQueryProvider);
    final searchResults = ref.watch(searchResultsProvider);

    if (searchQuery.isEmpty) {
      return const _InitialSearchView();
    }

    return searchResults.when(
      // The progress indicator will automatically use the theme's primary color.
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) =>
          Center(child: Text('An error occurred: $error')),
      data: (products) {
        if (products.isEmpty) {
          return _NoResultsView(query: searchQuery);
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: products.length,
          itemBuilder: (context, index) {
            return _SearchResultItem(productData: products[index]);
          },
        );
      },
    );
  }
}

// A single item in the search results list
class _SearchResultItem extends ConsumerWidget {
  final Map<String, dynamic> productData;
  const _SearchResultItem({required this.productData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      // --- FIX: Add theme-aware color and shadow for consistency
      color: theme.colorScheme.surface,
      shadowColor: theme.colorScheme.shadow.withOpacity(0.1),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: CachedNetworkImage(
                imageUrl: productData['image'],
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productData['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    productData['price'],
                    style: TextStyle(
                      // This was already correct!
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            // The ElevatedButton will automatically use the theme's default style.
            ElevatedButton(
              onPressed: () {
                ref.read(cartProvider.notifier).addItem(productData);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${productData['name']} added to cart!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}

// The view to show before any search is performed
class _InitialSearchView extends StatelessWidget {
  const _InitialSearchView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // --- FIX: Use a theme-aware color
          Icon(Icons.search, size: 80, color: theme.hintColor.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            'Find Your Favorite Groceries',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Search for fruits, snacks, drinks and more.',
            // --- FIX: Use a theme-aware color
            style: theme.textTheme.bodyLarge?.copyWith(color: theme.hintColor),
          ),
        ],
      ),
    );
  }
}

// The view to show when no results are found
class _NoResultsView extends StatelessWidget {
  final String query;
  const _NoResultsView({required this.query});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- FIX: Use a theme-aware color
            Icon(Icons.search_off, size: 80, color: theme.hintColor.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'No Results Found',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'We couldn\'t find any products matching "$query". Try searching for something else.',
              textAlign: TextAlign.center,
              // --- FIX: Use a theme-aware color
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.hintColor),
            ),
          ],
        ),
      ),
    );
  }
}