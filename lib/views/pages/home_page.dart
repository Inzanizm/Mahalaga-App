import 'package:flutter/material.dart';
import 'package:mahalaga_app/data/notifiers.dart';
import 'dart:io';

import 'package:mahalaga_app/data/selected_pet_data.dart';
import 'package:mahalaga_app/database/pet_table.dart';
import 'package:mahalaga_app/views/pages/pet_page/pet_adoption_page.dart';
import 'package:mahalaga_app/views/pages/pet_page/pet_detail_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    void showPetSelectorDialog(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Center(
              child: Text(
                'Select a Pet',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            content: ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: petListNotifier,
              builder: (context, pets, child) {
                if (pets.isEmpty) {
                  return SizedBox(
                    height: 100,
                    child: Center(
                      child: Text(
                        'You have no pets yet.\nAdd one to get started!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  );
                }

                return SizedBox(
                  width: double.maxFinite,
                  height: 400,
                  child: SingleChildScrollView(
                    child: Column(
                      children:
                          pets.map((pet) {
                            return GestureDetector(
                              onTap: () {
                                SelectedPetData.selectedPet = pet;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => PetDetailScreen(
                                          pet: PetTable.fromMap(pet),
                                        ),
                                  ),
                                );
                              },
                              child: Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 5,
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        radius: 40,
                                        backgroundImage:
                                            pet['image'] != null
                                                ? FileImage(File(pet['image']))
                                                : const AssetImage(
                                                      'assets/images/dog.png',
                                                    )
                                                    as ImageProvider,
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              pet['name'],
                                              style: TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.teal.shade700,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${pet['breed']} • ${pet['age']} years old',
                                              style: TextStyle(
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          /// Pet Stats Card
          Center(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Buddy",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            showPetSelectorDialog(context);
                          },
                          child: const Text('Change Pet'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Walk",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: 0.7,
                      backgroundColor: Colors.grey[300],
                      color: Colors.blue,
                      minHeight: 10,
                    ),
                    const SizedBox(height: 8),
                    const Text("70% - 2.1 km"),
                    const SizedBox(height: 24),
                    const Text(
                      "Playtime",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: 0.5,
                      backgroundColor: Colors.grey[300],
                      color: Colors.green,
                      minHeight: 10,
                    ),
                    const SizedBox(height: 8),
                    const Text("50% - 30 min"),
                    const SizedBox(height: 24),
                    const Text(
                      "Food",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: 0.9,
                      backgroundColor: Colors.grey[300],
                      color: Colors.orange,
                      minHeight: 10,
                    ),
                    const SizedBox(height: 8),
                    const Text("90% - 450g"),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),

          /// Adoption Card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Adoptable Pets",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Scrollbar(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Container(
                            width: 140,
                            margin: const EdgeInsets.only(right: 12),
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    'assets/pets/pet1.png', // Example images
                                    height: 100,
                                    width: 140,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Clover",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                const PetAdoptionPage(),
                                      ),
                                    );
                                  },

                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(
                                      double.infinity,
                                      36,
                                    ),
                                    textStyle: const TextStyle(fontSize: 12),
                                  ),
                                  child: const Text('Adopt'),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 140,
                            margin: const EdgeInsets.only(right: 12),
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    'assets/pets/pet1.png', // Example images
                                    height: 100,
                                    width: 140,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Haru",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                ElevatedButton(
                                  onPressed: () {
                                    // TODO: Adopt functionality
                                  },

                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(
                                      double.infinity,
                                      36,
                                    ),
                                    textStyle: const TextStyle(fontSize: 12),
                                  ),
                                  child: const Text('Adopt'),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 140,
                            margin: const EdgeInsets.only(right: 12),
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    'assets/pets/pet1.png', // Example images
                                    height: 100,
                                    width: 140,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Dagul",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                ElevatedButton(
                                  onPressed: () {
                                    // TODO: Adopt functionality
                                  },

                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(
                                      double.infinity,
                                      36,
                                    ),
                                    textStyle: const TextStyle(fontSize: 12),
                                  ),
                                  child: const Text('Adopt'),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 140,
                            margin: const EdgeInsets.only(right: 12),
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    'assets/pets/pet1.png', // Example images
                                    height: 100,
                                    width: 140,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Bambam",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                ElevatedButton(
                                  onPressed: () {
                                    // TODO: Adopt functionality
                                  },

                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(
                                      double.infinity,
                                      36,
                                    ),
                                    textStyle: const TextStyle(fontSize: 12),
                                  ),
                                  child: const Text('Adopt'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Lost Pet",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  // Image of the lost pet
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/pets/pet1.png', // Example image for lost pet
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Pet details
                  const Text(
                    "Name: Max",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text("Missing Since: March 5, 2025"),
                  const SizedBox(height: 4),
                  const Text("Last Location: Central Park"),
                  const SizedBox(height: 4),
                  const Text("Gender: Male"),
                  const SizedBox(height: 4),
                  const Text(
                    "Description: Max is a small brown dog with white paws. He was last seen near the park. He is friendly and well-trained.",
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Contact No: +1 234 567 890",
                    style: TextStyle(color: Colors.blue),
                  ),
                  const SizedBox(height: 16),

                  // Button to help find the lost pet
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Implement the report found functionality
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 36),
                    ),
                    child: const Text('Report Found Pet'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
