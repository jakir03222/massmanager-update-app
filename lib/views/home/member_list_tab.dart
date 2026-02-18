import 'package:flutter/material.dart';

import '../../controllers/home_controller.dart';
import '../../models/member_model.dart';
import '../../services/firebase_service.dart';
import 'widgets/add_member_sheet.dart';
import 'widgets/member_tile.dart';

class MemberListTab extends StatelessWidget {
  const MemberListTab({
    super.key,
    required this.controller,
    required this.uid,
  });

  final HomeController controller;
  final String uid;

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

    return StreamBuilder<List<MemberModel>>(
      stream: FirebaseService.instance.watchMembers(uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    snapshot.error.toString(),
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
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final members = snapshot.data!;
        if (members.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  'No members yet',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: openAddMember,
                  icon: const Icon(Icons.add),
                  label: const Text('Add first member'),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: members.length,
          itemBuilder: (context, index) {
            final member = members[index];
            return MemberTile(
              member: member,
              onDelete: () => controller.deleteMember(member.id),
            );
          },
        );
      },
    );
  }
}
