// lib/providers/color_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _colorPrefKey = 'selected_theme_color';

// The NotifierProvider manages a Color object as its state.
final colorProvider = NotifierProvider<ColorNotifier, Color>(ColorNotifier.new);

class ColorNotifier extends Notifier<Color> {
  late SharedPreferences _prefs;

  @override
  // The initial state is set here. We'll default to green.
  Color build() {
    _loadColor(); // Asynchronously load the saved color.
    return Colors.green; // Return the default color immediately.
  }

  // Load the color's integer value from storage.
  Future<void> _loadColor() async {
    _prefs = await SharedPreferences.getInstance();
    final savedColorValue = _prefs.getInt(_colorPrefKey);
    if (savedColorValue != null) {
      // If a color was saved, update the state.
      state = Color(savedColorValue);
    }
  }

  // This method will be called from the UI to change the theme color.
  Future<void> setColor(Color newColor) async {
    state = newColor;
    // We store the color as an integer (its 'value').
    await _prefs.setInt(_colorPrefKey, newColor.value);
  }
}