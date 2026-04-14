import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/summary_controller.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/app_utils.dart';
import '../../routes/app_routes.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/summary_card.dart';

class MonthlySummaryView extends GetView<SummaryController> {
  const MonthlySummaryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.summary),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () => Get.toNamed(AppRoutes.reports),
            tooltip: 'Export PDF',
          ),
        ],
      ),
      body: Column(
        children: [
          // Month/Year filter
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: Obx(() => _DropdownFilter<int>(
                        value: controller.selectedMonth.value,
                        items: List.generate(12, (i) => i + 1),
                        labelBuilder: (m) => AppConstants.months[m - 1],
                        onChanged: controller.setMonth,
                      )),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() => _DropdownFilter<int>(
                        value: controller.selectedYear.value,
                        items: AppConstants.years,
                        labelBuilder: (y) => '$y',
                        onChanged: controller.setYear,
                      )),
                ),
              ],
            ),
          ),

          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const CenteredLoader();
              }

              final summary = controller.summary;

              if (summary.totalMembers == 0) {
                return EmptyState(
                  message: 'No data for ${summary.monthName} ${summary.year}',
                  icon: Icons.bar_chart_outlined,
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Period title
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${summary.monthName} ${summary.year}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${summary.totalMembers} Members',
                            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              StatChip(
                                label: 'Receivable',
                                count: '${summary.receivableCount}',
                                color: AppColors.receivable,
                              ),
                              const SizedBox(width: 8),
                              StatChip(
                                label: 'Payable',
                                count: '${summary.payableCount}',
                                color: AppColors.payable,
                              ),
                              const SizedBox(width: 8),
                              StatChip(
                                label: 'Settled',
                                count: '${summary.settledCount}',
                                color: AppColors.settled,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.4,
                      children: [
                        SummaryCard(
                          title: 'Total Deposit',
                          value: AppUtils.formatCurrency(summary.totalDeposit),
                          icon: Icons.account_balance_wallet_outlined,
                          color: AppColors.success,
                        ),
                        SummaryCard(
                          title: 'Meal Cost',
                          value: AppUtils.formatCurrency(summary.totalCostOfMeal),
                          icon: Icons.restaurant_outlined,
                          color: AppColors.accent,
                        ),
                        SummaryCard(
                          title: 'Cook Cost',
                          value: AppUtils.formatCurrency(summary.totalCookCost),
                          icon: Icons.soup_kitchen_outlined,
                          color: AppColors.warning,
                        ),
                        SummaryCard(
                          title: 'Eid Bonus',
                          value: AppUtils.formatCurrency(summary.totalEidBonus),
                          icon: Icons.card_giftcard_outlined,
                          color: Colors.purple,
                        ),
                        SummaryCard(
                          title: 'Total Due',
                          value: AppUtils.formatCurrency(summary.totalDue),
                          icon: Icons.receipt_outlined,
                          color: AppColors.error,
                        ),
                        SummaryCard(
                          title: 'Total Cost',
                          value: AppUtils.formatCurrency(summary.totalCost),
                          icon: Icons.payments_outlined,
                          color: AppColors.primaryDark,
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Net balance card
                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'NET BALANCE',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textSecondary,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    AppUtils.formatCurrency(summary.totalNetAmount.abs()),
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: summary.totalNetAmount >= 0
                                          ? AppColors.receivable
                                          : AppColors.payable,
                                    ),
                                  ),
                                  Text(
                                    summary.totalNetAmount >= 0
                                        ? 'Surplus (Receivable)'
                                        : 'Deficit (Payable)',
                                    style: TextStyle(
                                      color: summary.totalNetAmount >= 0
                                          ? AppColors.receivable
                                          : AppColors.payable,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: (summary.totalNetAmount >= 0 ? AppColors.receivable : AppColors.payable)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                summary.totalNetAmount >= 0 ? Icons.trending_up : Icons.trending_down,
                                size: 36,
                                color: summary.totalNetAmount >= 0 ? AppColors.receivable : AppColors.payable,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Member breakdown header
                    const Text(
                      'MEMBER BREAKDOWN',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),

                    ...controller.statements.map((s) {
                      final statusColor = AppUtils.statusColor(s.status);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          title: Text(
                            s.memberName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            'Deposit: ${AppUtils.formatCurrency(s.depositMoney)}  |  Cost: ${AppUtils.formatCurrency(s.totalCost)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                AppUtils.formatCurrency(s.netAmount.abs()),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                  fontSize: 14,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppUtils.statusBgColor(s.status),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  s.status,
                                  style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 80),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _DropdownFilter<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final String Function(T) labelBuilder;
  final void Function(T) onChanged;

  const _DropdownFilter({
    required this.value,
    required this.items,
    required this.labelBuilder,
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
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
          items: items
              .map((item) => DropdownMenuItem<T>(
                    value: item,
                    child: Text(labelBuilder(item)),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
