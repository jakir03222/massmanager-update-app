import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';

class MemberModel {
  final String id;
  final String name;
  final String phone;
  final DateTime createdAt;

  const MemberModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.createdAt,
  });

  factory MemberModel.fromMap(Map<String, dynamic> map, String docId) {
    return MemberModel(
      id: docId,
      name: map[FirestoreKeys.name] ?? '',
      phone: map[FirestoreKeys.phone] ?? '',
      createdAt: (map[FirestoreKeys.createdAt] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      FirestoreKeys.name: name,
      FirestoreKeys.phone: phone,
      FirestoreKeys.createdAt: Timestamp.fromDate(createdAt),
    };
  }

  MemberModel copyWith({String? id, String? name, String? phone, DateTime? createdAt}) {
    return MemberModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => name;
}
