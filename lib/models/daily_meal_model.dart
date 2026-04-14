import 'package:cloud_firestore/cloud_firestore.dart';

class DailyMealModel {
  final String id;
  final String memberId;
  final String memberName;
  final DateTime date;   // midnight of the day
  final int day;
  final int month;
  final int year;
  final double morning;
  final double afternoon;
  final double night;

  const DailyMealModel({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.date,
    required this.day,
    required this.month,
    required this.year,
    required this.morning,
    required this.afternoon,
    required this.night,
  });

  double get total => morning + afternoon + night;

  factory DailyMealModel.fromMap(Map<String, dynamic> map, String docId) {
    return DailyMealModel(
      id: docId,
      memberId: map['memberId'] ?? '',
      memberName: map['memberName'] ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      day: (map['day'] ?? 1) as int,
      month: (map['month'] ?? 1) as int,
      year: (map['year'] ?? DateTime.now().year) as int,
      morning: (map['morning'] ?? 0).toDouble(),
      afternoon: (map['afternoon'] ?? 0).toDouble(),
      night: (map['night'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'memberId': memberId,
      'memberName': memberName,
      'date': Timestamp.fromDate(date),
      'day': day,
      'month': month,
      'year': year,
      'morning': morning,
      'afternoon': afternoon,
      'night': night,
      'total': total,
    };
  }

  DailyMealModel copyWith({
    String? id,
    double? morning,
    double? afternoon,
    double? night,
  }) {
    return DailyMealModel(
      id: id ?? this.id,
      memberId: memberId,
      memberName: memberName,
      date: date,
      day: day,
      month: month,
      year: year,
      morning: morning ?? this.morning,
      afternoon: afternoon ?? this.afternoon,
      night: night ?? this.night,
    );
  }

  /// Returns midnight DateTime for a given date (used as the key)
  static DateTime dayKey(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
