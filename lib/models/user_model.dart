import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/app_constants.dart';

/// Login user data stored in Firestore `users` collection.
class UserModel {
  const UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.createdAt,
    required this.lastLoginAt,
  });

  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime lastLoginAt;

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserModel(
      uid: doc.id,
      email: data[AppConstants.fieldEmail] as String? ?? '',
      displayName: data[AppConstants.fieldDisplayName] as String?,
      photoUrl: data[AppConstants.fieldPhotoUrl] as String?,
      createdAt: _parseTimestamp(data[AppConstants.fieldCreatedAtUser]),
      lastLoginAt: _parseTimestamp(data[AppConstants.fieldLastLoginAt]),
    );
  }

  static DateTime _parseTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    return DateTime.now();
  }

  Map<String, dynamic> toMap() => {
        AppConstants.fieldEmail: email,
        AppConstants.fieldDisplayName: displayName,
        AppConstants.fieldPhotoUrl: photoUrl,
        AppConstants.fieldCreatedAtUser: Timestamp.fromDate(createdAt),
        AppConstants.fieldLastLoginAt: Timestamp.fromDate(lastLoginAt),
      };
}
