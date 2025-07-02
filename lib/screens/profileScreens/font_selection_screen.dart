// lib/screens/profileScreens/font_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocery_app/providers/font_provider.dart';
import 'package:grocery_app/utils/font_utils.dart';

class FontSelectionScreen extends ConsumerWidget {
  const FontSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the provider to get the current font and rebuild when it changes.
    final currentFont = ref.watch(fontProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Change App Font'),
      ),
      body: ListView.builder(
        itemCount: availableFonts.length,
        itemBuilder: (context, index) {
          final fontName = availableFonts.keys.elementAt(index);
          final fontThemeFunction = getFontTheme(fontName);
          final isSelected = fontName == currentFont;

          return ListTile(
            title: Text(
              fontName,
              // Display each font option in its own style!
              style: fontThemeFunction(textTheme).bodyLarge,
            ),
            trailing: isSelected
                ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                : null,
            onTap: () {
              // Use read().notifier to call the method to update the state.
              ref.read(fontProvider.notifier).setFont(fontName);
            },
          );
        },
      ),
    );
  }
}