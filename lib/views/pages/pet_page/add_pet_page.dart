import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class AddPetPage extends StatefulWidget {
  const AddPetPage({super.key});

  @override
  State<AddPetPage> createState() => _AddPetPageState();
}

class _AddPetPageState extends State<AddPetPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _genderController = TextEditingController();
  final _weightController = TextEditingController();
  final _locationController = TextEditingController();
  final _aboutController = TextEditingController();
  final _statusController = TextEditingController();

  // Variable to store the image picked from the gallery
  File? _imageFile;

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imageFile = File(image.path); // Update the state with the picked image
      });
    }
  }

  // Submit form
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Collecting data from the form fields
      final petName = _nameController.text;
      final petBreed = _breedController.text;
      final petAge = _ageController.text;
      final petGender = _genderController.text;
      final petWeight = _weightController.text;
      final petLocation = _locationController.text;
      final petAbout = _aboutController.text;
      final petStatus = _statusController.text;

      // Add your pet submission logic here (e.g., saving data to a database)

      // Show confirmation snackbar
      final snackBar = SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        backgroundColor: Colors.teal,
        content: Text(
          '$petName has been added for adoption!',
          style: const TextStyle(color: Colors.white),
        ),
        duration: const Duration(seconds: 3),
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(snackBar); // Display the snackbar
      Navigator.pop(
        context,
      ); // Go back to the pet adoption page after submission
    }
  }

  // Validator for numbers (age, weight)
  String? _validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field cannot be empty';
    }
    final number = int.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number'; // Ensure the input is a valid number
    }
    return null;
  }

  // Validator for status (Available/Pending)
  String? _validateStatus(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the pet status';
    }
    if (value != 'Available' && value != 'Pending') {
      return 'Status must be either "Available" or "Pending"'; // Ensure the status is valid
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a Pet for Adoption'),
        backgroundColor: Colors.teal, // AppBar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding around the form
        child: Form(
          key: _formKey, // The form key used for validation
          child: ListView(
            children: [
              // Pet Image Picker
              GestureDetector(
                onTap:
                    _pickImage, // Call the function when the container is tapped
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color:
                        Colors
                            .grey[300], // Default color for empty image container
                    image:
                        _imageFile != null
                            ? DecorationImage(
                              image: FileImage(
                                _imageFile!,
                              ), // Display the selected image
                              fit: BoxFit.cover,
                            )
                            : null,
                  ),
                  child:
                      _imageFile == null
                          ? Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 50,
                          ) // Camera icon when no image is picked
                          : null,
                ),
              ),
              const SizedBox(height: 20),

              // Pet Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Pet Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the pet name'; // Ensure the name is not empty
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // Breed
              TextFormField(
                controller: _breedController,
                decoration: const InputDecoration(
                  labelText: 'Breed',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the pet breed'; // Ensure the breed is not empty
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // Age
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number, // Numeric input for age
                validator: _validateNumber, // Validate if it's a valid number
              ),
              const SizedBox(height: 10),

              // Gender
              TextFormField(
                controller: _genderController,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the pet gender'; // Ensure gender is provided
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // Weight
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number, // Numeric input for weight
                validator: _validateNumber, // Validate if it's a valid number
              ),
              const SizedBox(height: 10),

              // Location
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the pet location'; // Ensure location is provided
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // About
              TextFormField(
                controller: _aboutController,
                decoration: const InputDecoration(
                  labelText: 'About',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter information about the pet'; // Ensure description is provided
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // Status
              TextFormField(
                controller: _statusController,
                decoration: const InputDecoration(
                  labelText: 'Status (Available/Pending)',
                  border: OutlineInputBorder(),
                ),
                validator: _validateStatus, // Validate if the status is valid
              ),
              const SizedBox(height: 20),

              // Submit Button
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ), // Call submit function when pressed
                child: const Text('Add Pet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
