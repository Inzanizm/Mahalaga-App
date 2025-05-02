import 'package:mahalaga_app/database/reminder.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReminderDatabase {
  final database = Supabase.instance.client.from('reminders');

  // Create
  Future<void> createReminder(Reminder reminder) async {
    try {
      await database.insert(reminder.toMap());
      print('Reminder added successfully');
    } catch (e) {
      print('Failed to insert reminder: $e');
    }
  }

  // Read reminders for a specific pet
  Future<List<Reminder>> getRemindersByPetId(int petId) async {
    try {
      final response = await database
          .select()
          .eq('pet_id', petId)
          .order('reminder_date');
      return (response as List)
          .map((map) => Reminder.fromMap(map as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching reminders: $e');
      return [];
    }
  }

  // Delete
  Future<void> deleteReminder(String reminderId) async {
    try {
      await database.delete().eq('id', reminderId);
    } catch (e) {
      print('Failed to delete reminder: $e');
    }
  }

  Future<void> updateReminder(Reminder updatedReminder) async {
    if (updatedReminder.id == null) {
      throw Exception('Reminder ID cannot be null');
    }

    try {
      // Create update map with only the fields we want to update
      final Map<String, dynamic> updateData = {
        'description': updatedReminder.description,
        'type': updatedReminder.type,
        'reminder_date': updatedReminder.reminderDate.toIso8601String(),
      };

      // Execute the update operation
      await database.update(updateData).eq('id', updatedReminder.id!);

      print('Reminder updated successfully');
    } catch (e) {
      // Log the error with more detail
      print('Error in updateReminder: $e');
      // Rethrow the original exception
      rethrow;
    }
  }
}
