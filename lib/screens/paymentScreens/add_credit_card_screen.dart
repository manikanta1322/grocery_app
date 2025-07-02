import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocery_app/providers/payment_provider.dart';

class AddCreditCardScreen extends ConsumerStatefulWidget {
  const AddCreditCardScreen({super.key});

  @override
  ConsumerState<AddCreditCardScreen> createState() =>
      _AddCreditCardScreenState();
}

class _AddCreditCardScreenState extends ConsumerState<AddCreditCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardHolderNameController = TextEditingController();

  // State for the card flip animation
  bool _isCvvFocused = false;
  late final FocusNode _cvvFocusNode;

  @override
  void initState() {
    super.initState();
    _cvvFocusNode = FocusNode();
    _cvvFocusNode.addListener(() {
      if (mounted) {
        setState(() {
          _isCvvFocused = _cvvFocusNode.hasFocus;
        });
      }
    });

    // Add listeners to update the card UI in real-time
    _cardNumberController.addListener(() => setState(() {}));
    _expiryDateController.addListener(() => setState(() {}));
    _cardHolderNameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _cardHolderNameController.dispose();
    _cvvFocusNode.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final newCard = CreditCardPayment(
        cardHolderName: _cardHolderNameController.text,
        cardNumber: _cardNumberController.text.replaceAll(' ', ''),
        expiryDate: _expiryDateController.text,
        cvv: _cvvController.text,
      );
      ref.read(paymentProvider.notifier).addPaymentMethod(newCard);
      ref.read(selectedPaymentMethodProvider.notifier).state = newCard;
      if (mounted) {
        Navigator.of(context)
          ..pop()
          ..pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Card'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildCreditCard(theme, colorScheme),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTextFormField(
                      controller: _cardNumberController,
                      labelText: 'Card Number',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(16),
                        CardNumberInputFormatter(),
                      ],
                      validator: (v) =>
                          (v?.replaceAll(' ', '').length ?? 0) != 16
                              ? 'Enter a valid 16-digit card number'
                              : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextFormField(
                            controller: _expiryDateController,
                            labelText: 'Expiry Date',
                            hintText: 'MM/YY',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                              CardMonthInputFormatter(),
                            ],
                            validator: (v) => (v?.length ?? 0) != 5
                                ? 'Enter MM/YY'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextFormField(
                            controller: _cvvController,
                            focusNode: _cvvFocusNode, // Assign the focus node
                            labelText: 'CVV',
                            hintText: '123',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(3),
                            ],
                            validator: (v) => (v?.length ?? 0) != 3
                                ? 'Enter a 3-digit CVV'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      controller: _cardHolderNameController,
                      labelText: 'Cardholder Name',
                      validator: (v) =>
                          (v?.isEmpty ?? true) ? 'Enter cardholder name' : null,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add_card),
                      label: const Text('Add Card'),
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
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

  // A helper for styled text form fields
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    FocusNode? focusNode,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
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
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      focusNode: focusNode,
    );
  }

  // The animated, interactive credit card widget
  Widget _buildCreditCard(ThemeData theme, ColorScheme colorScheme) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        // Create a flip animation
        final rotateAnim = Tween(begin: 3.14, end: 0.0).animate(animation);
        return AnimatedBuilder(
          animation: rotateAnim,
          child: child,
          builder: (context, child) {
            final isUnder = (ValueKey(_isCvvFocused) != child?.key);
            var tilt = ((animation.value - 0.5).abs() - 0.5) * 0.003;
            tilt = isUnder ? -tilt : tilt;
            final value = isUnder
                ? rotateAnim.value < (3.14 / 2)
                : rotateAnim.value > (3.14 / 2);
            return Transform(
              transform: Matrix4.rotationY(value ? 3.14 : rotateAnim.value)
                ..setEntry(3, 0, tilt),
              child: child,
              alignment: Alignment.center,
            );
          },
        );
      },
      child: _isCvvFocused
          ? _buildCardBack(theme, colorScheme)
          : _buildCardFront(theme, colorScheme),
    );
  }

  Widget _buildCardFront(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      key: const ValueKey(false),
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            // Lerp with a darker surface color for a rich, dynamic gradient
            Color.lerp(colorScheme.primary, colorScheme.inverseSurface, 0.2)!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Stack(
        children: [
          Positioned(
            top: 15,
            right: 20,
            child: Text(
              'VISA',
              style: TextStyle(
                color: colorScheme.onPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: 20,
            child: Icon(
              Icons.sd_card_rounded,
              color: colorScheme.onPrimary.withOpacity(0.8),
              size: 40,
            ),
          ),
          Positioned(
            bottom: 60,
            left: 20,
            right: 20,
            child: Text(
              _cardNumberController.text.isEmpty
                  ? '**** **** **** ****'
                  : _cardNumberController.text,
              style: TextStyle(
                color: colorScheme.onPrimary,
                fontSize: 22,
                letterSpacing: 2,
                fontFamily: 'monospace',
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: Text(
              _cardHolderNameController.text.isEmpty
                  ? 'CARDHOLDER NAME'
                  : _cardHolderNameController.text.toUpperCase(),
              style: TextStyle(
                color: colorScheme.onPrimary.withOpacity(0.8),
                fontSize: 14,
                letterSpacing: 1,
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'EXPIRES',
                  style: TextStyle(
                    color: colorScheme.onPrimary.withOpacity(0.8),
                    fontSize: 10,
                  ),
                ),
                Text(
                  _expiryDateController.text.isEmpty
                      ? 'MM/YY'
                      : _expiryDateController.text,
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      key: const ValueKey(true),
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: colorScheme.surfaceContainer,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          // Magnetic Strip
          Container(height: 50, color: colorScheme.onSurface.withOpacity(0.8)),
          const SizedBox(height: 20),
          // Signature and CVV area
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    height: 40,
                    color: colorScheme.onSurface.withOpacity(0.1),
                    child: Text(
                      'Signature',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  alignment: Alignment.center,
                  width: 50,
                  height: 40,
                  color: colorScheme.onSurface.withOpacity(0.1),
                  child: Text(
                    _cvvController.text,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 18,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Custom Input Formatters (no changes needed here) ---

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.selection.baseOffset == 0) return newValue;
    String inputData = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    StringBuffer buffer = StringBuffer();
    for (var i = 0; i < inputData.length; i++) {
      buffer.write(inputData[i]);
      if ((i + 1) % 4 == 0 && i != inputData.length - 1) {
        buffer.write(" ");
      }
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class CardMonthInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (newValue.selection.baseOffset == 0) return newValue;
    var buffer = StringBuffer();
    for (int i = 0; i < newText.length; i++) {
      buffer.write(newText[i]);
      if (i == 1 && newText.length > 2) {
        buffer.write('/');
      }
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}