import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

// An enum for clear, readable order statuses
enum OrderStatus { processing, shipped, delivered, cancelled }

// The data model for a single past order
class PastOrder {
  final String id;
  final DateTime orderDate;
  final List<Map<String, dynamic>> items; // A snapshot of items at the time of purchase
  final double totalAmount;
  final OrderStatus status;

  PastOrder({
    required this.orderDate,
    required this.items,
    required this.totalAmount,
    required this.status,
    String? id,
  }) : id = id ?? _uuid.v4();
}

// A Notifier to manage the list of orders
class OrderNotifier extends StateNotifier<List<PastOrder>> {
  // Initialize with some mock data for demonstration
  OrderNotifier() : super([
    PastOrder(
      id: 'ORDER-1024',
      orderDate: DateTime.now().subtract(const Duration(days: 2)),
      items: [
        {'name': 'Organic Apples', 'image': 'https://images.pexels.com/photos/102104/pexels-photo-102104.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2'},
        {'name': 'Whole Milk', 'image': 'https://images.pexels.com/photos/248412/pexels-photo-248412.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2'},
      ],
      totalAmount: 5.69,
      status: OrderStatus.delivered,
    ),
    PastOrder(
      id: 'ORDER-1023',
      orderDate: DateTime.now().subtract(const Duration(days: 5)),
      items: [
        {'name': 'Wireless Headphones', 'image': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1770&q=80'},
        {'name': 'Smart HD Camera', 'image': 'https://images.unsplash.com/photo-1517430526953-eda33541445b?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=774&q=80'},
        {'name': 'Minimalist Backpack', 'image': 'https://images.unsplash.com/photo-1553062407-98eeb68c6a62?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=774&q=80'},
      ],
      totalAmount: 349.00,
      status: OrderStatus.shipped,
    ),
     PastOrder(
      id: 'ORDER-1022',
      orderDate: DateTime.now().subtract(const Duration(days: 10)),
      items: [
        {'name': 'Fresh Carrots', 'image': 'https://images.pexels.com/photos/143133/pexels-photo-143133.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2'},
      ],
      totalAmount: 0.99,
      status: OrderStatus.processing,
    ),
  ]);

  // In a real app, you would have a method like this:
  // void addOrder(List<Map<String, dynamic>> cartItems, double total) {
  //   final newOrder = PastOrder(
  //     orderDate: DateTime.now(),
  //     items: cartItems,
  //     totalAmount: total,
  //     status: OrderStatus.processing,
  //   );
  //   state = [newOrder, ...state];
  // }
}

// The provider that the UI will interact with
final orderProvider = StateNotifierProvider<OrderNotifier, List<PastOrder>>((ref) {
  return OrderNotifier();
});