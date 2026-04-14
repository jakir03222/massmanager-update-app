import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';
import '../models/daily_meal_model.dart';
import '../models/member_model.dart';
import '../models/monthly_statement_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _membersCol =>
      _db.collection(FirestoreKeys.members);

  CollectionReference<Map<String, dynamic>> get _statementsCol =>
      _db.collection(FirestoreKeys.monthlyStatements);

  CollectionReference<Map<String, dynamic>> get _dailyMealsCol =>
      _db.collection(FirestoreKeys.dailyMeals);

  // ─── Members ────────────────────────────────────────────────────────────────

  Stream<List<MemberModel>> membersStream() {
    return _membersCol
        .orderBy(FirestoreKeys.name)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => MemberModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<List<MemberModel>> getMembers() async {
    final snap = await _membersCol.orderBy(FirestoreKeys.name).get();
    return snap.docs.map((doc) => MemberModel.fromMap(doc.data(), doc.id)).toList();
  }

  Future<String> addMember(MemberModel member) async {
    final doc = await _membersCol.add(member.toMap());
    return doc.id;
  }

  Future<void> updateMember(MemberModel member) async {
    await _membersCol.doc(member.id).update(member.toMap());
  }

  Future<void> deleteMember(String memberId) async {
    await _membersCol.doc(memberId).delete();
  }

  // ─── Monthly Statements ──────────────────────────────────────────────────────

  Stream<List<MonthlyStatementModel>> statementsStream({int? month, int? year}) {
    Query<Map<String, dynamic>> query = _statementsCol;

    if (month != null) query = query.where(FirestoreKeys.month, isEqualTo: month);
    if (year != null) query = query.where(FirestoreKeys.year, isEqualTo: year);

    // orderBy is intentionally omitted here — sorting in-memory avoids requiring
    // a Firestore composite index on (month, year, memberName).
    return query.snapshots().map((snap) {
      final list = snap.docs
          .map((doc) => MonthlyStatementModel.fromMap(doc.data(), doc.id))
          .toList();
      list.sort((a, b) => a.memberName.toLowerCase().compareTo(b.memberName.toLowerCase()));
      return list;
    });
  }

  Future<List<MonthlyStatementModel>> getStatements({int? month, int? year}) async {
    Query<Map<String, dynamic>> query = _statementsCol;

    if (month != null) query = query.where(FirestoreKeys.month, isEqualTo: month);
    if (year != null) query = query.where(FirestoreKeys.year, isEqualTo: year);

    final snap = await query.get();
    final list = snap.docs
        .map((doc) => MonthlyStatementModel.fromMap(doc.data(), doc.id))
        .toList();
    list.sort((a, b) => a.memberName.toLowerCase().compareTo(b.memberName.toLowerCase()));
    return list;
  }

  Future<List<MonthlyStatementModel>> getStatementsByMember(String memberId) async {
    final snap = await _statementsCol
        .where(FirestoreKeys.memberId, isEqualTo: memberId)
        .get();
    final list = snap.docs
        .map((doc) => MonthlyStatementModel.fromMap(doc.data(), doc.id))
        .toList();
    list.sort((a, b) {
      final yearCmp = b.year.compareTo(a.year);
      return yearCmp != 0 ? yearCmp : b.month.compareTo(a.month);
    });
    return list;
  }

  Future<bool> statementExists({
    required String memberId,
    required int month,
    required int year,
    String? excludeId,
  }) async {
    final snap = await _statementsCol
        .where(FirestoreKeys.memberId, isEqualTo: memberId)
        .where(FirestoreKeys.month, isEqualTo: month)
        .where(FirestoreKeys.year, isEqualTo: year)
        .get();

    if (snap.docs.isEmpty) return false;
    if (excludeId != null) {
      return snap.docs.any((doc) => doc.id != excludeId);
    }
    return true;
  }

  Future<String> addStatement(MonthlyStatementModel statement) async {
    final doc = await _statementsCol.add(statement.toMap());
    return doc.id;
  }

  Future<void> updateStatement(MonthlyStatementModel statement) async {
    await _statementsCol.doc(statement.id).update(statement.toMap());
  }

  Future<void> deleteStatement(String statementId) async {
    await _statementsCol.doc(statementId).delete();
  }

  // ─── Daily Meals ─────────────────────────────────────────────────────────────

  /// Stream of all daily meals for a given date (no orderBy = no composite index needed)
  Stream<List<DailyMealModel>> dailyMealsStream(DateTime date) {
    final day = DailyMealModel.dayKey(date);
    return _dailyMealsCol
        .where('day', isEqualTo: day.day)
        .where('month', isEqualTo: day.month)
        .where('year', isEqualTo: day.year)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((doc) => DailyMealModel.fromMap(doc.data(), doc.id))
          .toList();
      list.sort((a, b) => a.memberName.toLowerCase().compareTo(b.memberName.toLowerCase()));
      return list;
    });
  }

  /// Get a specific member's meal entry for a date (null if not yet added)
  Future<DailyMealModel?> getDailyMeal(String memberId, DateTime date) async {
    final day = DailyMealModel.dayKey(date);
    final snap = await _dailyMealsCol
        .where('memberId', isEqualTo: memberId)
        .where('day', isEqualTo: day.day)
        .where('month', isEqualTo: day.month)
        .where('year', isEqualTo: day.year)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return DailyMealModel.fromMap(snap.docs.first.data(), snap.docs.first.id);
  }

  Future<String> addDailyMeal(DailyMealModel meal) async {
    final doc = await _dailyMealsCol.add(meal.toMap());
    return doc.id;
  }

  Future<void> updateDailyMeal(DailyMealModel meal) async {
    await _dailyMealsCol.doc(meal.id).update(meal.toMap());
  }

  Future<void> deleteDailyMeal(String id) async {
    await _dailyMealsCol.doc(id).delete();
  }

  /// Get total consumed meals for a member in a month (sum of daily totals)
  Future<double> getMemberMonthlyMealTotal(String memberId, int month, int year) async {
    final snap = await _dailyMealsCol
        .where('memberId', isEqualTo: memberId)
        .where('month', isEqualTo: month)
        .where('year', isEqualTo: year)
        .get();
    double total = 0;
    for (final doc in snap.docs) {
      total += ((doc.data()['total'] ?? 0) as num).toDouble();
    }
    return total;
  }

  // ─── Dashboard aggregates ────────────────────────────────────────────────────

  Stream<List<MonthlyStatementModel>> allStatementsStream() {
    return _statementsCol.snapshots().map((snap) {
      final list = snap.docs
          .map((doc) => MonthlyStatementModel.fromMap(doc.data(), doc.id))
          .toList();
      list.sort((a, b) {
        final yearCmp = b.year.compareTo(a.year);
        return yearCmp != 0 ? yearCmp : b.month.compareTo(a.month);
      });
      return list;
    });
  }
}
