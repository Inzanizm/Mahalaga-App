import 'package:flutter/material.dart';
import 'package:mahalaga_app/database/pet_table.dart';
import 'package:mahalaga_app/views/pages/pet_page/pet_detail_screen.dart';

class SelectPetPage extends StatelessWidget {
  final List<Map<String, dynamic>> pets = [
    {
      'name': 'Buddy',
      'breed': 'Golden Retriever',
      'age': 3,
      'image': 'assets/images/dog.png',
    },
    // Add more pet details as needed
  ];

  SelectPetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select a Pet'), backgroundColor: Colors.teal),
      body: Padding(
        padding: const EdgeInsets.all(8.0), // Padding for list view
        child: SingleChildScrollView(
          child: GridView.builder(
            shrinkWrap: true, // Let the grid take only required space
            physics:
                NeverScrollableScrollPhysics(), // Disable scrolling in GridView
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Display two items per row
              crossAxisSpacing: 8.0, // Space between columns
              mainAxisSpacing: 8.0, // Space between rows
            ),
            itemCount: pets.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  // Navigate to PetDetailScreen with the selected pet's data
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return PetDetailScreen(
                          pet: PetTable(
                            name: pets[index]['name'],
                            breed: pets[index]['breed'],
                            age: pets[index]['age'],
                            image: pets[index]['image'],
                            species: pets[index]['species'] ?? 'Unknown',
                            status: pets[index]['status'] ?? 'Healthy',
                            weight: pets[index]['weight'] ?? 0.0,
                            blood: pets[index]['blood'] ?? 'Unknown',
                            allergy: pets[index]['allergy'] ?? 'None',
                            mark: pets[index]['mark'] ?? 'None',
                          ),
                        );
                      },
                    ),
                  );
                },
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                        child: Image.asset(
                          pets[index]['image'], // Display the pet's image
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          pets[index]['name'], // Display the pet's name
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
