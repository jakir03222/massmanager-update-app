import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/app_constants.dart';

class MealModel {
  const MealModel({
    required this.id,
    required this.mealDate,
    this.memberId,
    this.memberName,
    required this.type,
    required this.rate,
    required this.createdAt,
  });

  final String id;
  final DateTime mealDate;
  final String? memberId;
  final String? memberName;
  final String type; // sokal | bikal
  final double rate;
  final DateTime createdAt;

  bool get isSokal => type == AppConstants.mealTypeSokal;
  bool get isBikal => type == AppConstants.mealTypeBikal;

  factory MealModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final mealDate = data[AppConstants.fieldMealDate];
    final createdAt = data[AppConstants.fieldMealCreatedAt];
    final rate = data[AppConstants.fieldMealRate];
    return MealModel(
      id: doc.id,
      mealDate: mealDate is Timestamp ? mealDate.toDate() : DateTime.now(),
      memberId: data[AppConstants.fieldMealMemberId] as String?,
      memberName: data[AppConstants.fieldMealMemberName] as String?,
      type: data[AppConstants.fieldMealType] as String? ?? AppConstants.mealTypeSokal,
      rate: (rate is num) ? rate.toDouble() : 0,
      createdAt: createdAt is Timestamp ? createdAt.toDate() : DateTime.now(),
    );
  }
}
