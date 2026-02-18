import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../core/constants/app_constants.dart';
import '../models/bazar_model.dart';
import '../models/meal_model.dart';
import '../models/member_model.dart';

class FirebaseService {
  FirebaseService._();
  static final FirebaseService _instance = FirebaseService._();
  static FirebaseService get instance => _instance;

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(AppConstants.collectionUsers);
  DocumentReference<Map<String, dynamic>> _userDoc(String uid) => _users.doc(uid);
  CollectionReference<Map<String, dynamic>> _membersForUser(String uid) =>
      _users.doc(uid).collection(AppConstants.subcollectionMembers);
  CollectionReference<Map<String, dynamic>> _bazarForUser(String uid) =>
      _users.doc(uid).collection(AppConstants.subcollectionBazar);
  CollectionReference<Map<String, dynamic>> _mealsForUser(String uid) =>
      _users.doc(uid).collection(AppConstants.subcollectionMeals);

  Future<void> upsertLoginUser(User user) async {
    try {
      final doc = _users.doc(user.uid);
      final now = FieldValue.serverTimestamp();
      final existing = await doc.get();
      final existingData = existing.data();
      final keepCreatedAt = existing.exists &&
          existingData != null &&
          existingData.containsKey(AppConstants.fieldCreatedAtUser);
      await doc.set({
        AppConstants.fieldEmail: user.email ?? '',
        AppConstants.fieldDisplayName: user.displayName,
        AppConstants.fieldPhotoUrl: user.photoURL,
        AppConstants.fieldCreatedAtUser:
            keepCreatedAt ? existingData[AppConstants.fieldCreatedAtUser] : now,
        AppConstants.fieldLastLoginAt: now,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Failed to save user to Firestore: $e');
    }
  }

  Stream<Map<String, dynamic>> watchBills(String uid) {
    return _userDoc(uid).snapshots().map((doc) => doc.data() ?? <String, dynamic>{});
  }

  Future<void> upsertBills(
    String uid, {
    double? bashaVara,
    double? khalaBill,
    double? currentBill,
    double? gasBill,
    double? wifiBill,
    double? otherBill,
  }) async {
    final data = <String, dynamic>{
      if (bashaVara != null) AppConstants.fieldBillBashaVara: bashaVara,
      if (khalaBill != null) AppConstants.fieldBillKhala: khalaBill,
      if (currentBill != null) AppConstants.fieldBillCurrent: currentBill,
      if (gasBill != null) AppConstants.fieldBillGas: gasBill,
      if (wifiBill != null) AppConstants.fieldBillWifi: wifiBill,
      if (otherBill != null) AppConstants.fieldBillOther: otherBill,
      AppConstants.fieldBillsUpdatedAt: FieldValue.serverTimestamp(),
    };
    await _userDoc(uid).set(data, SetOptions(merge: true));
  }

  Stream<List<MemberModel>> watchMembers(String uid) {
    return _membersForUser(uid)
        .orderBy(AppConstants.fieldMemberCreatedAt, descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => MemberModel.fromFirestore(d)).toList());
  }

  Future<void> addMember(String uid, String name, String phone, String password) async {
    await _membersForUser(uid).add({
      AppConstants.fieldMemberName: name.trim(),
      AppConstants.fieldMemberPhone: phone.trim(),
      AppConstants.fieldMemberPassword: password,
      AppConstants.fieldMemberCreatedAt: FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteMember(String uid, String id) async {
    await _membersForUser(uid).doc(id).delete();
  }

  Stream<List<BazarModel>> watchBazar(String uid) {
    return _bazarForUser(uid)
        .orderBy(AppConstants.fieldBazarCreatedAt, descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => BazarModel.fromFirestore(d)).toList());
  }

  Future<void> addBazar(
    String uid,
    String title,
    double amount, {
    DateTime? bazarDate,
    String? memberId,
    String? memberName,
  }) async {
    final data = <String, dynamic>{
      AppConstants.fieldBazarTitle: title.trim(),
      AppConstants.fieldBazarAmount: amount,
      AppConstants.fieldBazarCreatedAt: FieldValue.serverTimestamp(),
    };
    if (bazarDate != null) {
      data[AppConstants.fieldBazarDate] = Timestamp.fromDate(bazarDate);
    }
    if (memberId != null && memberId.isNotEmpty) {
      data[AppConstants.fieldBazarMemberId] = memberId;
    }
    if (memberName != null && memberName.isNotEmpty) {
      data[AppConstants.fieldBazarMemberName] = memberName;
    }
    await _bazarForUser(uid).add(data);
  }

  Future<void> deleteBazar(String uid, String id) async {
    await _bazarForUser(uid).doc(id).delete();
  }

  Stream<List<MealModel>> watchMeals(String uid) {
    return _mealsForUser(uid)
        .orderBy(AppConstants.fieldMealCreatedAt, descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => MealModel.fromFirestore(d)).toList());
  }

  Future<void> addMeal(
    String uid,
    DateTime mealDate,
    String type, {
    String? memberId,
    String? memberName,
    required double rate,
  }) async {
    await _mealsForUser(uid).add({
      AppConstants.fieldMealDate: Timestamp.fromDate(mealDate),
      AppConstants.fieldMealType: type,
      AppConstants.fieldMealRate: rate,
      AppConstants.fieldMealCreatedAt: FieldValue.serverTimestamp(),
      if (memberId != null && memberId.isNotEmpty)
        AppConstants.fieldMealMemberId: memberId,
      if (memberName != null && memberName.isNotEmpty)
        AppConstants.fieldMealMemberName: memberName,
    });
  }

  Future<void> deleteMeal(String uid, String id) async {
    await _mealsForUser(uid).doc(id).delete();
  }
}
