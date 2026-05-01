import 'dart:convert';

enum TargetType { daily, weekly, none }

class TasbihItem {
  final String id;
  String name;
  int counter;
  int goal;
  TargetType targetType;
  int totalCount;
  Map<String, int> dailyHistory;
  DateTime lastUpdated;
  bool reminderEnabled;
  bool vibrationEnabled;

  TasbihItem({
    required this.id,
    required this.name,
    this.counter = 0,
    this.goal = 33,
    this.targetType = TargetType.none,
    this.totalCount = 0,
    Map<String, int>? dailyHistory,
    DateTime? lastUpdated,
    this.reminderEnabled = true,
    this.vibrationEnabled = true,
  })  : dailyHistory = dailyHistory ?? {},
        lastUpdated = lastUpdated ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'counter': counter,
      'totalCount': totalCount,
      'dailyHistory': dailyHistory,
      'goal': goal,
      'targetType': targetType.index,
      'lastUpdated': lastUpdated.toIso8601String(),
      'reminderEnabled': reminderEnabled,
      'vibrationEnabled': vibrationEnabled,
    };
  }

  factory TasbihItem.fromMap(Map<String, dynamic> map) {
    return TasbihItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      counter: map['counter']?.toInt() ?? 0,
      totalCount: map['totalCount']?.toInt() ?? 0,
      dailyHistory: Map<String, int>.from(map['dailyHistory'] ?? {}),
      goal: map['goal']?.toInt() ?? 33,
      targetType: TargetType.values[map['targetType'] ?? TargetType.none.index],
      lastUpdated: map['lastUpdated'] != null
          ? DateTime.parse(map['lastUpdated'])
          : DateTime.now(),
      reminderEnabled: map['reminderEnabled'] ?? true,
      vibrationEnabled: map['vibrationEnabled'] ?? true,
    );
  }

  String toJson() => json.encode(toMap());

  factory TasbihItem.fromJson(String source) => TasbihItem.fromMap(json.decode(source));
}
