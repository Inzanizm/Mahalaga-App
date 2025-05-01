import 'package:flutter/material.dart';
import 'package:mahalaga_app/kyme/models/place.dart';
import 'package:mahalaga_app/kyme/utils/cover_images_supabase.dart';
import 'package:mahalaga_app/kyme/widgets/review_section.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// ignore: unused_import
import 'package:latlong2/latlong.dart';

class PlaceDetailsBottomSheet extends StatefulWidget {
  final Map<String, dynamic> place;
  final void Function(LatLng destination)? onGetDirections;
  final Function(Place) onSave;

  const PlaceDetailsBottomSheet({
    super.key,
    required this.place,
    required this.onGetDirections,
    required this.onSave,
  });

  @override
  PlaceDetailsBottomSheetState createState() => PlaceDetailsBottomSheetState();
}

class PlaceDetailsBottomSheetState extends State<PlaceDetailsBottomSheet> {
  String? signedUrl;

  List<Place> similarPlaces = []; // List to hold the similar places

  @override
  void initState() {
    super.initState();
    fetchSignedUrl();
    fetchSimilarPlaces();
  }

  Future<void> fetchSignedUrl() async {
    final String imagePath = widget.place['placeCoverImage'] ?? '';
    if (imagePath.isNotEmpty) {
      final service = SupabaseStorageService();
      try {
        final url = await service.getSignedImageUrl(imagePath);
        if (url != null) {
          debugPrint("Signed URL fetched successfully: $url");
          setState(() => signedUrl = url);
        } else {
          debugPrint("No signed URL returned.");
          setState(() => signedUrl = null);
        }
      } catch (e) {
        debugPrint("Error fetching signed URL: $e");
        setState(() => signedUrl = null);
      }
    }

    final placeId = widget.place['id'];

    if (placeId != null) {
      try {
        final response =
            await Supabase.instance.client
                .from('places')
                .select('placeCoverImage')
                .eq('id', placeId)
                .single();

        final placeCoverImage = response['placeCoverImage'] as String?;
        if (placeCoverImage != null) {
          final publicUrl = Supabase.instance.client.storage
              .from('place-cover-image')
              .getPublicUrl(placeCoverImage);

          setState(() {
            signedUrl = publicUrl;
          });
        }
      } catch (e) {
        debugPrint("Error fetching signed URL: $e");
      }
    }
  }

  Future<void> fetchSimilarPlaces() async {
    final category = widget.place['category'];
    final placeId = widget.place['id'];

    if (category != null && placeId != null) {
      try {
        final response = await Supabase.instance.client
            .from('places')
            .select()
            .eq('category', category)
            .neq('id', placeId) // Exclude the current place
            .limit(5);

        final places =
            (response as List).map((place) => Place.fromMap(place)).toList();

        setState(() {
          similarPlaces = places;
        });
      } catch (e) {
        debugPrint("Error fetching similar places: $e");
      }
    }
  }

  List<String> getFormattedOpeningHours(Map<String, dynamic> place) {
    final days = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    final fullNames = {
      'mon': 'Monday',
      'tue': 'Tuesday',
      'wed': 'Wednesday',
      'thu': 'Thursday',
      'fri': 'Friday',
      'sat': 'Saturday',
      'sun': 'Sunday',
    };

    bool allNull = days.every(
      (day) => place['${day}_open'] == null && place['${day}_close'] == null,
    );

    if (allNull) {
      return ['No Schedule Available'];
    }

    return days.map((day) {
      final open = place['${day}_open'];
      final close = place['${day}_close'];

      if (open == null || close == null) {
        return '${fullNames[day]}: Closed';
      } else {
        return '${fullNames[day]}: ${open.toString().substring(0, 5)} - ${close.toString().substring(0, 5)}';
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final String name = widget.place['name'] ?? 'Unknown Place';
    final String address = widget.place['address'] ?? 'No address available';
    final String description =
        widget.place['description'] ?? 'No description available';
    final openingHours = getFormattedOpeningHours(widget.place);
    final hasOpeningHours =
        openingHours.isNotEmpty ? openingHours : ['No schedule listed'];

    final double rating = switch (widget.place['rating']) {
      double r => r,
      int r => r.toDouble(),
      String s => double.tryParse(s) ?? 0,
      _ => 0,
    };

    return DraggableScrollableSheet(
      initialChildSize: 1,
      minChildSize: 0.45,
      maxChildSize: 1,
      builder: (_, scrollController) {
        return DefaultTabController(
          length: 2,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Drag handle
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Hero(
                          tag: widget.place.containsKey('placeCoverImage'),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child:
                                signedUrl != null
                                    ? Image.network(
                                      signedUrl!,
                                      width: double.infinity,
                                      height: 250,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (_, __, ___) => fallbackImage(),
                                    )
                                    : fallbackImage(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    address,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 18,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text('${rating.toStringAsFixed(1)} stars'),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const TabBar(
                          tabs: [Tab(text: 'Details'), Tab(text: 'Reviews')],
                        ),
                        SizedBox(
                          height: 350,
                          child: TabBarView(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 12),
                                  Text(
                                    description.isNotEmpty
                                        ? description
                                        : 'No description available',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          if (widget.onGetDirections != null) {
                                            final lat =
                                                widget.place['latitude'];
                                            final lon =
                                                widget.place['longitude'];
                                            widget.onGetDirections!(
                                              LatLng(lat, lon),
                                            );
                                          }
                                        },
                                        icon: Icon(Icons.directions),
                                        label: Text("Directions"),
                                      ),

                                      OutlinedButton.icon(
                                        onPressed: () {
                                          widget.onSave(
                                            Place.fromMap(widget.place),
                                          ); // Use widget.place converted to Place
                                          Navigator.pop(
                                            context,
                                          ); // Close the bottom sheet
                                        },
                                        icon: const Icon(Icons.bookmark_border),
                                        label: const Text('Save'),
                                      ),

                                      OutlinedButton.icon(
                                        onPressed: () {},
                                        icon: const Icon(Icons.share),
                                        label: const Text('Share'),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),

                                  ExpansionTile(
                                    title: const Text('Opening Hours'),
                                    initiallyExpanded: true,
                                    children:
                                        hasOpeningHours.map((hour) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                            ),
                                            child: Text(hour),
                                          );
                                        }).toList(),
                                  ),
                                ],
                              ),
                              //para naman ito sa review tab
                              ReviewSection(placeId: widget.place['id']),
                            ],
                          ),
                        ),
                        // if (signedUrl != null)
                        //   Image.network(signedUrl!), // Display the image
                        // const SizedBox(height: 20),

                        // Display similar places
                        if (similarPlaces.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          const Text(
                            'Similar Places',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 200, // Adjust the height of the carousel
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: similarPlaces.length,
                              itemBuilder: (context, index) {
                                final place = similarPlaces[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Column(
                                    children: [
                                      Image.network(
                                        place
                                            .placeCoverImage, // Assuming `imageUrl` is a property of Place
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        place
                                            .name, // Assuming `name` is a property of Place
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ] else if (similarPlaces.isEmpty) ...[
                          const SizedBox(height: 20),
                          const Text(
                            'No similar places found.',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget fallbackImage() {
    return Container(
      width: double.infinity,
      height: 200,
      color: Colors.grey[300],
      child: const Icon(
        Icons.image_not_supported,
        color: Colors.grey,
        size: 50,
      ),
    );
  }
}
