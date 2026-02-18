import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/home_controller.dart';
import 'widgets/add_member_sheet.dart';
import 'widgets/member_tile.dart';

/// View: Home with members list, + button to add member (name, phone), data from Firebase.
class HomeView extends StatefulWidget {
  const HomeView({super.key, required this.authController});

  final AuthController authController;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final HomeController _controller;

  @override
  void initState() {
    super.initState();
    final uid = widget.authController.user?.uid;
    _controller = HomeController(uid: uid ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openAddMemberSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddMemberSheet(
        onSave: (name, phone, password) async {
          await _controller.addMember(name, phone, password);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // App gates HomeView behind auth, but keep a safe fallback.
    if (widget.authController.user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () => widget.authController.signOut(),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_controller.error!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _controller.clearError,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (_controller.loading && _controller.members.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_controller.members.isEmpty) {
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
                    onPressed: _openAddMemberSheet,
                    icon: const Icon(Icons.add),
                    label: const Text('Add first member'),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: _controller.members.length,
            itemBuilder: (context, index) {
              final member = _controller.members[index];
              return MemberTile(
                member: member,
                onDelete: () => _controller.deleteMember(member.id),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddMemberSheet,
        tooltip: 'Add member',
        child: const Icon(Icons.add),
      ),
    );
  }
}
