import '../core/constants/app_constants.dart';
import '../core/utils/app_utils.dart';

class MonthlyStatementModel {
  final String id;
  final String memberId;
  final String memberName;
  final int month;
  final int year;
  final double consumedMeal;
  final double mealRate;
  final double cookCost;
  final double depositMoney;
  final double eidBonus;
  final String remarks;

  // Calculated fields (stored in Firestore for easy querying)
  final double costOfMeal;
  final double totalDue;
  final double totalCost;
  final double netAmount;
  final String status;

  const MonthlyStatementModel({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.month,
    required this.year,
    required this.consumedMeal,
    required this.mealRate,
    required this.cookCost,
    required this.depositMoney,
    required this.eidBonus,
    required this.remarks,
    required this.costOfMeal,
    required this.totalDue,
    required this.totalCost,
    required this.netAmount,
    required this.status,
  });

  factory MonthlyStatementModel.create({
    String id = '',
    required String memberId,
    required String memberName,
    required int month,
    required int year,
    required double consumedMeal,
    required double mealRate,
    required double cookCost,
    required double depositMoney,
    required double eidBonus,
    String remarks = '',
  }) {
    final costOfMeal = consumedMeal * mealRate;
    final totalDue = costOfMeal + cookCost;
    final totalCost = totalDue + eidBonus;
    final netAmount = depositMoney - totalCost;
    final status = AppUtils.computeStatus(netAmount);

    return MonthlyStatementModel(
      id: id,
      memberId: memberId,
      memberName: memberName,
      month: month,
      year: year,
      consumedMeal: consumedMeal,
      mealRate: mealRate,
      cookCost: cookCost,
      depositMoney: depositMoney,
      eidBonus: eidBonus,
      remarks: remarks,
      costOfMeal: costOfMeal,
      totalDue: totalDue,
      totalCost: totalCost,
      netAmount: netAmount,
      status: status,
    );
  }

  factory MonthlyStatementModel.fromMap(Map<String, dynamic> map, String docId) {
    return MonthlyStatementModel(
      id: docId,
      memberId: map[FirestoreKeys.memberId] ?? '',
      memberName: map[FirestoreKeys.memberName] ?? '',
      month: (map[FirestoreKeys.month] ?? 1) as int,
      year: (map[FirestoreKeys.year] ?? DateTime.now().year) as int,
      consumedMeal: (map[FirestoreKeys.consumedMeal] ?? 0).toDouble(),
      mealRate: (map[FirestoreKeys.mealRate] ?? 0).toDouble(),
      cookCost: (map[FirestoreKeys.cookCost] ?? 0).toDouble(),
      depositMoney: (map[FirestoreKeys.depositMoney] ?? 0).toDouble(),
      eidBonus: (map[FirestoreKeys.eidBonus] ?? 0).toDouble(),
      remarks: map[FirestoreKeys.remarks] ?? '',
      costOfMeal: (map[FirestoreKeys.costOfMeal] ?? 0).toDouble(),
      totalDue: (map[FirestoreKeys.totalDue] ?? 0).toDouble(),
      totalCost: (map[FirestoreKeys.totalCost] ?? 0).toDouble(),
      netAmount: (map[FirestoreKeys.netAmount] ?? 0).toDouble(),
      status: map[FirestoreKeys.status] ?? AppStrings.settled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      FirestoreKeys.memberId: memberId,
      FirestoreKeys.memberName: memberName,
      FirestoreKeys.month: month,
      FirestoreKeys.year: year,
      FirestoreKeys.consumedMeal: consumedMeal,
      FirestoreKeys.mealRate: mealRate,
      FirestoreKeys.cookCost: cookCost,
      FirestoreKeys.depositMoney: depositMoney,
      FirestoreKeys.eidBonus: eidBonus,
      FirestoreKeys.remarks: remarks,
      FirestoreKeys.costOfMeal: costOfMeal,
      FirestoreKeys.totalDue: totalDue,
      FirestoreKeys.totalCost: totalCost,
      FirestoreKeys.netAmount: netAmount,
      FirestoreKeys.status: status,
    };
  }

  String get monthName => AppConstants.months[month - 1];

  MonthlyStatementModel copyWith({
    String? id,
    String? memberId,
    String? memberName,
    int? month,
    int? year,
    double? consumedMeal,
    double? mealRate,
    double? cookCost,
    double? depositMoney,
    double? eidBonus,
    String? remarks,
  }) {
    return MonthlyStatementModel.create(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      memberName: memberName ?? this.memberName,
      month: month ?? this.month,
      year: year ?? this.year,
      consumedMeal: consumedMeal ?? this.consumedMeal,
      mealRate: mealRate ?? this.mealRate,
      cookCost: cookCost ?? this.cookCost,
      depositMoney: depositMoney ?? this.depositMoney,
      eidBonus: eidBonus ?? this.eidBonus,
      remarks: remarks ?? this.remarks,
    );
  }
}
