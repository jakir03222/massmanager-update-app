import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/statement_controller.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/app_utils.dart';
import '../../models/member_model.dart';
import '../../models/monthly_statement_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_overlay.dart';

class AddEditStatementView extends GetView<StatementController> {
  const AddEditStatementView({super.key});

  @override
  Widget build(BuildContext context) {
    final MonthlyStatementModel? existing = Get.arguments as MonthlyStatementModel?;
    final isEditing = existing != null;

    final formKey = GlobalKey<FormState>();

    // Form controllers
    final consumedMealCtrl = TextEditingController(
      text: existing != null ? existing.consumedMeal.toString() : '',
    );
    final mealRateCtrl = TextEditingController(
      text: existing != null ? existing.mealRate.toString() : '',
    );
    final cookCostCtrl = TextEditingController(
      text: existing != null ? existing.cookCost.toString() : '',
    );
    final depositCtrl = TextEditingController(
      text: existing != null ? existing.depositMoney.toString() : '',
    );
    final eidBonusCtrl = TextEditingController(
      text: existing != null ? existing.eidBonus.toString() : '0',
    );
    final remarksCtrl = TextEditingController(text: existing?.remarks ?? '');

    // Selected member and month/year
    final selectedMember = Rx<MemberModel?>(
      existing != null
          ? controller.members.firstWhereOrNull((m) => m.id == existing.memberId)
          : null,
    );
    final selectedMonth = (existing?.month ?? DateTime.now().month).obs;
    final selectedYear = (existing?.year ?? DateTime.now().year).obs;

    // Load existing values into reactive fields
    if (existing != null) {
      controller.loadFromStatement(existing);
    } else {
      controller.resetFormFields();
    }

    void updateCalc() {
      controller.consumedMeal.value = double.tryParse(consumedMealCtrl.text) ?? 0;
      controller.mealRate.value = double.tryParse(mealRateCtrl.text) ?? 0;
      controller.cookCost.value = double.tryParse(cookCostCtrl.text) ?? 0;
      controller.depositMoney.value = double.tryParse(depositCtrl.text) ?? 0;
      controller.eidBonus.value = double.tryParse(eidBonusCtrl.text) ?? 0;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? AppStrings.editStatement : AppStrings.addStatement),
      ),
      body: Obx(() => LoadingOverlay(
            isLoading: controller.isLoading.value,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Member & Period ─────────────────────────────────────
                    _SectionHeader(title: AppStrings.memberPeriod),
                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Member dropdown
                            Obx(() => DropdownButtonFormField<MemberModel>(
                                  initialValue: selectedMember.value,
                                  decoration: const InputDecoration(
                                    labelText: AppStrings.selectMember,
                                    prefixIcon: Icon(Icons.person_outline),
                                  ),
                                  items: controller.members
                                      .map((m) => DropdownMenuItem(
                                            value: m,
                                            child: Text(m.name),
                                          ))
                                      .toList(),
                                  onChanged: (m) => selectedMember.value = m,
                                  validator: (_) =>
                                      selectedMember.value == null ? AppStrings.pleaseSelectMember : null,
                                )),
                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(
                                  child: Obx(() => DropdownButtonFormField<int>(
                                        initialValue: selectedMonth.value,
                                        decoration: const InputDecoration(labelText: AppStrings.month),
                                        items: List.generate(
                                          12,
                                          (i) => DropdownMenuItem(
                                            value: i + 1,
                                            child: Text(AppConstants.months[i]),
                                          ),
                                        ),
                                        onChanged: (v) {
                                          if (v != null) selectedMonth.value = v;
                                        },
                                      )),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Obx(() => DropdownButtonFormField<int>(
                                        initialValue: selectedYear.value,
                                        decoration: const InputDecoration(labelText: AppStrings.year),
                                        items: AppConstants.years
                                            .map((y) => DropdownMenuItem(
                                                  value: y,
                                                  child: Text('$y'),
                                                ))
                                            .toList(),
                                        onChanged: (v) {
                                          if (v != null) selectedYear.value = v;
                                        },
                                      )),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Input Fields ────────────────────────────────────────
                    _SectionHeader(title: AppStrings.mealDetails),
                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Auto-fill hint banner
                            Obx(() {
                              final member = selectedMember.value;
                              if (member == null || isEditing) return const SizedBox.shrink();
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.teal.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.teal.withOpacity(0.3)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.restaurant_menu, color: Colors.teal, size: 18),
                                    const SizedBox(width: 8),
                                    const Expanded(
                                      child: Text(
                                        AppStrings.autoFillHint,
                                        style: TextStyle(fontSize: 12, color: Colors.teal),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        final db = FirestoreService();
                                        final total = await db.getMemberMonthlyMealTotal(
                                          member.id,
                                          selectedMonth.value,
                                          selectedYear.value,
                                        );
                                        consumedMealCtrl.text = total.toStringAsFixed(1);
                                        updateCalc();
                                        AppUtils.showSuccess(
                                          '${total.toStringAsFixed(1)} বার খাবার পূরণ হয়েছে',
                                        );
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.teal,
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        minimumSize: Size.zero,
                                      ),
                                      child: const Text(AppStrings.autoFill, style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              );
                            }),

                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    label: AppStrings.consumedMeal,
                                    controller: consumedMealCtrl,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                                    prefixIcon: const Icon(Icons.restaurant_outlined),
                                    onChanged: (_) => updateCalc(),
                                    validator: (v) {
                                      if (v == null || v.isEmpty) return AppStrings.fieldRequired;
                                      if (double.tryParse(v) == null) return AppStrings.invalidNumber;
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: CustomTextField(
                                    label: AppStrings.mealRate,
                                    controller: mealRateCtrl,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                                    prefixIcon: const Icon(Icons.monetization_on_outlined),
                                    onChanged: (_) => updateCalc(),
                                    validator: (v) {
                                      if (v == null || v.isEmpty) return AppStrings.fieldRequired;
                                      if (double.tryParse(v) == null) return AppStrings.invalidNumber;
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            CustomTextField(
                              label: AppStrings.cookCost,
                              controller: cookCostCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                              prefixIcon: const Icon(Icons.soup_kitchen_outlined),
                              onChanged: (_) => updateCalc(),
                              validator: (v) {
                              if (v == null || v.isEmpty) return AppStrings.fieldRequired;
                              if (double.tryParse(v) == null) return AppStrings.invalidNumber;
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          CustomTextField(
                            label: AppStrings.depositMoney,
                              controller: depositCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                              prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                              onChanged: (_) => updateCalc(),
                              validator: (v) {
                              if (v == null || v.isEmpty) return AppStrings.fieldRequired;
                              if (double.tryParse(v) == null) return AppStrings.invalidNumber;
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          CustomTextField(
                            label: AppStrings.eidBonus,
                              controller: eidBonusCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                              prefixIcon: const Icon(Icons.card_giftcard_outlined),
                              onChanged: (_) => updateCalc(),
                            ),
                            const SizedBox(height: 14),
                            CustomTextField(
                              label: AppStrings.remarks,
                              controller: remarksCtrl,
                              maxLines: 2,
                              prefixIcon: const Icon(Icons.notes_outlined),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Auto Calculation Preview ─────────────────────────────
                    _SectionHeader(title: AppStrings.calcPreview),
                    Obx(() => Card(
                          margin: EdgeInsets.zero,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                _CalcRow(
                                  label: AppStrings.costOfMeal,
                                  value: AppUtils.formatCurrency(controller.costOfMeal),
                                  hint: '${AppUtils.formatMeal(controller.consumedMeal.value)} × ${AppUtils.formatCurrency(controller.mealRate.value)}',
                                ),
                                _CalcRow(
                                  label: AppStrings.totalDue,
                                  value: AppUtils.formatCurrency(controller.totalDue),
                                  hint: 'খাবারের মূল্য + রান্নার খরচ',
                                  highlight: true,
                                ),
                                _CalcRow(
                                  label: AppStrings.totalCost,
                                  value: AppUtils.formatCurrency(controller.totalCost),
                                  hint: 'মোট বকেয়া + ঈদ বোনাস',
                                  highlight: true,
                                ),
                                const Divider(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      AppStrings.netAmount,
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          AppUtils.formatCurrency(controller.netAmount.abs()),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: AppUtils.statusColor(controller.status),
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(top: 4),
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppUtils.statusBgColor(controller.status),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            controller.status,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: AppUtils.statusColor(controller.status),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )),

                    const SizedBox(height: 24),

                    // ── Save Button ──────────────────────────────────────────
                    Obx(() => CustomButton(
                          label: isEditing ? AppStrings.updateStatement : AppStrings.saveStatement,
                          isLoading: controller.isLoading.value,
                          icon: Icons.save,
                          onPressed: () async {
                            if (!formKey.currentState!.validate()) return;
                            if (selectedMember.value == null) {
                              AppUtils.showError(AppStrings.pleaseSelectMember);
                              return;
                            }

                            bool success;
                            if (isEditing) {
                              success = await controller.updateStatement(
                                existing: existing,
                                memberId: selectedMember.value!.id,
                                memberName: selectedMember.value!.name,
                                month: selectedMonth.value,
                                year: selectedYear.value,
                                consumedMeal: double.tryParse(consumedMealCtrl.text) ?? 0,
                                mealRate: double.tryParse(mealRateCtrl.text) ?? 0,
                                cookCost: double.tryParse(cookCostCtrl.text) ?? 0,
                                depositMoney: double.tryParse(depositCtrl.text) ?? 0,
                                eidBonus: double.tryParse(eidBonusCtrl.text) ?? 0,
                                remarks: remarksCtrl.text.trim(),
                              );
                            } else {
                              success = await controller.addStatement(
                                memberId: selectedMember.value!.id,
                                memberName: selectedMember.value!.name,
                                month: selectedMonth.value,
                                year: selectedYear.value,
                                consumedMeal: double.tryParse(consumedMealCtrl.text) ?? 0,
                                mealRate: double.tryParse(mealRateCtrl.text) ?? 0,
                                cookCost: double.tryParse(cookCostCtrl.text) ?? 0,
                                depositMoney: double.tryParse(depositCtrl.text) ?? 0,
                                eidBonus: double.tryParse(eidBonusCtrl.text) ?? 0,
                                remarks: remarksCtrl.text.trim(),
                              );
                            }
                            if (success) Get.back();
                          },
                        )),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          )),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _CalcRow extends StatelessWidget {
  final String label;
  final String value;
  final String? hint;
  final bool highlight;

  const _CalcRow({
    required this.label,
    required this.value,
    this.hint,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: highlight ? FontWeight.w600 : FontWeight.normal,
                  color: highlight ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
              if (hint != null)
                Text(
                  hint!,
                  style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
              color: highlight ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
