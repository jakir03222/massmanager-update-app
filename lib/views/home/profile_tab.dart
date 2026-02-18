import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../bills/bills_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({
    super.key,
    required this.authController,
  });

  final AuthController authController;

  @override
  Widget build(BuildContext context) {
    final user = authController.user;
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final uid = user.uid;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          CircleAvatar(
            radius: 48,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            backgroundImage:
                user.photoURL != null && user.photoURL!.isNotEmpty
                    ? NetworkImage(user.photoURL!)
                    : null,
            child: user.photoURL == null || user.photoURL!.isEmpty
                ? Text(
                    (user.displayName?.isNotEmpty == true
                            ? user.displayName![0]
                            : user.email?.isNotEmpty == true
                                ? user.email![0]
                                : '?')
                        .toUpperCase(),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            user.displayName ?? 'User',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (user.email != null && user.email!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              user.email!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
          const SizedBox(height: 32),
          Card(
            child: ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: const Text('Bills'),
              subtitle: const Text('Basha vara, khala, current, gas, wifi, other'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BillsScreen(uid: uid),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => authController.signOut(),
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
