import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bazar_model.dart';
import '../models/meal_model.dart';
import '../models/member_model.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  FirebaseService._();
  static final FirebaseService _instance = FirebaseService._();
  static FirebaseService get instance => _instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Uses root collections instead of subcollections for simplicity, as per prompt's flat structure recommendation
  // but adding userId to each document to filter.
  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');
  CollectionReference<Map<String, dynamic>> get _members =>
      _firestore.collection('members');
  CollectionReference<Map<String, dynamic>> get _meals =>
      _firestore.collection('meals');
  CollectionReference<Map<String, dynamic>> get _bazar =>
      _firestore.collection('bazar');

  Future<void> upsertLoginUser(dynamic user) async {
    try {
      final doc = _users.doc(user.uid);
      final now = FieldValue.serverTimestamp();
      final existing = await doc.get();
      final existingData = existing.data();
      final keepCreatedAt = existing.exists &&
          existingData != null &&
          existingData.containsKey('createdAt');
      await doc.set({
        'email': user.email ?? '',
        'displayName': user.displayName,
        'photoUrl': user.photoURL,
        'createdAt': keepCreatedAt ? existingData['createdAt'] : now,
        'lastLoginAt': now,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Failed to save user to Firestore: $e');
    }
  }

  // Members
  Stream<List<MemberModel>> getMembersStream(String userId) {
    return _members
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MemberModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> addMember(MemberModel member) async {
    await _members.add(member.toMap());
  }

  // Meals
  Stream<List<MealModel>> getMealsStream(String userId) {
    return _meals
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MealModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> addMeal(MealModel meal) async {
    await _meals.add(meal.toMap());
  }

  // Bazar
  Stream<List<BazarModel>> getBazarStream(String userId) {
    return _bazar
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BazarModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> addBazar(BazarModel bazar) async {
    await _bazar.add(bazar.toMap());
  }
}
