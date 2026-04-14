import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/daily_meal_controller.dart';
import '../../core/constants/app_constants.dart';
import '../../models/daily_meal_model.dart';
import '../../models/member_model.dart';
import '../../widgets/loading_overlay.dart';

// ─── colour palette for members ──────────────────────────────────────────────
const _palette = [
  Color(0xFF1565C0),
  Color(0xFF00897B),
  Color(0xFFE65100),
  Color(0xFF6A1B9A),
  Color(0xFFC62828),
  Color(0xFF558B2F),
  Color(0xFF0277BD),
  Color(0xFF4527A0),
];

Color _memberColor(int index) => _palette[index % _palette.length];

class MealChartView extends GetView<DailyMealController> {
  const MealChartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.mealCharts)),
      body: Column(
        children: [
          // ── Month / Year filter ──────────────────────────────────────────
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: Obx(() => _DropDown<int>(
                        value: controller.summaryMonth.value,
                        items: List.generate(12, (i) => i + 1),
                        label: (m) => AppConstants.months[m - 1],
                        onChanged: controller.setSummaryMonth,
                      )),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Obx(() => _DropDown<int>(
                        value: controller.summaryYear.value,
                        items: AppConstants.years,
                        label: (y) => '$y',
                        onChanged: controller.setSummaryYear,
                      )),
                ),
              ],
            ),
          ),

          Expanded(
            child: Obx(() {
              if (controller.isSummaryLoading.value) return const CenteredLoader();

              final allMeals = controller.allMonthlyMeals;
              if (allMeals.isEmpty) {
                return const EmptyState(
                  message: AppStrings.noChartData,
                  icon: Icons.bar_chart_outlined,
                );
              }

              final members = controller.members;
              final byMember = controller.mealsByMember;
              final monthName =
                  '${AppConstants.months[controller.summaryMonth.value - 1]} ${controller.summaryYear.value}';

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── 1. Member total bar chart ──────────────────────────
                    _ChartCard(
                      title: AppStrings.totalMealsPerMember,
                      subtitle: monthName,
                      icon: Icons.bar_chart,
                      child: SizedBox(
                        height: 220,
                        child: _MemberBarChart(
                          members: members,
                          byMember: byMember,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── 2. Day-by-day line chart ──────────────────────────
                    _ChartCard(
                      title: AppStrings.dailyMealTrend,
                      subtitle: monthName,
                      icon: Icons.show_chart,
                      child: SizedBox(
                        height: 220,
                        child: _DailyLineChart(
                          allMeals: allMeals,
                          members: members,
                          byMember: byMember,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── 3. Morning / Afternoon / Night donut ──────────────
                    _ChartCard(
                      title: AppStrings.mealSlotDistribution,
                      subtitle: monthName,
                      icon: Icons.donut_large_outlined,
                      child: SizedBox(
                        height: 220,
                        child: _SlotPieChart(allMeals: allMeals),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── 4. Stacked slot bar (Morning/Afternoon/Night per member) ──
                    _ChartCard(
                      title: AppStrings.mealSlotsPerMember,
                      subtitle: AppStrings.morningAfternoonNight,
                      icon: Icons.stacked_bar_chart,
                      child: SizedBox(
                        height: 240,
                        child: _StackedSlotChart(
                          members: members,
                          byMember: byMember,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Chart 1: Member bar chart ─────────────────────────────────────────────────

class _MemberBarChart extends StatefulWidget {
  final List<MemberModel> members;
  final Map<String, List<DailyMealModel>> byMember;

  const _MemberBarChart({required this.members, required this.byMember});

  @override
  State<_MemberBarChart> createState() => _MemberBarChartState();
}

class _MemberBarChartState extends State<_MemberBarChart> {
  int? _touched;

  @override
  Widget build(BuildContext context) {
    final membersWithData = widget.members
        .where((m) => widget.byMember.containsKey(m.id))
        .toList();

    if (membersWithData.isEmpty) return const SizedBox.shrink();

    final maxY = membersWithData.map((m) {
      return widget.byMember[m.id]!.fold(0.0, (s, e) => s + e.total);
    }).reduce((a, b) => a > b ? a : b);

    final groups = membersWithData.asMap().entries.map((entry) {
      final i = entry.key;
      final member = entry.value;
      final total = widget.byMember[member.id]!.fold(0.0, (s, e) => s + e.total);
      final isTouched = _touched == i;

      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: total,
            color: _memberColor(i),
            width: isTouched ? 22 : 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: maxY * 1.15,
              color: _memberColor(i).withOpacity(0.07),
            ),
          ),
        ],
        showingTooltipIndicators: isTouched ? [0] : [],
      );
    }).toList();

    return BarChart(
      BarChartData(
        maxY: maxY * 1.15,
        barTouchData: BarTouchData(
          touchCallback: (event, response) {
            setState(() {
              if (event is FlTapUpEvent || event is FlPanEndEvent) {
                _touched = null;
              } else if (response?.spot != null) {
                _touched = response!.spot!.touchedBarGroupIndex;
              }
            });
          },
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppColors.primaryDark,
            getTooltipItem: (group, _, rod, __) {
              final member = membersWithData[group.x];
              return BarTooltipItem(
                '${member.name}\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                children: [
                  TextSpan(
                    text: '${_fmt(rod.toY)} বার',
                    style: TextStyle(
                      color: _memberColor(group.x).withOpacity(0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (v, _) => Text(
                _fmt(v),
                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (value, _) {
                final i = value.toInt();
                if (i >= membersWithData.length) return const SizedBox.shrink();
                final name = membersWithData[i].name.split(' ').first;
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    name.length > 7 ? '${name.substring(0, 6)}.' : name,
                    style: TextStyle(
                      fontSize: 10,
                      color: _touched == i ? _memberColor(i) : AppColors.textSecondary,
                      fontWeight: _touched == i ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: AppColors.divider.withOpacity(0.5),
            strokeWidth: 1,
          ),
        ),
        barGroups: groups,
      ),
    );
  }
}

// ── Chart 2: Day-by-day line chart ────────────────────────────────────────────

class _DailyLineChart extends StatelessWidget {
  final List<DailyMealModel> allMeals;
  final List<MemberModel> members;
  final Map<String, List<DailyMealModel>> byMember;

  const _DailyLineChart({
    required this.allMeals,
    required this.members,
    required this.byMember,
  });

  @override
  Widget build(BuildContext context) {
    // Build day → total across all members
    final Map<int, double> dayTotals = {};
    for (final m in allMeals) {
      dayTotals[m.day] = (dayTotals[m.day] ?? 0) + m.total;
    }
    if (dayTotals.isEmpty) return const SizedBox.shrink();

    final sortedDays = dayTotals.keys.toList()..sort();
    final spots = sortedDays
        .map((d) => FlSpot(d.toDouble(), dayTotals[d]!))
        .toList();

    final maxY = dayTotals.values.reduce((a, b) => a > b ? a : b);

    return LineChart(
      LineChartData(
        minX: sortedDays.first.toDouble(),
        maxX: sortedDays.last.toDouble(),
        minY: 0,
        maxY: maxY * 1.2,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.primaryDark,
            getTooltipItems: (spots) => spots.map((s) {
              return LineTooltipItem(
                '${s.x.toInt()} তারিখ\n${_fmt(s.y)} বার',
                const TextStyle(color: Colors.white, fontSize: 12),
              );
            }).toList(),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: AppColors.divider.withOpacity(0.5),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (v, _) => Text(
                _fmt(v),
                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: _xInterval(sortedDays).toDouble(),
              getTitlesWidget: (v, _) => Text(
                '${v.toInt()}',
                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
              ),
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: AppColors.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                radius: 4,
                color: AppColors.primary,
                strokeWidth: 2,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withOpacity(0.25),
                  AppColors.primary.withOpacity(0.02),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _xInterval(List<int> days) {
    final span = (days.last - days.first).clamp(1, 31);
    if (span <= 7) return 1;
    if (span <= 14) return 2;
    return 5;
  }
}

// ── Chart 3: Slot distribution pie / donut ────────────────────────────────────

class _SlotPieChart extends StatefulWidget {
  final List<DailyMealModel> allMeals;

  const _SlotPieChart({required this.allMeals});

  @override
  State<_SlotPieChart> createState() => _SlotPieChartState();
}

class _SlotPieChartState extends State<_SlotPieChart> {
  int _touched = -1;

  @override
  Widget build(BuildContext context) {
    final morning = widget.allMeals.fold(0.0, (s, m) => s + m.morning);
    final afternoon = widget.allMeals.fold(0.0, (s, m) => s + m.afternoon);
    final night = widget.allMeals.fold(0.0, (s, m) => s + m.night);
    final total = morning + afternoon + night;
    if (total == 0) return const SizedBox.shrink();

    final sections = [
      _pieSection(0, morning, total, 'সকাল', Colors.orange),
      _pieSection(1, afternoon, total, 'দুপুর', AppColors.primary),
      _pieSection(2, night, total, 'রাত', Colors.indigo),
    ];

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  setState(() {
                    if (event is FlTapUpEvent) {
                      _touched = -1;
                    } else if (response?.touchedSection != null) {
                      _touched = response!.touchedSection!.touchedSectionIndex;
                    }
                  });
                },
              ),
              sectionsSpace: 3,
              centerSpaceRadius: 48,
              sections: sections,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LegendItem(color: Colors.orange, label: 'সকাল', value: morning, total: total),
              const SizedBox(height: 12),
              _LegendItem(color: AppColors.primary, label: 'দুপুর', value: afternoon, total: total),
              const SizedBox(height: 12),
              _LegendItem(color: Colors.indigo, label: 'রাত', value: night, total: total),
            ],
          ),
        ),
      ],
    );
  }

  PieChartSectionData _pieSection(
    int index,
    double value,
    double total,
    String title,
    Color color,
  ) {
    final isTouched = _touched == index;
    final pct = total > 0 ? (value / total * 100).toStringAsFixed(1) : '0';

    return PieChartSectionData(
      color: color,
      value: value,
      title: isTouched ? '$pct%' : '',
      radius: isTouched ? 62 : 54,
      titleStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      badgeWidget: isTouched
          ? null
          : Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
      badgePositionPercentageOffset: 1.1,
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final double value;
  final double total;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (value / total * 100).toStringAsFixed(1) : '0';
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              Text(
                '${_fmt(value)} বার ($pct%)',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Chart 4: Stacked slot bar chart ──────────────────────────────────────────

class _StackedSlotChart extends StatefulWidget {
  final List<MemberModel> members;
  final Map<String, List<DailyMealModel>> byMember;

  const _StackedSlotChart({required this.members, required this.byMember});

  @override
  State<_StackedSlotChart> createState() => _StackedSlotChartState();
}

class _StackedSlotChartState extends State<_StackedSlotChart> {
  int? _touched;

  @override
  Widget build(BuildContext context) {
    final membersWithData = widget.members
        .where((m) => widget.byMember.containsKey(m.id))
        .toList();

    if (membersWithData.isEmpty) return const SizedBox.shrink();

    double maxY = 0;
    for (final m in membersWithData) {
      final entries = widget.byMember[m.id]!;
      final total = entries.fold(0.0, (s, e) => s + e.total);
      if (total > maxY) maxY = total;
    }

    final groups = membersWithData.asMap().entries.map((entry) {
      final i = entry.key;
      final member = entry.value;
      final entries = widget.byMember[member.id]!;
      final morning = entries.fold(0.0, (s, e) => s + e.morning);
      final afternoon = entries.fold(0.0, (s, e) => s + e.afternoon);
      final night = entries.fold(0.0, (s, e) => s + e.night);
      final isTouched = _touched == i;

      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: morning + afternoon + night,
            width: isTouched ? 22 : 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
            rodStackItems: [
              BarChartRodStackItem(0, morning, Colors.orange),
              BarChartRodStackItem(morning, morning + afternoon, AppColors.primary),
              BarChartRodStackItem(morning + afternoon, morning + afternoon + night, Colors.indigo),
            ],
          ),
        ],
        showingTooltipIndicators: isTouched ? [0] : [],
      );
    }).toList();

    return Column(
      children: [
        // Legend row
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _BarLegendDot(color: Colors.orange, label: 'সকাল'),
              const SizedBox(width: 16),
              _BarLegendDot(color: AppColors.primary, label: 'দুপুর'),
              const SizedBox(width: 16),
              _BarLegendDot(color: Colors.indigo, label: 'রাত'),
            ],
          ),
        ),
        Expanded(
          child: BarChart(
            BarChartData(
              maxY: maxY * 1.2,
              barTouchData: BarTouchData(
                touchCallback: (event, response) {
                  setState(() {
                    if (event is FlTapUpEvent || event is FlPanEndEvent) {
                      _touched = null;
                    } else if (response?.spot != null) {
                      _touched = response!.spot!.touchedBarGroupIndex;
                    }
                  });
                },
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => AppColors.primaryDark,
                  getTooltipItem: (group, _, rod, __) {
                    final member = membersWithData[group.x];
                    final entries = widget.byMember[member.id]!;
                    final m = entries.fold(0.0, (s, e) => s + e.morning);
                    final a = entries.fold(0.0, (s, e) => s + e.afternoon);
                    final n = entries.fold(0.0, (s, e) => s + e.night);
                    return BarTooltipItem(
                      '${member.name.split(' ').first}\n',
                      const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      children: [
                        TextSpan(text: 'সকাল: ${_fmt(m)}\n', style: const TextStyle(color: Colors.orange, fontSize: 11)),
                        TextSpan(text: 'দুপুর: ${_fmt(a)}\n', style: const TextStyle(color: Colors.lightBlueAccent, fontSize: 11)),
                        TextSpan(text: 'রাত: ${_fmt(n)}', style: const TextStyle(color: Colors.purpleAccent, fontSize: 11)),
                      ],
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    getTitlesWidget: (v, _) => Text(
                      _fmt(v),
                      style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    getTitlesWidget: (value, _) {
                      final i = value.toInt();
                      if (i >= membersWithData.length) return const SizedBox.shrink();
                      final name = membersWithData[i].name.split(' ').first;
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          name.length > 7 ? '${name.substring(0, 6)}.' : name,
                          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                        ),
                      );
                    },
                  ),
                ),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: AppColors.divider.withOpacity(0.5),
                  strokeWidth: 1,
                ),
              ),
              barGroups: groups,
            ),
          ),
        ),
      ],
    );
  }
}

class _BarLegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _BarLegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}

// ── Shared widgets & helpers ──────────────────────────────────────────────────

class _ChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }
}

class _DropDown<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final String Function(T) label;
  final void Function(T) onChanged;

  const _DropDown({
    required this.value,
    required this.items,
    required this.label,
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
          onChanged: (v) { if (v != null) onChanged(v); },
          items: items
              .map((i) => DropdownMenuItem<T>(value: i, child: Text(label(i))))
              .toList(),
        ),
      ),
    );
  }
}

String _fmt(double v) =>
    v == v.truncateToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
