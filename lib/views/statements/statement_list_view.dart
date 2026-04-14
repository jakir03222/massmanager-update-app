import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/statement_controller.dart';
import '../../core/constants/app_constants.dart';
import '../../routes/app_routes.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/statement_table_row.dart';

class StatementListView extends GetView<StatementController> {
  const StatementListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.statements),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () => Get.toNamed(AppRoutes.reports),
            tooltip: AppStrings.exportPdf,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.addEditStatement),
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.addStatement),
      ),
      body: Column(
        children: [
          // Filters
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                // Search
                TextField(
                  onChanged: controller.onSearchChanged,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: AppStrings.search,
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                    prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.7)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white30),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 10),

                // Month / Year filter
                Row(
                  children: [
                    Expanded(
                      child: Obx(() => _FilterDropdown<int>(
                            value: controller.selectedMonth.value,
                            items: List.generate(12, (i) => i + 1),
                            labelBuilder: (m) => AppConstants.months[m - 1],
                            onChanged: controller.setMonth,
                            hint: AppStrings.month,
                          )),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Obx(() => _FilterDropdown<int>(
                            value: controller.selectedYear.value,
                            items: AppConstants.years,
                            labelBuilder: (y) => '$y',
                            onChanged: controller.setYear,
                            hint: AppStrings.year,
                          )),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Statement count strip
          Obx(() => Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: AppColors.primaryLight.withOpacity(0.08),
                child: Row(
                  children: [
                    Text(
                      '${controller.filteredStatements.length} বিবরণী — '
                      '${AppConstants.months[controller.selectedMonth.value - 1]} ${controller.selectedYear.value}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )),

          Expanded(
            child: Obx(() {
              if (controller.filteredStatements.isEmpty) {
                return EmptyState(
                  message: controller.searchQuery.value.isEmpty
                      ? '${AppConstants.months[controller.selectedMonth.value - 1]} ${controller.selectedYear.value} এ কোনো বিবরণী নেই।\nযোগ করতে + ট্যাপ করুন।'
                      : '"${controller.searchQuery.value}" এর জন্য কোনো ফলাফল নেই',
                  icon: Icons.receipt_long_outlined,
                  onAction: controller.searchQuery.value.isEmpty
                      ? () => Get.toNamed(AppRoutes.addEditStatement)
                      : null,
                  actionLabel: AppStrings.addStatement,
                );
              }

              return Obx(() => LoadingOverlay(
                    isLoading: controller.isLoading.value,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(0, 4, 0, 100),
                      itemCount: controller.filteredStatements.length,
                      itemBuilder: (_, i) {
                        final s = controller.filteredStatements[i];
                        return StatementCard(
                          statement: s,
                          onEdit: () => Get.toNamed(AppRoutes.addEditStatement, arguments: s),
                          onDelete: () => controller.deleteStatement(s),
                        );
                      },
                    ),
                  ));
            }),
          ),
        ],
      ),
    );
  }
}

class _FilterDropdown<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final String Function(T) labelBuilder;
  final void Function(T) onChanged;
  final String hint;

  const _FilterDropdown({
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          dropdownColor: AppColors.primaryDark,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          icon: const Icon(Icons.expand_more, color: Colors.white, size: 18),
          isExpanded: true,
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
          items: items
              .map((item) => DropdownMenuItem<T>(
                    value: item,
                    child: Text(labelBuilder(item)),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
