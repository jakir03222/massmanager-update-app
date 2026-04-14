import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/daily_meal_controller.dart';
import '../../controllers/member_controller.dart';
import '../../core/constants/app_constants.dart';
import '../../models/daily_meal_model.dart';
import '../../models/member_model.dart';
import '../../routes/app_routes.dart';
import '../../widgets/loading_overlay.dart';

class DailyMealView extends GetView<DailyMealController> {
  const DailyMealView({super.key});

  @override
  Widget build(BuildContext context) {
    final memberCtrl = Get.find<MemberController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.dailyMeals),
        actions: [
          Obx(() => controller.isToday
              ? const SizedBox.shrink()
              : TextButton.icon(
                  onPressed: controller.goToToday,
                  icon: const Icon(Icons.today, color: Colors.white, size: 18),
                  label: const Text(AppStrings.today, style: TextStyle(color: Colors.white)),
                )),
          IconButton(
            icon: const Icon(Icons.people_outlined),
            tooltip: AppStrings.allMemberMeal,
            onPressed: () => Get.toNamed(AppRoutes.allMemberMeal),
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart_outlined),
            tooltip: AppStrings.mealCharts,
            onPressed: () => Get.toNamed(AppRoutes.mealChart),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Date navigator ──────────────────────────────────────────────────
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                  onPressed: controller.goToPreviousDay,
                  tooltip: 'আগের দিন',
                ),
                Expanded(
                  child: Obx(() => Text(
                        controller.formattedDate,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      )),
                ),
                Obx(() => IconButton(
                      icon: Icon(
                        Icons.chevron_right,
                        color: controller.isToday ? Colors.white30 : Colors.white,
                      ),
                      onPressed: controller.isToday ? null : controller.goToNextDay,
                      tooltip: 'পরের দিন',
                    )),
              ],
            ),
          ),

          // ── Daily meal totals strip ─────────────────────────────────────────
          Obx(() {
            final total = controller.meals.fold(0.0, (s, m) => s + m.total);
            final count = controller.meals.length;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: AppColors.primaryLight.withOpacity(0.08),
              child: Row(
                children: [
                  const Icon(Icons.restaurant, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    '$count সদস্য  •  মোট: ${_fmt(total)} বার',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }),

          // ── Member list ─────────────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              final members = memberCtrl.members;
              if (members.isEmpty) {
                return const EmptyState(
                  message: AppStrings.noMembers,
                  icon: Icons.people_outline,
                );
              }
              return Obx(() => LoadingOverlay(
                    isLoading: controller.isLoading.value,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(0, 6, 0, 100),
                      itemCount: members.length,
                      itemBuilder: (_, i) {
                        final member = members[i];
                        final entry = controller.mealForMember(member.id);
                        return _MemberMealTile(
                          member: member,
                          entry: entry,
                          onAdd: () => Get.toNamed(
                            AppRoutes.addDailyMeal,
                            arguments: {'member': member, 'existing': entry},
                          ),
                          onDelete: entry != null
                              ? () => controller.deleteMeal(entry)
                              : null,
                        );
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

class _MemberMealTile extends StatelessWidget {
  final MemberModel member;
  final DailyMealModel? entry;
  final VoidCallback onAdd;
  final VoidCallback? onDelete;

  const _MemberMealTile({
    required this.member,
    required this.entry,
    required this.onAdd,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final hasEntry = entry != null;
    final initials = member.name.trim().split(' ').map((w) => w[0].toUpperCase()).take(2).join();

    return Card(
      child: InkWell(
        onTap: onAdd,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 22,
                backgroundColor: hasEntry
                    ? AppColors.success.withOpacity(0.12)
                    : AppColors.primary.withOpacity(0.1),
                child: Text(
                  initials,
                  style: TextStyle(
                    color: hasEntry ? AppColors.success : AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Name + meal slots
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (hasEntry)
                      Row(
                        children: [
                          _MealSlotChip(
                            label: 'সকাল',
                            value: entry!.morning,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 6),
                          _MealSlotChip(
                            label: 'দুপুর',
                            value: entry!.afternoon,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          _MealSlotChip(
                            label: 'রাত',
                            value: entry!.night,
                            color: Colors.indigo,
                          ),
                        ],
                      )
                    else
                      Text(
                        AppStrings.tapToAdd,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary.withOpacity(0.7),
                        ),
                      ),
                  ],
                ),
              ),

              // Total badge or add button
              if (hasEntry) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_fmt(entry!.total)} বার',
                        style: const TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    if (onDelete != null)
                      GestureDetector(
                        onTap: onDelete,
                        child: const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                        ),
                      ),
                  ],
                ),
              ] else
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: AppColors.primary, size: 20),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MealSlotChip extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _MealSlotChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '$label: ${_fmt(value)}',
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

String _fmt(double v) => v == v.truncateToDouble() ? v.toInt().toString() : v.toString();
