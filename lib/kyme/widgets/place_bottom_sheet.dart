import 'package:flutter/material.dart';
import 'package:mahalaga_app/kyme/utils/cover_images_supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';

// Widget for displaying a bottom sheet with a list of suggested places
class PlaceBottomSheet extends StatelessWidget {
  final List<Map<String, dynamic>> suggestedPlaces;
  final ScrollController scrollController;
  final Function(Map<String, dynamic>) onPlaceTap;
  final String title;

  const PlaceBottomSheet({
    super.key,
    required this.suggestedPlaces,
    required this.scrollController,
    required this.onPlaceTap,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.5, // Lower or make dynamic
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 50,
            height: 5,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          // Title
          Padding(
            padding: EdgeInsets.all(12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          // List of suggested places or empty message
          suggestedPlaces.isEmpty
              ? const Expanded(
                child: Center(child: Text("No suggested places found.")),
              )
              : SizedBox(
                height: 320,
                child: ListView.separated(
                  controller: scrollController,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: suggestedPlaces.length,
                  separatorBuilder: (context, _) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final place = suggestedPlaces[index];
                    return _CarouselPlaceCard(
                      place: place,
                      onTap: () => onPlaceTap(place),
                    );
                  },
                ),
              ),
        ],
      ),
    );
  }
}

// Card widget for displaying a single place in the carousel
class _CarouselPlaceCard extends StatefulWidget {
  final Map<String, dynamic> place;
  final VoidCallback onTap;

  const _CarouselPlaceCard({required this.place, required this.onTap});

  @override
  State<_CarouselPlaceCard> createState() => _CarouselPlaceCardState();
}

class _CarouselPlaceCardState extends State<_CarouselPlaceCard> {
  String? signedUrl;

  @override
  void initState() {
    super.initState();
    fetchSignedUrl();
  }

  // Fetches a signed URL for the place's cover image from Supabase Storage
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
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.place['name'] as String? ?? 'Unknown';
    final category = widget.place['category'] as String? ?? 'Category';

    // Parse distance and rating from place data
    final double? distance = switch (widget.place['distance']) {
      String d => double.tryParse(d),
      double d => d,
      int d => d.toDouble(),
      _ => null,
    };

    final double? rating = switch (widget.place['rating']) {
      String r => double.tryParse(r),
      double r => r,
      int r => r.toDouble(),
      _ => null,
    };

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(2, 2)),
        ],
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Place cover image or fallback
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child:
                    signedUrl != null
                        ? Image.network(
                          signedUrl!,
                          width: double.infinity,
                          height: 150,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => fallbackImage(),
                        )
                        : fallbackImage(),
              ),
              const SizedBox(height: 8),
              // Place name
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              // Place category
              Text(category, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 4),
              // Distance and rating
              Text(
                '${distance?.toStringAsFixed(2) ?? '--'} km • ${rating != null ? '${rating.toStringAsFixed(1)} ★' : 'No rating'}',
                style: const TextStyle(color: Colors.black54),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  // Widget for fallback image if cover image is not available
  Widget fallbackImage() {
    return Container(
      width: double.infinity,
      height: 150,
      color: Colors.grey[300],
      child: const Icon(
        Icons.image_not_supported,
        color: Colors.grey,
        size: 30,
      ),
    );
  }
}

// Gets the current device location using Geolocator
Future<Position?> getCurrentLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return null;
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return null;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return null;
  }

  return await Geolocator.getCurrentPosition();
}

// Attaches distance (in km) from current location to each place in the list
Future<List<Map<String, dynamic>>> attachDistanceToPlaces(
  List<Map<String, dynamic>> places,
) async {
  final Position? currentPosition = await getCurrentLocation();

  if (currentPosition == null) return places;

  return places.map((place) {
    final double? lat = place['latitude']?.toDouble();
    final double? lng = place['longitude']?.toDouble();

    if (lat != null && lng != null) {
      final distanceInMeters = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        lat,
        lng,
      );
      return {...place, 'distance': distanceInMeters / 1000};
    }

    return place;
  }).toList();
}

// Initializes Supabase client with project URL and anon key
Future<void> initializeSupabase() async {
  await Supabase.initialize(
    url: 'https://hntloshxinkevqumurmm.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhudGxvc2h4aW5rZXZxdW11cm1tIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUzMTIyMDgsImV4cCI6MjA2MDg4ODIwOH0.OqMe0u5YupElH3rY422KvnYTYdje-nuBjv0Ls86glwo',
  );
}

Future<List<Map<String, dynamic>>> fetchFilteredPlacesWithDistance({
  required Map<String, dynamic> filters,
  String? searchQuery,
}) async {
  final supabase = Supabase.instance.client;
  var query = supabase.schema('mahalaga_pca_schema').from('places').select();

  // Apply filters to the query
  if (filters['category'] != null && filters['category'] != 'All') {
    query = query.eq('category', filters['category']);
  }
  if (filters['minRating'] != null) {
    query = query.gte('rating', filters['minRating']);
  }
  if (searchQuery != null && searchQuery.trim().isNotEmpty) {
    query = query.ilike('name', '%$searchQuery%');
  }

  try {
    final List data = await query;
    List<Map<String, dynamic>> places = List<Map<String, dynamic>>.from(data);

    // Debugging: Print data fetched from Supabase
    debugPrint("Fetched places: $places");

    // Add distances
    places = await attachDistanceToPlaces(places);

    // Debugging: Print places with attached distances
    debugPrint("Places with distances: $places");

    // Sort by nearest
    places.sort(
      (a, b) => (a['distance'] ?? double.infinity).compareTo(
        b['distance'] ?? double.infinity,
      ),
    );

    // Optionally filter by radius
    if (filters['maxDistanceKm'] != null) {
      final double maxDistance = filters['maxDistanceKm'];
      places =
          places
              .where((p) => (p['distance'] ?? double.infinity) <= maxDistance)
              .toList();
    }

    // Debugging: Final list of places after filtering by distance
    debugPrint("Final filtered places: $places");

    return places;
  } catch (e) {
    debugPrint('Error fetching filtered places: $e');
    return [];
  }
}
