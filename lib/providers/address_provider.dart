import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

// --- 1. UPDATE THE ADDRESS CLASS MODEL ---
class Address {
  final String id;
  final String label; // e.g., "Home", "Work"
  // REMOVED: final String addressLine;
  // ADDED: Detailed address fields
  final String addressLine1;
  final String area;
  final String city;
  final String postalCode;
  final bool isDefault;

  Address({
    required this.label,
    // --- UPDATE CONSTRUCTOR PARAMETERS ---
    required this.addressLine1,
    required this.area,
    required this.city,
    required this.postalCode,
    this.isDefault = false,
    String? id,
  }) : id = id ?? _uuid.v4();

  // ADD A HELPER GETTER to easily display the full address elsewhere
  String get fullAddress => '$addressLine1, $area, $city, $postalCode';

  // --- UPDATE THE copyWith METHOD ---
  Address copyWith({
    String? id,
    String? label,
    String? addressLine1,
    String? area,
    String? city,
    String? postalCode,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      label: label ?? this.label,
      addressLine1: addressLine1 ?? this.addressLine1,
      area: area ?? this.area,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

// 2. Notifier to manage the list of addresses
class AddressNotifier extends StateNotifier<List<Address>> {
  AddressNotifier()
      // --- 3. UPDATE THE MOCK DATA TO USE THE NEW FIELDS ---
      : super([
          Address(
            label: 'Home',
            addressLine1: '123 Flutter Lane',
            area: 'Dev District',
            city: 'Widget City',
            postalCode: '12345',
            isDefault: true,
          ),
          Address(
            label: 'Work',
            addressLine1: '456 Riverpod Avenue',
            area: 'State Street',
            city: 'Provider Town',
            postalCode: '67890',
          ),
        ]);

  void addAddress(Address address) {
    // Small UX improvement: if it's the first address, make it the default
    if (state.isEmpty) {
      state = [address.copyWith(isDefault: true)];
    } else {
      state = [...state, address];
    }
  }

  void removeAddress(String addressId) {
    state = state.where((addr) => addr.id != addressId).toList();
  }

  void setDefault(String addressId) {
    state = [
      for (final address in state)
        address.copyWith(isDefault: address.id == addressId)
    ];
  }
}

// 3. Provider for the address list (no changes needed here)
final addressProvider =
    StateNotifierProvider<AddressNotifier, List<Address>>((ref) {
  return AddressNotifier();
});

// 4. Provider to hold the address currently selected for checkout (no changes needed here)
final selectedAddressProvider = StateProvider<Address?>((ref) {
  final addresses = ref.watch(addressProvider);
  try {
    return addresses.firstWhere((addr) => addr.isDefault);
  } catch (e) {
    return addresses.isNotEmpty ? addresses.first : null;
  }
});