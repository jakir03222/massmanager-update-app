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
  // App
  static const appName = 'মেস ম্যানেজার';
  static const appTagline = 'খাবার • জমা • হিসাব ট্র্যাকার';
  static const messManagement = 'মেস ব্যবস্থাপনা সিস্টেম';

  // Auth
  static const login = 'লগইন';
  static const email = 'ইমেইল';
  static const password = 'পাসওয়ার্ড';
  static const welcomeBack = 'স্বাগতম!';
  static const signInToContinue = 'চালিয়ে যেতে লগইন করুন';
  static const authorizedOnly = 'শুধুমাত্র অনুমোদিত ব্যবহারকারী';
  static const logout = 'লগআউট';
  static const logoutConfirmTitle = 'লগআউট';
  static const logoutConfirmMessage = 'আপনি কি লগআউট করতে চান?';

  // Navigation
  static const dashboard = 'ড্যাশবোর্ড';
  static const members = 'সদস্যগণ';
  static const statements = 'মাসিক বিবরণী';
  static const summary = 'মাসিক সারসংক্ষেপ';
  static const reports = 'রিপোর্ট ও পিডিএফ';
  static const dailyMeals = 'দৈনিক খাবার';
  static const addDailyMeal = 'দৈনিক খাবার যোগ';
  static const allMemberMeal = 'সকল সদস্যের খাবার';
  static const mealCharts = 'খাবারের চার্ট';

  // Dashboard sections
  static const overview = 'সামগ্রিক চিত্র';
  static const quickAccess = 'দ্রুত প্রবেশ';
  static const totalMembers = 'মোট সদস্য';
  static const totalDeposit = 'মোট জমা';
  static const totalExpense = 'মোট খরচ';
  static const netBalance = 'নিট ব্যালেন্স';

  // Member
  static const addMember = 'সদস্য যোগ করুন';
  static const editMember = 'সদস্য সম্পাদনা';
  static const deleteMember = 'সদস্য মুছুন';
  static const memberInfo = 'সদস্যের তথ্য';
  static const noPhone = 'ফোন নেই';
  static const name = 'নাম';
  static const phone = 'ফোন নম্বর';
  static const addMemberBtn = 'সদস্য যোগ';
  static const updateMemberBtn = 'সদস্য আপডেট';
  static const deleteMemberBtn = 'সদস্য মুছুন';

  // Statement
  static const addStatement = 'বিবরণী যোগ করুন';
  static const editStatement = 'বিবরণী সম্পাদনা';
  static const month = 'মাস';
  static const year = 'বছর';
  static const selectMember = 'সদস্য নির্বাচন করুন';
  static const consumedMeal = 'গৃহীত খাবার (বার)';
  static const mealRate = 'খাবারের হার (৳)';
  static const cookCost = 'রান্নার খরচ (৳)';
  static const depositMoney = 'জমা টাকা (৳)';
  static const eidBonus = 'ঈদ বোনাস (৳)';
  static const remarks = 'মন্তব্য';
  static const memberPeriod = 'সদস্য ও সময়কাল';
  static const mealDetails = 'খাবারের বিবরণ';
  static const calcPreview = 'হিসাব পূর্বরূপ';
  static const autoFill = 'স্বয়ংক্রিয় পূরণ';
  static const autoFillHint = 'দৈনিক এন্ট্রি থেকে গৃহীত খাবার স্বয়ংক্রিয়ভাবে পূরণ করুন';
  static const saveStatement = 'বিবরণী সংরক্ষণ';
  static const updateStatement = 'বিবরণী আপডেট';

  // Calculations
  static const costOfMeal = 'খাবারের মূল্য';
  static const totalDue = 'মোট বকেয়া';
  static const totalCost = 'মোট খরচ';
  static const netAmount = 'নিট পরিমাণ';
  static const status = 'অবস্থা';
  static const receivable = 'পাবেন';
  static const payable = 'দেবেন';
  static const settled = 'সমন্বিত';
  static const surplus = 'উদ্বৃত্ত (পাবেন)';
  static const deficit = 'ঘাটতি (দেবেন)';

  // Meal slots
  static const morning = 'সকাল';
  static const afternoon = 'দুপুর';
  static const night = 'রাত';
  static const totalMeals = 'মোট খাবার';
  static const mealsToday = 'আজকের খাবার';
  static const tapToAdd = 'যোগ করতে ট্যাপ করুন';
  static const saveMeal = 'খাবার সংরক্ষণ';
  static const updateMeal = 'খাবার আপডেট';
  static const removeMeal = 'এন্ট্রি মুছুন';

  // Actions
  static const save = 'সংরক্ষণ';
  static const delete = 'মুছুন';
  static const cancel = 'বাতিল';
  static const edit = 'সম্পাদনা';
  static const exportPdf = 'পিডিএফ রপ্তানি';
  static const shareDownloadPdf = 'পিডিএফ শেয়ার / ডাউনলোড';

  // Search & Filter
  static const search = 'সদস্য খুঁজুন...';
  static const filterByMonth = 'মাস অনুযায়ী ফিল্টার';

  // Status & Empty states
  static const noData = 'কোনো তথ্য নেই';
  static const loading = 'লোড হচ্ছে...';
  static const noMembers = 'এখনো কোনো সদস্য নেই।\nযোগ করতে + ট্যাপ করুন।';
  static const noStatements = 'এই মাসে কোনো বিবরণী নেই।\nযোগ করতে + ট্যাপ করুন।';
  static const noMealsThisMonth = 'এই মাসে কোনো খাবার এন্ট্রি নেই।\nআগে দৈনিক খাবার যোগ করুন।';
  static const noChartData = 'চার্টের জন্য কোনো তথ্য নেই।\nআগে দৈনিক খাবার যোগ করুন।';
  static const noReportData = 'রিপোর্ট তৈরির কোনো তথ্য নেই।\nআগে বিবরণী যোগ করুন।';
  static const addDailyMealsFirst = 'দৈনিক খাবার যোগ করুন';

  // Validation
  static const fieldRequired = 'এই তথ্য আবশ্যক';
  static const invalidEmail = 'সঠিক ইমেইল ঠিকানা দিন';
  static const passwordTooShort = 'পাসওয়ার্ড কমপক্ষে ৬ অক্ষরের হতে হবে';
  static const nameTooShort = 'নাম কমপক্ষে ২ অক্ষরের হতে হবে';
  static const invalidNumber = 'সঠিক সংখ্যা দিন';
  static const pleaseFillAll = 'সকল তথ্য পূরণ করুন';
  static const pleaseSelectMember = 'একজন সদস্য নির্বাচন করুন';
  static const atLeastOneMeal = 'কমপক্ষে একটি খাবার যোগ করুন';

  // Confirm dialogs
  static const confirmDelete = 'মুছে ফেলুন';
  static const cannotUndo = 'এটি পূর্বাবস্থায় ফেরানো যাবে না।';
  static const confirmRemoveMeal = 'খাবার সরান';
  static const yes = 'হ্যাঁ';
  static const no = 'না';

  // Success messages
  static const memberAdded = 'সদস্য সফলভাবে যোগ হয়েছে';
  static const memberUpdated = 'সদস্য সফলভাবে আপডেট হয়েছে';
  static const memberDeleted = 'সদস্য মুছে ফেলা হয়েছে';
  static const statementAdded = 'বিবরণী সফলভাবে যোগ হয়েছে';
  static const statementUpdated = 'বিবরণী সফলভাবে আপডেট হয়েছে';
  static const statementDeleted = 'বিবরণী মুছে ফেলা হয়েছে';
  static const mealEntryRemoved = 'খাবার এন্ট্রি মুছে ফেলা হয়েছে';

  // PDF / Report
  static const monthlyReport = 'মাসিক বিবরণী রিপোর্ট';
  static const generatedOn = 'তৈরির তারিখ';
  static const memberStatements = 'সদস্যওয়ারী বিবরণী';
  static const monthlySummaryTitle = 'মাসিক সারসংক্ষেপ';
  static const calcFormula = 'হিসাবের সূত্র';
  static const formulaLine1 = '• খাবারের মূল্য = গৃহীত খাবার × খাবারের হার';
  static const formulaLine2 = '• মোট বকেয়া = খাবারের মূল্য + রান্নার খরচ';
  static const formulaLine3 = '• মোট খরচ = মোট বকেয়া + ঈদ বোনাস';
  static const formulaLine4 = '• নিট পরিমাণ = জমা টাকা − মোট খরচ';
  static const formulaLine5 = '• নিট > ০ → পাবেন | নিট < ০ → দেবেন | নিট = ০ → সমন্বিত';
  static const confidential = 'মেস ম্যানেজার — গোপনীয়';
  static const page = 'পৃষ্ঠা';
  static const of = 'এর';

  // Chart labels
  static const totalMealsPerMember = 'সদস্যওয়ারী মোট খাবার';
  static const dailyMealTrend = 'দৈনিক খাবারের ধারা';
  static const mealSlotDistribution = 'খাবারের সময় বিতরণ';
  static const mealSlotsPerMember = 'সদস্যওয়ারী খাবারের সময়';
  static const morningAfternoonNight = 'সকাল · দুপুর · রাত';
  static const grandTotal = 'সর্বমোট';
  static const days = 'দিন';
  static const day = 'দিন';

  // Summary
  static const memberBreakdown = 'সদস্যওয়ারী বিবরণ';
  static const mealCost = 'খাবারের মূল্য';
  static const today = 'আজ';

  // Statement table columns (PDF)
  static const colMember = 'সদস্য';
  static const colMeal = 'খাবার';
  static const colRate = 'হার';
  static const colCost = 'মূল্য';
  static const colCook = 'রান্না';
  static const colDeposit = 'জমা';
  static const colTotal = 'মোট';
  static const colNet = 'নিট';
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
    'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল',
    'মে', 'জুন', 'জুলাই', 'আগস্ট',
    'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর',
  ];

  static List<int> get years {
    final current = DateTime.now().year;
    return List.generate(5, (i) => current - 2 + i);
  }
}
