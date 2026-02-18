/// App-wide constants.
class AppConstants {
  AppConstants._();

  static const String appTitle = 'Text App';

  // Firestore
  static const String collectionItems = 'items';
  static const String fieldTitle = 'title';
  static const String fieldBody = 'body';
  static const String fieldCreatedAt = 'createdAt';

  // Users
  static const String collectionUsers = 'users';
  static const String fieldEmail = 'email';
  static const String fieldDisplayName = 'displayName';
  static const String fieldPhotoUrl = 'photoUrl';
  static const String fieldCreatedAtUser = 'createdAt';
  static const String fieldLastLoginAt = 'lastLoginAt';

  // Bills (stored on users/{uid} document)
  static const String fieldBillBashaVara = 'billBashaVara';
  static const String fieldBillKhala = 'billKhala';
  static const String fieldBillCurrent = 'billCurrent';
  static const String fieldBillGas = 'billGas';
  static const String fieldBillWifi = 'billWifi';
  static const String fieldBillOther = 'billOther';
  static const String fieldBillsUpdatedAt = 'billsUpdatedAt';

  // Members (subcollection under users)
  static const String subcollectionMembers = 'members';
  static const String fieldMemberName = 'name';
  static const String fieldMemberPhone = 'phone';
  static const String fieldMemberPassword = 'password';
  static const String fieldMemberCreatedAt = 'createdAt';

  // Bazar (subcollection under users)
  static const String subcollectionBazar = 'bazar';
  static const String fieldBazarTitle = 'title';
  static const String fieldBazarAmount = 'amount';
  static const String fieldBazarDate = 'bazarDate';
  static const String fieldBazarMemberId = 'memberId';
  static const String fieldBazarMemberName = 'memberName';
  static const String fieldBazarCreatedAt = 'createdAt';

  // Meals (subcollection under users)
  static const String subcollectionMeals = 'meals';
  static const String fieldMealDate = 'mealDate';
  static const String fieldMealMemberId = 'memberId';
  static const String fieldMealMemberName = 'memberName';
  static const String fieldMealType = 'type'; // 'sokal' | 'bikal'
  static const String fieldMealRate = 'rate';
  static const String fieldMealCreatedAt = 'createdAt';

  static const String mealTypeSokal = 'sokal';
  static const String mealTypeBikal = 'bikal';
  static const double mealRateStep = 0.05;
}
