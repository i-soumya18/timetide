import 'package:firebase_auth/firebase_auth.dart';
import 'package:timetide/core/services/logging_service.dart';
import 'package:timetide/features/authentication/data/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LoggingService _logger = LoggingService();

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _logger.info('User signed in: ${result.user?.uid}');
      return result;
    } catch (e) {
      _logger.error('Sign in error', error: e);
      rethrow;
    }
  }

  // Create user with email and password
  Future<UserCredential> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _logger.info('User created: ${result.user?.uid}');
      return result;
    } catch (e) {
      _logger.error('Create user error', error: e);
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _logger.info('User signed out');
    } catch (e) {
      _logger.error('Sign out error', error: e);
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      _logger.info('Password reset email sent to $email');
    } catch (e) {
      _logger.error('Reset password error', error: e);
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      await _auth.currentUser?.updateDisplayName(displayName);
      await _auth.currentUser?.updatePhotoURL(photoURL);
      _logger.info('User profile updated');
    } catch (e) {
      _logger.error('Update profile error', error: e);
      rethrow;
    }
  }

  // Delete user
  Future<void> deleteUser() async {
    try {
      await _auth.currentUser?.delete();
      _logger.info('User deleted');
    } catch (e) {
      _logger.error('Delete user error', error: e);
      rethrow;
    }
  }

  // Convert Firebase User to UserModel
  UserModel? userFromFirebase(User? user) {
    if (user == null) return null;

    return UserModel(
      id: user.uid,
      name: user.displayName ?? '',
      email: user.email ?? '',
      avatarUrl: user.photoURL,
      isAnonymous: user.isAnonymous,
    );
  }
}
