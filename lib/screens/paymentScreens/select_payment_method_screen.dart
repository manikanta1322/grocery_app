import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocery_app/providers/payment_provider.dart';
import 'package:grocery_app/screens/paymentScreens/add_credit_card_screen.dart';
import 'package:grocery_app/screens/paymentScreens/add_upi_screen.dart';

class SelectPaymentMethodScreen extends ConsumerWidget {
  const SelectPaymentMethodScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedMethods = ref.watch(paymentProvider);
    final selectedMethod = ref.watch(selectedPaymentMethodProvider);

    return Scaffold(
      // backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Select Payment Method'),
        // backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Saved Methods Section ---
            if (savedMethods.isNotEmpty) ...[
              const _Header(title: 'Saved Methods'),
              ...savedMethods.map((method) {
                return _PaymentOptionCard(
                  method: method,
                  isSelected: selectedMethod?.id == method.id,
                  onTap: () {
                    ref.read(selectedPaymentMethodProvider.notifier).state =
                        method;
                    Navigator.of(context).pop();
                  },
                  onDelete: () {
                    if (selectedMethod?.id == method.id) {
                      ref.read(selectedPaymentMethodProvider.notifier).state =
                          null;
                    }
                    ref
                        .read(paymentProvider.notifier)
                        .removePaymentMethod(method.id);
                  },
                );
              }),
              const SizedBox(height: 16),
            ],

            // --- Other Payment Options Section ---
            const _Header(title: 'Other Payment Options'),
            // Using the now-defined ActionPaymentMethod class
            _PaymentOptionCard(
              method: ActionPaymentMethod(
                displayName: 'Add Credit/Debit Card',
                icon: Icons.add_card,
              ),
              isAction: true,
              onTap:
                  () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => const AddCreditCardScreen(),
                    ),
                  ),
            ),
            _PaymentOptionCard(
              method: ActionPaymentMethod(
                displayName: 'Add UPI ID',
                icon: Icons.currency_rupee,
              ),
              isAction: true,
              onTap:
                  () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (ctx) => const AddUpiScreen()),
                  ),
            ),
            _PaymentOptionCard(
              method: CashOnDeliveryPayment(),
              isSelected: selectedMethod is CashOnDeliveryPayment,
              onTap: () {
                ref.read(selectedPaymentMethodProvider.notifier).state =
                    CashOnDeliveryPayment();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ... The _PaymentOptionCard and _Header helper widgets remain unchanged ...
class _PaymentOptionCard extends StatelessWidget {
  final PaymentMethod method;
  final bool isSelected;
  final bool isAction;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _PaymentOptionCard({
    required this.method,
    this.isSelected = false,
    this.isAction = false,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle =
        method is CreditCardPayment
            ? 'Card ending in ****'
            : method is UpiPayment
            ? 'Pay with UPI'
            : '';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          // color: Colors.white,
            color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            // color:
            //     isSelected ? theme.colorScheme.primary : Colors.grey.shade200,
             color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              // backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              // foregroundColor: theme.colorScheme.primary,
               backgroundColor: theme.colorScheme.primaryContainer,
              foregroundColor: theme.colorScheme.onPrimaryContainer,
              child: Icon(method.icon),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        // color: Colors.grey.shade600,
                           color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isAction)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                // color: Colors.grey.shade400,
                 color: theme.hintColor,
              )
            else if (onDelete != null)
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') onDelete?.call();
                },
                itemBuilder:
                    (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                icon: Icon(Icons.more_vert, color: theme.hintColor),
              )
            else if (isSelected)
              Icon(Icons.check_circle, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  const _Header({required this.title});
  @override
  Widget build(BuildContext context) {
     final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 12.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          // color: Colors.grey.shade600,
           color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
          fontSize: 12,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
