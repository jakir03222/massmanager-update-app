import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/daily_meal_controller.dart';
import '../../core/constants/app_constants.dart';
import '../../models/daily_meal_model.dart';
import '../../models/member_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_overlay.dart';

class AddDailyMealView extends GetView<DailyMealController> {
  const AddDailyMealView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>;
    final MemberModel member = args['member'] as MemberModel;
    final DailyMealModel? existing = args['existing'] as DailyMealModel?;

    final morning = (existing?.morning ?? 0.0).obs;
    final afternoon = (existing?.afternoon ?? 0.0).obs;
    final night = (existing?.night ?? 0.0).obs;

    return Scaffold(
      appBar: AppBar(
        title: Text(existing == null ? AppStrings.addDailyMeal : 'খাবার সম্পাদনা'),
      ),
      body: Obx(() => LoadingOverlay(
            isLoading: controller.isLoading.value,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Member card ───────────────────────────────────────────
                  _MemberHeader(member: member, date: controller.selectedDate.value),
                  const SizedBox(height: 24),

                  // ── Morning ───────────────────────────────────────────────
                  const _SlotLabel(
                    label: AppStrings.morning,
                    icon: Icons.wb_sunny_outlined,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 8),
                  Obx(() => _MealSelector(
                        value: morning.value,
                        onChanged: (v) => morning.value = v,
                        color: Colors.orange,
                      )),

                  const SizedBox(height: 20),

                  // ── Afternoon ─────────────────────────────────────────────
                  const _SlotLabel(
                    label: AppStrings.afternoon,
                    icon: Icons.wb_cloudy_outlined,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 8),
                  Obx(() => _MealSelector(
                        value: afternoon.value,
                        onChanged: (v) => afternoon.value = v,
                        color: AppColors.primary,
                      )),

                  const SizedBox(height: 20),

                  // ── Night ─────────────────────────────────────────────────
                  const _SlotLabel(
                    label: AppStrings.night,
                    icon: Icons.nights_stay_outlined,
                    color: Colors.indigo,
                  ),
                  const SizedBox(height: 8),
                  Obx(() => _MealSelector(
                        value: night.value,
                        onChanged: (v) => night.value = v,
                        color: Colors.indigo,
                      )),

                  const SizedBox(height: 24),

                  // ── Total preview ─────────────────────────────────────────
                  Obx(() {
                    final total = morning.value + afternoon.value + night.value;
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            AppStrings.mealsToday,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${_fmt(total)} বার',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 24),

                  // ── Save button ───────────────────────────────────────────
                  Obx(() => CustomButton(
                        label: existing == null ? AppStrings.saveMeal : AppStrings.updateMeal,
                        isLoading: controller.isLoading.value,
                        icon: Icons.save_outlined,
                        onPressed: () async {
                          final success = await controller.saveMeal(
                            member: member,
                            morning: morning.value,
                            afternoon: afternoon.value,
                            night: night.value,
                          );
                          if (success) Get.back();
                        },
                      )),

                  if (existing != null) ...[
                    const SizedBox(height: 12),
                    CustomButton(
                      label: AppStrings.removeMeal,
                      outlined: true,
                      color: AppColors.error,
                      icon: Icons.delete_outline,
                      onPressed: () async {
                        await controller.deleteMeal(existing);
                        Get.back();
                      },
                    ),
                  ],
                ],
              ),
            ),
          )),
    );
  }
}

// ── Meal selector widget ─────────────────────────────────────────────────────

class _MealSelector extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final Color color;

  // Quick-select values: 0 | 0.5 | 1 | 1.5 | 2 | 2.5 | 3
  static const _quickValues = [0.0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0];

  const _MealSelector({
    required this.value,
    required this.onChanged,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quick tap buttons
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _quickValues.map((v) {
            final selected = value == v;
            return GestureDetector(
              onTap: () => onChanged(v),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 56,
                height: 48,
                decoration: BoxDecoration(
                  color: selected ? color : color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selected ? color : color.withOpacity(0.25),
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    _fmt(v),
                    style: TextStyle(
                      color: selected ? Colors.white : color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 12),

        // +/- fine-tuner row
        Row(
          children: [
            _AdjustButton(
              icon: Icons.remove,
              color: color,
              onPressed: value > 0
                  ? () => onChanged(
                        double.parse((value - 0.5).clamp(0, 99).toStringAsFixed(1)),
                      )
                  : null,
            ),
            const SizedBox(width: 12),
            Container(
              width: 72,
              height: 44,
              decoration: BoxDecoration(
                border: Border.all(color: color.withOpacity(0.4)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  _fmt(value),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            _AdjustButton(
              icon: Icons.add,
              color: color,
              onPressed: () => onChanged(
                double.parse((value + 0.5).toStringAsFixed(1)),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'বার',
              style: TextStyle(color: color, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }
}

class _AdjustButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  const _AdjustButton({
    required this.icon,
    required this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: onPressed != null ? color.withOpacity(0.12) : Colors.grey.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: onPressed != null ? color.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
          ),
        ),
        child: Icon(
          icon,
          color: onPressed != null ? color : Colors.grey,
          size: 22,
        ),
      ),
    );
  }
}

class _SlotLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _SlotLabel({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _MemberHeader extends StatelessWidget {
  final MemberModel member;
  final DateTime date;

  const _MemberHeader({required this.member, required this.date});

  @override
  Widget build(BuildContext context) {
    final initials = member.name.trim().split(' ').map((w) => w[0].toUpperCase()).take(2).join();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white24,
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('EEEE, dd MMM yyyy').format(date),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.restaurant_menu, color: Colors.white54, size: 28),
        ],
      ),
    );
  }
}

String _fmt(double v) =>
    v == v.truncateToDouble() ? v.toInt().toString() : v.toString();
