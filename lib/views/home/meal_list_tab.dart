import 'package:flutter/material.dart';

import '../../controllers/home_controller.dart';
import 'widgets/add_meal_sheet.dart';
import 'widgets/meal_tile.dart';

class MealListTab extends StatelessWidget {
  const MealListTab({super.key, required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    void openAddMeal() {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (ctx) => AddMealSheet(
          members: controller.members,
          onSave: ({
            required mealDate,
            required type,
            memberId,
            memberName,
            required rate,
          }) async =>
              await controller.addMeal(
            mealDate,
            type,
            memberId: memberId,
            memberName: memberName,
            rate: rate,
          ),
        ),
      );
    }

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.error != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    controller.error!,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: controller.clearError,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        if (controller.loading && controller.meals.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.meals.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.restaurant_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  'No meals yet',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: openAddMeal,
                  icon: const Icon(Icons.add),
                  label: const Text('Add first meal'),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: controller.meals.length,
          itemBuilder: (context, index) {
            final meal = controller.meals[index];
            return MealTile(
              meal: meal,
              onDelete: () => controller.deleteMeal(meal.id),
            );
          },
        );
      },
    );
  }
}
