class Event {
  final String petName;
  final String title;
  final String type; // 'Reminder' or 'Appointment'
  final String? location;
  final DateTime dateTime;
  final String? notes;

  Event({
    required this.petName,
    required this.title,
    required this.type,
    this.location,
    required this.dateTime,
    this.notes,
  });
}
