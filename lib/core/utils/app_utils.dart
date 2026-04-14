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
    switch (status) {
      case AppStrings.receivable:
        return AppColors.receivable;
      case AppStrings.payable:
        return AppColors.payable;
      default:
        return AppColors.settled;
    }
  }

  static Color statusBgColor(String status) {
    switch (status) {
      case AppStrings.receivable:
        return const Color(0xFFE8F5E9);
      case AppStrings.payable:
        return const Color(0xFFFFEBEE);
      default:
        return const Color(0xFFE3F2FD);
    }
  }

  static void showSuccess(String message) {
    Get.snackbar(
      'Success',
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
      'Error',
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
      'Warning',
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
    String confirmText = 'Delete',
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
            child: const Text('Cancel'),
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
