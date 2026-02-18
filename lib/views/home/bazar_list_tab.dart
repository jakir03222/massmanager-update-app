import 'package:flutter/material.dart';

import '../../controllers/home_controller.dart';
import '../../models/bazar_model.dart';
import 'widgets/add_bazar_sheet.dart';
import 'widgets/bazar_tile.dart';

/// Filter value: null = All, empty string = Unassigned, else = member name.
const String _filterAll = 'all';
const String _filterUnassigned = 'unassigned';

class BazarListTab extends StatefulWidget {
  const BazarListTab({super.key, required this.controller});

  final HomeController controller;

  @override
  State<BazarListTab> createState() => _BazarListTabState();
}

class _BazarListTabState extends State<BazarListTab> {
  String _filterByMember = _filterAll;
  DateTime? _filterDate; // null = all dates, else filter by this date (day only)

  static bool _isSameDay(DateTime? a, DateTime b) {
    if (a == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static List<BazarModel> _filterList(
    List<BazarModel> list,
    String filterByMember,
    DateTime? filterDate,
  ) {
    var result = list;
    if (filterDate != null) {
      result = result.where((e) => _isSameDay(e.bazarDate, filterDate)).toList();
    }
    if (filterByMember == _filterAll) return result;
    if (filterByMember == _filterUnassigned) {
      return result.where((e) => e.memberName == null || e.memberName!.isEmpty).toList();
    }
    return result.where((e) => e.memberName == filterByMember).toList();
  }

  @override
  Widget build(BuildContext context) {
    void openAddBazar() {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (ctx) => AddBazarSheet(
          members: widget.controller.members,
          onSave: (title, amount) async =>
              await widget.controller.addBazar(title, amount),
          onSaveList: (items) async => await widget.controller.addBazarList(
            items
                .map((e) => (
                      title: e.title,
                      amount: e.amount,
                      bazarDate: e.bazarDate,
                      memberId: e.memberId,
                      memberName: e.memberName,
                    ))
                .toList(),
          ),
        ),
      );
    }

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        if (widget.controller.error != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.controller.error!,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: widget.controller.clearError,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        if (widget.controller.loading && widget.controller.bazarList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (widget.controller.bazarList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_basket_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  'No bazar items yet',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: openAddBazar,
                  icon: const Icon(Icons.add),
                  label: const Text('Add first item'),
                ),
              ],
            ),
          );
        }

        final memberNames = widget.controller.members
            .map((m) => m.name)
            .where((n) => n.isNotEmpty)
            .toSet()
            .toList();
        final filtered = _filterList(
          widget.controller.bazarList,
          _filterByMember,
          _filterDate,
        );

        String dateLabel() {
          if (_filterDate == null) return 'All dates';
          final d = _filterDate!;
          return '${d.day}/${d.month}/${d.year}';
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Filter by member',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _filterByMember,
                          isExpanded: true,
                          items: [
                            const DropdownMenuItem<String>(
                              value: _filterAll,
                              child: Text('All'),
                            ),
                            const DropdownMenuItem<String>(
                              value: _filterUnassigned,
                              child: Text('Unassigned'),
                            ),
                            ...memberNames.map((name) => DropdownMenuItem<String>(
                                  value: name,
                                  child: Text(name),
                                )),
                          ],
                          onChanged: (v) {
                            if (v != null) setState(() => _filterByMember = v);
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Filter by date',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              dateLabel(),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _filterDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (picked != null) setState(() => _filterDate = picked);
                            },
                            child: const Text('Pick'),
                          ),
                          if (_filterDate != null)
                            IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              onPressed: () => setState(() => _filterDate = null),
                              tooltip: 'Clear date filter',
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (filtered.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    _filterByMember == _filterAll && _filterDate == null
                        ? 'No bazar items yet'
                        : 'No items for this filter (member + date)',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return BazarTile(
                      item: item,
                      onDelete: () => widget.controller.deleteBazar(item.id),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}
