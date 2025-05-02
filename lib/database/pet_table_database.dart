import 'dart:async';

import 'package:mahalaga_app/database/pet_table.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PetTableDatabase {
  final database = Supabase.instance.client.from('pet_table');

  // Create
  Future createPetTable(PetTable newPet) async {
    try {
      await database.insert(newPet.toMap());
      print('Pet added successfully');
    } catch (e) {
      print('Failed to insert pet: $e');
    }
  }

  // Read
  final stream = Supabase.instance.client
      .from('pet_table')
      .stream(primaryKey: ['id'])
      .map((data) => data.map((petMap) => PetTable.fromMap(petMap)).toList());

  // Update
  Future updatePetTable(
    PetTable oldpet,
    String newName,
    String newSpecies,
    String newBreed,
    int newAge,
    String newStatus,
    int newWeight,
    String newBlood,
    String newAllergy,
    String newMark,
    String? newImage,
  ) async {
    try {
      await database
          .update({
            'name': newName,
            'species': newSpecies,
            'breed': newBreed,
            'age': newAge,
            'status': newStatus,
            'weight': newWeight,
            'blood': newBlood,
            'allergy': newAllergy,
            'mark': newMark,
            'image': newImage,
          })
          .eq('id', oldpet.id!);
    } catch (e) {
      print('Error updating pet: $e');
      // Optionally, rethrow or handle error accordingly
      // throw Exception('Failed to update pet');
    }
  }

  // Delete
  Future deletePetTable(PetTable pet) async {
    await database.delete().eq('id', pet.id!);
  }

  // Fetch a single pet by ID
  Future<PetTable?> getPetById(int id) async {
    try {
      final response = await database.select().eq('id', id).single();

      return PetTable.fromMap(response);
    } catch (e) {
      print('Error fetching pet by ID: $e');
      return null;
    }
  }

  Stream<PetTable> watchPetById(int id) {
    // If you're using a library like sqflite, you'll need to create a stream
    // Here's a simple approach using StreamController
    final controller = StreamController<PetTable>();

    // Initial load
    getPetById(id).then((pet) {
      if (pet != null) controller.add(pet);
    });

    // You could set up a timer to check for updates periodically
    // Or implement a more sophisticated stream based on your database system

    // Don't forget to close the controller when it's no longer needed
    return controller.stream;
  }
}
