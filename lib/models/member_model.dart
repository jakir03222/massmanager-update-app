import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/app_constants.dart';

/// Member data for Firestore `members` collection.
class MemberModel {
  const MemberModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.password,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String phone;
  final String password;
  final DateTime createdAt;

  factory MemberModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final createdAt = data[AppConstants.fieldMemberCreatedAt];
    return MemberModel(
      id: doc.id,
      name: data[AppConstants.fieldMemberName] as String? ?? '',
      phone: data[AppConstants.fieldMemberPhone] as String? ?? '',
      password: data[AppConstants.fieldMemberPassword] as String? ?? '',
      createdAt: createdAt is Timestamp ? createdAt.toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        AppConstants.fieldMemberName: name,
        AppConstants.fieldMemberPhone: phone,
        AppConstants.fieldMemberPassword: password,
        AppConstants.fieldMemberCreatedAt: Timestamp.fromDate(createdAt),
      };
}
