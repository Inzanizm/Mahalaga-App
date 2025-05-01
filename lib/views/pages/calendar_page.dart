import 'package:flutter/material.dart';
import 'package:mahalaga_app/data/event.dart';
import 'package:mahalaga_app/views/pages/pet_page/select_pet_page.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay =
      DateTime.now(); // Current day that the calendar is focused on
  DateTime? _selectedDay; // Selected day by the user
  Map<DateTime, List<Event>> _events = {}; // Store events for each day

  int _appointmentCount = 0; // Number of appointments for the selected day
  int _reminderCount = 0; // Number of reminders for the selected day

  // Function to format time for events in AM/PM format
  String _formatTime(DateTime dateTime) {
    int hour = dateTime.hour;
    int minute = dateTime.minute;
    String ampm = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12 == 0 ? 12 : hour % 12;
    String minuteStr = minute.toString().padLeft(2, '0');
    return '$hour:$minuteStr $ampm';
  }

  @override
  void initState() {
    super.initState();
    _loadSampleEvents(); // Load sample events when the page is initialized
  }

  // Function to load sample events for testing
  void _loadSampleEvents() {
    final today = DateTime.now();
    final todayKey = DateTime(
      today.year,
      today.month,
      today.day,
    ); // Key for today
    final futureDay = today.add(Duration(days: 3)); // A future day for events
    final futureDayKey = DateTime(
      futureDay.year,
      futureDay.month,
      futureDay.day,
    );

    // Sample events for today and future day
    _events = {
      todayKey: [
        Event(
          petName: 'Buddy',
          title: 'Vet Check-up',
          type: 'Appointment',
          location: 'Happy Paws Clinic',
          dateTime: today,
          notes: 'Bring vaccination record.',
        ),
        Event(
          petName: 'Mittens',
          title: 'Monthly Deworming',
          type: 'Reminder',
          dateTime: today,
          notes: 'Use VetGuard Dewormer.',
        ),
      ],
      futureDayKey: [
        Event(
          petName: 'Buddy',
          title: 'Grooming Session',
          type: 'Appointment',
          location: 'Pet Salon',
          dateTime: futureDay,
        ),
      ],
    };
  }

  // Function to retrieve events for a specific day
  List<Event> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  // Function to update the counts of appointments and reminders for the selected day
  void _updateCounts(DateTime day) {
    final events = _getEventsForDay(day);
    _appointmentCount = events.where((e) => e.type == 'Appointment').length;
    _reminderCount = events.where((e) => e.type == 'Reminder').length;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TableCalendar(
                  firstDay: DateTime.utc(
                    2020,
                    1,
                    1,
                  ), // First date of calendar view
                  lastDay: DateTime.utc(
                    2030,
                    12,
                    31,
                  ), // Last date of calendar view
                  focusedDay: _focusedDay,
                  selectedDayPredicate:
                      (day) => isSameDay(
                        _selectedDay,
                        day,
                      ), // Highlight selected day
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay; // Update selected day
                      _focusedDay = focusedDay; // Update focused day
                      _updateCounts(selectedDay); // Update event counts
                    });
                  },
                  eventLoader: _getEventsForDay, // Load events for the day
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false, // Disable format button
                    titleCentered: true, // Center title
                    titleTextStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.teal,
                      shape:
                          BoxShape.circle, // Circle decoration for today's date
                    ),
                    selectedDecoration: BoxDecoration(
                      color:
                          Colors
                              .teal
                              .shade700, // Circle decoration for selected day
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.teal, width: 2),
                    ),
                  ),
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, events) {
                      // Display markers for events on selected days
                      if (events.isNotEmpty) {
                        return Positioned(
                          bottom: 4,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children:
                                events.take(3).map((e) {
                                  final event =
                                      e as Event; // Safely cast to Event
                                  Color markerColor = Colors.grey;
                                  if (event.type == 'Appointment') {
                                    markerColor =
                                        Colors.blue; // Blue for appointments
                                  } else if (event.type == 'Reminder') {
                                    markerColor =
                                        Colors.orange; // Orange for reminders
                                  }
                                  return Container(
                                    width: 6,
                                    height: 6,
                                    margin: EdgeInsets.symmetric(
                                      horizontal: 1.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: markerColor,
                                      shape: BoxShape.circle,
                                    ),
                                  );
                                }).toList(),
                          ),
                        );
                      } else {
                        // Optional: Grey dot for days with no events
                        return Positioned(
                          bottom: 4,
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child:
                  _selectedDay == null
                      ? Center(
                        child: Text(
                          'Select a date to view events!',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                      : _getEventsForDay(_selectedDay!).isEmpty
                      ? Center(
                        child: Text(
                          'No events for this day.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                      : ListView(
                        children:
                            _getEventsForDay(_selectedDay!).map((event) {
                              // Display events in a card format
                              Color cardColor =
                                  event.type == 'Appointment'
                                      ? Colors.blue.shade50
                                      : Colors.orange.shade50;

                              return Card(
                                color: cardColor,
                                margin: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                child: ListTile(
                                  leading: Icon(
                                    event.type == 'Appointment'
                                        ? Icons.event
                                        : Icons.alarm,
                                    color: Colors.teal,
                                  ),
                                  title: Text(
                                    '${event.petName}: ${event.title}',
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Type: ${event.type}'),
                                      if (event.location != null)
                                        Text('Location: ${event.location}'),
                                      if (event.notes != null)
                                        Text('Notes: ${event.notes}'),
                                      Text(
                                        'Time: ${_formatTime(event.dateTime)}',
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
            ),
          ],
        ),
        if (_selectedDay != null)
          Positioned(
            bottom: 20, // Adjust above main nav
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPopup('$_appointmentCount', Colors.blue),
                SizedBox(height: 8),
                _buildPopup('$_reminderCount', Colors.orange),
              ],
            ),
          ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            backgroundColor: Colors.teal,
            onPressed: () {
              // Navigate to SelectPetPage where the user selects a pet
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SelectPetPage()),
              );
            },
            child: Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  Widget _buildPopup(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha((0.8 * 255).toInt()),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
