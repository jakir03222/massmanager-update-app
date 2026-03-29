import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../controllers/mess_controller.dart';

class HomeTab extends StatefulWidget {
  final MessController messController;
  const HomeTab({super.key, required this.messController});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedMember;
  final _mealCountController = TextEditingController();
  final _noteController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _mealCountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _addMeal() async {
    if (_selectedMember == null) {
      _snack('Please select a member');
      return;
    }
    if (_mealCountController.text.isEmpty) {
      _snack('Please enter meal count');
      return;
    }
    final count = num.tryParse(_mealCountController.text);
    if (count == null || count <= 0) {
      _snack('Enter a valid meal count');
      return;
    }
    setState(() => _saving = true);
    await widget.messController.addMeal(
      _selectedMember!,
      _selectedDate,
      count,
      _noteController.text.isNotEmpty ? _noteController.text : null,
    );
    if (mounted) {
      setState(() {
        _saving = false;
        _mealCountController.clear();
        _noteController.clear();
      });
      _snack('Meal added successfully');
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

  void _showAddMemberDialog() {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Member'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Member Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                widget.messController.addMember(nameController.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.messController,
      builder: (context, _) {
        final members = widget.messController.members;
        final meals = widget.messController.meals;

        // If the selected member was deleted from Firebase, clear selection
        if (_selectedMember != null &&
            members.isNotEmpty &&
            !members.any((m) => m.name == _selectedMember)) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => setState(() => _selectedMember = null),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Daily Meals'),
            actions: [
              TextButton.icon(
                onPressed: _showAddMemberDialog,
                icon: const Icon(Icons.person_add),
                label: const Text('Add Member'),
              ),
            ],
          ),
          body: Column(
            children: [
              // ── Add Meal Card ──────────────────────────────────────
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Add Meal',
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

                      // Member Dropdown (feeds from Firebase stream)
                      members.isEmpty
                          ? Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade400),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: const [
                                  Icon(Icons.person_off_outlined, color: Colors.grey),
                                  SizedBox(width: 10),
                                  Text(
                                    'No members yet — tap "Add Member"',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                          : InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Select Member',
                                border: const OutlineInputBorder(),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                suffixIcon: _selectedMember != null
                                    ? IconButton(
                                        icon: const Icon(Icons.clear, size: 18),
                                        onPressed: () =>
                                            setState(() => _selectedMember = null),
                                      )
                                    : null,
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedMember,
                                  hint: const Text('Choose member'),
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
                                      setState(() => _selectedMember = val),
                                ),
                              ),
                            ),

                      const SizedBox(height: 14),

                      // Meal Count + Note
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _mealCountController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'Meal Count',
                                border: OutlineInputBorder(),
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
                        onPressed: _saving ? null : _addMeal,
                        child: _saving
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Save Meal'),
                      ),
                    ],
                  ),
                ),
              ),

              const Divider(height: 1),

              // ── Recent Meals List ──────────────────────────────────
              Expanded(
                child: meals.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.restaurant_outlined, size: 48, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('No meals added yet.', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 8),
                        itemCount: meals.length,
                        itemBuilder: (context, index) {
                          final meal = meals[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primaryContainer,
                              child: Text(
                                meal.memberName.isNotEmpty
                                    ? meal.memberName[0].toUpperCase()
                                    : '?',
                              ),
                            ),
                            title: Text(
                              '${meal.memberName}  —  ${meal.mealCount} Meals',
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text(
                              '${DateFormat('dd MMM yyyy').format(meal.date)}'
                              '${meal.note != null ? "  •  ${meal.note}" : ""}',
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
