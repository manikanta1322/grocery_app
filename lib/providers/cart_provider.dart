import 'package:flutter_riverpod/flutter_riverpod.dart';

// The state will be a list of cart items. Each item is a map.
class CartNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  CartNotifier() : super([]);

  // Adds a product to the cart. If it already exists, increments the quantity.
  void addItem(Map<String, dynamic> product) {
    // Check if the product is already in the cart
    final existingIndex = state.indexWhere((item) => item['id'] == product['id']);

    if (existingIndex != -1) {
      // Product exists, so we update its quantity
      final updatedItem = Map<String, dynamic>.from(state[existingIndex]);
      updatedItem['quantity'] = (updatedItem['quantity'] as int) + 1;

      final newState = List<Map<String, dynamic>>.from(state);
      newState[existingIndex] = updatedItem;
      state = newState;
    } else {
      // Product is new, add it to the cart with quantity 1
      state = [...state, {...product, 'quantity': 1}];
    }
  }

  // Removes an item from the cart completely
  void removeItem(String productId) {
    state = state.where((item) => item['id'] != productId).toList();
  }

  // Decrements an item's quantity. If it reaches 0, removes the item.
  void decrementQuantity(String productId) {
    final existingIndex = state.indexWhere((item) => item['id'] == productId);
    if (existingIndex == -1) return;

    final updatedItem = Map<String, dynamic>.from(state[existingIndex]);
    final currentQuantity = updatedItem['quantity'] as int;

    if (currentQuantity > 1) {
      updatedItem['quantity'] = currentQuantity - 1;
      final newState = List<Map<String, dynamic>>.from(state);
      newState[existingIndex] = updatedItem;
      state = newState;
    } else {
      // If quantity is 1, decrementing removes the item
      removeItem(productId);
    }
  }

  // Increments an item's quantity
  void incrementQuantity(String productId) {
    final existingIndex = state.indexWhere((item) => item['id'] == productId);
    if (existingIndex == -1) return;

    final updatedItem = Map<String, dynamic>.from(state[existingIndex]);
    updatedItem['quantity'] = (updatedItem['quantity'] as int) + 1;

    final newState = List<Map<String, dynamic>>.from(state);
    newState[existingIndex] = updatedItem;
    state = newState;
  }

  // --- ADD THIS METHOD ---
  /// Clears all items from the cart by setting the state to an empty list.
  void clearCart() {
    state = [];
  }
}

// The provider for our CartNotifier
final cartProvider = StateNotifierProvider<CartNotifier, List<Map<String, dynamic>>>((ref) {
  return CartNotifier();
});

// A provider to calculate the total price of items in the cart (Derived State)
// final cartTotalProvider = Provider<double>((ref) {
//   final cart = ref.watch(cartProvider);
//   double total = 0.0;
//   for (final item in cart) {
//     // Remove '$' and parse price to double, then multiply by quantity
//     final price = double.tryParse(item['price'].toString().replaceAll('\$', '')) ?? 0.0;
//     total += price * (item['quantity'] as int);
//   }
//   return total;
// });

final cartTotalProvider = Provider<double>((ref) {
  // Watch the cart provider to rebuild when the cart changes
  final cart = ref.watch(cartProvider);

  // If the cart is empty, the total is 0
  if (cart.isEmpty) return 0.0;

  // Use fold to sum up the total price
  return cart.fold(0.0, (sum, item) {
    // Assuming price is a string like "$19.99"
    // Remove the '$' sign and parse it to a double
    final priceString = (item['price'] as String).replaceAll(r'$', '');
    final price = double.tryParse(priceString) ?? 0.0;
    
    // Get the quantity
    final quantity = item['quantity'] as int;

    // Add the item's total price (price * quantity) to the sum
    return sum + (price * quantity);
  });
});