import 'package:flutter/material.dart';

import '../../../models/text_item_model.dart';

class ItemTile extends StatelessWidget {
  const ItemTile({
    super.key,
    required this.item,
    required this.onTap,
    required this.onDelete,
  });

  final TextItemModel item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        title: Text(item.title.isEmpty ? 'Untitled' : item.title),
        subtitle: item.body.isEmpty ? null : Text(item.body, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
        ),
        onTap: onTap,
      ),
    );
  }
}
