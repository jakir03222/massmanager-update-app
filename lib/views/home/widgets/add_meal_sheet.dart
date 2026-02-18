import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../models/member_model.dart';

class AddMealSheet extends StatefulWidget {
  const AddMealSheet({
    super.key,
    required this.members,
    required this.onSave,
  });

  final List<MemberModel> members;
  final Future<void> Function({
    required DateTime mealDate,
    required String type,
    String? memberId,
    String? memberName,
    required double rate,
  }) onSave;

  @override
  State<AddMealSheet> createState() => _AddMealSheetState();
}

class _AddMealSheetState extends State<AddMealSheet> {
  DateTime _mealDate = DateTime.now();
  String? _memberId;
  String? _memberName;
  double _rate = 0.0;
  bool _saving = false;
  late final TextEditingController _rateController;

  @override
  void initState() {
    super.initState();
    _rateController = TextEditingController(text: _rate.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _rateController.dispose();
    super.dispose();
  }

  void _updateRate(double value) {
    final clamped = value.clamp(0.0, double.infinity);
    setState(() {
      _rate = double.parse(clamped.toStringAsFixed(2));
      _rateController.text = _rate.toStringAsFixed(2);
    });
  }

  void _incrementRate() {
    _updateRate(_rate + AppConstants.mealRateStep);
  }

  void _decrementRate() {
    _updateRate(_rate - AppConstants.mealRateStep);
  }

  Future<void> _submit() async {
    setState(() => _saving = true);
    await widget.onSave(
      mealDate: _mealDate,
      type: AppConstants.mealTypeSokal,
      memberId: _memberId,
      memberName: _memberName,
      rate: _rate,
    );
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
                      'Add Meal',
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
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_outlined),
                title: const Text('Date'),
                subtitle: Text(
                  '${_mealDate.day}/${_mealDate.month}/${_mealDate.year}',
                ),
                trailing: FilledButton.tonal(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _mealDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setState(() => _mealDate = picked);
                  },
                  child: const Text('Change'),
                ),
              ),
              const SizedBox(height: 8),
              if (widget.members.isNotEmpty) ...[
                InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Select member',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: _memberId,
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
                          _memberId = v;
                          _memberName = v == null
                              ? null
                              : widget.members.firstWhere((m) => m.id == v).name;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              const Text('Rate', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _rateController,
                decoration: const InputDecoration(
                  labelText: 'Rate',
                  hintText: '0.5, 1, 2, 3...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.paid_outlined),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (v) {
                  final parsed = double.tryParse(v.replaceAll(',', '.').trim());
                  if (parsed != null && parsed >= 0) {
                    setState(() => _rate = double.parse(parsed.toStringAsFixed(2)));
                  }
                },
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.filled(
                    onPressed: _decrementRate,
                    icon: const Icon(Icons.remove),
                    tooltip: 'Decrease by 0.05',
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      _rate.toStringAsFixed(2),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton.filled(
                    onPressed: _incrementRate,
                    icon: const Icon(Icons.add),
                    tooltip: 'Increase by 0.05',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [0.5, 1.0, 2.0, 3.0].map((value) {
                  final isSelected = (_rate - value).abs() < 0.001;
                  return FilterChip(
                    label: Text(value.toStringAsFixed(value == value.roundToDouble() ? 0 : 1)),
                    selected: isSelected,
                    onSelected: (_) => _updateRate(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _saving ? null : _submit,
                icon: _saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add),
                label: Text(_saving ? 'Saving...' : 'Add meal'),
                style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
