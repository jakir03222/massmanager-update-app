import 'package:flutter/material.dart';

import '../../../models/meal_model.dart';

class MealTile extends StatelessWidget {
  const MealTile({
    super.key,
    required this.meal,
    required this.onDelete,
  });

  final MealModel meal;
  final VoidCallback onDelete;

  static String _dateStr(DateTime d) => '${d.day}/${d.month}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final subtitle = StringBuffer();
    subtitle.write(_dateStr(meal.mealDate));
    if (meal.memberName != null && meal.memberName!.isNotEmpty) {
      subtitle.write(' • ${meal.memberName}');
    }
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
          child: Icon(
            Icons.restaurant_outlined,
            color: Theme.of(context).colorScheme.onTertiaryContainer,
          ),
        ),
        title: Text('Rate: ${meal.rate.toStringAsFixed(2)}'),
        subtitle: Text(subtitle.toString()),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
