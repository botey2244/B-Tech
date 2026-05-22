import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? user;
  bool isLoading = false;
  String? errorMessage;

  Future<void> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      user = await _authService.signIn(email, password);
    } catch (error) {
      errorMessage = _authService.getReadableAuthError(error);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String name, String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      user = await _authService.signUp(
        name: name,
        email: email,
        password: password,
      );
    } catch (error) {
      errorMessage = _authService.getReadableAuthError(error);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _authService.sendPasswordReset(email);
    } catch (error) {
      errorMessage = _authService.getReadableAuthError(error);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
