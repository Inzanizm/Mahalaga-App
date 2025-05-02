class Reminder {
  final int? id; // Now an integer, since the table uses BIGINT
  final int petId; // Link to PetTable ID (also BIGINT)
  final String type;
  final String description;
  final DateTime reminderDate;

  Reminder({
    this.id,
    required this.petId,
    required this.type,
    required this.description,
    required this.reminderDate,
  });

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'] as int,
      petId: map['pet_id'] as int,
      type: map['type'] as String,
      description: map['description'] as String,
      reminderDate: DateTime.parse(map['reminder_date']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pet_id': petId,
      'type': type,
      'description': description,
      'reminder_date': reminderDate.toIso8601String(),
    };
  }

  Reminder copyWith({
    int? id,
    int? petId,
    String? type,
    String? description,
    DateTime? reminderDate,
  }) {
    return Reminder(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      type: type ?? this.type,
      description: description ?? this.description,
      reminderDate: reminderDate ?? this.reminderDate,
    );
  }
}
