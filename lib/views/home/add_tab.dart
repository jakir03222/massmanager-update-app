import 'package:flutter/material.dart';

import '../../controllers/home_controller.dart';
import 'widgets/add_bazar_sheet.dart';
import 'widgets/add_member_sheet.dart';

class AddTab extends StatelessWidget {
  const AddTab({super.key, required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    void openAddMember() {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (ctx) => AddMemberSheet(
          onSave: (name, phone, password) async =>
              await controller.addMember(name, phone, password),
        ),
      );
    }

    void openAddBazar() {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (ctx) => AddBazarSheet(
          members: controller.members,
          onSave: (title, amount) async =>
              await controller.addBazar(title, amount),
          onSaveList: (items) async => await controller.addBazarList(
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

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Add new',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 32),
            _AddOptionCard(
              icon: Icons.person_add_outlined,
              title: 'Add Member',
              subtitle: 'Add name, mobile and password',
              onTap: openAddMember,
            ),
            const SizedBox(height: 16),
            _AddOptionCard(
              icon: Icons.shopping_basket_outlined,
              title: 'Add to Bazar',
              subtitle: 'One card: date + member + multiple items',
              onTap: openAddBazar,
            ),
          ],
        ),
      ),
    );
  }
}

class _AddOptionCard extends StatelessWidget {
  const _AddOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                child: Icon(icon, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
