import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocery_app/providers/address_provider.dart';
import 'package:grocery_app/providers/cart_provider.dart';
import 'package:grocery_app/providers/payment_provider.dart';
import 'package:grocery_app/screens/paymentScreens/select_payment_method_screen.dart';
import 'package:grocery_app/screens/profileScreens/shipping_address_screen.dart';

class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  // A simple method to show a confirmation dialog
  void _showOrderPlacedDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap button to close
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Order Placed!'),
          content: const Text(
            'Thank you for your purchase. Your order is being processed.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                // Clear the cart
                ref.read(cartProvider.notifier).clearCart();
                // Pop until we get back to the home screen
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartTotal = ref.watch(cartTotalProvider);
    final selectedAddress = ref.watch(selectedAddressProvider);
    final selectedPayment = ref.watch(selectedPaymentMethodProvider);
    const deliveryFee = 5.00;
    final total = cartTotal + deliveryFee;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        elevation: 0.5,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const _SectionHeader(title: 'Shipping Address'),
          const SizedBox(height: 8),
          if (selectedAddress == null)
            const _AddAddressPromptCard()
          else
            _InfoCard(
              icon: Icons.location_on_outlined,
              title: selectedAddress.label,
              subtitle: selectedAddress.fullAddress,
              trailing: 'Change',
              onTrailingTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      const ShippingAddressScreen(isSelecting: true),
                ));
              },
            ),
          const SizedBox(height: 24),
          const _SectionHeader(title: 'Payment Method'),
          const SizedBox(height: 8),
          if (selectedPayment == null)
            const _AddPaymentPromptCard()
          else
            _InfoCard(
              icon: selectedPayment.icon,
              title: selectedPayment.displayName,
              subtitle: selectedPayment is CreditCardPayment
                  ? 'Card ending in ${selectedPayment.cardNumber.substring(selectedPayment.cardNumber.length - 4)}'
                  : selectedPayment.displayName,
              trailing: 'Change',
              onTrailingTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const SelectPaymentMethodScreen(),
                ));
              },
            ),
        ],
      ),
      // The structure is preserved as you provided.
      bottomNavigationBar: SafeArea(
        child: _buildBottomSummary(context, ref, total),
      ),
    );
  }

  // A dedicated widget for the bottom summary and action button
  Widget _buildBottomSummary(
      BuildContext context, WidgetRef ref, double total) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedAddress = ref.watch(selectedAddressProvider);
    final selectedPayment = ref.watch(selectedPaymentMethodProvider);
    final canPlaceOrder = selectedAddress != null && selectedPayment != null;

    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canPlaceOrder
                  ? () => _showOrderPlacedDialog(context, ref)
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                // --- CHANGE: Added consistent text style for the button. ---
                textStyle: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              child: const Text('Place Order'),
            ),
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
    return Text(
      title,
      style:
          Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String trailing;
  final VoidCallback onTrailingTap;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTrailingTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.primary, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- CHANGE: Using semantic theme style for the title. ---
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                // --- CHANGE: Using semantic theme style for the subtitle. ---
                Text(subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    )),
              ],
            ),
          ),
          TextButton(
            onPressed: onTrailingTap,
            child: Text(trailing),
          ),
        ],
      ),
    );
  }
}

class _AddAddressPromptCard extends StatelessWidget {
  const _AddAddressPromptCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return InkWell(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (ctx) => const ShippingAddressScreen(isSelecting: true))),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_location_alt_outlined, color: colorScheme.primary),
            const SizedBox(width: 12),
            // --- CHANGE: Using semantic theme style for the prompt text. ---
            Text('Select a Shipping Address',
                style: theme.textTheme.labelLarge
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _AddPaymentPromptCard extends StatelessWidget {
  const _AddPaymentPromptCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return InkWell(
      onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (ctx) => const SelectPaymentMethodScreen())),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payment, color: colorScheme.primary),
            const SizedBox(width: 12),
            // --- CHANGE: Using semantic theme style for the prompt text. ---
            Text('Select a Payment Method',
                style: theme.textTheme.labelLarge
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}