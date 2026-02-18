import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';
import '../services/firebase_service.dart';

/// Auth state and actions. Notifies views; uses AuthService only.
class AuthController extends ChangeNotifier {
  AuthController() {
    _subscription = AuthService.instance.authStateChanges.listen(_onAuthChange);
  }

  StreamSubscription<User?>? _subscription;
  User? _user;
  bool _loading = true;
  String? _error;

  User? get user => _user;
  bool get isSignedIn => _user != null;
  bool get loading => _loading;
  String? get error => _error;

  /// True after sign-up success; app shows login screen. Clear after showing message.
  bool get justSignedUp => _justSignedUp;
  bool _justSignedUp = false;

  void clearJustSignedUp() {
    _justSignedUp = false;
    notifyListeners();
  }

  void _onAuthChange(User? user) {
    _user = user;
    _loading = false;
    _error = null;
    if (user != null) {
      // Save user to Firestore (non-blocking, fails silently if Firestore unavailable)
      FirebaseService.instance.upsertLoginUser(user).catchError((e) {
        // Already handled in FirebaseService, but catch here too for safety
      });
    }
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> signInWithGoogle() async {
    _error = null;
    _loading = true;
    notifyListeners();
    try {
      final user = await AuthService.instance.signInWithGoogle();
      return user != null;
    } on FirebaseAuthException catch (e) {
      _error = e.message ?? e.code;
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> signUpWithEmail(String email, String password) async {
    _error = null;
    _loading = true;
    notifyListeners();
    try {
      final user = await AuthService.instance.signUpWithEmail(email, password);
      if (user != null) {
        _justSignedUp = true;
        await AuthService.instance.signOut();
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _error = e.message ?? e.code;
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _error = null;
    _loading = true;
    notifyListeners();
    try {
      final user = await AuthService.instance.signInWithEmail(email, password);
      return user != null;
    } on FirebaseAuthException catch (e) {
      _error = e.message ?? e.code;
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _error = null;
    notifyListeners();
    try {
      await AuthService.instance.signOut();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
