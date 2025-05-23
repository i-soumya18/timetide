import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  UserModel? _user;
  String? _errorMessage;
  bool _needsProfileSetup = false;
  bool _isInitialized = false;

  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get needsProfileSetup => _needsProfileSetup;
  bool get isInitialized => _isInitialized;

  // Initialize and check for existing session
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        _user = await _getUserDataFromFirestore(currentUser.uid);
        if (_user != null) {
          _needsProfileSetup = _user!.name.isEmpty;
        }
      }
    } catch (e) {
      _errorMessage = "Failed to restore session: ${e.toString()}";
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Helper method to get user data from Firestore
  Future<UserModel?> _getUserDataFromFirestore(String userId) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (docSnapshot.exists) {
        return UserModel.fromJson(docSnapshot.data() ?? {});
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    try {
      _errorMessage = null;
      _user = await _authRepository.signInWithEmail(email, password);
      _needsProfileSetup = _user?.name == null || _user!.name.isEmpty;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> signUpWithEmail(
      String email, String password, String name) async {
    try {
      _errorMessage = null;
      _user = await _authRepository.signUpWithEmail(email, password, name);
      _needsProfileSetup = _user?.name == null || _user!.name.isEmpty;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      _errorMessage = null;
      _user = await _authRepository.signInWithGoogle();
      _needsProfileSetup = _user?.name == null || _user!.name.isEmpty;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> signInAsGuest() async {
    try {
      _errorMessage = null;
      _user = await _authRepository.signInAsGuest();
      _needsProfileSetup = false; // Guests skip profile setup
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateUserProfile({
    String? name,
    File? avatar,
    List<String>? preferences,
  }) async {
    try {
      if (_user == null) throw Exception('No user logged in');
      _errorMessage = null;
      await _authRepository.updateUserProfile(
        userId: _user!.id,
        name: name,
        avatar: avatar,
        preferences: preferences,
      );
      final updatedUser = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.id)
          .get()
          .then((doc) => UserModel.fromJson(doc.data() ?? {}));
      _user = updatedUser;
      _needsProfileSetup = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    _user = null;
    _needsProfileSetup = false;
    notifyListeners();
  }

  Stream<UserModel?> get userStream => _authRepository.user;
}
