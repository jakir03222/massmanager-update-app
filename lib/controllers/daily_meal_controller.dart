import 'package:get/get.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/app_utils.dart';
import '../models/daily_meal_model.dart';
import '../models/member_model.dart';
import '../services/firestore_service.dart';

class DailyMealController extends GetxController {
  final FirestoreService _db = FirestoreService();

  // Daily view
  final meals = <DailyMealModel>[].obs;
  final members = <MemberModel>[].obs;
  final isLoading = false.obs;
  final selectedDate = DateTime.now().obs;

  // Monthly all-members summary
  final allMonthlyMeals = <DailyMealModel>[].obs;
  final summaryMonth = DateTime.now().month.obs;
  final summaryYear = DateTime.now().year.obs;
  final isSummaryLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadMembers();
    _listenToDate(selectedDate.value);
    ever(selectedDate, _listenToDate);
    ever(summaryMonth, (_) => _listenToMonthlyAll());
    ever(summaryYear, (_) => _listenToMonthlyAll());
    _listenToMonthlyAll();
  }

  void _listenToDate(DateTime date) {
    _db.dailyMealsStream(date).listen(
      (data) => meals.value = data,
      onError: (e) => AppUtils.showError('খাবার লোড করতে সমস্যা হয়েছে।'),
    );
  }

  void _listenToMonthlyAll() {
    isSummaryLoading.value = true;
    _db.allMealsForMonthStream(summaryMonth.value, summaryYear.value).listen(
      (data) {
        allMonthlyMeals.value = data;
        isSummaryLoading.value = false;
      },
      onError: (e) {
        isSummaryLoading.value = false;
        AppUtils.showError('মাসিক খাবার লোড করতে সমস্যা হয়েছে।');
      },
    );
  }

  Future<void> _loadMembers() async {
    try {
      members.value = await _db.getMembers();
    } catch (e) {
      AppUtils.showError('সদস্য লোড করতে সমস্যা হয়েছে।');
    }
  }

  void goToPreviousDay() {
    selectedDate.value = selectedDate.value.subtract(const Duration(days: 1));
  }

  void goToNextDay() {
    final tomorrow = selectedDate.value.add(const Duration(days: 1));
    if (tomorrow.isBefore(DateTime.now().add(const Duration(days: 1)))) {
      selectedDate.value = tomorrow;
    }
  }

  void goToToday() {
    selectedDate.value = DateTime.now();
  }

  bool get isToday {
    final now = DateTime.now();
    final d = selectedDate.value;
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  String get formattedDate {
    final d = selectedDate.value;
    final monthName = AppConstants.months[d.month - 1];
    return '${d.day} $monthName ${d.year}';
  }

  void setSummaryMonth(int m) => summaryMonth.value = m;
  void setSummaryYear(int y) => summaryYear.value = y;

  DailyMealModel? mealForMember(String memberId) {
    try {
      return meals.firstWhere((m) => m.memberId == memberId);
    } catch (_) {
      return null;
    }
  }

  Future<bool> saveMeal({
    required MemberModel member,
    required double morning,
    required double afternoon,
    required double night,
  }) async {
    if (morning == 0 && afternoon == 0 && night == 0) {
      AppUtils.showError(AppStrings.atLeastOneMeal);
      return false;
    }

    isLoading.value = true;
    try {
      final date = DateTime(
        selectedDate.value.year,
        selectedDate.value.month,
        selectedDate.value.day,
      );
      final existing = await _db.getDailyMeal(member.id, date);
      final meal = DailyMealModel(
        id: existing?.id ?? '',
        memberId: member.id,
        memberName: member.name,
        date: date,
        day: date.day,
        month: date.month,
        year: date.year,
        morning: morning,
        afternoon: afternoon,
        night: night,
      );

      if (existing == null) {
        await _db.addDailyMeal(meal);
      } else {
        await _db.updateDailyMeal(meal);
      }
      AppUtils.showSuccess('${member.name} এর খাবার সংরক্ষণ হয়েছে');
      return true;
    } catch (e) {
      AppUtils.showError('খাবার সংরক্ষণ করতে সমস্যা হয়েছে।');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteMeal(DailyMealModel meal) async {
    final confirmed = await AppUtils.showConfirmDialog(
      title: AppStrings.removeMeal,
      message: '"${meal.memberName}" এর এই দিনের খাবার এন্ট্রি মুছে ফেলবেন?',
    );
    if (!confirmed) return;

    isLoading.value = true;
    try {
      await _db.deleteDailyMeal(meal.id);
      AppUtils.showSuccess(AppStrings.mealEntryRemoved);
    } catch (e) {
      AppUtils.showError('এন্ট্রি মুছতে সমস্যা হয়েছে।');
    } finally {
      isLoading.value = false;
    }
  }

  Future<double> getMonthlyTotal(String memberId, int month, int year) async {
    return _db.getMemberMonthlyMealTotal(memberId, month, year);
  }

  Map<String, List<DailyMealModel>> get mealsByMember {
    final map = <String, List<DailyMealModel>>{};
    for (final meal in allMonthlyMeals) {
      map.putIfAbsent(meal.memberName, () => []).add(meal);
    }
    return map;
  }
}
