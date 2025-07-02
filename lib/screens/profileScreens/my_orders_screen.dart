import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocery_app/providers/order_provider.dart';
import 'package:intl/intl.dart';

class MyOrdersScreen extends ConsumerWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(orderProvider);

    return Scaffold(
      // Let the theme handle the background color
      appBar: AppBar(
        title: const Text('My Orders'),
        // Let the theme handle the AppBar's color and elevation
      ),
      body: orders.isEmpty
          ? const _EmptyOrdersView()
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                return _OrderCard(order: orders[index]);
              },
            ),
    );
  }
}

// A dedicated card for displaying a single order
class _OrderCard extends StatelessWidget {
  final PastOrder order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Card(
      elevation: 1,
      // --- FIX: Use theme-aware colors and border for the card ---
      color: colorScheme.surface,
      shadowColor: colorScheme.shadow.withOpacity(0.1),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Order Header ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // --- FIX: Use theme text style ---
                Text(
                  order.id,
                  style: theme.textTheme.titleMedium,
                ),
                // --- FIX: Use theme text style and color ---
                Text(
                  DateFormat.yMMMd()
                      .format(order.orderDate), // e.g., "Jan 23, 2024"
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            const Divider(height: 24),
            // --- Item Preview ---
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: order.items.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: CircleAvatar(
                      radius: 25,
                      backgroundImage:
                          CachedNetworkImageProvider(order.items[index]['image']),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // --- Order Footer ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // --- FIX: Use theme text style ---
                Text(
                  'Total: \$${order.totalAmount.toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                _StatusChip(status: order.status),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// A helper widget to display the order status in a styled chip
class _StatusChip extends StatelessWidget {
  final OrderStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color backgroundColor;
    Color foregroundColor = Colors.white; // Default for most dark backgrounds
    String label = status.name.toUpperCase();

    switch (status) {
      case OrderStatus.processing:
        backgroundColor = Colors.orange.shade700;
        break;
      case OrderStatus.shipped:
        backgroundColor = Colors.blue.shade700;
        break;
      case OrderStatus.delivered:
        backgroundColor = Colors.green.shade700;
        break;
      case OrderStatus.cancelled:
        backgroundColor = colorScheme.error;
        foregroundColor = colorScheme.onError; // Use theme's onError color
        break;
    }

    return Chip(
      label: Text(label),
      backgroundColor: backgroundColor,
      side: BorderSide.none,
      labelStyle: theme.textTheme.labelSmall?.copyWith(
        color: foregroundColor,
        fontWeight: FontWeight.bold,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

// A dedicated widget for the empty state view
class _EmptyOrdersView extends StatelessWidget {
  const _EmptyOrdersView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- FIX: Use theme-aware color ---
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No Orders Yet',
              style:
                  theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // --- FIX: Use theme-aware color ---
            Text(
              "You haven't placed any orders yet. When you do, they will appear here.",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}