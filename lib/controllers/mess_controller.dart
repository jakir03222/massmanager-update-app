import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/bazar_model.dart';
import '../models/meal_model.dart';
import '../models/member_model.dart';
import '../services/firebase_service.dart';
import 'auth_controller.dart';

class MessController extends ChangeNotifier {
  final AuthController authController;
  MessController({required this.authController}) {
    _init();
    authController.addListener(_init);
  }

  List<MemberModel> members = [];
  List<MealModel> meals = [];
  List<BazarModel> bazars = [];

  StreamSubscription? _membersSub;
  StreamSubscription? _mealsSub;
  StreamSubscription? _bazarSub;

  void _init() {
    final userId = authController.user?.uid;
    if (userId == null) {
      _clear();
      return;
    }

    _membersSub?.cancel();
    _membersSub = FirebaseService.instance.getMembersStream(userId).listen((data) {
      members = data;
      notifyListeners();
    });

    _mealsSub?.cancel();
    _mealsSub = FirebaseService.instance.getMealsStream(userId).listen((data) {
      meals = data;
      notifyListeners();
    });

    _bazarSub?.cancel();
    _bazarSub = FirebaseService.instance.getBazarStream(userId).listen((data) {
      bazars = data;
      notifyListeners();
    });
  }

  void _clear() {
    members = [];
    meals = [];
    bazars = [];
    _membersSub?.cancel();
    _mealsSub?.cancel();
    _bazarSub?.cancel();
    notifyListeners();
  }

  Future<void> addMember(String name) async {
    final userId = authController.user?.uid;
    if (userId == null || name.trim().isEmpty) return;
    final member = MemberModel(
      id: '',
      userId: userId,
      name: name.trim(),
      createdAt: DateTime.now(),
    );
    await FirebaseService.instance.addMember(member);
  }

  Future<void> addMeal(String memberName, DateTime date, num mealCount, String? note) async {
    final userId = authController.user?.uid;
    if (userId == null) return;
    final meal = MealModel(
      id: '',
      userId: userId,
      memberName: memberName,
      date: date,
      mealCount: mealCount,
      note: note,
      createdAt: DateTime.now(),
    );
    await FirebaseService.instance.addMeal(meal);
  }

  Future<void> addBazar(String buyerName, DateTime date, num amount, String description, String? note) async {
    final userId = authController.user?.uid;
    if (userId == null) return;
    final bazar = BazarModel(
      id: '',
      userId: userId,
      buyerName: buyerName,
      date: date,
      amount: amount,
      description: description,
      note: note,
      createdAt: DateTime.now(),
    );
    await FirebaseService.instance.addBazar(bazar);
  }

  @override
  void dispose() {
    authController.removeListener(_init);
    _clear();
    super.dispose();
  }
}
