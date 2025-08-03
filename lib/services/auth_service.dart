import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;
  bool _isLoading = true;
  bool _firebaseAvailable = true;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get firebaseAvailable => _firebaseAvailable;

  AuthService() {
    print('AuthService constructor called');
    try {
      _auth.authStateChanges().listen((User? user) {
        print('AuthService - authStateChanges: user = ${user?.email}');
        _currentUser = user;
        _isLoading = false;
        print('AuthService - notifying listeners, isLoading: $_isLoading');
        notifyListeners();
        // Don't automatically navigate - let the UI handle navigation
      });
    } catch (e) {
      print('AuthService - Firebase not available: $e');
      _firebaseAvailable = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<UserCredential?> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    if (!_firebaseAvailable) {
      throw Exception('Firebase is not available. Please check your configuration.');
    }
    
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Add a small delay to handle timing issues
      await Future.delayed(const Duration(milliseconds: 500));
      
      await credential.user?.updateDisplayName(displayName);
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      // If it's a PigeonUserDetails error but we have a user, consider it successful
      if (e.toString().contains('PigeonUserDetails') && _auth.currentUser != null) {
        print('PigeonUserDetails error but user created successfully');
        return null; // Return null to indicate success but no credential
      }
      throw Exception('Sign up failed: ${e.toString()}');
    }
  }

  Future<UserCredential?> signIn({
    required String email,
    required String password,
  }) async {
    if (!_firebaseAvailable) {
      throw Exception('Firebase is not available. Please check your configuration.');
    }
    
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Add a small delay to handle timing issues
      await Future.delayed(const Duration(milliseconds: 500));
      
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      // If it's a PigeonUserDetails error but we have a user, consider it successful
      if (e.toString().contains('PigeonUserDetails') && _auth.currentUser != null) {
        print('PigeonUserDetails error but user signed in successfully');
        return null; // Return null to indicate success but no credential
      }
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    if (!_firebaseAvailable) {
      throw Exception('Firebase is not available. Please check your configuration.');
    }
    
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    if (!_firebaseAvailable) {
      throw Exception('Firebase is not available. Please check your configuration.');
    }
    
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }
} 