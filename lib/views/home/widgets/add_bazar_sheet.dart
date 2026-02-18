import 'package:flutter/material.dart';

import '../../../models/member_model.dart';

class BazarEntry {
  const BazarEntry({
    required this.title,
    required this.amount,
    this.bazarDate,
    this.memberId,
    this.memberName,
  });
  final String title;
  final double amount;
  final DateTime? bazarDate;
  final String? memberId;
  final String? memberName;
}

class AddBazarSheet extends StatefulWidget {
  const AddBazarSheet({
    super.key,
    required this.onSave,
    this.onSaveList,
    this.members = const [],
  });

  final Future<void> Function(String title, double amount) onSave;
  final Future<void> Function(List<BazarEntry> items)? onSaveList;
  final List<MemberModel> members;

  @override
  State<AddBazarSheet> createState() => _AddBazarSheetState();
}

class _AddBazarSheetState extends State<AddBazarSheet> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _list = <BazarEntry>[];
  bool _saving = false;
  DateTime _cardDate = DateTime.now();
  String? _selectedMemberId;
  String? _selectedMemberName;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _addToList() {
    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text.trim());
    if (title.isEmpty) return;
    if (amount == null || amount < 0) return;
    setState(() {
      _list.add(BazarEntry(
        title: title,
        amount: amount,
        bazarDate: _cardDate,
        memberId: _selectedMemberId,
        memberName: _selectedMemberName,
      ));
      _titleController.clear();
      _amountController.clear();
    });
  }

  void _removeFromList(int index) {
    setState(() => _list.removeAt(index));
  }

  Future<void> _saveAll() async {
    if (_list.isEmpty) return;
    setState(() => _saving = true);
    if (widget.onSaveList != null) {
      await widget.onSaveList!(_list);
    } else {
      for (final e in _list) {
        await widget.onSave(e.title, e.amount);
      }
    }
    if (mounted) {
      setState(() => _saving = false);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 10,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 8, bottom: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Add Bazar (multiple items)',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: _saving ? null : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Date for this card
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_outlined),
                title: const Text('Date'),
                subtitle: Text(
                  '${_cardDate.day}/${_cardDate.month}/${_cardDate.year}',
                ),
                trailing: FilledButton.tonal(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _cardDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setState(() => _cardDate = picked);
                  },
                  child: const Text('Change'),
                ),
              ),
              const SizedBox(height: 8),
              if (widget.members.isNotEmpty) ...[
                InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Assign to member',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: _selectedMemberId,
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('None'),
                        ),
                        ...widget.members.map((m) => DropdownMenuItem<String?>(
                              value: m.id,
                              child: Text('${m.name} (${m.phone})'),
                            )),
                      ],
                      onChanged: (v) {
                        setState(() {
                          _selectedMemberId = v;
                          _selectedMemberName = v == null
                              ? null
                              : widget.members.firstWhere((m) => m.id == v).name;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Item name',
                        hintText: 'e.g. Rice, Oil',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        hintText: '0',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onFieldSubmitted: (_) => _addToList(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _addToList,
                    tooltip: 'Add to list',
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_list.isNotEmpty) ...[
                Text(
                  'List (${_list.length} items) • ${_cardDate.day}/${_cardDate.month}/${_cardDate.year}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _list.length,
                    itemBuilder: (context, index) {
                      final e = _list[index];
                      return ListTile(
                        dense: true,
                        title: Text(e.title),
                        subtitle: e.memberName != null
                            ? Text('Member: ${e.memberName}',
                                style: Theme.of(context).textTheme.bodySmall)
                            : null,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              e.amount.toStringAsFixed(2),
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () => _removeFromList(index),
                              tooltip: 'Remove',
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _saving ? null : _saveAll,
                  icon: _saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                      _saving ? 'Saving...' : 'Save all (${_list.length})'),
                  style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                ),
              ] else
                Text(
                  'Add item name and price, then tap + to add to list. One card = one date + one member for all items.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
