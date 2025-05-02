import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:mahalaga_app/database/pet_table.dart';
import 'package:mahalaga_app/database/pet_table_database.dart';
import 'package:mahalaga_app/database/reminder.dart';
import 'package:mahalaga_app/database/reminder_database.dart';

class PetDetailScreen extends StatefulWidget {
  // final Map<String, dynamic> pet;
  final PetTable pet;

  // Constructor to receive pet data
  const PetDetailScreen({super.key, required this.pet});

  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen> {
  late PetTable pet; // Pet object to hold pet data

  List<Reminder> remindersTable = [];

  List<String> reminders = []; // List to hold reminders
  List<String> appointments = []; // List to hold appointments
  List<String> medications = [
    'Med A - April 1',
    'Med B - April 15',
  ]; // List to hold medication details
  List<String> vetHistories = [
    'Checkup - April 5',
    'Vaccine - March 25',
  ]; // List to hold vet history

  TextEditingController medicationController =
      TextEditingController(); // Controller for medication input
  TextEditingController vetHistoryController =
      TextEditingController(); // Controller for vet history input

  // Date and time variables for reminder
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  // List to store pet data (sample data for demonstration)
  List<Map<String, dynamic>> pets = [];

  // The selected pet, which is assigned from the list of pets
  Map<String, dynamic>? selectedPet;

  Future<void> loadReminders(int petId) async {
    final results = await ReminderDatabase().getRemindersByPetId(petId);
    setState(() {
      remindersTable = results;
    });
  }

  void _confirmDeletePet(BuildContext context, PetTable pet) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Pet'),
            content: Text(
              'Are you sure you want to delete ${pet.name}? This cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false), // Cancel
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true), // Confirm
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await PetTableDatabase().deletePetTable(pet);
      Navigator.pop(context); // Go back to the pet profile list
    }
  }

  @override
  void initState() {
    super.initState();

    // Sample data to demonstrate multiple pets
    pets = [
      {
        'name': 'Buddy',
        'breed': 'Golden Retriever',
        'age': 3,
        'image': 'assets/images/dog.png',
      },
      {
        'name': 'Max',
        'breed': 'Beagle',
        'age': 2,
        'image': 'assets/images/dog.png',
      },
    ];

    // Initialize selectedPet to the first pet if available
    if (pets.isNotEmpty) {
      selectedPet = pets[0];
    }
  }

  // Function to add a new reminder
  void addReminder(PetTable pet) {
    List<String> reminderTypes = [
      'Medications',
      'Feeding',
      'Grooming',
      'Exercise',
      'Adoption',
      'Medication Refill',
    ];

    String selectedReminderType = reminderTypes[0];
    TextEditingController localReminderController = TextEditingController();
    DateTime localSelectedDate = DateTime.now();
    TimeOfDay localSelectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 10,
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.teal.shade50,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Add Reminder',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    SizedBox(height: 16),

                    DropdownButton<String>(
                      value: selectedReminderType,
                      icon: Icon(Icons.arrow_drop_down, color: Colors.teal),
                      elevation: 16,
                      style: TextStyle(color: Colors.teal),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setModalState(() {
                            selectedReminderType = newValue;
                          });
                        }
                      },
                      items:
                          reminderTypes
                              .map(
                                (String value) => DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                ),
                              )
                              .toList(),
                    ),
                    SizedBox(height: 16),

                    SizedBox(
                      height: 100,
                      child: TextField(
                        controller: localReminderController,
                        decoration: InputDecoration(
                          labelText: 'Reminder Details',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                        ),
                        maxLines: null,
                        expands: true,
                      ),
                    ),
                    SizedBox(height: 16),

                    GestureDetector(
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: localSelectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null) {
                          setModalState(() {
                            localSelectedDate = picked;
                          });
                        }
                      },
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.teal),
                          SizedBox(width: 8),
                          Text(
                            'Date: ${localSelectedDate.month}/${localSelectedDate.day}/${localSelectedDate.year}',
                            style: TextStyle(fontSize: 16, color: Colors.teal),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),

                    GestureDetector(
                      onTap: () async {
                        TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: localSelectedTime,
                        );
                        if (picked != null) {
                          setModalState(() {
                            localSelectedTime = picked;
                          });
                        }
                      },
                      child: Row(
                        children: [
                          Icon(Icons.access_time, color: Colors.teal),
                          SizedBox(width: 8),
                          Text(
                            'Time: ${localSelectedTime.format(context)}',
                            style: TextStyle(fontSize: 16, color: Colors.teal),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            String reminderText =
                                localReminderController.text.trim();
                            if (reminderText.isEmpty) return;

                            // Combine date and time into DateTime
                            DateTime combinedDateTime = DateTime(
                              localSelectedDate.year,
                              localSelectedDate.month,
                              localSelectedDate.day,
                              localSelectedTime.hour,
                              localSelectedTime.minute,
                            );

                            // Create and insert Reminder
                            Reminder newReminder = Reminder(
                              petId: pet.id!,
                              type: selectedReminderType,
                              description: reminderText,
                              reminderDate: combinedDateTime,
                            );

                            await ReminderDatabase().createReminder(
                              newReminder,
                            );

                            // Reload the reminders from the database and update the UI
                            final updatedReminders = await ReminderDatabase()
                                .getRemindersByPetId(pet.id!);
                            setState(() {
                              remindersTable = updatedReminders;
                            });

                            Navigator.of(dialogContext).pop(); // Close dialog
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            padding: EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 10,
                            ),
                          ),
                          child: Text('Save'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop(); // Close dialog
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            padding: EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 10,
                            ),
                          ),
                          child: Text('Cancel'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void addAppointment() {
    // List of available appointment types
    List<String> appointmentTypes = [
      'Vaccination',
      'Check Up',
      'Spay/Neuter',
      'Dental Care',
      'Grooming',
      'Sick Visit',
      'Emergency Visit',
    ];

    // Default selected appointment type is the first in the list
    String selectedAppointmentType = appointmentTypes[0];

    // Initialize default appointment date and time
    DateTime appointmentDate = DateTime.now(); // Default to current date
    TimeOfDay appointmentTime = TimeOfDay.now(); // Default to current time

    // Controllers for appointment details and location input fields
    final TextEditingController localAppointmentController =
        TextEditingController();
    final TextEditingController locationController = TextEditingController();

    // Show a dialog to input appointment details
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 10,
              child: Container(
                width: 400,
                // Set the dialog width
                constraints: BoxConstraints(minHeight: 300),
                // Set a minimum height
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.teal.shade50,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Add Appointment',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Dropdown button for selecting the appointment type
                    DropdownButton<String>(
                      value: selectedAppointmentType,
                      icon: Icon(Icons.arrow_drop_down, color: Colors.teal),
                      elevation: 16,
                      style: TextStyle(color: Colors.teal),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setModalState(() {
                            selectedAppointmentType = newValue;
                          });
                        }
                      },
                      items:
                          appointmentTypes.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                    ),
                    SizedBox(height: 16),

                    // TextField for entering appointment details
                    SizedBox(
                      height: 50, // Set the desired height
                      child: TextField(
                        controller: localAppointmentController,
                        decoration: InputDecoration(
                          labelText: 'Appointment Details', // Floating label
                          border: OutlineInputBorder(), // Default border
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ), // Padding inside the TextField
                        ),
                        maxLines: null,
                        // Allow the TextField to expand vertically
                        expands:
                            true, // Make the TextField expand to fill the space
                      ),
                    ),
                    SizedBox(height: 16),

                    // TextField for entering location details
                    TextField(
                      controller: locationController,
                      decoration: InputDecoration(
                        labelText: 'Location',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),

                    // GestureDetector to open date picker for selecting appointment date
                    GestureDetector(
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: appointmentDate,
                          // Default to current date
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null && picked != appointmentDate) {
                          setModalState(() {
                            appointmentDate = picked;
                          });
                        }
                      },
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.teal),
                          SizedBox(width: 8),
                          Text(
                            'Date: ${appointmentDate.month}/${appointmentDate.day}/${appointmentDate.year}',
                            style: TextStyle(fontSize: 16, color: Colors.teal),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),

                    // GestureDetector to open time picker for selecting appointment time
                    GestureDetector(
                      onTap: () async {
                        TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime:
                              appointmentTime, // Default to current time
                        );
                        if (picked != null && picked != appointmentTime) {
                          setModalState(() {
                            appointmentTime = picked;
                          });
                        }
                      },
                      child: Row(
                        children: [
                          Icon(Icons.access_time, color: Colors.teal),
                          SizedBox(width: 8),
                          Text(
                            'Time: ${appointmentTime.format(context)}',
                            // Safe to use format
                            style: TextStyle(fontSize: 16, color: Colors.teal),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),

                    // Buttons to save or cancel the appointment
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            String details =
                                localAppointmentController.text.trim();
                            String location = locationController.text.trim();

                            if (details.isEmpty || location.isEmpty) return;

                            // Create a new appointment string with the selected details
                            String newAppointment =
                                '$selectedAppointmentType - $details at $location on ${appointmentDate.month}/${appointmentDate.day}/${appointmentDate.year} at ${appointmentTime.format(context)}';

                            setState(() {
                              appointments.add(
                                newAppointment,
                              ); // Add appointment to list
                            });

                            Navigator.of(dialogContext).pop(); // Close dialog
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            padding: EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 10,
                            ),
                          ),
                          child: Text('Save'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(
                              dialogContext,
                            ).pop(); // Cancel and close the dialog
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            padding: EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 10,
                            ),
                          ),
                          child: Text('Cancel'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Function to add a medication to the medications list
  void addMedication() {
    setState(() {
      // Add the medication entered in the text controller to the list
      medications.add(medicationController.text);

      // Clear the text controller after adding the medication
      medicationController.clear();
    });
  }

  // Function to add a vet history entry to the vetHistories list
  void addVetHistory() {
    setState(() {
      // Add the vet history entered in the text controller to the list
      vetHistories.add(vetHistoryController.text);

      // Clear the text controller after adding the vet history entry
      vetHistoryController.clear();
    });
  }

  // Function to parse a time string in the format "hh:mm AM/PM" to a TimeOfDay object
  TimeOfDay? parseTimeOfDay(String timeString) {
    final format = RegExp(
      r'(\d+):(\d+)\s*(AM|PM)',
    ); // Regular expression to match the time format
    final match = format.firstMatch(
      timeString,
    ); // Attempt to find a match in the input string

    if (match != null) {
      // Extract the hour, minute, and period (AM/PM) from the match groups
      int hour = int.parse(match.group(1)!);
      int minute = int.parse(match.group(2)!);
      String period = match.group(3)!;

      // Adjust hour based on AM/PM format
      if (period == 'PM' && hour != 12) hour += 12; // Convert PM times
      if (period == 'AM' && hour == 12) hour = 0; // Convert 12 AM to 0 hour

      // Return a TimeOfDay object with the parsed hour and minute
      return TimeOfDay(hour: hour, minute: minute);
    }

    // If the time string doesn't match the expected format, return null
    return null;
  }

  // Function to edit a reminder at the specified index in the reminders list
  void editReminder(int index) {
    Reminder reminder = remindersTable[index];

    String selectedReminderType = reminder.type;
    DateTime selectedDate = reminder.reminderDate;
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(reminder.reminderDate);
    final TextEditingController localReminderController = TextEditingController(
      text: reminder.description,
    );

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 10,
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.teal.shade50,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Edit Reminder',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Dropdown
                    DropdownButton<String>(
                      value: selectedReminderType,
                      icon: Icon(Icons.arrow_drop_down, color: Colors.teal),
                      elevation: 16,
                      style: TextStyle(color: Colors.teal),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setModalState(() {
                            selectedReminderType = newValue;
                          });
                        }
                      },
                      items:
                          [
                            'Medications',
                            'Feeding',
                            'Grooming',
                            'Exercise',
                            'Adoption',
                            'Medication Refill',
                          ].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                    ),
                    SizedBox(height: 20),

                    // TextField
                    SizedBox(
                      height: 100,
                      child: TextField(
                        controller: localReminderController,
                        decoration: InputDecoration(
                          labelText: 'Reminder Details',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                        ),
                        maxLines: null,
                        expands: true,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Date picker
                    GestureDetector(
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null) {
                          setModalState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.teal),
                          SizedBox(width: 8),
                          Text(
                            'Date: ${selectedDate.month}/${selectedDate.day}/${selectedDate.year}',
                            style: TextStyle(fontSize: 16, color: Colors.teal),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),

                    // Time picker
                    GestureDetector(
                      onTap: () async {
                        TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );
                        if (picked != null) {
                          setModalState(() {
                            selectedTime = picked;
                          });
                        }
                      },
                      child: Row(
                        children: [
                          Icon(Icons.access_time, color: Colors.teal),
                          SizedBox(width: 8),
                          Text(
                            'Time: ${selectedTime.format(context)}',
                            style: TextStyle(fontSize: 16, color: Colors.teal),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),

                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            String newDetails =
                                localReminderController.text.trim();
                            if (newDetails.isEmpty) return;

                            DateTime combinedDateTime = DateTime(
                              selectedDate.year,
                              selectedDate.month,
                              selectedDate.day,
                              selectedTime.hour,
                              selectedTime.minute,
                            );

                            // Update locally
                            Reminder updatedReminder = reminder.copyWith(
                              type: selectedReminderType,
                              description: newDetails,
                              reminderDate: combinedDateTime,
                            );

                            try {
                              await ReminderDatabase().updateReminder(
                                updatedReminder,
                              );

                              // Update in UI
                              setState(() {
                                remindersTable[index] = updatedReminder;
                              });

                              Navigator.of(dialogContext).pop();
                            } catch (e) {
                              print('Failed to update reminder: $e');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            padding: EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 10,
                            ),
                          ),
                          child: Text('Save'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            padding: EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 10,
                            ),
                          ),
                          child: Text('Cancel'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // This function is used to build a reminder card with edit and delete options.
  Widget _buildReminderCard(
    Reminder reminder,
    VoidCallback onEdit,
    VoidCallback onDelete,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(Icons.notification_important, color: Colors.teal),
        title: Text(
          reminder.type,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(reminder.description),
            SizedBox(height: 4),
            Text(
              'Date: ${reminder.reminderDate.toLocal().toString().split('.')[0]}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.teal),
              onPressed: onEdit,
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  // Function to edit an appointment by index
  void editAppointment(int index) {
    // Get the appointment details from the appointments list using the index
    String appointment = appointments[index];

    // Split the appointment string into its components (e.g., type, details, date)
    List<String> appointmentParts = appointment.split(' - ');
    if (appointmentParts.length < 2) {
      return; // Exit if the string format is invalid
    }

    String selectedAppointmentType =
        appointmentParts[0]; // Extract appointment type (e.g., Vaccination)
    String detailsAndDate = appointmentParts[1]; // Extract details and date

    // Split the details and date part into further components (details and location, date/time)
    List<String> detailsParts = detailsAndDate.split(' on ');
    String detailsAndLocationPart = detailsParts[0];
    String dateTimePart = detailsParts.length > 1 ? detailsParts[1] : '';

    // Split details and location by 'at' to separate details and location
    List<String> detailsAndLocation = detailsAndLocationPart.split(' at ');
    String appointmentDetails =
        detailsAndLocation[0]; // Appointment details (e.g., "Checkup")
    String location = detailsAndLocation[1]; // Location (e.g., "Clinic")

    // Parse the date and time if present
    if (dateTimePart.contains(' at ')) {
      List<String> dateAndTime = dateTimePart.split(
        ' at ',
      ); // Separate date and time
      String datePart = dateAndTime[0]; // Date part (e.g., "4/28")
      String timePart = dateAndTime[1]; // Time part (e.g., "6:30 PM")

      // Parse the date
      List<String> dateSplit = datePart.split('/');
      if (dateSplit.length == 2) {
        int month = int.parse(dateSplit[0]);
        int day = int.parse(dateSplit[1]);
        selectedDate = DateTime(
          DateTime.now().year,
          month,
          day,
        ); // Store the selected date
      }

      // Parse the time
      TimeOfDay? parsedTime = parseTimeOfDay(
        timePart,
      ); // Custom function to parse time
      if (parsedTime != null) {
        selectedTime = parsedTime; // Store the selected time
      }
    }

    // Controllers to manage text input fields for details and location
    final TextEditingController localDetailsController =
        TextEditingController();
    final TextEditingController locationController = TextEditingController();

    // Set the initial text values for the input fields
    localDetailsController.text = appointmentDetails;
    locationController.text = location;

    // Show a dialog to edit the appointment details
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ), // Round corners
              elevation: 10, // Add elevation for shadow effect
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.teal.shade50, // Light teal background
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  // Ensure the dialog is as small as possible
                  children: [
                    Text(
                      'Edit Appointment',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Dropdown for selecting the appointment type
                    DropdownButton<String>(
                      value: selectedAppointmentType,
                      icon: Icon(Icons.arrow_drop_down, color: Colors.teal),
                      elevation: 16,
                      style: TextStyle(color: Colors.teal, fontSize: 16),
                      underline: Container(height: 2, color: Colors.teal),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setModalState(() {
                            selectedAppointmentType =
                                newValue; // Update the appointment type
                          });
                        }
                      },
                      items:
                          [
                            'Vaccination',
                            'Check Up',
                            'Spay/Neuter',
                            'Dental Care',
                            'Grooming',
                            'Sick Visit',
                            'Emergency Visit',
                          ].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                    ),

                    // Text field for entering details of the appointment
                    TextField(
                      controller: localDetailsController,
                      decoration: InputDecoration(
                        labelText: 'Details',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Text field for entering location of the appointment
                    TextField(
                      controller: locationController,
                      decoration: InputDecoration(
                        labelText: 'Location',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Gesture detector to allow the user to select a date
                    GestureDetector(
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null && picked != selectedDate) {
                          setModalState(() {
                            selectedDate = picked; // Update selected date
                          });
                        }
                      },
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.teal),
                          SizedBox(width: 8),
                          Text(
                            'Date: ${selectedDate.month}/${selectedDate.day}/${selectedDate.year}',
                            style: TextStyle(fontSize: 16, color: Colors.teal),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),

                    // Gesture detector to allow the user to select a time
                    GestureDetector(
                      onTap: () async {
                        TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );
                        if (picked != null && picked != selectedTime) {
                          setModalState(() {
                            selectedTime = picked; // Update selected time
                          });
                        }
                      },
                      child: Row(
                        children: [
                          Icon(Icons.access_time, color: Colors.teal),
                          SizedBox(width: 8),
                          Text(
                            'Time: ${selectedTime.format(context)}',
                            style: TextStyle(fontSize: 16, color: Colors.teal),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),

                    // Row with buttons to save or cancel the appointment edit
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Save button to confirm changes
                        ElevatedButton(
                          onPressed: () {
                            String details = localDetailsController.text.trim();
                            String location = locationController.text.trim();

                            // Check if both fields are filled before saving
                            if (details.isEmpty || location.isEmpty) {
                              return; // Don't save if fields are empty
                            }

                            // Create the updated appointment string
                            String updatedAppointment =
                                '$selectedAppointmentType - $details at $location on ${selectedDate.month}/${selectedDate.day}/${selectedDate.year} at ${selectedTime.format(context)}';

                            // Update the appointment in the list
                            setState(() {
                              appointments[index] = updatedAppointment;
                            });

                            // Close the dialog
                            Navigator.of(dialogContext).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            padding: EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 10,
                            ),
                          ),
                          child: Text('Save'),
                        ),
                        // Cancel button to discard changes
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(
                              dialogContext,
                            ).pop(); // Close the dialog without saving
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            padding: EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 10,
                            ),
                          ),
                          child: Text('Cancel'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // This function builds an appointment card widget, displaying the appointment text
  // and providing edit and delete actions through icons in the trailing section.
  Widget _buildAppointmentCard(
    String appointmentText,
    // The text to be displayed in the appointment card
    Function onEdit, // Callback function to trigger the edit action
    Function onDelete, // Callback function to trigger the delete action
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      // Rounded corners for the card
      elevation: 5,
      // Shadow effect for elevation
      margin: EdgeInsets.symmetric(vertical: 8),
      // Vertical margin between cards
      child: ListTile(
        leading: Icon(Icons.notification_important, color: Colors.teal),
        // Icon displayed on the left
        title: Text(appointmentText),
        // Text to display the appointment details
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          // Ensure the icons only take up the necessary space
          children: [
            // Edit button
            IconButton(
              icon: Icon(Icons.edit, color: Colors.teal), // Edit icon in teal
              onPressed: () {
                onEdit(); // Calls the onEdit function passed as a parameter to trigger the edit process
              },
            ),
            // Delete button
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red), // Delete icon in red
              onPressed: () {
                onDelete(); // Calls the onDelete function passed as a parameter to trigger the delete process
              },
            ),
          ],
        ),
      ),
    );
  }

  // This function deletes a reminder from the reminders list at the specified index.
  void deleteReminder(int index) async {
    if (index < 0 || index >= remindersTable.length) {
      print('Invalid index: $index');
      return;
    }

    final reminderToDelete = remindersTable[index];

    try {
      // Delete from Supabase
      await ReminderDatabase().deleteReminder(reminderToDelete.id.toString());

      // Remove from local list and update UI
      setState(() {
        remindersTable.removeAt(index);
      });

      print('Reminder deleted successfully');
    } catch (e) {
      print('Error deleting reminder: $e');
      // Optional: Show a snackbar or dialog
    }
  }

  // This function deletes an appointment from the appointments list at the specified index.
  void deleteAppointment(int index) {
    setState(() {
      appointments.removeAt(
        index,
      ); // Removes the appointment from the list at the given index
    });
  }

  // This function deletes a medication from the medications list at the specified index.
  void deleteMedication(int index) {
    setState(() {
      medications.removeAt(
        index,
      ); // Removes the medication from the list at the given index
    });
  }

  // This function deletes a vet history record from the vetHistories list at the specified index.
  void deleteVetHistory(int index) {
    setState(() {
      vetHistories.removeAt(
        index,
      ); // Removes the vet history from the list at the given index
    });
  }

  // Show Settings Dialog with Edit and Archive options
  // This function shows a dialog to edit the pet profile.
  // It takes the pet details, context, and a callback function to update the pet data.
  void _showSettingsDialog(
    BuildContext context,
    PetTable pet,
    PetTableDatabase db,
    Function() onUpdateDone,
  ) {
    final nameController = TextEditingController(text: pet.name);
    final speciesController = TextEditingController(text: pet.species);
    final breedController = TextEditingController(text: pet.breed);
    final ageController = TextEditingController(text: pet.age.toString());
    final statusController = TextEditingController(text: pet.status);
    final weightController = TextEditingController(text: pet.weight.toString());
    final bloodController = TextEditingController(text: pet.blood);
    final allergyController = TextEditingController(text: pet.allergy);
    final markController = TextEditingController(text: pet.mark);
    XFile? newPickedImage;
    final ImagePicker picker = ImagePicker();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Center(
                child: Text(
                  "Edit Pet Profile",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ),
              content: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final picked = await picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (picked != null) {
                            setState(() {
                              newPickedImage = picked;
                            });
                          }
                        },
                        child: CircleAvatar(
                          radius: 45,
                          backgroundImage:
                              newPickedImage != null
                                  ? FileImage(File(newPickedImage!.path))
                                  : (pet.image != null && pet.image!.isNotEmpty
                                          ? FileImage(File(pet.image!))
                                          : const AssetImage(
                                            'assets/images/dog.png',
                                          ))
                                      as ImageProvider,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: nameController,
                        label: 'Pet Name',
                        icon: Icons.pets,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: speciesController,
                        label: 'Species',
                        icon: Icons.pets,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: breedController,
                        label: 'Breed',
                        icon: Icons.pets,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: ageController,
                        label: 'Age (Years)',
                        icon: Icons.cake,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: statusController,
                        label: 'Reproductive Status',
                        icon: Icons.favorite,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: weightController,
                        label: 'Weight (kg)',
                        icon: Icons.monitor_weight,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: bloodController,
                        label: 'Blood Type',
                        icon: Icons.bloodtype,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: allergyController,
                        label: 'Allergies',
                        icon: Icons.warning,
                        required: false,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: markController,
                        label: 'Distinctive Mark',
                        icon: Icons.local_offer,
                        required: false,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    // Update the database
                    await db.updatePetTable(
                      pet,
                      nameController.text,
                      speciesController.text,
                      breedController.text,
                      int.tryParse(ageController.text) ?? 0,
                      statusController.text,
                      int.tryParse(weightController.text) ?? 0,
                      bloodController.text,
                      allergyController.text,
                      markController.text,
                      newPickedImage?.path ?? pet.image,
                    );

                    // Callback to refresh view
                    onUpdateDone();

                    Navigator.of(context).pop();
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // This function builds a customized TextFormField widget.
  // It allows for creating text fields with labels, icons, and validation.
  Widget _buildTextField({
    required TextEditingController
    controller, // Controller for managing the text input
    required String label, // Label for the text field
    required IconData icon, // Icon to display inside the text field
    TextInputType keyboardType =
        TextInputType.text, // Keyboard type (default is text)
    int maxLines = 1, // Number of lines for the text field (default is 1)
    bool required =
        true, // Whether the field is required or not (default is true)
  }) {
    return TextFormField(
      controller: controller,
      // Assigning the controller to manage the text input
      keyboardType: keyboardType,
      // Setting the appropriate keyboard type
      maxLines: maxLines,
      // Setting the number of lines (e.g., for multiline input)
      decoration: InputDecoration(
        labelText: label,
        // Displaying the label text above the field
        prefixIcon: Icon(icon, color: Colors.teal),
        // Icon inside the text field
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        // Rounded border for the field
        filled: true,
        // Enable the field's background color
        fillColor: Colors.grey.shade100,
        // Background color of the text field
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ), // Padding inside the field
      ),
      // Validator for checking if the field is required and if it's empty
      validator:
          required
              ? (value) =>
                  value!.trim().isEmpty
                      ? 'Please enter $label'
                      : null // If required, show validation message if empty
              : null, // No validation if not required
    );
  }

  // Widget to build the Medications and Vet History Card
  // It accepts the history text, icon, and delete function to display a card for each history item
  Widget _buildHistoryCard(
    String historyText,
    // Text to display on the card (medication or vet history info)
    IconData icon,
    // Icon to represent the type of history (medication or vet history)
    Function() onDelete,
    // Function to handle the deletion of the history item
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5, // Adds shadow for the card
      margin: EdgeInsets.symmetric(vertical: 8), // Margin between cards
      child: ListTile(
        leading: Icon(icon, color: Colors.teal),
        // Icon on the left side of the card
        title: Text(historyText),
        // Display the history text
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          // Delete icon on the right
          onPressed: onDelete, // Calls the onDelete function when pressed
        ),
      ),
    );
  }

  bool _didLoadReminders = false;

  @override
  Widget build(BuildContext context) {
    // Get the selected pet or use the passed pet from the widget
    final pet = widget.pet;
    PetTable currentPet = pet;

    return Scaffold(
      appBar: AppBar(
        title: Text('Pet Profile'), // AppBar title
        backgroundColor: Colors.teal, // AppBar background color
        actions: [
          // Settings button to edit pet profile
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              _showSettingsDialog(
                context,
                currentPet, // This must be a PetTable object, not a Map
                PetTableDatabase(), // Create an instance of PetTableDatabase
                () {
                  setState(() {
                    // Re-fetch or reload the pet list if needed
                  });
                },
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _confirmDeletePet(context, pet);
            },
          ),
        ],
      ),
      body: StreamBuilder<PetTable>(
        stream: PetTableDatabase().watchPetById(pet.id!),
        initialData: pet,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return Center(child: Text('Pet not found'));
          }

          currentPet = snapshot.data!;

          if (!_didLoadReminders) {
            _didLoadReminders = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              loadReminders(currentPet.id!);
            });
          }

          return SingleChildScrollView(
            // Scrollable content for pet profile
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Pet profile image
                CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      currentPet.image != null
                          ? (currentPet.image!.startsWith('http')
                              ? NetworkImage(currentPet.image!)
                              : FileImage(File(currentPet.image!))
                                  as ImageProvider)
                          : AssetImage('assets/images/dog.png'),
                ),
                SizedBox(height: 16),
                // Pet name and breed/age info
                Text(
                  currentPet.name,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text('${currentPet.breed} • ${currentPet.age} years'),
                SizedBox(height: 20),

                // Reminders section with add button
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Reminders',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          addReminder(
                            currentPet,
                          ); // Trigger the add reminder function
                        },
                      ),
                    ],
                  ),
                ),
                // Display list of reminders
                ListView.builder(
                  shrinkWrap: true,
                  physics:
                      NeverScrollableScrollPhysics(), // Prevent scroll conflict
                  itemCount: remindersTable.length,
                  itemBuilder: (context, index) {
                    return _buildReminderCard(
                      remindersTable[index],
                      () => editReminder(index),
                      () => deleteReminder(index),
                    );
                  },
                ),

                SizedBox(height: 20),

                // Appointments section with add button
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Appointments',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          addAppointment(); // Trigger the add appointment function
                        },
                      ),
                    ],
                  ),
                ),
                // Display list of appointments
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    return _buildAppointmentCard(
                      appointments[index],
                      () => editAppointment(index), // Edit appointment function
                      () => deleteAppointment(
                        index,
                      ), // Delete appointment function
                    );
                  },
                ),

                SizedBox(height: 20),

                // Previous Medications section
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Previous Medications',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                // Display list of medications
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: medications.length,
                  itemBuilder: (context, index) {
                    return _buildHistoryCard(
                      medications[index],
                      Icons.medical_services, // Medication icon
                      () =>
                          deleteMedication(index), // Delete medication function
                    );
                  },
                ),

                // Vet History section
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Vet History',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                // Display list of vet histories
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: vetHistories.length,
                  itemBuilder: (context, index) {
                    return _buildHistoryCard(
                      vetHistories[index],
                      Icons.healing, // Vet history icon
                      () => deleteVetHistory(
                        index,
                      ), // Delete vet history function
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
