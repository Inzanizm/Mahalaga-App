// class SelectedPetData {
//   // A static variable to store the selected pet data
//   static Map<String, dynamic>? selectedPet;
// }
import 'package:flutter/material.dart';

class SelectedPetData {
  static ValueNotifier<Map<String, dynamic>> selectedPetNotifier =
      ValueNotifier({});

  static Map<String, dynamic> get selectedPet => selectedPetNotifier.value;
  static set selectedPet(Map<String, dynamic> pet) {
    selectedPetNotifier.value = pet;
  }
}
