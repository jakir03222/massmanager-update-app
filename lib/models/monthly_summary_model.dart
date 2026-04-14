import '../core/constants/app_constants.dart';

class MonthlySummaryModel {
  final int month;
  final int year;
  final int totalMembers;
  final double totalDeposit;
  final double totalCostOfMeal;
  final double totalCookCost;
  final double totalEidBonus;
  final double totalDue;
  final double totalCost;
  final double totalNetAmount;
  final int receivableCount;
  final int payableCount;
  final int settledCount;

  const MonthlySummaryModel({
    required this.month,
    required this.year,
    required this.totalMembers,
    required this.totalDeposit,
    required this.totalCostOfMeal,
    required this.totalCookCost,
    required this.totalEidBonus,
    required this.totalDue,
    required this.totalCost,
    required this.totalNetAmount,
    required this.receivableCount,
    required this.payableCount,
    required this.settledCount,
  });

  String get monthName => AppConstants.months[month - 1];

  Map<String, dynamic> toMap() {
    return {
      FirestoreKeys.month: month,
      FirestoreKeys.year: year,
      FirestoreKeys.totalMembers: totalMembers,
      FirestoreKeys.totalDeposit: totalDeposit,
      FirestoreKeys.totalExpense: totalCost,
      FirestoreKeys.netBalance: totalNetAmount,
    };
  }
}
