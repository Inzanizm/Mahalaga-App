// Import Flutter's material design package
import 'package:flutter/material.dart';

// Import package to handle image picking (camera/gallery)
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:mahalaga_app/data/selected_pet_data.dart';
import 'package:mahalaga_app/database/pet_table.dart';
import 'package:mahalaga_app/database/pet_table_database.dart';
import 'package:mahalaga_app/views/pages/pet_page/pet_detail_screen.dart';

// Import package for calendar widget
// import 'package:table_calendar/table_calendar.dart';

class PetProfileView extends StatefulWidget {

  final PetTable pet;
  const PetProfileView({super.key, required this.pet});
  

  @override
  State<PetProfileView> createState() => _PetProfileViewState();
}

class _PetProfileViewState extends State<PetProfileView> {
  List<Map<String, dynamic>> pets = []; // List to hold pet data
  final ImagePicker _picker =
      ImagePicker(); // Image picker instance for selecting pet images
  String searchQuery = ''; // String to hold the search query for filtering pets

  final petTableDatabase =
      PetTableDatabase(); // Database instance for pet table

  final nameController = TextEditingController(); // Controller for pet's name
  final speciesController =
      TextEditingController(); // Controller for pet's species
  final breedController = TextEditingController(); // Controller for pet's breed
  final ageController = TextEditingController(); // Controller for pet's age
  final statusController =
      TextEditingController(); // Controller for pet's reproductive status
  final weightController =
      TextEditingController(); // Controller for pet's weight
  final bloodController =
      TextEditingController(); // Controller for pet's blood type
  final allergyController =
      TextEditingController(); // Controller for pet's allergies
  final markController =
      TextEditingController(); // Controller for pet's distinctive mark
  XFile? pickedImage; // Variable to store picked image file

  void addNewPetTable() {
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Center(
                child: Text(
                  'Add New Pet',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              content: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Form(
                    key: formKey, // Attach form key for validation
                    child: Column(
                      children: [
                        // Pet image picker
                        Center(
                          child: GestureDetector(
                            onTap: () async {
                              final image = await _picker.pickImage(
                                source: ImageSource.gallery,
                              ); // Pick image from gallery
                              if (image != null) {
                                setModalState(() {
                                  pickedImage = image; // Update picked image
                                });
                              }
                            },
                            child: CircleAvatar(
                              radius: 40,
                              backgroundImage:
                                  pickedImage != null
                                      ? FileImage(
                                        File(pickedImage!.path),
                                      ) // Display selected image
                                      : AssetImage('assets/images/dog.png')
                                          as ImageProvider, // Default image
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Build text fields for various pet attributes
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
              ),
              actions: [
                OverflowBar(
                  alignment: MainAxisAlignment.end,
                  children: [
                    // Cancel button to close dialog without saving
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Cancel'),
                    ),
                    // Add button to save the new pet
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          final newPet = PetTable(
                            name: nameController.text.trim(),
                            species: speciesController.text.trim(),
                            breed: breedController.text.trim(),
                            age: int.tryParse(ageController.text.trim()) ?? 0,
                            status: statusController.text.trim(),
                            weight:
                                int.tryParse(weightController.text.trim()) ?? 0,
                            blood: bloodController.text.trim(),
                            allergy: allergyController.text.trim(),
                            mark: markController.text.trim(),
                            image: pickedImage?.path,
                          );

                          await petTableDatabase.createPetTable(
                            newPet,
                          ); //  Save new pet to database

                          Navigator.pop(dialogContext); // Close dialog

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              backgroundColor: Colors.teal,
                              content: Text(
                                '${nameController.text} has been added!',
                                style: const TextStyle(color: Colors.white),
                              ),
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Method to add a new pet

  // Helper method to build text fields for pet attributes
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool required = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.teal),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
      validator:
          required
              ? (value) => value!.trim().isEmpty ? 'Please enter $label' : null
              : null,
    );
  }

  // Helper method to display health details in a line
  Widget _healthDetailLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(width: 8),
          Text("$label: ", style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        StreamBuilder<List<PetTable>>(
          stream: petTableDatabase.stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error loading pets'));
            }

            final pets = snapshot.data ?? [];

            final filteredPets =
                pets.where((pet) {
                  final name = pet.name.toLowerCase();
                  return name.contains(searchQuery);
                }).toList();

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: true,
                  pinned: true,
                  backgroundColor: Colors.teal,
                  elevation: 0,
                  title: const Padding(
                    padding: EdgeInsets.only(top: 7),
                    child: Text(
                      'Pet Profile',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  centerTitle: true,
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(75),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value.toLowerCase();
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search your pets...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.teal),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    if (pets.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Text(
                          'You have no pets yet.\nAdd one to get started!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      )
                    else if (filteredPets.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Text(
                          'No pets found matching your search.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      )
                    else
                      ...filteredPets.map((pet) {
                        return GestureDetector(
                          onTap: () {
                            SelectedPetData.selectedPet = pet;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PetDetailScreen(pet: pet),
                              ),
                            );
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 5,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        radius: 40,
                                        backgroundImage:
                                            pet.image != null
                                                ? FileImage(File(pet.image!))
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
                                              pet.name,
                                              style: TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.teal.shade700,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${pet.breed} • ${pet.age} years old',
                                              style: TextStyle(
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  const Divider(thickness: 1.2),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.medical_services,
                                        color: Colors.teal,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Health Information',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.teal.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _healthDetailLine("Species", pet.species),
                                      _healthDetailLine(
                                        "Reproductive Status",
                                        pet.status,
                                      ),
                                      _healthDetailLine(
                                        "Weight",
                                        pet.weight.toString(),
                                      ),
                                      _healthDetailLine(
                                        "Blood Type",
                                        pet.blood,
                                      ),
                                      _healthDetailLine(
                                        "Allergies",
                                        pet.allergy,
                                      ),
                                      _healthDetailLine(
                                        "Distinctive Mark",
                                        pet.mark,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    const SizedBox(height: 80),
                  ]),
                ),
              ],
            );
          },
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            backgroundColor: Colors.teal,
            onPressed: addNewPetTable,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
