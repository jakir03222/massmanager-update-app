import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';
import '../services/auth_service.dart';
import '../core/utils/app_utils.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  final isLoading = false.obs;
  final isLoggedIn = false.obs;
  final userEmail = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _authService.authStateChanges.listen((user) {
      isLoggedIn.value = user != null;
      userEmail.value = user?.email ?? '';
    });
  }

  User? get currentUser => _authService.currentUser;

  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      AppUtils.showError('Please fill in all fields');
      return;
    }

    isLoading.value = true;
    try {
      await _authService.signIn(email: email, password: password);
      Get.offAllNamed(AppRoutes.dashboard);
    } on FirebaseAuthException catch (e) {
      AppUtils.showError(_authErrorMessage(e.code));
    } catch (e) {
      AppUtils.showError('Login failed. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    final confirmed = await AppUtils.showConfirmDialog(
      title: 'Logout',
      message: 'Are you sure you want to logout?',
      confirmText: 'Logout',
      confirmColor: Get.theme.colorScheme.primary,
    );
    if (!confirmed) return;

    await _authService.signOut();
    Get.offAllNamed(AppRoutes.login);
  }

  String _authErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Try again later.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
