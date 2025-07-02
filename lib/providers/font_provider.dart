// lib/providers/font_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocery_app/utils/font_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

// The key we'll use to store the font name in SharedPreferences.
const String _fontPrefKey = 'selected_font';

// Use NotifierProvider for state that can be modified from the UI.
final fontProvider = NotifierProvider<FontNotifier, String>(FontNotifier.new);

class FontNotifier extends Notifier<String> {
  late SharedPreferences _prefs;

  @override
  // The build method is where we initialize our state.
  String build() {
    // We can't use `async` here, so we initialize synchronously and load async.
    // The default font is the first one in our list.
    final defaultFont = availableFonts.keys.first;
    _loadFont(); // Start the async loading process.
    return defaultFont; // Return the default immediately.
  }

  // A private method to load the saved font from storage.
  Future<void> _loadFont() async {
    _prefs = await SharedPreferences.getInstance();
    final savedFont = _prefs.getString(_fontPrefKey);
    // If a font was saved and it's a valid font, update the state.
    if (savedFont != null && availableFonts.containsKey(savedFont)) {
      state = savedFont;
    }
  }

  // A public method the UI can call to change the font.
  Future<void> setFont(String newFontName) async {
    if (availableFonts.containsKey(newFontName)) {
      state = newFontName;
      await _prefs.setString(_fontPrefKey, newFontName);
    }
  }
}