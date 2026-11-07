class Workout {
  const Workout({required this.id, required this.title, required this.reason});

  final String id;
  final String title;
  final String reason;

  Workout copyWith({String? title, String? reason}) {
    return Workout(
      id: id,
      title: title ?? this.title,
      reason: reason ?? this.reason,
    );
  }
}
