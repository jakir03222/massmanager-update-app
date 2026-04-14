import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/member_controller.dart';
import '../../controllers/summary_controller.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/app_utils.dart';
import '../../routes/app_routes.dart';
import '../../widgets/summary_card.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final summaryCtrl = Get.find<SummaryController>();
    final memberCtrl = Get.find<MemberController>();
    final authCtrl = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.dashboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: AppStrings.logout,
            onPressed: authCtrl.logout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => summaryCtrl.reloadData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting — uses userEmail.obs so Obx has a real observable to watch
              Obx(() => Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.restaurant_menu, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                AppStrings.appName,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                authCtrl.userEmail.value.isEmpty
                                    ? 'Admin'
                                    : authCtrl.userEmail.value,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),

              const SizedBox(height: 24),
              const Text(
                'Overview',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              // Summary cards
              Obx(() {
                final memberCount = memberCtrl.members.length;
                final totalDeposit = summaryCtrl.totalDepositAll;
                final totalExpense = summaryCtrl.totalExpenseAll;
                final netBalance = summaryCtrl.netBalanceAll;

                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  children: [
                    SummaryCard(
                      title: 'Total Members',
                      value: '$memberCount',
                      icon: Icons.people_outline,
                      color: AppColors.primary,
                      onTap: () => Get.toNamed(AppRoutes.memberList),
                    ),
                    SummaryCard(
                      title: 'Total Deposit',
                      value: AppUtils.formatCurrency(totalDeposit),
                      icon: Icons.account_balance_wallet_outlined,
                      color: AppColors.success,
                      onTap: () => Get.toNamed(AppRoutes.statementList),
                    ),
                    SummaryCard(
                      title: 'Total Expense',
                      value: AppUtils.formatCurrency(totalExpense),
                      icon: Icons.receipt_long_outlined,
                      color: AppColors.error,
                      onTap: () => Get.toNamed(AppRoutes.statementList),
                    ),
                    SummaryCard(
                      title: 'Net Balance',
                      value: AppUtils.formatCurrency(netBalance.abs()),
                      icon: netBalance >= 0 ? Icons.trending_up : Icons.trending_down,
                      color: netBalance >= 0 ? AppColors.success : AppColors.error,
                    ),
                  ],
                );
              }),

              const SizedBox(height: 24),
              const Text(
                'Quick Access',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              _QuickActionGrid(),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(
        label: 'Members',
        icon: Icons.people,
        color: AppColors.primary,
        route: AppRoutes.memberList,
      ),
      _QuickAction(
        label: 'Statements',
        icon: Icons.receipt_long,
        color: AppColors.accent,
        route: AppRoutes.statementList,
      ),
      _QuickAction(
        label: 'Summary',
        icon: Icons.bar_chart,
        color: AppColors.warning,
        route: AppRoutes.monthlySummary,
      ),
      _QuickAction(
        label: 'PDF Report',
        icon: Icons.picture_as_pdf,
        color: AppColors.error,
        route: AppRoutes.reports,
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.8,
      children: actions.map((a) => _QuickActionTile(action: a)).toList(),
    );
  }
}

class _QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  final String route;
  const _QuickAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.route,
  });
}

class _QuickActionTile extends StatelessWidget {
  final _QuickAction action;
  const _QuickActionTile({required this.action});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => Get.toNamed(action.route),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: action.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(action.icon, color: action.color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  action.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
