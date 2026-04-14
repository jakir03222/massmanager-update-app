import 'package:get/get.dart';
import '../core/utils/app_utils.dart';
import '../models/monthly_statement_model.dart';
import '../models/monthly_summary_model.dart';
import '../services/firestore_service.dart';

class SummaryController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  final statements = <MonthlyStatementModel>[].obs;
  final isLoading = false.obs;

  final selectedMonth = DateTime.now().month.obs;
  final selectedYear = DateTime.now().year.obs;

  MonthlySummaryModel get summary => _computeSummary(statements);

  // Dashboard totals across all statements
  final allStatements = <MonthlyStatementModel>[].obs;
  int get totalMembersAll => _uniqueMembers(allStatements);
  double get totalDepositAll => allStatements.fold(0, (s, e) => s + e.depositMoney);
  double get totalExpenseAll => allStatements.fold(0, (s, e) => s + e.totalCost);
  double get netBalanceAll => allStatements.fold(0, (s, e) => s + e.netAmount);

  @override
  void onInit() {
    super.onInit();
    _listenToCurrentMonth();
    _listenToAllStatements();
    ever(selectedMonth, (_) => _listenToCurrentMonth());
    ever(selectedYear, (_) => _listenToCurrentMonth());
  }

  void reloadData() => _listenToCurrentMonth();

  void _listenToCurrentMonth() {
    isLoading.value = true;
    _firestoreService
        .statementsStream(month: selectedMonth.value, year: selectedYear.value)
        .listen(
      (data) {
        statements.value = data;
        isLoading.value = false;
      },
      onError: (e) {
        AppUtils.showError('সারসংক্ষেপ লোড করতে সমস্যা হয়েছে।');
        isLoading.value = false;
      },
    );
  }

  void _listenToAllStatements() {
    _firestoreService.allStatementsStream().listen(
      (data) => allStatements.value = data,
      onError: (_) {},
    );
  }

  void setMonth(int month) => selectedMonth.value = month;
  void setYear(int year) => selectedYear.value = year;

  MonthlySummaryModel _computeSummary(List<MonthlyStatementModel> list) {
    return MonthlySummaryModel(
      month: selectedMonth.value,
      year: selectedYear.value,
      totalMembers: list.length,
      totalDeposit: list.fold(0, (s, e) => s + e.depositMoney),
      totalCostOfMeal: list.fold(0, (s, e) => s + e.costOfMeal),
      totalCookCost: list.fold(0, (s, e) => s + e.cookCost),
      totalEidBonus: list.fold(0, (s, e) => s + e.eidBonus),
      totalDue: list.fold(0, (s, e) => s + e.totalDue),
      totalCost: list.fold(0, (s, e) => s + e.totalCost),
      totalNetAmount: list.fold(0, (s, e) => s + e.netAmount),
      receivableCount: list.where((e) => e.netAmount > 0).length,
      payableCount: list.where((e) => e.netAmount < 0).length,
      settledCount: list.where((e) => e.netAmount == 0).length,
    );
  }

  int _uniqueMembers(List<MonthlyStatementModel> list) {
    return list.map((e) => e.memberId).toSet().length;
  }
}
