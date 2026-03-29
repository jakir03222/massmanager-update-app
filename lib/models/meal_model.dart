class MealModel {
  final String id;
  final String userId;
  final String memberName;
  final DateTime date;
  final num mealCount;
  final String? note;
  final DateTime createdAt;

  MealModel({
    required this.id,
    required this.userId,
    required this.memberName,
    required this.date,
    required this.mealCount,
    this.note,
    required this.createdAt,
  });

  factory MealModel.fromMap(Map<String, dynamic> map, String id) {
    return MealModel(
      id: id,
      userId: map['userId'] ?? '',
      memberName: map['memberName'] ?? '',
      date: map['date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['date'])
          : DateTime.now(),
      mealCount: map['mealCount'] ?? 0,
      note: map['note'],
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'memberName': memberName,
      'date': date.millisecondsSinceEpoch,
      'mealCount': mealCount,
      'note': note,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}
