import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/app_constants.dart';

/// Model: domain data only. No UI, no Firebase calls.
class TextItemModel {
  const TextItemModel({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;

  factory TextItemModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final createdAt = data[AppConstants.fieldCreatedAt];
    return TextItemModel(
      id: doc.id,
      title: data[AppConstants.fieldTitle] as String? ?? '',
      body: data[AppConstants.fieldBody] as String? ?? '',
      createdAt: createdAt is Timestamp ? createdAt.toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        AppConstants.fieldTitle: title,
        AppConstants.fieldBody: body,
        AppConstants.fieldCreatedAt: Timestamp.fromDate(createdAt),
      };

  TextItemModel copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? createdAt,
  }) =>
      TextItemModel(
        id: id ?? this.id,
        title: title ?? this.title,
        body: body ?? this.body,
        createdAt: createdAt ?? this.createdAt,
      );
}
