import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final obscurePassword = true.obs;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, AppColors.primaryDark],
            stops: [0.0, 0.4],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: Colors.white24, width: 2),
                        ),
                        child: const Icon(Icons.restaurant_menu, size: 44, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        AppStrings.appName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppStrings.messManagement,
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),

              // Login card
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            AppStrings.welcomeBack,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            AppStrings.signInToContinue,
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                          ),
                          const SizedBox(height: 28),

                          CustomTextField(
                            label: AppStrings.email,
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            prefixIcon: const Icon(Icons.email_outlined),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return AppStrings.fieldRequired;
                              if (!GetUtils.isEmail(v.trim())) return AppStrings.invalidEmail;
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          Obx(() => CustomTextField(
                                label: AppStrings.password,
                                controller: passwordController,
                                obscureText: obscurePassword.value,
                                textInputAction: TextInputAction.done,
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    obscurePassword.value
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: AppColors.textSecondary,
                                  ),
                                  onPressed: () => obscurePassword.value = !obscurePassword.value,
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return AppStrings.fieldRequired;
                                  if (v.length < 6) return AppStrings.passwordTooShort;
                                  return null;
                                },
                                onFieldSubmitted: (_) {
                                  if (formKey.currentState!.validate()) {
                                    controller.login(
                                      emailController.text,
                                      passwordController.text,
                                    );
                                  }
                                },
                              )),
                          const SizedBox(height: 28),

                          Obx(() => CustomButton(
                                label: AppStrings.login,
                                isLoading: controller.isLoading.value,
                                icon: Icons.login,
                                onPressed: () {
                                  if (formKey.currentState!.validate()) {
                                    controller.login(
                                      emailController.text,
                                      passwordController.text,
                                    );
                                  }
                                },
                              )),

                          const SizedBox(height: 16),
                          Center(
                            child: Text(
                              AppStrings.authorizedOnly,
                              style: TextStyle(
                                color: AppColors.textSecondary.withOpacity(0.6),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
