// lib/providers/search_provider.dart

import 'dart:async'; // Import the async library for Timer
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocery_app/providers/product_provider.dart';

// 1. Provider to hold the current search query string (NO CHANGE HERE)
final searchQueryProvider = StateProvider<String>((ref) => '');

// 2. Provider to perform the search and return results (CORRECTED LOGIC)
final searchResultsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  // Watch the search query from the other provider.
  final searchTerm = ref.watch(searchQueryProvider);

  // If the search term is empty, return an empty list immediately.
  if (searchTerm.isEmpty) {
    return [];
  }

  // This is the debouncing logic. We use keepAlive to prevent the provider
  // from being disposed immediately, and a Timer to control the delay.
  final link = ref.keepAlive();
  final timer = Timer(const Duration(milliseconds: 500), () {
    // When the timer fires after 500ms, we close the link, allowing the
    // provider to be disposed if it's no longer being listened to.
    link.close();
  });

  // If the user types again, this provider will be re-evaluated, and the
  // onDispose callback below will cancel the previous timer.
  ref.onDispose(() {
    timer.cancel();
  });

  // By awaiting the timer's future, we effectively pause the execution
  // for 500ms. If the provider is disposed during this time (because the
  // user typed again), the execution stops here.
  await Future.delayed(const Duration(milliseconds: 500));


  // --- If the code reaches here, it means the user has stopped typing for 500ms ---

  // In a real app, you would make an API call here with the `searchTerm`.
  // For this example, we will search our existing product list.
  final allProducts = await ref.read(featuredProductsProvider.future);

  // Filter the products based on the search term (case-insensitive)
  return allProducts
      .where((product) =>
          product['name'].toLowerCase().contains(searchTerm.toLowerCase()))
      .toList();
});