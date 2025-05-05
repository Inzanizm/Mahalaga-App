import 'package:flutter/material.dart';
import 'package:mahalaga_app/views/pages/pet_page/add_pet_page.dart';
import 'package:mahalaga_app/views/pages/pet_page/pet_details_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class PetAdoptionPage extends StatefulWidget {
  const PetAdoptionPage({super.key});

  @override
  State<PetAdoptionPage> createState() => _PetAdoptionPageState();
}

class _PetAdoptionPageState extends State<PetAdoptionPage> {
  bool isLoading = true;

  List<Map<String, String>> adoptablePets = [
    {
      'name': 'Bella',
      'breed': 'Golden Retriever',
      'age': '2 years',
      'gender': 'Female',
      'description': 'Friendly and playful. Loves children!',
      'image': 'https://images.unsplash.com/photo-1560807707-8cc77767d783',
      'status': 'Available',
      'caretaker': 'Pawfect Rescue Center',
      'contact': 'pawfectrescue@email.com',
    },
    {
      'name': 'Luna',
      'breed': 'Siberian Husky',
      'age': '1 year',
      'gender': 'Female',
      'description': 'Energetic and smart. Needs an active owner!',
      'image': 'https://images.unsplash.com/photo-1560807707-8cc77767d783',
      'status': 'Pending',
      'caretaker': 'Happy Tails Shelter',
      'contact': 'happytails@shelter.org',
    },
    {
      'name': 'Max',
      'image': 'https://images.unsplash.com/photo-1560807707-8cc77767d783',
      'breed': 'Golden Retriever',
      'gender': 'Male',
      'age': '2 years',
      'weight': '30 kg',
      'location': 'Laguna',
      'description': 'Friendly and energetic dog who loves to play!',
      'status': 'Unavailable',
      'caretaker': 'Jane Doe',
      'contact': '+63 912 345 6789',
      'caretaker_image': 'https://example.com/jane.jpg',
      'caretaker_description':
          'Jane has been caring for rescued animals for 6 years. She ensures every pet is healthy, trained, and ready for a new home.',
    },
  ];

  // List to store filtered pets after applying search
  List<Map<String, String>> filteredPets = [];

  @override
  void initState() {
    super.initState();
    // Initially, display all adoptable pets
    fetchPetsFromSupabase();
  }

  Future<void> fetchPetsFromSupabase() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await supabase
          .from('adoptable_pets')
          .select()
          .order('name', ascending: true);

          debugPrint('Supabase response: $response');

      if (mounted) {
        setState(() {
          adoptablePets = List<Map<String, String>>.from(
            response.map(
              (e) =>
                  e.map((key, value) => MapEntry(key, value?.toString() ?? '')),
            ),
          );
          filteredPets = adoptablePets;
        });
      }
    } catch (e) {
      debugPrint('Error fetching pets: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Function to filter pets by breed
  void filterPets(String query) {
    final filtered =
        adoptablePets.where((pet) {
          final breed = pet['breed']!.toLowerCase();
          return breed.contains(query.toLowerCase());
        }).toList();

    setState(() {
      // Update the filteredPets list to display the filtered results
      filteredPets = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white, // optional
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (filteredPets.isEmpty) {
      return const Scaffold(
         backgroundColor: Colors.white, 
        body: Center(child: Text('No adoptable pets found.')),
      );
    }

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            // SliverAppBar with search bar for breed filtering
            SliverAppBar(
              floating: true,
              pinned: true,
              backgroundColor: Colors.teal,
              elevation: 0,
              title: Padding(
                padding: EdgeInsets.only(
                  top: 7,
                  bottom: 0,
                ), // Adjust the bottom margin
                child: Text(
                  'Adopt a Pet',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
              ),
              centerTitle: true,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(75), // Reduced height
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    onChanged: filterPets, // Filter pets as user types
                    decoration: InputDecoration(
                      hintText: 'Search by breed...',
                      prefixIcon: const Icon(Icons.search),
                      fillColor: Colors.white, // Color of the search bar
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.teal),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // SliverList to display the list of filtered pets
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final pet = filteredPets[index];
                return GestureDetector(
                  onTap: () {
                    // Navigate to PetDetailsPage when a pet card is tapped
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PetDetailsPage(pet: pet),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hero animation for image transition
                        Hero(
                          tag: pet['name']!,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                            child: Image.network(
                              pet['image']!,
                              height: 220,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          pet['name']!,
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        // Display pet's status with color-coded label
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                pet['status'] == 'Available'
                                                    ? Colors.green
                                                    : Colors.red,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            pet['status']!,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      pet['breed']!,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              ),
                              // Arrow icon to indicate more details
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 18,
                                color: Colors.teal,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }, childCount: filteredPets.length),
            ),
          ],
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            backgroundColor: Colors.teal,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddPetPage(), // Navigate to the Add Pet page
                ),
              );
            },
            child: Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
