import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/app_constants.dart';

class BazarModel {
  const BazarModel({
    required this.id,
    required this.title,
    required this.amount,
    this.bazarDate,
    this.memberId,
    this.memberName,
    required this.createdAt,
  });

  final String id;
  final String title;
  final double amount;
  final DateTime? bazarDate;
  final String? memberId;
  final String? memberName;
  final DateTime createdAt;

  factory BazarModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final createdAt = data[AppConstants.fieldBazarCreatedAt];
    final amount = data[AppConstants.fieldBazarAmount];
    final bazarDate = data[AppConstants.fieldBazarDate];
    return BazarModel(
      id: doc.id,
      title: data[AppConstants.fieldBazarTitle] as String? ?? '',
      amount: (amount is num) ? amount.toDouble() : 0,
      bazarDate: bazarDate is Timestamp ? bazarDate.toDate() : null,
      memberId: data[AppConstants.fieldBazarMemberId] as String?,
      memberName: data[AppConstants.fieldBazarMemberName] as String?,
      createdAt: createdAt is Timestamp ? createdAt.toDate() : DateTime.now(),
    );
  }
}
