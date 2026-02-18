import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../services/firebase_service.dart';

class BillsScreen extends StatefulWidget {
  const BillsScreen({super.key, required this.uid});

  final String uid;

  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  final _bashaVaraController = TextEditingController();
  final _khalaController = TextEditingController();
  final _currentController = TextEditingController();
  final _gasController = TextEditingController();
  final _wifiController = TextEditingController();
  final _otherController = TextEditingController();

  bool _saving = false;
  bool _initializedFromRemote = false;

  static double _num(Map<String, dynamic> data, String key) {
    final v = data[key];
    if (v is num) return v.toDouble();
    return 0.0;
  }

  static String _money(double v) {
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(2);
  }

  static String _dateTimeStr(DateTime d) =>
      '${d.day}/${d.month}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  @override
  void dispose() {
    _bashaVaraController.dispose();
    _khalaController.dispose();
    _currentController.dispose();
    _gasController.dispose();
    _wifiController.dispose();
    _otherController.dispose();
    super.dispose();
  }

  static String _toText(num? v) {
    if (v == null) return '';
    final d = v.toDouble();
    if (d == d.roundToDouble()) return d.toStringAsFixed(0);
    return d.toStringAsFixed(2);
  }

  static double _parseAmount(String s) {
    final t = s.trim().replaceAll(',', '.');
    return double.tryParse(t) ?? 0.0;
  }

  void _initControllersFrom(Map<String, dynamic> data) {
    if (_initializedFromRemote) return;
    _bashaVaraController.text =
        _toText(data[AppConstants.fieldBillBashaVara] as num?);
    _khalaController.text = _toText(data[AppConstants.fieldBillKhala] as num?);
    _currentController.text =
        _toText(data[AppConstants.fieldBillCurrent] as num?);
    _gasController.text = _toText(data[AppConstants.fieldBillGas] as num?);
    _wifiController.text = _toText(data[AppConstants.fieldBillWifi] as num?);
    _otherController.text = _toText(data[AppConstants.fieldBillOther] as num?);
    _initializedFromRemote = true;
  }

  Future<void> _saveBills() async {
    setState(() => _saving = true);
    try {
      await FirebaseService.instance.upsertBills(
        widget.uid,
        bashaVara: _parseAmount(_bashaVaraController.text),
        khalaBill: _parseAmount(_khalaController.text),
        currentBill: _parseAmount(_currentController.text),
        gasBill: _parseAmount(_gasController.text),
        wifiBill: _parseAmount(_wifiController.text),
        otherBill: _parseAmount(_otherController.text),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bills saved')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bills')),
      body: StreamBuilder<Map<String, dynamic>>(
        stream: FirebaseService.instance.watchBills(widget.uid),
        builder: (context, snap) {
          final data = snap.data ?? const <String, dynamic>{};
          _initControllersFrom(data);

          final bashaVara = _num(data, AppConstants.fieldBillBashaVara);
          final khala = _num(data, AppConstants.fieldBillKhala);
          final current = _num(data, AppConstants.fieldBillCurrent);
          final gas = _num(data, AppConstants.fieldBillGas);
          final wifi = _num(data, AppConstants.fieldBillWifi);
          final other = _num(data, AppConstants.fieldBillOther);
          final total = bashaVara + khala + current + gas + wifi + other;

          DateTime? updatedAt;
          final ua = data[AppConstants.fieldBillsUpdatedAt];
          if (ua is Timestamp) updatedAt = ua.toDate();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Saved bills',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            if (updatedAt != null)
                              Text(
                                _dateTimeStr(updatedAt),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.outline,
                                    ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _BillRow(label: 'Basha vara', value: _money(bashaVara)),
                        _BillRow(label: 'Khala bill', value: _money(khala)),
                        _BillRow(label: 'Current bill', value: _money(current)),
                        _BillRow(label: 'Gas bill', value: _money(gas)),
                        _BillRow(label: 'WiFi bill', value: _money(wifi)),
                        _BillRow(label: 'Other bill', value: _money(other)),
                        const Divider(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Total',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            Text(
                              _money(total),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _bashaVaraController,
                          decoration: const InputDecoration(
                            labelText: 'Basha vara',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.home_outlined),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _khalaController,
                          decoration: const InputDecoration(
                            labelText: 'Khala bill',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.cleaning_services_outlined),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _currentController,
                          decoration: const InputDecoration(
                            labelText: 'Current bill',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.bolt_outlined),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _gasController,
                          decoration: const InputDecoration(
                            labelText: 'Gas bill',
                            border: OutlineInputBorder(),
                            prefixIcon:
                                Icon(Icons.local_fire_department_outlined),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _wifiController,
                          decoration: const InputDecoration(
                            labelText: 'WiFi bill',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.wifi_outlined),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _otherController,
                          decoration: const InputDecoration(
                            labelText: 'Other bill',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.receipt_long_outlined),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: _saving ? null : _saveBills,
                          icon: _saving
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                )
                              : const Icon(Icons.save),
                          label: Text(_saving ? 'Saving...' : 'Save bills'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BillRow extends StatelessWidget {
  const _BillRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ],
      ),
    );
  }
}

