import 'package:flutter/material.dart';
import 'package:mahalaga_app/data/notifiers.dart';
import 'dart:io';

import 'package:mahalaga_app/data/selected_pet_data.dart';
import 'package:mahalaga_app/database/pet_table.dart';
import 'package:mahalaga_app/views/pages/pet_page/pet_adoption_page.dart';
import 'package:mahalaga_app/views/pages/pet_page/pet_detail_screen.dart';
import 'package:mahalaga_app/views/pages/pet_page/pet_details_page.dart';
import 'package:mahalaga_app/views/pages/pet_page/pet_profile_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<Map<String, dynamic>>> fetchAdoptablePets() async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('adoptable_pets')
        .select()
        .eq('status', 'Available')
        .order('created_at', ascending: false)
        .limit(5);

    if (response.isEmpty) {
      return []; // fallback for empty list
    }

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> fetchFirstPet() async {
    final response =
        await Supabase.instance.client
            .from('pet_table')
            .select()
            .limit(1)
            .maybeSingle();

    return response;
  }

  Future<void> loadPets() async {
    final response = await Supabase.instance.client.from('pet_table').select();

    petListNotifier.value = List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    void showPetSelectorDialog(BuildContext context) async {
      final response =
          await Supabase.instance.client.from('pet_table').select();

      petListNotifier.value = List<Map<String, dynamic>>.from(response);

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
                                final selectedPet = PetTable.fromMap(pet);
                                SelectedPetData.selectedPetNotifier.value =
                                    selectedPet;
                                selectedPet;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${selectedPet.name} has been added!',
                                    ),
                                  ),
                                );

                                Navigator.pop(
                                  dialogContext,
                                ); // Close the dialog first

                                // Then navigate after the dialog closes
                                Future.delayed(Duration.zero, () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              PetProfileView(pet: selectedPet),
                                    ),
                                  );
                                });

                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder:
                                //         (context) =>
                                //             PetProfileView(pet: selectedPet),
                                //   ),
                                // );
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
                                                ? (pet['image'].startsWith(
                                                      'http',
                                                    )
                                                    ? NetworkImage(pet['image'])
                                                        as ImageProvider
                                                    : FileImage(
                                                      File(pet['image']),
                                                    ))
                                                : const AssetImage(
                                                  'assets/images/dog.png',
                                                ),
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
          FutureBuilder<Map<String, dynamic>?>(
            future: fetchFirstPet(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError || !snapshot.hasData) {
                return const Center(child: Text("No pet found."));
              }

              final pet = snapshot.data!;
              final petName = pet['name'] ?? 'Unknown Pet';

              return Center(
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
                            Text(
                              petName,
                              style: const TextStyle(
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
              );
            },
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
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: fetchAdoptablePets(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (snapshot.data!.isEmpty) {
                        return const Text(
                          'No adoptable pets available right now.',
                        );
                      } else {
                        final pets = snapshot.data!;
                        return Column(
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  ...pets.take(5).map((pet) {
                                    return Container(
                                      width: 140,
                                      margin: const EdgeInsets.only(right: 12),
                                      child: Column(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: Image.network(
                                              pet['image'] ?? '',
                                              height: 100,
                                              width: 140,
                                              fit: BoxFit.cover,
                                              errorBuilder: (
                                                context,
                                                error,
                                                stackTrace,
                                              ) {
                                                return Image.asset(
                                                  'assets/images/dog.png',
                                                  height: 100,
                                                  width: 140,
                                                  fit: BoxFit.cover,
                                                );
                                              },
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            pet['name'] ?? 'Unknown',
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
                                                      (_) => PetDetailsPage(
                                                        pet: pet,
                                                      ),
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              minimumSize: const Size(
                                                double.infinity,
                                                36,
                                              ),
                                              textStyle: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                            child: const Text('Adopt'),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                  // This is the 6th "More Pets" button styled card
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => const PetAdoptionPage(),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: 140,
                                      margin: const EdgeInsets.only(right: 12),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.teal),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Icon(
                                            Icons.pets,
                                            color: Colors.teal,
                                            size: 40,
                                          ),
                                          SizedBox(height: 12),
                                          Text(
                                            "More Pets",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.teal,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      }
                    },
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
