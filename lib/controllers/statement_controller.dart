import 'package:get/get.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/app_utils.dart';
import '../models/member_model.dart';
import '../models/monthly_statement_model.dart';
import '../services/firestore_service.dart';

class StatementController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  final statements = <MonthlyStatementModel>[].obs;
  final filteredStatements = <MonthlyStatementModel>[].obs;
  final members = <MemberModel>[].obs;
  final isLoading = false.obs;

  final selectedMonth = DateTime.now().month.obs;
  final selectedYear = DateTime.now().year.obs;
  final searchQuery = ''.obs;

  // Form reactive fields for real-time calculation preview
  final consumedMeal = 0.0.obs;
  final mealRate = 0.0.obs;
  final cookCost = 0.0.obs;
  final depositMoney = 0.0.obs;
  final eidBonus = 0.0.obs;

  double get costOfMeal => consumedMeal.value * mealRate.value;
  double get totalDue => costOfMeal + cookCost.value;
  double get totalCost => totalDue + eidBonus.value;
  double get netAmount => depositMoney.value - totalCost;
  String get status => AppUtils.computeStatus(netAmount);

  @override
  void onInit() {
    super.onInit();
    _listenToStatements();
    _loadMembers();
    debounce(searchQuery, (_) => _filterStatements(), time: const Duration(milliseconds: 300));
    ever(selectedMonth, (_) => _listenToStatements());
    ever(selectedYear, (_) => _listenToStatements());
  }

  void _listenToStatements() {
    _firestoreService
        .statementsStream(month: selectedMonth.value, year: selectedYear.value)
        .listen(
      (data) {
        statements.value = data;
        _filterStatements();
      },
      onError: (e) => AppUtils.showError('Failed to load statements: $e'),
    );
  }

  Future<void> _loadMembers() async {
    try {
      members.value = await _firestoreService.getMembers();
    } catch (e) {
      AppUtils.showError('Failed to load members: $e');
    }
  }

  void _filterStatements() {
    if (searchQuery.value.isEmpty) {
      filteredStatements.value = statements;
    } else {
      final q = searchQuery.value.toLowerCase();
      filteredStatements.value = statements
          .where((s) => s.memberName.toLowerCase().contains(q))
          .toList();
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  void setMonth(int month) => selectedMonth.value = month;
  void setYear(int year) => selectedYear.value = year;

  void resetFormFields() {
    consumedMeal.value = 0.0;
    mealRate.value = 0.0;
    cookCost.value = 0.0;
    depositMoney.value = 0.0;
    eidBonus.value = 0.0;
  }

  void loadFromStatement(MonthlyStatementModel statement) {
    consumedMeal.value = statement.consumedMeal;
    mealRate.value = statement.mealRate;
    cookCost.value = statement.cookCost;
    depositMoney.value = statement.depositMoney;
    eidBonus.value = statement.eidBonus;
  }

  Future<bool> addStatement({
    required String memberId,
    required String memberName,
    required int month,
    required int year,
    required double consumedMeal,
    required double mealRate,
    required double cookCost,
    required double depositMoney,
    required double eidBonus,
    required String remarks,
  }) async {
    final exists = await _firestoreService.statementExists(
      memberId: memberId,
      month: month,
      year: year,
    );
    if (exists) {
      AppUtils.showError('A statement for this member already exists for ${AppConstants.months[month - 1]} $year');
      return false;
    }

    isLoading.value = true;
    try {
      final statement = MonthlyStatementModel.create(
        memberId: memberId,
        memberName: memberName,
        month: month,
        year: year,
        consumedMeal: consumedMeal,
        mealRate: mealRate,
        cookCost: cookCost,
        depositMoney: depositMoney,
        eidBonus: eidBonus,
        remarks: remarks,
      );
      await _firestoreService.addStatement(statement);
      AppUtils.showSuccess('Statement added successfully');
      return true;
    } catch (e) {
      AppUtils.showError('Failed to add statement: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateStatement({
    required MonthlyStatementModel existing,
    required String memberId,
    required String memberName,
    required int month,
    required int year,
    required double consumedMeal,
    required double mealRate,
    required double cookCost,
    required double depositMoney,
    required double eidBonus,
    required String remarks,
  }) async {
    final exists = await _firestoreService.statementExists(
      memberId: memberId,
      month: month,
      year: year,
      excludeId: existing.id,
    );
    if (exists) {
      AppUtils.showError('A statement for this member already exists for ${AppConstants.months[month - 1]} $year');
      return false;
    }

    isLoading.value = true;
    try {
      final updated = existing.copyWith(
        memberId: memberId,
        memberName: memberName,
        month: month,
        year: year,
        consumedMeal: consumedMeal,
        mealRate: mealRate,
        cookCost: cookCost,
        depositMoney: depositMoney,
        eidBonus: eidBonus,
        remarks: remarks,
      );
      await _firestoreService.updateStatement(updated);
      AppUtils.showSuccess('Statement updated successfully');
      return true;
    } catch (e) {
      AppUtils.showError('Failed to update statement: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteStatement(MonthlyStatementModel statement) async {
    final confirmed = await AppUtils.showConfirmDialog(
      title: 'Delete Statement',
      message: 'Delete statement for "${statement.memberName}"? This cannot be undone.',
    );
    if (!confirmed) return;

    isLoading.value = true;
    try {
      await _firestoreService.deleteStatement(statement.id);
      AppUtils.showSuccess('Statement deleted');
    } catch (e) {
      AppUtils.showError('Failed to delete statement: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
