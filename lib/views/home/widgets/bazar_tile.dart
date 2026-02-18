import 'package:flutter/material.dart';

import '../../../models/bazar_model.dart';

class BazarTile extends StatelessWidget {
  const BazarTile({
    super.key,
    required this.item,
    required this.onDelete,
  });

  final BazarModel item;
  final VoidCallback onDelete;

  static String _dateStr(DateTime? d) {
    if (d == null) return '';
    return '${d.day}/${d.month}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = StringBuffer();
    subtitle.write('Amount: ${item.amount.toStringAsFixed(2)}');
    if (item.bazarDate != null) {
      subtitle.write(' • ${_dateStr(item.bazarDate)}');
    }
    if (item.memberName != null) {
      subtitle.write(' • ${item.memberName}');
    }
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          child: Icon(
            Icons.shopping_basket_outlined,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
        title: Text(item.title),
        subtitle: Text(subtitle.toString()),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
