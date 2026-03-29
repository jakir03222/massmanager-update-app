class BazarModel {
  final String id;
  final String userId;
  final String buyerName;
  final DateTime date;
  final num amount;
  final String description;
  final String? note;
  final DateTime createdAt;

  BazarModel({
    required this.id,
    required this.userId,
    required this.buyerName,
    required this.date,
    required this.amount,
    required this.description,
    this.note,
    required this.createdAt,
  });

  factory BazarModel.fromMap(Map<String, dynamic> map, String id) {
    return BazarModel(
      id: id,
      userId: map['userId'] ?? '',
      buyerName: map['buyerName'] ?? '',
      date: map['date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['date'])
          : DateTime.now(),
      amount: map['amount'] ?? 0,
      description: map['description'] ?? '',
      note: map['note'],
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'buyerName': buyerName,
      'date': date.millisecondsSinceEpoch,
      'amount': amount,
      'description': description,
      'note': note,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}
