// class SelectedPetData {
//   // A static variable to store the selected pet data
//   static Map<String, dynamic>? selectedPet;
// }
import 'package:flutter/material.dart';
import 'package:mahalaga_app/database/pet_table.dart';
class SelectedPetData {
  static ValueNotifier<PetTable?> selectedPetNotifier = ValueNotifier(null);

  static PetTable? get selectedPet => selectedPetNotifier.value;
  static set selectedPet(PetTable? pet) {
    selectedPetNotifier.value = pet;
  }
}
