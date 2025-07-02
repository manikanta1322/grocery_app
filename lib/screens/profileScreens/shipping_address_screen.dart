import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocery_app/providers/address_provider.dart';
import 'package:grocery_app/screens/profileScreens/add_address_screen.dart';

class ShippingAddressScreen extends ConsumerWidget {
  final bool isSelecting;

  const ShippingAddressScreen({super.key, this.isSelecting = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addresses = ref.watch(addressProvider);

    return Scaffold(
      // backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(isSelecting ? 'Select Address' : 'Shipping Addresses'),
        // backgroundColor: Colors.white,
        elevation: 0.5,
        // --- REMOVED: The actions list is gone from here ---
      ),
      body:
          addresses.isEmpty
              ? const _EmptyAddressView() // Use a more engaging empty state view
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: addresses.length,
                itemBuilder: (ctx, index) {
                  final address = addresses[index];
                  final selectedAddress = ref.watch(selectedAddressProvider);
                  final isCurrentlySelected = selectedAddress?.id == address.id;

                  // Use a dedicated, cleaner widget for the address card
                  return _AddressCard(
                    address: address,
                    isSelecting: isSelecting,
                    isCurrentlySelected: isCurrentlySelected,
                    onTap: () {
                      if (isSelecting) {
                        ref.read(selectedAddressProvider.notifier).state =
                            address;
                        Navigator.of(context).pop();
                      } else {
                        // In management mode, tapping does nothing by default,
                        // options are in the popup menu.
                      }
                    },
                    onSetDefault:
                        () => ref
                            .read(addressProvider.notifier)
                            .setDefault(address.id),
                    onDelete:
                        () => ref
                            .read(addressProvider.notifier)
                            .removeAddress(address.id),
                  );
                },
              ),
      // --- CHANGED: The FAB is now always visible ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => const AddAddressScreen()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// A dedicated, beautifully designed card for displaying a single address.
class _AddressCard extends StatelessWidget {
  final Address address;
  final bool isSelecting;
  final bool isCurrentlySelected;
  final VoidCallback onTap;
  final VoidCallback onSetDefault;
  final VoidCallback onDelete;

  const _AddressCard({
    required this.address,
    required this.isSelecting,
    required this.isCurrentlySelected,
    required this.onTap,
    required this.onSetDefault,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isCurrentlySelected && isSelecting
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outlineVariant,
            width: isCurrentlySelected && isSelecting ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Radio button or Icon
            Icon(
              isSelecting
                  ? (isCurrentlySelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked)
                  : (address.label == 'Home'
                      ? Icons.home_outlined
                      : address.label == 'Work'
                      ? Icons.work_outline
                      : Icons.location_on_outlined),
              color: theme.colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 16),
            // Address details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        address.label,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (address.isDefault) ...[
                        const SizedBox(width: 8),
                        Chip(
                          label: const Text('Default'),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                          labelStyle: TextStyle(
                            fontSize: 10,
                            color: theme.colorScheme.primary,
                          ),
                          backgroundColor: theme.colorScheme.primary
                              .withOpacity(0.1),
                          side: BorderSide.none,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  // --- Use the fullAddress getter for a complete display ---
                  Text(
                    address.fullAddress,
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // More options button (only in management mode)
            if (!isSelecting)
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'setDefault') {
                    onSetDefault();
                  } else if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder:
                    (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'setDefault',
                        child: Text('Set as Default'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                icon: Icon(Icons.more_vert, color: theme.hintColor),
              ),
          ],
        ),
      ),
    );
  }
}

/// A dedicated widget for the empty state view.
class _EmptyAddressView extends StatelessWidget {
  const _EmptyAddressView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 80,
              color:theme.hintColor.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No Addresses Found',
             style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "You haven't saved any shipping addresses yet. Add one to get started!",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.hintColor),
            ),
          ],
        ),
      ),
    );
  }
}
