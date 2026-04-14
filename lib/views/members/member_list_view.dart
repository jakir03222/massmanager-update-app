import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/member_controller.dart';
import '../../core/constants/app_constants.dart';
import '../../models/member_model.dart';
import '../../routes/app_routes.dart';
import '../../widgets/loading_overlay.dart';

class MemberListView extends GetView<MemberController> {
  const MemberListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.members),
        actions: [
          Obx(() => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Chip(
                  label: Text(
                    '${controller.members.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: Colors.white24,
                  side: BorderSide.none,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              )),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.addEditMember),
        icon: const Icon(Icons.person_add),
        label: const Text('Add Member'),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              onChanged: controller.onSearchChanged,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: AppStrings.search,
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.7)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.white30),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          Expanded(
            child: Obx(() {
              if (controller.filteredMembers.isEmpty) {
                return EmptyState(
                  message: controller.searchQuery.value.isEmpty
                      ? 'No members yet.\nTap + to add the first member.'
                      : 'No members found for "${controller.searchQuery.value}"',
                  icon: Icons.people_outline,
                  onAction: controller.searchQuery.value.isEmpty
                      ? () => Get.toNamed(AppRoutes.addEditMember)
                      : null,
                  actionLabel: 'Add Member',
                );
              }

              return Obx(() => LoadingOverlay(
                    isLoading: controller.isLoading.value,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: controller.filteredMembers.length,
                      itemBuilder: (_, i) {
                        final member = controller.filteredMembers[i];
                        return _MemberTile(member: member);
                      },
                    ),
                  ));
            }),
          ),
        ],
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final MemberModel member;
  const _MemberTile({required this.member});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<MemberController>();
    final initials = member.name.isNotEmpty
        ? member.name.trim().split(' ').map((w) => w[0].toUpperCase()).take(2).join()
        : '?';

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.12),
          radius: 24,
          child: Text(
            initials,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        title: Text(
          member.name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: member.phone.isNotEmpty
            ? Row(
                children: [
                  const Icon(Icons.phone_outlined, size: 12, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(member.phone, style: const TextStyle(fontSize: 12)),
                ],
              )
            : const Text('No phone', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
              onPressed: () => Get.toNamed(AppRoutes.addEditMember, arguments: member),
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
              onPressed: () => ctrl.deleteMember(member),
              tooltip: 'Delete',
            ),
          ],
        ),
        onTap: () => Get.toNamed(AppRoutes.addEditMember, arguments: member),
      ),
    );
  }
}
