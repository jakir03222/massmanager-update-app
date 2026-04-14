import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF1565C0);
  static const primaryDark = Color(0xFF003c8f);
  static const primaryLight = Color(0xFF5e92f3);
  static const accent = Color(0xFF0288D1);
  static const surface = Color(0xFFF5F7FA);
  static const cardBg = Colors.white;
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF6B7280);
  static const success = Color(0xFF2E7D32);
  static const error = Color(0xFFC62828);
  static const warning = Color(0xFFF57F17);
  static const divider = Color(0xFFE0E0E0);
  static const receivable = Color(0xFF1B5E20);
  static const payable = Color(0xFFB71C1C);
  static const settled = Color(0xFF1565C0);
}

class AppStrings {
  static const appName = 'Mess Manager';
  static const login = 'Login';
  static const email = 'Email';
  static const password = 'Password';
  static const dashboard = 'Dashboard';
  static const members = 'Members';
  static const statements = 'Monthly Statements';
  static const summary = 'Monthly Summary';
  static const reports = 'Reports & PDF';
  static const addMember = 'Add Member';
  static const editMember = 'Edit Member';
  static const addStatement = 'Add Statement';
  static const editStatement = 'Edit Statement';
  static const name = 'Name';
  static const phone = 'Phone';
  static const month = 'Month';
  static const year = 'Year';
  static const consumedMeal = 'Consumed Meal';
  static const mealRate = 'Meal Rate (৳)';
  static const cookCost = 'Cook Cost (৳)';
  static const depositMoney = 'Deposit Money (৳)';
  static const eidBonus = 'Eid Bonus (৳)';
  static const remarks = 'Remarks';
  static const costOfMeal = 'Cost of Meal';
  static const totalDue = 'Total Due';
  static const totalCost = 'Total Cost';
  static const netAmount = 'Net Amount';
  static const status = 'Status';
  static const receivable = 'Receivable';
  static const payable = 'Payable';
  static const settled = 'Settled';
  static const save = 'Save';
  static const delete = 'Delete';
  static const cancel = 'Cancel';
  static const logout = 'Logout';
  static const search = 'Search member...';
  static const noData = 'No data found';
  static const loading = 'Loading...';
  static const exportPdf = 'Export PDF';
  static const fieldRequired = 'This field is required';
  static const invalidEmail = 'Enter a valid email';
  static const passwordTooShort = 'Password must be at least 6 characters';
  static const dailyMeals = 'Daily Meals';
  static const addDailyMeal = 'Add Daily Meal';
  static const morning = 'Morning (সকাল)';
  static const afternoon = 'Afternoon (দুপুর)';
  static const night = 'Night (রাত)';
}

class FirestoreKeys {
  static const members = 'members';
  static const monthlyStatements = 'monthly_statements';
  static const monthlySummaries = 'monthly_summaries';
  static const dailyMeals = 'daily_meals';

  static const id = 'id';
  static const name = 'name';
  static const phone = 'phone';
  static const createdAt = 'createdAt';
  static const memberId = 'memberId';
  static const memberName = 'memberName';
  static const month = 'month';
  static const year = 'year';
  static const consumedMeal = 'consumedMeal';
  static const mealRate = 'mealRate';
  static const cookCost = 'cookCost';
  static const depositMoney = 'depositMoney';
  static const eidBonus = 'eidBonus';
  static const remarks = 'remarks';
  static const costOfMeal = 'costOfMeal';
  static const totalDue = 'totalDue';
  static const totalCost = 'totalCost';
  static const netAmount = 'netAmount';
  static const status = 'status';
  static const totalMembers = 'totalMembers';
  static const totalDeposit = 'totalDeposit';
  static const totalExpense = 'totalExpense';
  static const netBalance = 'netBalance';
}

class AppConstants {
  static const List<String> months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  static List<int> get years {
    final current = DateTime.now().year;
    return List.generate(5, (i) => current - 2 + i);
  }
}
