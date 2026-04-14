import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../core/utils/app_utils.dart';
import '../models/daily_meal_model.dart';
import '../models/member_model.dart';
import '../services/firestore_service.dart';

class DailyMealController extends GetxController {
  final FirestoreService _db = FirestoreService();

  final meals = <DailyMealModel>[].obs;
  final members = <MemberModel>[].obs;
  final isLoading = false.obs;

  final selectedDate = DateTime.now().obs;

  // Per-member meal totals for the current month (memberId → total meals)
  final monthlyTotals = <String, double>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadMembers();
    _listenToDate(selectedDate.value);
    ever(selectedDate, (date) => _listenToDate(date as DateTime));
  }

  void _listenToDate(DateTime date) {
    _db.dailyMealsStream(date).listen(
      (list) => meals.value = list,
      onError: (e) => AppUtils.showError('Failed to load meals: $e'),
    );
  }

  Future<void> _loadMembers() async {
    try {
      members.value = await _db.getMembers();
    } catch (e) {
      AppUtils.showError('Failed to load members');
    }
  }

  void goToPreviousDay() {
    selectedDate.value = selectedDate.value.subtract(const Duration(days: 1));
  }

  void goToNextDay() {
    final tomorrow = selectedDate.value.add(const Duration(days: 1));
    if (tomorrow.isAfter(DateTime.now())) return; // cannot go to future
    selectedDate.value = tomorrow;
  }

  void goToToday() => selectedDate.value = DateTime.now();

  bool get isToday {
    final now = DateTime.now();
    final d = selectedDate.value;
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  String get formattedDate =>
      DateFormat('EEEE, dd MMM yyyy').format(selectedDate.value);

  /// Returns this member's entry for the selected date, or null
  DailyMealModel? mealForMember(String memberId) {
    try {
      return meals.firstWhere((m) => m.memberId == memberId);
    } catch (_) {
      return null;
    }
  }

  /// Save (add or update) a member's meal for the selected date
  Future<bool> saveMeal({
    required MemberModel member,
    required double morning,
    required double afternoon,
    required double night,
  }) async {
    if (morning + afternoon + night == 0) {
      AppUtils.showError('Please add at least one meal');
      return false;
    }

    isLoading.value = true;
    try {
      final day = DailyMealModel.dayKey(selectedDate.value);
      final existing = await _db.getDailyMeal(member.id, day);

      final newMeal = DailyMealModel(
        id: existing?.id ?? '',
        memberId: member.id,
        memberName: member.name,
        date: day,
        day: day.day,
        month: day.month,
        year: day.year,
        morning: morning,
        afternoon: afternoon,
        night: night,
      );

      if (existing == null) {
        await _db.addDailyMeal(newMeal);
      } else {
        await _db.updateDailyMeal(newMeal.copyWith(id: existing.id));
      }

      AppUtils.showSuccess('Meal saved for ${member.name}');
      return true;
    } catch (e) {
      AppUtils.showError('Failed to save meal: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteMeal(DailyMealModel meal) async {
    final confirmed = await AppUtils.showConfirmDialog(
      title: 'Remove Meal',
      message: 'Remove meal entry for "${meal.memberName}"?',
    );
    if (!confirmed) return;

    isLoading.value = true;
    try {
      await _db.deleteDailyMeal(meal.id);
      AppUtils.showSuccess('Meal entry removed');
    } catch (e) {
      AppUtils.showError('Failed to remove meal: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Get the total consumed meals for a member in the selected month/year
  Future<double> getMonthlyTotal(String memberId) async {
    return _db.getMemberMonthlyMealTotal(
      memberId,
      selectedDate.value.month,
      selectedDate.value.year,
    );
  }
}
