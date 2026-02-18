import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/bazar_model.dart';
import '../models/meal_model.dart';
import '../models/member_model.dart';
import '../services/firebase_service.dart';

class HomeController extends ChangeNotifier {
  HomeController({required String uid}) : _uid = uid {
    _membersSub = FirebaseService.instance.watchMembers(_uid).listen(_onMembersUpdate);
    _bazarSub = FirebaseService.instance.watchBazar(_uid).listen(_onBazarUpdate);
    _mealsSub = FirebaseService.instance.watchMeals(_uid).listen(_onMealsUpdate);
  }

  final String _uid;
  StreamSubscription<List<MemberModel>>? _membersSub;
  StreamSubscription<List<BazarModel>>? _bazarSub;
  StreamSubscription<List<MealModel>>? _mealsSub;
  List<MemberModel> _members = [];
  List<BazarModel> _bazarList = [];
  List<MealModel> _meals = [];
  bool _loading = true;
  String? _error;

  List<MemberModel> get members => List.unmodifiable(_members);
  List<BazarModel> get bazarList => List.unmodifiable(_bazarList);
  List<MealModel> get meals => List.unmodifiable(_meals);
  bool get loading => _loading;
  String? get error => _error;

  void _onMembersUpdate(List<MemberModel> list) {
    _members = list;
    _loading = false;
    _error = null;
    notifyListeners();
  }

  void _onBazarUpdate(List<BazarModel> list) {
    _bazarList = list;
    _loading = false;
    _error = null;
    notifyListeners();
  }

  void _onMealsUpdate(List<MealModel> list) {
    _meals = list;
    _loading = false;
    _error = null;
    notifyListeners();
  }

  Future<void> addMember(String name, String phone, String password) async {
    _error = null;
    notifyListeners();
    try {
      await FirebaseService.instance.addMember(_uid, name, phone, password);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteMember(String id) async {
    _error = null;
    notifyListeners();
    try {
      await FirebaseService.instance.deleteMember(_uid, id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> addBazar(
    String title,
    double amount, {
    DateTime? bazarDate,
    String? memberId,
    String? memberName,
  }) async {
    _error = null;
    notifyListeners();
    try {
      await FirebaseService.instance.addBazar(
        _uid,
        title,
        amount,
        bazarDate: bazarDate,
        memberId: memberId,
        memberName: memberName,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> addBazarList(
    List<({
      String title,
      double amount,
      DateTime? bazarDate,
      String? memberId,
      String? memberName,
    })> items,
  ) async {
    _error = null;
    notifyListeners();
    try {
      for (final e in items) {
        await FirebaseService.instance.addBazar(
          _uid,
          e.title,
          e.amount,
          bazarDate: e.bazarDate,
          memberId: e.memberId,
          memberName: e.memberName,
        );
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteBazar(String id) async {
    _error = null;
    notifyListeners();
    try {
      await FirebaseService.instance.deleteBazar(_uid, id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> addMeal(
    DateTime mealDate,
    String type, {
    String? memberId,
    String? memberName,
    required double rate,
  }) async {
    _error = null;
    notifyListeners();
    try {
      await FirebaseService.instance.addMeal(
        _uid,
        mealDate,
        type,
        memberId: memberId,
        memberName: memberName,
        rate: rate,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteMeal(String id) async {
    _error = null;
    notifyListeners();
    try {
      await FirebaseService.instance.deleteMeal(_uid, id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _membersSub?.cancel();
    _bazarSub?.cancel();
    _mealsSub?.cancel();
    super.dispose();
  }
}
