/// Modèle de donnée pour les schedules.
class Schedule {
  final int id;

  Schedule({
    this.id = -1,
  });

  factory Schedule.fromJson(dynamic json) {
    Schedule permissions = Schedule(
      id: json['schedule_id'] ?? -1,
    );
    return permissions;
  }

  dynamic toJson() {
    return {
      'schedule_id': id,
    };
  }
}
