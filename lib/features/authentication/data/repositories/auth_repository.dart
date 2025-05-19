import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  AuthRepository() {
    // Firebase Auth on mobile already uses Persistence.LOCAL by default
    // We'll explicitly set it for web platforms
    if (kIsWeb) {
      _auth.setPersistence(Persistence.LOCAL);
    }
  }

  Future<UserModel?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _getUserModel(credential.user);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> signUpWithEmail(
      String email, String password, String name) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user != null) {
        final userModel = UserModel(
          id: user.uid,
          email: email,
          name: name,
        );
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(userModel.toJson());
        return userModel;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn();
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user != null) {
        final userModel = UserModel(
          id: user.uid,
          email: user.email ?? '',
          name: user.displayName ?? '',
          avatarUrl: user.photoURL,
        );
        await _firestore.collection('users').doc(user.uid).set(
              userModel.toJson(),
              SetOptions(merge: true),
            );
        return userModel;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> signInAsGuest() async {
    try {
      final credential = await _auth.signInAnonymously();
      return _getUserModel(credential.user);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUserProfile({
    required String userId,
    String? name,
    File? avatar,
    List<String>? preferences,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (preferences != null) updates['preferences'] = preferences;

      if (avatar != null) {
        final ref = _storage.ref().child('avatars/$userId/avatar.jpg');
        await ref.putFile(avatar);
        final avatarUrl = await ref.getDownloadURL();
        updates['avatarUrl'] = avatarUrl;
      }

      await _firestore.collection('users').doc(userId).update(updates);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
  }

  UserModel? _getUserModel(User? user) {
    if (user == null) return null;
    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      name: user.displayName ?? '',
      avatarUrl: user.photoURL,
      isAnonymous: user.isAnonymous,
      preferences: [],
    );
  }

  Stream<UserModel?> get user {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }
      return _getUserModel(user);
    });
  }
}
