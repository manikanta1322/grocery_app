import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocery_app/providers/auth_provider.dart';
import 'package:grocery_app/screens/profileScreens/color_selection_screen.dart';
import 'package:grocery_app/screens/profileScreens/edit_profile_screen.dart';
import 'package:grocery_app/screens/profileScreens/font_selection_screen.dart';
import 'package:grocery_app/screens/profileScreens/my_orders_screen.dart';
import 'package:grocery_app/screens/profileScreens/shipping_address_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authState = ref.watch(authProvider);
    final isLoggingOut = ref.watch(
      authProvider.select((state) => state.isLoading),
    );

    return Scaffold(
      // Let the theme handle the background color
      appBar: AppBar(
        title: const Text('My Profile'),
        // Let the theme handle the AppBar color and elevation
      ),
      // --- FIX: Wrap the body content with SafeArea ---
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // --- Profile Header ---
                CircleAvatar(
                  radius: 50,
                  // --- FIX: Use dynamic theme color ---
                  backgroundColor: colorScheme.surfaceContainer,
                  backgroundImage: authState.photoUrl != null
                      ? CachedNetworkImageProvider(authState.photoUrl!)
                      : null,
                  child: authState.photoUrl == null
                      ? Icon(
                          Icons.person,
                          size: 50,
                          // --- FIX: Use dynamic theme color ---
                          color: colorScheme.onSurfaceVariant,
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  authState.name ?? 'Guest User',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  authState.email ?? 'No email provided',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    // --- FIX: Use dynamic theme color for secondary text ---
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),

                // --- Menu Options ---
                const Divider(),
                _ProfileMenuOption(
                  icon: Icons.person_outline,
                  title: 'Edit Profile',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const EditProfileScreen(),
                      ),
                    );
                  },
                ),
                _ProfileMenuOption(
                  icon: Icons.receipt_long_outlined,
                  title: 'My Orders',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const MyOrdersScreen(),
                      ),
                    );
                  },
                ),
                _ProfileMenuOption(
                  icon: Icons.location_on_outlined,
                  title: 'Shipping Addresses',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ShippingAddressScreen(),
                      ),
                    );
                  },
                ),
                _ProfileMenuOption(
                  icon: Icons.font_download_outlined,
                  title: 'Change Font',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const FontSelectionScreen(),
                      ),
                    );
                  },
                ),
                _ProfileMenuOption(
                  icon: Icons.color_lens_outlined,
                  title: 'Change Theme Color',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ColorSelectionScreen(),
                      ),
                    );
                  },
                ),
                _ProfileMenuOption(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () {
                    // TODO: Navigate to Settings Screen
                  },
                ),
                _ProfileMenuOption(
                  icon: Icons.help_outline,
                  title: 'Help Center',
                  onTap: () {
                    // TODO: Navigate to Help Screen
                  },
                ),
                const Divider(),
                const SizedBox(height: 16),

                // --- Logout Button ---
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: isLoggingOut
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.logout),
                    label: Text(isLoggingOut ? 'Logging out...' : 'Logout'),
                    onPressed: isLoggingOut
                        ? null
                        : () async {
                            try {
                              await ref.read(authProvider.notifier).logout();
                              if (context.mounted) {
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  '/login',
                                  (Route<dynamic> route) => false,
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Logout failed: $e')),
                                );
                              }
                            }
                          },
                    // --- FIX: Use theme's error color for destructive actions ---
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      foregroundColor: colorScheme.error,
                      side: BorderSide(color: colorScheme.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      // --- FIX: Added consistent text style ---
                      textStyle: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A reusable widget for menu items on the profile screen.
class _ProfileMenuOption extends StatelessWidget {
  const _ProfileMenuOption({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          children: [
            // --- FIX: Use a theme-aware color for the icon ---
            Icon(icon, color: colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              // --- FIX: Use a more appropriate text style for a menu item title ---
              child: Text(title, style: theme.textTheme.titleMedium),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              // --- FIX: Use a theme-aware color for the trailing arrow ---
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}