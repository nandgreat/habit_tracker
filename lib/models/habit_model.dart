class HabitModel {
  late String _id;
  late String _name;
  num? _streak;
  bool? _completedToday;
  late String _createdAt;
  String? _lastCompletedOn;

  HabitModel({
    required String id,
    required String name,
    num? streak,
    bool? completedToday,
    required String createdAt,
    String? lastCompletedOn,
  }) {
    _id = id;
    _name = name;
    _streak = streak;
    _completedToday = completedToday;
    _createdAt = createdAt;
    _lastCompletedOn = lastCompletedOn;
  }

  HabitModel.fromJson(dynamic json) {
    _id = json['id'];
    _name = json['name'];
    _streak = json['streak'];
    _completedToday = json['completed_today'];
    _createdAt = json['created_at'];
    _lastCompletedOn = json['last_completed_on'];
  }

  HabitModel copyWith({
    String? id,
    String? name,
    num? streak,
    bool? completedToday,
    String? createdAt,
    String? lastCompletedOn,
  }) => HabitModel(
    id: id ?? _id,
    name: name ?? _name,
    streak: streak ?? _streak,
    completedToday: completedToday ?? _completedToday,
    createdAt: createdAt ?? _createdAt,
    lastCompletedOn: lastCompletedOn ?? _lastCompletedOn,
  );

  String get id => _id;
  String get name => _name;

  num? get streak => _streak;

  bool? get completedToday => _completedToday;

  String get createdAt => _createdAt;

  String? get lastCompletedOn => _lastCompletedOn;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['name'] = _name;
    map['streak'] = _streak;
    map['completed_today'] = _completedToday;
    map['created_at'] = _createdAt;
    map['last_completed_on'] = _lastCompletedOn;
    return map;
  }
  HabitModel refreshedForToday() {
    if (!(completedToday ?? false)) return this;
    final now = DateTime.now();
    final last = DateTime.parse(lastCompletedOn!);
    final isToday = last != null &&
        last.year == now.year &&
        last.month == now.month &&
        last.day == now.day;
    if (isToday) return this;
    return copyWith(completedToday: false);
  }
}
