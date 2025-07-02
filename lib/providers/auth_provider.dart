import 'package:flutter_riverpod/flutter_riverpod.dart';
// --- 1. IMPORT image_picker for the XFile type ---
import 'package:image_picker/image_picker.dart';

class AuthState {
  // A loading flag for UI feedback (e.g., showing a spinner)
  final bool isLoading;

  final bool isAuthenticated;
  final String? userId;
  final String? phone;
  final String? name;

  // email and photoUrl are already part of your state
  final String? email;
  final String? photoUrl;

  const AuthState({
    this.isLoading = false,
    required this.isAuthenticated,
    this.userId,
    this.phone,
    this.name,
    this.email,
    this.photoUrl,
  });

  // copyWith already includes all the necessary properties
  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? userId,
    String? phone,
    String? name,
    String? email,
    String? photoUrl,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userId: userId ?? this.userId,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  // The initial state
  AuthNotifier() : super(const AuthState(isAuthenticated: false));

  Future<void> login({required String phone, required String password}) async {
    // ... your existing login logic remains unchanged
    state = state.copyWith(isLoading: true, isAuthenticated: false);
    try {
      await Future.delayed(const Duration(seconds: 2));
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        userId: 'user-$phone',
        phone: phone,
        name: 'Manikanta',
        email: 'manikanta@example.com',
        photoUrl: 'https://i.pravatar.cc/150?u=manikanta',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, isAuthenticated: false);
      rethrow;
    }
  }

  Future<void> signup({
    required String phone,
    required String password,
    required String name,
  }) async {
    // ... your existing signup logic remains unchanged
    state = state.copyWith(isLoading: true, isAuthenticated: false);
    try {
      await Future.delayed(const Duration(seconds: 2));
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        userId: 'new-user-${DateTime.now().millisecondsSinceEpoch}',
        phone: phone,
        name: name,
        email: '$name@example.com'.toLowerCase().replaceAll(' ', '.'),
        photoUrl: 'https://i.pravatar.cc/150?u=$name',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, isAuthenticated: false);
      rethrow;
    }
  }

  Future<void> logout() async {
    // ... your existing logout logic remains unchanged
    state = state.copyWith(isLoading: true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      state = const AuthState(isAuthenticated: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }
  
  // --- 2. ADD THE NEW updateProfile METHOD HERE ---
  /// Updates the user's profile information.
  Future<void> updateProfile({
    required String name,
    XFile? imageFile, // This is an optional image file from image_picker
  }) async {
    // Set loading to true to show a spinner on the UI
    state = state.copyWith(isLoading: true);

    // Simulate a network delay for saving the profile data
    await Future.delayed(const Duration(seconds: 2));

    String? newPhotoUrl = state.photoUrl;
    if (imageFile != null) {
      // In a real application, you would:
      // 1. Upload the image file (imageFile.path) to a cloud storage service (like Firebase Storage, AWS S3, etc.).
      // 2. Get the public URL of the uploaded image.
      // 3. Save that URL to your user database.
      
      // For this demo, we'll just use the local file path to show that the image has been updated.
      // This will work on mobile but not on web.
      newPhotoUrl = imageFile.path;
    }

    // Update the state with the new name and photo URL
    state = state.copyWith(
      name: name,
      photoUrl: newPhotoUrl,
      isLoading: false, // Set loading back to false
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);