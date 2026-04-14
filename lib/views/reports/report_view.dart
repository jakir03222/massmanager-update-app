import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../controllers/summary_controller.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/app_utils.dart';
import '../../models/monthly_statement_model.dart';
import '../../models/monthly_summary_model.dart';
import '../../widgets/loading_overlay.dart';

class ReportView extends StatelessWidget {
  const ReportView({super.key});

  @override
  Widget build(BuildContext context) {
    final summaryCtrl = Get.find<SummaryController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.reports),
      ),
      body: Column(
        children: [
          // Month/Year filter
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: Obx(() => _DropdownFilter<int>(
                        value: summaryCtrl.selectedMonth.value,
                        items: List.generate(12, (i) => i + 1),
                        labelBuilder: (m) => AppConstants.months[m - 1],
                        onChanged: summaryCtrl.setMonth,
                      )),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() => _DropdownFilter<int>(
                        value: summaryCtrl.selectedYear.value,
                        items: AppConstants.years,
                        labelBuilder: (y) => '$y',
                        onChanged: summaryCtrl.setYear,
                      )),
                ),
              ],
            ),
          ),

          Expanded(
            child: Obx(() {
              if (summaryCtrl.isLoading.value) return const CenteredLoader();

              final summary = summaryCtrl.summary;
              final statements = summaryCtrl.statements;

              return Column(
                children: [
                  // Preview header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: AppColors.primaryLight.withOpacity(0.08),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${summary.monthName} ${summary.year} Report',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${summary.totalMembers} members · Generated ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: statements.isEmpty
                        ? const EmptyState(
                            message: 'No data to generate report.\nAdd statements first.',
                            icon: Icons.picture_as_pdf_outlined,
                          )
                        : _ReportPreview(summary: summary, statements: statements),
                  ),

                  if (statements.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: ElevatedButton.icon(
                        onPressed: () => _generateAndSharePdf(summary, statements),
                        icon: const Icon(Icons.share_outlined),
                        label: const Text('Share / Download PDF'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 52),
                        ),
                      ),
                    ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Future<void> _generateAndSharePdf(
    MonthlySummaryModel summary,
    List<MonthlyStatementModel> statements,
  ) async {
    final doc = await _buildPdf(summary, statements);
    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: 'mess_report_${summary.monthName}_${summary.year}.pdf',
    );
  }
}

class _ReportPreview extends StatelessWidget {
  final MonthlySummaryModel summary;
  final List<MonthlyStatementModel> statements;

  const _ReportPreview({required this.summary, required this.statements});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Summary table
          _TableSection(
            title: 'Monthly Summary',
            rows: [
              ['Total Members', '${summary.totalMembers}'],
              ['Total Deposit', AppUtils.formatCurrency(summary.totalDeposit)],
              ['Total Meal Cost', AppUtils.formatCurrency(summary.totalCostOfMeal)],
              ['Total Cook Cost', AppUtils.formatCurrency(summary.totalCookCost)],
              ['Total Eid Bonus', AppUtils.formatCurrency(summary.totalEidBonus)],
              ['Total Due', AppUtils.formatCurrency(summary.totalDue)],
              ['Total Cost', AppUtils.formatCurrency(summary.totalCost)],
              ['Net Balance', AppUtils.formatCurrency(summary.totalNetAmount.abs())],
            ],
          ),
          const SizedBox(height: 16),

          // Member detail table
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Member Statements',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(AppColors.primary.withOpacity(0.08)),
                      columnSpacing: 16,
                      headingTextStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: AppColors.primary,
                      ),
                      dataTextStyle: const TextStyle(fontSize: 11),
                      columns: const [
                        DataColumn(label: Text('Member')),
                        DataColumn(label: Text('Meal'), numeric: true),
                        DataColumn(label: Text('Rate'), numeric: true),
                        DataColumn(label: Text('Cost'), numeric: true),
                        DataColumn(label: Text('Cook'), numeric: true),
                        DataColumn(label: Text('Deposit'), numeric: true),
                        DataColumn(label: Text('Total'), numeric: true),
                        DataColumn(label: Text('Net'), numeric: true),
                        DataColumn(label: Text('Status')),
                      ],
                      rows: statements.map((s) {
                        final statusColor = AppUtils.statusColor(s.status);
                        return DataRow(cells: [
                          DataCell(Text(s.memberName, style: const TextStyle(fontWeight: FontWeight.w600))),
                          DataCell(Text(AppUtils.formatMeal(s.consumedMeal))),
                          DataCell(Text(AppUtils.formatCurrency(s.mealRate))),
                          DataCell(Text(AppUtils.formatCurrency(s.costOfMeal))),
                          DataCell(Text(AppUtils.formatCurrency(s.cookCost))),
                          DataCell(Text(AppUtils.formatCurrency(s.depositMoney))),
                          DataCell(Text(AppUtils.formatCurrency(s.totalCost))),
                          DataCell(Text(
                            AppUtils.formatCurrency(s.netAmount.abs()),
                            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                          )),
                          DataCell(Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppUtils.statusBgColor(s.status),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              s.status,
                              style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.w600),
                            ),
                          )),
                        ]);
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

class _TableSection extends StatelessWidget {
  final String title;
  final List<List<String>> rows;

  const _TableSection({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const Divider(height: 16),
            ...rows.map((row) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(row[0], style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      Text(row[1], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _DropdownFilter<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final String Function(T) labelBuilder;
  final void Function(T) onChanged;

  const _DropdownFilter({
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
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

Future<pw.Document> _buildPdf(
  MonthlySummaryModel summary,
  List<MonthlyStatementModel> statements,
) async {
  final doc = pw.Document();
  final primaryColor = PdfColor.fromHex('#1565C0');
  final lightBlue = PdfColor.fromHex('#E3F2FD');
  final grey = PdfColor.fromHex('#6B7280');
  final successColor = PdfColor.fromHex('#2E7D32');
  final errorColor = PdfColor.fromHex('#C62828');

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      header: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    AppStrings.appName,
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  pw.Text(
                    'Monthly Statement Report',
                    style: pw.TextStyle(fontSize: 12, color: grey),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    '${summary.monthName} ${summary.year}',
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    'Generated: ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
                    style: pw.TextStyle(fontSize: 10, color: grey),
                  ),
                ],
              ),
            ],
          ),
          pw.Divider(color: primaryColor),
          pw.SizedBox(height: 4),
        ],
      ),
      footer: (context) => pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Mess Manager — Confidential',
            style: pw.TextStyle(fontSize: 9, color: grey),
          ),
          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: pw.TextStyle(fontSize: 9, color: grey),
          ),
        ],
      ),
      build: (context) => [
        // Summary section
        pw.Container(
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            color: lightBlue,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Monthly Summary',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: primaryColor),
              ),
              pw.SizedBox(height: 8),
              pw.Row(
                children: [
                  _pdfSummaryItem('Members', '${summary.totalMembers}', primaryColor),
                  _pdfSummaryItem('Total Deposit', AppUtils.formatCurrency(summary.totalDeposit), successColor),
                  _pdfSummaryItem('Total Cost', AppUtils.formatCurrency(summary.totalCost), errorColor),
                  _pdfSummaryItem(
                    'Net Balance',
                    AppUtils.formatCurrency(summary.totalNetAmount.abs()),
                    summary.totalNetAmount >= 0 ? successColor : errorColor,
                  ),
                ],
              ),
            ],
          ),
        ),

        pw.SizedBox(height: 16),

        pw.Text(
          'Member Statements',
          style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),

        // Statement table
        pw.TableHelper.fromTextArray(
          headers: [
            'Member',
            'Meal',
            'Rate',
            'Meal Cost',
            'Cook Cost',
            'Eid Bonus',
            'Deposit',
            'Total Cost',
            'Net',
            'Status',
          ],
          data: statements.map((s) => [
            s.memberName,
            AppUtils.formatMeal(s.consumedMeal),
            AppUtils.formatCurrency(s.mealRate),
            AppUtils.formatCurrency(s.costOfMeal),
            AppUtils.formatCurrency(s.cookCost),
            AppUtils.formatCurrency(s.eidBonus),
            AppUtils.formatCurrency(s.depositMoney),
            AppUtils.formatCurrency(s.totalCost),
            AppUtils.formatCurrency(s.netAmount.abs()),
            s.status,
          ]).toList(),
          headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 9,
            color: PdfColors.white,
          ),
          headerDecoration: pw.BoxDecoration(color: primaryColor),
          cellStyle: const pw.TextStyle(fontSize: 9),
          rowDecoration: pw.BoxDecoration(color: PdfColors.white),
          oddRowDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#F5F7FA')),
          cellAlignments: {
            0: pw.Alignment.centerLeft,
            1: pw.Alignment.centerRight,
            2: pw.Alignment.centerRight,
            3: pw.Alignment.centerRight,
            4: pw.Alignment.centerRight,
            5: pw.Alignment.centerRight,
            6: pw.Alignment.centerRight,
            7: pw.Alignment.centerRight,
            8: pw.Alignment.centerRight,
            9: pw.Alignment.center,
          },
          cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        ),

        pw.SizedBox(height: 16),

        // Calculation note
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColor.fromHex('#E0E0E0')),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Calculation Formula:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
              pw.SizedBox(height: 4),
              pw.Text('• Meal Cost = Consumed Meals × Meal Rate', style: const pw.TextStyle(fontSize: 9)),
              pw.Text('• Total Due = Meal Cost + Cook Cost', style: const pw.TextStyle(fontSize: 9)),
              pw.Text('• Total Cost = Total Due + Eid Bonus', style: const pw.TextStyle(fontSize: 9)),
              pw.Text('• Net Amount = Deposit - Total Cost', style: const pw.TextStyle(fontSize: 9)),
              pw.Text(
                '• Positive Net = Receivable | Negative Net = Payable | Zero = Settled',
                style: const pw.TextStyle(fontSize: 9),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  return doc;
}

pw.Widget _pdfSummaryItem(String label, String value, PdfColor color) {
  return pw.Expanded(
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 9, color: PdfColor.fromHex('#6B7280'))),
        pw.Text(value, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: color)),
      ],
    ),
  );
}
