import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/member_controller.dart';
import '../../core/constants/app_constants.dart';
import '../../models/member_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_overlay.dart';

class AddEditMemberView extends GetView<MemberController> {
  const AddEditMemberView({super.key});

  @override
  Widget build(BuildContext context) {
    final MemberModel? existing = Get.arguments as MemberModel?;
    final isEditing = existing != null;

    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: existing?.name ?? '');
    final phoneController = TextEditingController(text: existing?.phone ?? '');

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? AppStrings.editMember : AppStrings.addMember),
      ),
      body: Obx(() => LoadingOverlay(
            isLoading: controller.isLoading.value,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar preview
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 44,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    const Text(
                      'Member Information',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),

                    CustomTextField(
                      label: AppStrings.name,
                      controller: nameController,
                      textInputAction: TextInputAction.next,
                      prefixIcon: const Icon(Icons.person_outline),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return AppStrings.fieldRequired;
                        if (v.trim().length < 2) return 'Name must be at least 2 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      label: AppStrings.phone,
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      prefixIcon: const Icon(Icons.phone_outlined),
                    ),
                    const SizedBox(height: 32),

                    Obx(() => CustomButton(
                          label: isEditing ? 'Update Member' : 'Add Member',
                          isLoading: controller.isLoading.value,
                          icon: isEditing ? Icons.save : Icons.person_add,
                          onPressed: () async {
                            if (!formKey.currentState!.validate()) return;

                            bool success;
                            if (isEditing) {
                              success = await controller.updateMember(
                                existing,
                                name: nameController.text,
                                phone: phoneController.text,
                              );
                            } else {
                              success = await controller.addMember(
                                name: nameController.text,
                                phone: phoneController.text,
                              );
                            }
                            if (success) Get.back();
                          },
                        )),

                    if (isEditing) ...[
                      const SizedBox(height: 12),
                      CustomButton(
                        label: 'Delete Member',
                        outlined: true,
                        color: AppColors.error,
                        icon: Icons.delete_outline,
                        onPressed: () async {
                          await controller.deleteMember(existing);
                          Get.back();
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          )),
    );
  }
}
