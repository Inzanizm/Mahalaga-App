import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:mahalaga_app/data/notifiers.dart';
import 'package:mahalaga_app/data/selected_pet_data.dart';

class PetDetailScreen extends StatefulWidget {
  final Map<String, dynamic> pet;

  // Constructor to receive pet data
  const PetDetailScreen({super.key, required this.pet});

  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen> {
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
  void addReminder() {
    // List of reminder types (e.g., medication, grooming)
    List<String> reminderTypes = [
      'Medications',
      'Feeding',
      'Grooming',
      'Exercise',
      'Adoption',
      'Medication Refill',
    ];

    // Initial state for the reminder dialog (default reminder type, controller for text input, etc.)
    String selectedReminderType = reminderTypes[0];
    TextEditingController localReminderController = TextEditingController();
    DateTime localSelectedDate = DateTime.now(); // Set current date initially
    TimeOfDay localSelectedTime = TimeOfDay.now(); // Set current time initially

    // Show dialog to add reminder
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

                    // Dropdown menu for selecting reminder type
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
                          reminderTypes.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                    ),
                    SizedBox(height: 16),

                    // TextField for entering reminder details
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

                    // Date picker for selecting date
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

                    // Time picker for selecting time
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

                    // Save and Cancel buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // Save the reminder if it's valid
                            String reminderText =
                                localReminderController.text.trim();
                            if (reminderText.isEmpty) return;

                            String fullReminder =
                                '$selectedReminderType - $reminderText on ${localSelectedDate.month}/${localSelectedDate.day} at ${localSelectedTime.format(context)}';

                            setState(() {
                              reminders.add(
                                fullReminder,
                              ); // Add reminder to list
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
    // Example reminder format: "Feeding - Chicken meal on 4/28 at 6:30 PM"
    String reminder = reminders[index]; // Get the reminder at the given index
    List<String> reminderParts = reminder.split(
      ' - ',
    ); // Split the reminder into parts
    if (reminderParts.length < 2) {
      return; // If the reminder format is invalid, return
    }

    String selectedReminderType =
        reminderParts[0]; // Get the reminder type (e.g., Feeding)
    String detailsAndDate = reminderParts[1]; // Get the details and date part

    // Split the details and date part into reminder details and date-time
    List<String> detailsParts = detailsAndDate.split(' on ');
    String reminderDetails =
        detailsParts[0]; // Extract the reminder details (e.g., "Chicken meal")
    String dateTimePart =
        detailsParts.length > 1 ? detailsParts[1] : ''; // Extract date and time

    // Try to extract the date and time from the dateTimePart
    if (dateTimePart.contains(' at ')) {
      List<String> dateAndTime = dateTimePart.split(' at ');
      String datePart = dateAndTime[0]; // Extract date (e.g., "4/28")
      String timePart = dateAndTime[1]; // Extract time (e.g., "6:30 PM")

      // Parse the date
      List<String> dateSplit = datePart.split('/');
      if (dateSplit.length == 2) {
        int month = int.parse(dateSplit[0]);
        int day = int.parse(dateSplit[1]);
        selectedDate = DateTime(
          DateTime.now().year,
          month,
          day,
        ); // Set the selected date
      }

      // Parse the time
      TimeOfDay? parsedTime = parseTimeOfDay(timePart);
      if (parsedTime != null) {
        selectedTime = parsedTime; // Set the selected time
      }
    }

    // Text controller for editing the reminder's details
    final TextEditingController localReminderController =
        TextEditingController();
    localReminderController.text =
        reminderDetails; // Set the current reminder details in the text field

    // Show the dialog to edit the reminder
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  15.0,
                ), // Rounded corners for the dialog
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

                    // Dropdown for selecting reminder type (e.g., Medications, Feeding)
                    DropdownButton<String>(
                      value: selectedReminderType,
                      icon: Icon(Icons.arrow_drop_down, color: Colors.teal),
                      elevation: 16,
                      style: TextStyle(color: Colors.teal),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setModalState(() {
                            selectedReminderType =
                                newValue; // Update the selected reminder type
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

                    // TextField for entering reminder details
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
                        maxLines: null, // Allows multi-line input
                        expands:
                            true, // Makes the text field expand to fill the available space
                      ),
                    ),
                    SizedBox(height: 16),

                    // Date picker for selecting the reminder date
                    GestureDetector(
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          // Use the currently selected date
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null && picked != selectedDate) {
                          setModalState(() {
                            selectedDate = picked; // Update the selected date
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

                    // Time picker for selecting the reminder time
                    GestureDetector(
                      onTap: () async {
                        TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime:
                              selectedTime, // Use the currently selected time
                        );
                        if (picked != null && picked != selectedTime) {
                          setModalState(() {
                            selectedTime = picked; // Update the selected time
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

                    // Buttons to save or cancel the changes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            String newReminderDetail =
                                localReminderController.text.trim();
                            if (newReminderDetail.isEmpty) return;

                            // Format the updated reminder with type, details, date, and time
                            String updatedReminder =
                                '$selectedReminderType - $newReminderDetail on ${selectedDate.month}/${selectedDate.day} at ${selectedTime.format(context)}';

                            setState(() {
                              reminders[index] =
                                  updatedReminder; // Update the reminder in the list
                            });

                            Navigator.of(
                              dialogContext,
                            ).pop(); // Close the dialog
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

  // This function is used to build a reminder card with edit and delete options.
  _buildReminderCard(String reminderText, Function onEdit, Function onDelete) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      // Rounded corners for the card
      elevation: 5,
      // Card shadow for a slight elevation effect
      margin: EdgeInsets.symmetric(vertical: 8),
      // Vertical margin between cards
      child: ListTile(
        leading: Icon(Icons.notification_important, color: Colors.teal),
        // Icon at the start of the card
        title: Text(reminderText),
        // Display the reminder text
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          // Align buttons to the right of the card
          children: [
            // Edit button to show the Edit Reminder dialog when pressed
            IconButton(
              icon: Icon(Icons.edit, color: Colors.teal),
              onPressed: () {
                onEdit(); // Call the provided onEdit function to open the edit dialog
              },
            ),
            // Delete button to trigger the delete logic when pressed
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                onDelete(); // Call the provided onDelete function to handle the delete action
              },
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
  void deleteReminder(int index) {
    setState(() {
      reminders.removeAt(
        index,
      ); // Removes the reminder from the list at the given index
    });
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
    int index,
    Map<String, dynamic> pet,
    Function(Map<String, dynamic>) onPetUpdated,
  ) {
    // Text controllers initialized with the current pet details
    final nameController = TextEditingController(text: pet['name']);
    final speciesController = TextEditingController(text: pet['species']);
    final breedController = TextEditingController(text: pet['breed']);
    final ageController = TextEditingController(text: pet['age']);
    final statusController = TextEditingController(text: pet['status']);
    final weightController = TextEditingController(text: pet['weight']);
    final bloodController = TextEditingController(text: pet['blood']);
    final allergyController = TextEditingController(text: pet['allergy']);
    final markController = TextEditingController(text: pet['mark']);
    XFile? newPickedImage;
    final ImagePicker picker = ImagePicker();

    // Show dialog to edit pet profile
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Center(
                child: Text(
                  "Edit Pet Profile", // Dialog title
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
                      // Profile image picker (tap to select new image)
                      GestureDetector(
                        onTap: () async {
                          final picked = await picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (picked != null) {
                            setState(() {
                              newPickedImage =
                                  picked; // Update image if new image picked
                            });
                          }
                        },
                        child: CircleAvatar(
                          radius: 45,
                          backgroundImage:
                              newPickedImage != null
                                  ? FileImage(
                                    File(newPickedImage!.path),
                                  ) // New image if available
                                  : pet['image'] != null
                                  ? FileImage(
                                    File(pet['image']),
                                  ) // Existing image if available
                                  : AssetImage('assets/images/dog.png')
                                      as ImageProvider, // Default image
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Text fields for editing pet details (using _buildTextField style)
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
                // Cancel button to close the dialog without saving changes
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                // Save button to save changes and return updated pet details
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    final updatedPet = {
                      'name': nameController.text,
                      'species': speciesController.text,
                      'breed': breedController.text,
                      'age': ageController.text,
                      'status': statusController.text,
                      'weight': weightController.text,
                      'blood': bloodController.text,
                      'allergy': allergyController.text,
                      'mark': markController.text,
                      'image': newPickedImage?.path ?? pet['image'],
                      // Use new image if available, else use old one
                    };

                    // Update the selected pet data
                    SelectedPetData.selectedPet = updatedPet; // ✅
                    Navigator.of(
                      context,
                    ).pop(updatedPet); // Return updated pet details
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

  @override
  Widget build(BuildContext context) {
    // Get the selected pet or use the passed pet from the widget
    final pet = SelectedPetData.selectedPet ?? widget.pet;

    return ValueListenableBuilder<Map<String, dynamic>?>(
      valueListenable: SelectedPetData.selectedPetNotifier,
      builder: (context, pet, child) {
        final currentPet =
            pet ?? widget.pet; // Use the selected pet or the passed pet

        return Scaffold(
          appBar: AppBar(
            title: Text('Pet Profile'), // AppBar title
            backgroundColor: Colors.teal, // AppBar background color
            actions: [
              // Settings button to edit pet profile
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {
                  // Ensure pet is non-null before proceeding
                  if (pet != null) {
                    // Show settings dialog to edit pet profile
                    _showSettingsDialog(context, pets.indexOf(pet), pet!, (
                      updatedPet,
                    ) {
                      setState(() {
                        final index = pets.indexOf(pet);
                        pets[index] = updatedPet;
                        petListNotifier.value[index] = updatedPet;
                        petListNotifier
                            .notifyListeners(); // Make sure listeners update
                        SelectedPetData.selectedPet = updatedPet;
                      });
                    });
                  }
                },
              ),
            ],
          ),
          body:
              selectedPet == null
                  ? Center(
                    child: Text('No pet selected'),
                  ) // Show message if no pet is selected
                  : SingleChildScrollView(
                    // Scrollable content for pet profile
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Pet profile image
                        CircleAvatar(
                          radius: 60,
                          backgroundImage:
                              pet?['image'] != null
                                  ? NetworkImage(
                                    pet?['image'],
                                  ) // Show image if available
                                  : AssetImage('assets/images/dog.png')
                                      as ImageProvider, // Default image
                        ),
                        SizedBox(height: 16),
                        // Pet name and breed/age info
                        Text(
                          pet?['name'] ?? 'Unknown',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text('${pet?['breed']} • ${pet?['age']} years'),
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
                                  addReminder(); // Trigger the add reminder function
                                },
                              ),
                            ],
                          ),
                        ),
                        // Display list of reminders
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: reminders.length,
                          itemBuilder: (context, index) {
                            return _buildReminderCard(
                              reminders[index],
                              () =>
                                  editReminder(index), // Edit reminder function
                              () => deleteReminder(
                                index,
                              ), // Delete reminder function
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
                              () => editAppointment(
                                index,
                              ), // Edit appointment function
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
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
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
                              () => deleteMedication(
                                index,
                              ), // Delete medication function
                            );
                          },
                        ),

                        // Vet History section
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Vet History',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
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
                  ),
        );
      },
    );
  }
}
