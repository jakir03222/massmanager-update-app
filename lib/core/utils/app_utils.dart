import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class AppUtils {
  static final _currencyFormat = NumberFormat('#,##0.00', 'en_US');
  static final _mealFormat = NumberFormat('#,##0.##', 'en_US');

  static String formatCurrency(double amount) {
    return '৳${_currencyFormat.format(amount)}';
  }

  static String formatMeal(double meal) {
    return _mealFormat.format(meal);
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static Color statusColor(String status) {
    if (status == AppStrings.receivable || status == 'Receivable') {
      return AppColors.receivable;
    }
    if (status == AppStrings.payable || status == 'Payable') {
      return AppColors.payable;
    }
    return AppColors.settled;
  }

  static Color statusBgColor(String status) {
    if (status == AppStrings.receivable || status == 'Receivable') {
      return const Color(0xFFE8F5E9);
    }
    if (status == AppStrings.payable || status == 'Payable') {
      return const Color(0xFFFFEBEE);
    }
    return const Color(0xFFE3F2FD);
  }

  static String localizeStatus(String status) {
    switch (status) {
      case 'Receivable':
        return AppStrings.receivable;
      case 'Payable':
        return AppStrings.payable;
      case 'Settled':
        return AppStrings.settled;
      default:
        return status;
    }
  }

  static void showSuccess(String message) {
    Get.snackbar(
      'সফল ✓',
      message,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );
  }

  static void showError(String message) {
    Get.snackbar(
      'ত্রুটি !',
      message,
      backgroundColor: AppColors.error,
      colorText: Colors.white,
      icon: const Icon(Icons.error, color: Colors.white),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 4),
    );
  }

  static void showWarning(String message) {
    Get.snackbar(
      'সতর্কতা',
      message,
      backgroundColor: AppColors.warning,
      colorText: Colors.white,
      icon: const Icon(Icons.warning, color: Colors.white),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );
  }

  static Future<bool> showConfirmDialog({
    required String title,
    required String message,
    String confirmText = 'মুছুন',
    Color confirmColor = AppColors.error,
  }) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('বাতিল'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: confirmColor),
            onPressed: () => Get.back(result: true),
            child: Text(confirmText, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  static String computeStatus(double netAmount) {
    if (netAmount > 0) return AppStrings.receivable;
    if (netAmount < 0) return AppStrings.payable;
    return AppStrings.settled;
  }
}
