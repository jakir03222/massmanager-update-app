import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/home_controller.dart';
import 'bazar_list_tab.dart';
import 'member_list_tab.dart';
import 'meal_list_tab.dart';
import 'profile_tab.dart';
import 'widgets/add_bazar_sheet.dart';
import 'widgets/add_meal_sheet.dart';
import 'widgets/add_member_sheet.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.authController});

  final AuthController authController;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const int _mealIndex = 0;
  static const int _bazarIndex = 1;
  static const int _memberListIndex = 2;
  static const int _profileIndex = 3;

  late final HomeController _homeController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    final uid = widget.authController.user?.uid ?? '';
    _homeController = HomeController(uid: uid);
  }

  @override
  void dispose() {
    _homeController.dispose();
    super.dispose();
  }

  String get _title {
    switch (_currentIndex) {
      case _mealIndex:
        return 'Meal';
      case _bazarIndex:
        return 'Bazar';
      case _memberListIndex:
        return 'Members';
      case _profileIndex:
        return 'Profile';
      default:
        return AppConstants.appTitle;
    }
  }

  Widget get _body {
    final uid = widget.authController.user?.uid ?? '';
    switch (_currentIndex) {
      case _mealIndex:
        return MealListTab(controller: _homeController);
      case _bazarIndex:
        return BazarListTab(controller: _homeController);
      case _memberListIndex:
        return MemberListTab(controller: _homeController, uid: uid);
      case _profileIndex:
        return ProfileTab(authController: widget.authController);
      default:
        return MealListTab(controller: _homeController);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.authController.user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: _body,
      floatingActionButton: _currentIndex == _mealIndex
          ? FloatingActionButton(
              onPressed: () {
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (ctx) => AddMealSheet(
                    members: _homeController.members,
                    onSave: ({
                      required mealDate,
                      required type,
                      memberId,
                      memberName,
                      required rate,
                    }) async =>
                        await _homeController.addMeal(
                      mealDate,
                      type,
                      memberId: memberId,
                      memberName: memberName,
                      rate: rate,
                    ),
                  ),
                );
              },
              tooltip: 'Add meal',
              child: const Icon(Icons.add),
            )
          : _currentIndex == _bazarIndex
              ? FloatingActionButton(
                  onPressed: () {
                    showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      builder: (ctx) => AddBazarSheet(
                        members: _homeController.members,
                        onSave: (title, amount) async =>
                            await _homeController.addBazar(title, amount),
                        onSaveList: (items) async =>
                            await _homeController.addBazarList(
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
                  },
                  tooltip: 'Add bazar (multiple items)',
                  child: const Icon(Icons.add),
                )
              : _currentIndex == _memberListIndex
                  ? FloatingActionButton(
                      onPressed: () {
                        showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          builder: (ctx) => AddMemberSheet(
                            onSave: (name, phone, password) async =>
                                await _homeController.addMember(
                                    name, phone, password),
                          ),
                        );
                      },
                      tooltip: 'Add member',
                      child: const Icon(Icons.add),
                    )
                  : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.restaurant_outlined),
            selectedIcon: Icon(Icons.restaurant),
            label: 'Meal',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_basket_outlined),
            selectedIcon: Icon(Icons.shopping_basket),
            label: 'Bazar',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Members',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
