import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocery_app/providers/payment_provider.dart';

class AddUpiScreen extends ConsumerStatefulWidget {
  const AddUpiScreen({super.key});

  @override
  ConsumerState<AddUpiScreen> createState() => _AddUpiScreenState();
}

class _AddUpiScreenState extends ConsumerState<AddUpiScreen> {
  final _formKey = GlobalKey<FormState>();
  final _upiIdController = TextEditingController();

  @override
  void dispose() {
    _upiIdController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final newUpiPayment = UpiPayment(upiId: _upiIdController.text);
      ref.read(paymentProvider.notifier).addPaymentMethod(newUpiPayment);
      ref.read(selectedPaymentMethodProvider.notifier).state = newUpiPayment;
      Navigator.of(context)
        ..pop()
        ..pop();
    }
  }

  // --- DESIGN OVERHAUL: The build method is completely redesigned ---
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Add UPI ID',
          // style: theme.textTheme.headlineSmall?.copyWith(
          //   fontWeight: FontWeight.bold,
          // ),
          textAlign: TextAlign.center,
        ),
        // backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- 1. A large, friendly icon to set the theme ---
              CircleAvatar(
                radius: 50,
                backgroundColor: colorScheme.primary.withOpacity(0.1),
                child: Icon(
                  Icons.currency_rupee_rounded,
                  size: 60,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),

              // --- 2. Clear, helpful text for the user ---
              Text(
                'Link your UPI ID',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'For fast and secure payments directly from your bank account.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // --- 3. The beautifully styled form ---
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _upiIdController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                        hintText: 'yourname@bank',
                        prefixIcon: Icon(
                          Icons.alternate_email,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.outline),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.outline),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colorScheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your UPI ID';
                        }
                        final upiRegex = RegExp(
                          r'^[a-zA-Z0-9.\-_]{2,256}@[a-zA-Z]{2,64}$',
                        );
                        if (!upiRegex.hasMatch(value)) {
                          return 'Please enter a valid UPI ID format';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.verified_user_outlined),
                      label: Text(
                        'Verify & Add UPI ID',
                        // style: theme.textTheme.headlineSmall?.copyWith(
                        //   fontWeight: FontWeight.bold,
                        // ),
                        textAlign: TextAlign.center,
                      ),
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
