// lib/screens/profileScreens/color_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocery_app/providers/color_provider.dart';
import 'package:grocery_app/utils/color_utils.dart' show availableColors;

class ColorSelectionScreen extends ConsumerWidget {
  const ColorSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the provider to get the current color and rebuild when it changes.
    final currentColor = ref.watch(colorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Theme Color'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: availableColors.length,
          itemBuilder: (context, index) {
            final colorName = availableColors.keys.elementAt(index);
            final colorValue = availableColors.values.elementAt(index);
            final isSelected = currentColor.value == colorValue.value;

            return GestureDetector(
              onTap: () {
                // Call the notifier's method to update the color.
                ref.read(colorProvider.notifier).setColor(colorValue);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: colorValue,
                  borderRadius: BorderRadius.circular(16),
                  border: isSelected
                      ? Border.all(
                          color: Theme.of(context).colorScheme.onSurface,
                          width: 3,
                        )
                      : null,
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 30)
                    : null,
              ),
            );
          },
        ),
      ),
    );
  }
}