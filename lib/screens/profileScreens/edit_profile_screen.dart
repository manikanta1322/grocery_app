import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocery_app/providers/auth_provider.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;

  XFile? _pickedImageFile;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: ref.read(authProvider).name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 1024,
    );

    if (pickedFile != null) {
      setState(() {
        _pickedImageFile = pickedFile;
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      await ref.read(authProvider.notifier).updateProfile(
            name: _nameController.text,
            imageFile: _pickedImageFile,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authState = ref.watch(authProvider);

    ImageProvider? backgroundImage;
    if (_pickedImageFile != null) {
      backgroundImage = FileImage(File(_pickedImageFile!.path));
    } else if (authState.photoUrl != null &&
        authState.photoUrl!.startsWith('http')) {
      backgroundImage = CachedNetworkImageProvider(authState.photoUrl!);
    } else if (authState.photoUrl != null) {
      backgroundImage = FileImage(File(authState.photoUrl!));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      // --- FIX: Wrap with SafeArea to avoid system intrusions ---
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // --- Interactive Profile Picture ---
              Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    // --- FIX: Use theme-aware colors ---
                    backgroundColor: colorScheme.surfaceContainer,
                    backgroundImage: backgroundImage,
                    child: backgroundImage == null
                        ? Icon(Icons.person,
                            size: 60, color: colorScheme.onSurfaceVariant)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: colorScheme.primary,
                      child: IconButton(
                        icon: Icon(Icons.edit,
                            color: colorScheme.onPrimary, size: 20),
                        onPressed: _pickImage,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // --- Form Fields ---
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- FIX: Styled TextFormField for name ---
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none),
                      ),
                      validator: (v) =>
                          (v?.isEmpty ?? true) ? 'Please enter your name' : null,
                    ),
                    const SizedBox(height: 16),
                    // --- FIX: Styled TextFormField for non-editable email ---
                    TextFormField(
                      initialValue: authState.email,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        filled: true,
                        // The theme handles the disabled fill color automatically
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none),
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 32),
                    // --- Save Button with Loading State ---
                    SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        icon: authState.isLoading
                            ? const SizedBox.shrink()
                            : const Icon(Icons.save_alt_outlined),
                        label: authState.isLoading
                            // --- FIX: Use theme-aware color for indicator ---
                            ? CircularProgressIndicator(
                                color: colorScheme.onPrimary, strokeWidth: 3)
                            : const Text('Save Changes'),
                        onPressed: authState.isLoading ? null : _submit,
                        // --- FIX: Add consistent styling ---
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          textStyle: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
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