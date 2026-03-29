import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../controllers/mess_controller.dart';

class BazarTab extends StatefulWidget {
  final MessController messController;
  const BazarTab({super.key, required this.messController});

  @override
  State<BazarTab> createState() => _BazarTabState();
}

class _BazarTabState extends State<BazarTab> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedBuyer;
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  final _noteController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _addBazar() async {
    if (_selectedBuyer == null) {
      _snack('Please select a buyer');
      return;
    }
    if (_amountController.text.isEmpty) {
      _snack('Please enter amount');
      return;
    }
    if (_descController.text.isEmpty) {
      _snack('Please enter description');
      return;
    }
    final amount = num.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _snack('Enter a valid amount');
      return;
    }
    setState(() => _saving = true);
    await widget.messController.addBazar(
      _selectedBuyer!,
      _selectedDate,
      amount,
      _descController.text,
      _noteController.text.isNotEmpty ? _noteController.text : null,
    );
    if (mounted) {
      setState(() {
        _saving = false;
        _amountController.clear();
        _descController.clear();
        _noteController.clear();
      });
      _snack('Bazar added successfully');
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.messController,
      builder: (context, _) {
        final members = widget.messController.members;
        final bazars = widget.messController.bazars;

        // If selected buyer was deleted from Firebase, clear selection
        if (_selectedBuyer != null &&
            members.isNotEmpty &&
            !members.any((m) => m.name == _selectedBuyer)) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => setState(() => _selectedBuyer = null),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Daily Bazar'),
          ),
          body: Column(
            children: [
              // ── Add Bazar Card ─────────────────────────────────────
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Add Bazar',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 14),

                      // Date Picker
                      OutlinedButton.icon(
                        onPressed: _pickDate,
                        icon: const Icon(Icons.calendar_today, size: 18),
                        label: Text(DateFormat('dd MMM yyyy').format(_selectedDate)),
                      ),
                      const SizedBox(height: 14),

                      // Buyer Dropdown (feeds from Firebase stream)
                      members.isEmpty
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 14),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade400),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: const [
                                  Icon(Icons.person_off_outlined,
                                      color: Colors.grey),
                                  SizedBox(width: 10),
                                  Text(
                                    'No members — add from Meal tab',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                          : InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Select Buyer',
                                border: const OutlineInputBorder(),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                suffixIcon: _selectedBuyer != null
                                    ? IconButton(
                                        icon: const Icon(Icons.clear, size: 18),
                                        onPressed: () =>
                                            setState(() => _selectedBuyer = null),
                                      )
                                    : null,
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedBuyer,
                                  hint: const Text('Choose buyer'),
                                  isExpanded: true,
                                  items: members
                                      .map(
                                        (m) => DropdownMenuItem<String>(
                                          value: m.name,
                                          child: Text(m.name),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (val) =>
                                      setState(() => _selectedBuyer = val),
                                ),
                              ),
                            ),

                      const SizedBox(height: 14),

                      // Description
                      TextField(
                        controller: _descController,
                        decoration: const InputDecoration(
                          labelText: 'Items / Description',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Amount + Note
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _amountController,
                              keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'Amount',
                                border: OutlineInputBorder(),
                                prefixText: '৳ ',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _noteController,
                              decoration: const InputDecoration(
                                labelText: 'Note (Optional)',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _saving ? null : _addBazar,
                        child: _saving
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Save Bazar'),
                      ),
                    ],
                  ),
                ),
              ),

              const Divider(height: 1),

              // ── Recent Bazar List ──────────────────────────────────
              Expanded(
                child: bazars.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shopping_cart_outlined,
                                size: 48, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('No bazar added yet.',
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 8),
                        itemCount: bazars.length,
                        itemBuilder: (context, index) {
                          final bazar = bazars[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  Theme.of(context).colorScheme.secondaryContainer,
                              child: Text(
                                bazar.buyerName.isNotEmpty
                                    ? bazar.buyerName[0].toUpperCase()
                                    : '?',
                              ),
                            ),
                            title: Text(
                              '${bazar.buyerName}  —  ৳${bazar.amount}',
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text(
                              '${DateFormat('dd MMM yyyy').format(bazar.date)}'
                              '  •  ${bazar.description}'
                              '${bazar.note != null ? "  •  ${bazar.note}" : ""}',
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
