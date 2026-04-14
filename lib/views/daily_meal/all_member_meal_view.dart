import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/daily_meal_controller.dart';
import '../../core/constants/app_constants.dart';
import '../../models/daily_meal_model.dart';
import '../../models/member_model.dart';
import '../../routes/app_routes.dart';
import '../../widgets/loading_overlay.dart';

class AllMemberMealView extends GetView<DailyMealController> {
  const AllMemberMealView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.allMemberMeal),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            tooltip: AppStrings.dailyMeals,
            onPressed: () => Get.toNamed(AppRoutes.dailyMeal),
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
          // ── Month / Year filter ────────────────────────────────────────────
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: Obx(() => _DropDown<int>(
                        value: controller.summaryMonth.value,
                        items: List.generate(12, (i) => i + 1),
                        label: (m) => AppConstants.months[m - 1],
                        onChanged: controller.setSummaryMonth,
                      )),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Obx(() => _DropDown<int>(
                        value: controller.summaryYear.value,
                        items: AppConstants.years,
                        label: (y) => '$y',
                        onChanged: controller.setSummaryYear,
                      )),
                ),
              ],
            ),
          ),

          // ── Grand total strip ──────────────────────────────────────────────
          Obx(() {
            final all = controller.allMonthlyMeals;
            final grandTotal = all.fold(0.0, (s, m) => s + m.total);
            final uniqueMembers = all.map((m) => m.memberId).toSet().length;
            final days = all.map((m) => m.day).toSet().length;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Colors.teal.withOpacity(0.07),
              child: Row(
                children: [
                  _TotalChip(label: AppStrings.totalMembers, value: '$uniqueMembers', color: AppColors.primary),
                  const SizedBox(width: 10),
                  _TotalChip(label: AppStrings.days, value: '$days', color: Colors.orange),
                  const SizedBox(width: 10),
                  _TotalChip(
                    label: AppStrings.grandTotal,
                    value: '${_fmt(grandTotal)} বার',
                    color: Colors.teal,
                  ),
                ],
              ),
            );
          }),

          // ── Member cards ───────────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              if (controller.isSummaryLoading.value) return const CenteredLoader();

              final members = controller.members;
              if (members.isEmpty) {
                return const EmptyState(
                  message: AppStrings.noMembers,
                  icon: Icons.people_outline,
                );
              }

              final byMember = controller.mealsByMember;

              if (byMember.isEmpty) {
                return EmptyState(
                  message: '${AppConstants.months[controller.summaryMonth.value - 1]} '
                      '${controller.summaryYear.value} এ কোনো খাবার এন্ট্রি নেই।\n'
                      'আগে দৈনিক খাবার যোগ করুন।',
                  icon: Icons.restaurant_outlined,
                  onAction: () => Get.toNamed(AppRoutes.dailyMeal),
                  actionLabel: AppStrings.addDailyMealsFirst,
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
                itemCount: members.length,
                itemBuilder: (_, i) {
                  final member = members[i];
                  final entries = byMember[member.id] ?? [];
                  return _MemberMealCard(member: member, entries: entries);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Per-member expandable card ───────────────────────────────────────────────

class _MemberMealCard extends StatefulWidget {
  final MemberModel member;
  final List<DailyMealModel> entries;

  const _MemberMealCard({required this.member, required this.entries});

  @override
  State<_MemberMealCard> createState() => _MemberMealCardState();
}

class _MemberMealCardState extends State<_MemberMealCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final hasEntries = widget.entries.isNotEmpty;
    final totalMeals = widget.entries.fold(0.0, (s, e) => s + e.total);
    final totalMorning = widget.entries.fold(0.0, (s, e) => s + e.morning);
    final totalAfternoon = widget.entries.fold(0.0, (s, e) => s + e.afternoon);
    final totalNight = widget.entries.fold(0.0, (s, e) => s + e.night);

    final initials = widget.member.name.trim().split(' ').map((w) => w[0].toUpperCase()).take(2).join();

    return Card(
      child: Column(
        children: [
          // ── Header row ────────────────────────────────────────────────────
          InkWell(
            onTap: hasEntries ? () => setState(() => _expanded = !_expanded) : null,
            borderRadius: _expanded
                ? const BorderRadius.vertical(top: Radius.circular(12))
                : BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: hasEntries
                        ? Colors.teal.withOpacity(0.12)
                        : AppColors.primary.withOpacity(0.08),
                    child: Text(
                      initials,
                      style: TextStyle(
                        color: hasEntries ? Colors.teal : AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Name + slot totals
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.member.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 5),
                        if (hasEntries)
                          Row(
                            children: [
                              _SlotBadge(label: 'সকাল', value: totalMorning, color: Colors.orange),
                              const SizedBox(width: 5),
                              _SlotBadge(label: 'দুপুর', value: totalAfternoon, color: AppColors.primary),
                              const SizedBox(width: 5),
                              _SlotBadge(label: 'রাত', value: totalNight, color: Colors.indigo),
                            ],
                          )
                        else
                          Text(
                            'এই মাসে কোনো খাবার নেই',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary.withOpacity(0.6),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Total + expand arrow
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (hasEntries)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.teal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_fmt(totalMeals)} বার',
                            style: const TextStyle(
                              color: Colors.teal,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.divider.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '০ বার',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      if (hasEntries) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${widget.entries.length} দিন',
                          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                        ),
                      ],
                    ],
                  ),

                  if (hasEntries) ...[
                    const SizedBox(width: 6),
                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ── Day-by-day breakdown ──────────────────────────────────────────
          if (_expanded && hasEntries)
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.divider)),
              ),
              child: Column(
                children: [
                  // Column header
                  Container(
                    color: AppColors.surface,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: const [
                        Expanded(
                          flex: 2,
                          child: Text(
                            'তারিখ',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        _ColHeader(label: 'সকাল'),
                        _ColHeader(label: 'দুপুর'),
                        _ColHeader(label: 'রাত'),
                        _ColHeader(label: 'মোট'),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // Rows
                  ...widget.entries.map((entry) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: AppColors.divider, width: 0.5)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              _dayLabel(entry.day),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          _MealCell(value: entry.morning, color: Colors.orange),
                          _MealCell(value: entry.afternoon, color: AppColors.primary),
                          _MealCell(value: entry.night, color: Colors.indigo),
                          Expanded(
                            child: Text(
                              _fmt(entry.total),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  // Sub-total row
                  Container(
                    color: Colors.teal.withOpacity(0.06),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        const Expanded(
                          flex: 2,
                          child: Text(
                            'সর্বমোট',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        _MealCell(value: totalMorning, color: Colors.orange, bold: true),
                        _MealCell(value: totalAfternoon, color: AppColors.primary, bold: true),
                        _MealCell(value: totalNight, color: Colors.indigo, bold: true),
                        Expanded(
                          child: Text(
                            _fmt(totalMeals),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── Small reusable widgets ────────────────────────────────────────────────────

class _ColHeader extends StatelessWidget {
  final String label;
  const _ColHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _MealCell extends StatelessWidget {
  final double value;
  final Color color;
  final bool bold;

  const _MealCell({required this.value, required this.color, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        value == 0 ? '-' : _fmt(value),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          color: value == 0 ? AppColors.textSecondary.withOpacity(0.4) : color,
        ),
      ),
    );
  }
}

class _SlotBadge extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _SlotBadge({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        '$label ${_fmt(value)}',
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _TotalChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _TotalChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _DropDown<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final String Function(T) label;
  final void Function(T) onChanged;

  const _DropDown({
    required this.value,
    required this.items,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          dropdownColor: AppColors.primaryDark,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          icon: const Icon(Icons.expand_more, color: Colors.white, size: 18),
          isExpanded: true,
          onChanged: (v) { if (v != null) onChanged(v); },
          items: items
              .map((i) => DropdownMenuItem<T>(value: i, child: Text(label(i))))
              .toList(),
        ),
      ),
    );
  }
}

// ── helpers ────────────────────────────────────────────────────────────────────

String _fmt(double v) =>
    v == v.truncateToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

String _dayLabel(int day) => '$day তারিখ';
