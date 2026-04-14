import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';
import '../services/auth_service.dart';
import '../core/utils/app_utils.dart';
import '../core/constants/app_constants.dart';

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
      AppUtils.showError(AppStrings.pleaseFillAll);
      return;
    }

    isLoading.value = true;
    try {
      await _authService.signIn(email: email, password: password);
      Get.offAllNamed(AppRoutes.dashboard);
    } on FirebaseAuthException catch (e) {
      AppUtils.showError(_authErrorMessage(e.code));
    } catch (e) {
      AppUtils.showError('লগইন ব্যর্থ হয়েছে। আবার চেষ্টা করুন।');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    final confirmed = await AppUtils.showConfirmDialog(
      title: AppStrings.logoutConfirmTitle,
      message: AppStrings.logoutConfirmMessage,
      confirmText: AppStrings.logout,
      confirmColor: Get.theme.colorScheme.primary,
    );
    if (!confirmed) return;

    await _authService.signOut();
    Get.offAllNamed(AppRoutes.login);
  }

  String _authErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'এই ইমেইলে কোনো অ্যাকাউন্ট পাওয়া যায়নি।';
      case 'wrong-password':
        return 'পাসওয়ার্ড সঠিক নয়।';
      case 'invalid-email':
        return 'ইমেইল ঠিকানা সঠিক নয়।';
      case 'user-disabled':
        return 'এই অ্যাকাউন্টটি নিষ্ক্রিয় করা হয়েছে।';
      case 'too-many-requests':
        return 'বারবার ব্যর্থ প্রচেষ্টা। কিছুক্ষণ পরে আবার চেষ্টা করুন।';
      case 'invalid-credential':
        return 'ইমেইল বা পাসওয়ার্ড সঠিক নয়।';
      default:
        return 'লগইন ব্যর্থ হয়েছে। আবার চেষ্টা করুন।';
    }
  }
}
