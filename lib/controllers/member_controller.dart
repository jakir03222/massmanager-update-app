import 'package:get/get.dart';
import '../core/constants/app_constants.dart';
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
      onError: (e) => AppUtils.showError('সদস্য লোড করতে সমস্যা হয়েছে।'),
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
      AppUtils.showSuccess(AppStrings.memberAdded);
      return true;
    } catch (e) {
      AppUtils.showError('সদস্য যোগ করতে সমস্যা হয়েছে।');
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
      AppUtils.showSuccess(AppStrings.memberUpdated);
      return true;
    } catch (e) {
      AppUtils.showError('সদস্য আপডেট করতে সমস্যা হয়েছে।');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteMember(MemberModel member) async {
    final confirmed = await AppUtils.showConfirmDialog(
      title: AppStrings.deleteMember,
      message: '"${member.name}" কে মুছে ফেলবেন? এটি পূর্বাবস্থায় ফেরানো যাবে না।',
    );
    if (!confirmed) return;

    isLoading.value = true;
    try {
      await _firestoreService.deleteMember(member.id);
      AppUtils.showSuccess(AppStrings.memberDeleted);
    } catch (e) {
      AppUtils.showError('সদস্য মুছতে সমস্যা হয়েছে।');
    } finally {
      isLoading.value = false;
    }
  }
}
