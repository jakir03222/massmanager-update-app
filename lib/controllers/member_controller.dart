import 'package:get/get.dart';
import '../core/utils/app_utils.dart';
import '../models/member_model.dart';
import '../services/firestore_service.dart';

class MemberController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  final members = <MemberModel>[].obs;
  final filteredMembers = <MemberModel>[].obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _listenToMembers();
    debounce(searchQuery, (_) => _filterMembers(), time: const Duration(milliseconds: 300));
  }

  void _listenToMembers() {
    _firestoreService.membersStream().listen(
      (data) {
        members.value = data;
        _filterMembers();
      },
      onError: (e) => AppUtils.showError('Failed to load members: $e'),
    );
  }

  void _filterMembers() {
    if (searchQuery.value.isEmpty) {
      filteredMembers.value = members;
    } else {
      final q = searchQuery.value.toLowerCase();
      filteredMembers.value = members
          .where((m) => m.name.toLowerCase().contains(q) || m.phone.contains(q))
          .toList();
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  Future<bool> addMember({required String name, required String phone}) async {
    isLoading.value = true;
    try {
      final member = MemberModel(
        id: '',
        name: name.trim(),
        phone: phone.trim(),
        createdAt: DateTime.now(),
      );
      await _firestoreService.addMember(member);
      AppUtils.showSuccess('Member added successfully');
      return true;
    } catch (e) {
      AppUtils.showError('Failed to add member: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateMember(MemberModel member, {required String name, required String phone}) async {
    isLoading.value = true;
    try {
      final updated = member.copyWith(name: name.trim(), phone: phone.trim());
      await _firestoreService.updateMember(updated);
      AppUtils.showSuccess('Member updated successfully');
      return true;
    } catch (e) {
      AppUtils.showError('Failed to update member: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteMember(MemberModel member) async {
    final confirmed = await AppUtils.showConfirmDialog(
      title: 'Delete Member',
      message: 'Delete "${member.name}"? This cannot be undone.',
    );
    if (!confirmed) return;

    isLoading.value = true;
    try {
      await _firestoreService.deleteMember(member.id);
      AppUtils.showSuccess('Member deleted');
    } catch (e) {
      AppUtils.showError('Failed to delete member: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
