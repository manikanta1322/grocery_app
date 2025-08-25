import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocery_app/apiServices/Login_DetailsApi.dart';
import 'package:grocery_app/globalFuctions/globalFunctions.dart';
import 'package:grocery_app/screens/home/home_screen_body.dart';
import 'package:grocery_app/screens/loginScreens/login_screen.dart';
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

  Future<void> login({
    required BuildContext context,
    required String phone,
    required String password,
  }) async {
    // ... your existing login logic remains unchanged
    state = state.copyWith(isLoading: true, isAuthenticated: false);

    Map<String, String> params = {"phoneNumber": phone, "password": password};
    try {
      final responseData = await Login_DetailsApi().logIn(context, params);

      if (responseData != null && responseData['status'] == 200) {
        print("Login Successful: $responseData");

        var authID = responseData['authId'];
        print("printing the authID $authID");
        storage.write('authID', authID);
        Tgg.navigateTo(context, HomeScreenBody());
      } else {
        throw Exception(responseData?['message'] ?? 'Login failed');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, isAuthenticated: false);
      rethrow;
    }
  }

  Future<void> signup({
    // Add BuildContext as a parameter because your API class needs it
    required BuildContext context,
    required String fullName,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
  }) async {
    state = state.copyWith(isLoading: true);

    // Create the parameter map
    Map<String, String> params = {
      "fullName": fullName,
      "phoneNumber": phoneNumber,
      "password": password,
      "confirmPassword": confirmPassword,
    };

    try {
      // Create an instance of your API class and call the new signUp method
      final responseData = await Login_DetailsApi().signIn(context, params);

      // Check the response from your API helper
      if (responseData != null && responseData['status'] == 201) {
        state = state.copyWith(isLoading: false);
        print("Signup Successful: $responseData");
        Tgg.navigateTo(context, LoginScreen());
      } else {
        // Throw an exception with the message from the backend
        throw Exception(responseData?['message'] ?? 'Signup failed');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      // Rethrow the error so the UI can catch it
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
