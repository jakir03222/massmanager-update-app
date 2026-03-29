class MemberModel {
  final String id;
  final String userId;
  final String name;
  final DateTime createdAt;

  MemberModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.createdAt,
  });

  factory MemberModel.fromMap(Map<String, dynamic> map, String id) {
    return MemberModel(
      id: id,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}
