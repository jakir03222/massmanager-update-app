import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/app_utils.dart';
import '../models/monthly_statement_model.dart';

class StatementCard extends StatelessWidget {
  final MonthlyStatementModel statement;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const StatementCard({
    super.key,
    required this.statement,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = AppUtils.statusColor(statement.status);
    final statusBg = AppUtils.statusBgColor(statement.status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Expanded(
                  child: Text(
                    statement.memberName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    statement.status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (onEdit != null || onDelete != null) ...[
                  const SizedBox(width: 4),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: AppColors.textSecondary, size: 20),
                    onSelected: (value) {
                      if (value == 'edit') onEdit?.call();
                      if (value == 'delete') onDelete?.call();
                    },
                    itemBuilder: (_) => [
                      if (onEdit != null)
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(children: [
                            Icon(Icons.edit_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ]),
                        ),
                      if (onDelete != null)
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(children: [
                            Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: AppColors.error)),
                          ]),
                        ),
                    ],
                  ),
                ],
              ],
            ),

            const SizedBox(height: 4),
            Text(
              '${statement.monthName} ${statement.year}',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),

            const Divider(height: 20),

            // Calculation rows
            _InfoRow(label: 'Consumed Meal', value: '${AppUtils.formatMeal(statement.consumedMeal)} meals'),
            _InfoRow(label: 'Meal Rate', value: AppUtils.formatCurrency(statement.mealRate)),
            _InfoRow(label: AppStrings.costOfMeal, value: AppUtils.formatCurrency(statement.costOfMeal)),
            _InfoRow(label: 'Cook Cost', value: AppUtils.formatCurrency(statement.cookCost)),
            _InfoRow(label: AppStrings.totalDue, value: AppUtils.formatCurrency(statement.totalDue), isBold: true),
            _InfoRow(label: 'Eid Bonus', value: AppUtils.formatCurrency(statement.eidBonus)),
            _InfoRow(label: AppStrings.totalCost, value: AppUtils.formatCurrency(statement.totalCost), isBold: true),
            _InfoRow(label: 'Deposit', value: AppUtils.formatCurrency(statement.depositMoney)),

            const Divider(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Net Amount',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  AppUtils.formatCurrency(statement.netAmount.abs()),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: statusColor,
                  ),
                ),
              ],
            ),

            if (statement.remarks.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Note: ${statement.remarks}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _InfoRow({required this.label, required this.value, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: isBold ? AppColors.textPrimary : AppColors.textPrimary,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
