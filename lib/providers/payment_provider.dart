import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

// --- 1. DATA MODELING ---

// Base class for all payment methods
abstract class PaymentMethod {
  final String id;
  final String displayName;
  final IconData icon;

  PaymentMethod({required this.displayName, required this.icon, String? id}) : id = id ?? _uuid.v4();
}

// --- THIS IS THE NEW CLASS THAT WAS MISSING ---
/// A simple, concrete class for action items (like 'Add Card') that don't hold data.
class ActionPaymentMethod extends PaymentMethod {
  ActionPaymentMethod({required super.displayName, required super.icon});
}

enum CardType { visa, mastercard, other }

// Subclass for Credit Cards
class CreditCardPayment extends PaymentMethod {
  final String cardHolderName;
  final String cardNumber;
  final String expiryDate;
  final String cvv;
  final CardType cardType;

  CreditCardPayment({
    required this.cardHolderName,
    required this.cardNumber,
    required this.expiryDate,
    required this.cvv,
    this.cardType = CardType.visa,
  }) : super(
          displayName: 'Visa **** ${cardNumber.substring(cardNumber.length - 4)}',
          icon: Icons.credit_card,
        );
}

// Subclass for UPI
class UpiPayment extends PaymentMethod {
  final String upiId;
  UpiPayment({required this.upiId})
      : super(displayName: upiId, icon: Icons.currency_rupee);
}

// Subclass for Cash on Delivery
class CashOnDeliveryPayment extends PaymentMethod {
  CashOnDeliveryPayment() : super(displayName: 'Cash on Delivery', icon: Icons.money);
}


// --- 2. RIVERPOD PROVIDERS (No changes here) ---

// Notifier to manage the list of *saved* payment methods
class PaymentNotifier extends StateNotifier<List<PaymentMethod>> {
  PaymentNotifier() : super([]);

  void addPaymentMethod(PaymentMethod method) {
    if (method is! CashOnDeliveryPayment) {
      state = [...state, method];
    }
  }

  void removePaymentMethod(String methodId) {
    state = state.where((m) => m.id != methodId).toList();
  }
}

// Provider for the list of saved payment methods
final paymentProvider = StateNotifierProvider<PaymentNotifier, List<PaymentMethod>>((ref) {
  return PaymentNotifier();
});

// Provider to hold the payment method currently selected for checkout
final selectedPaymentMethodProvider = StateProvider<PaymentMethod?>((ref) {
  return null;
});