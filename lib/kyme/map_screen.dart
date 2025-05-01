// Import necessary packages for Flutter, mapping, geolocation, HTTP requests, and other utilities.
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mahalaga_app/kyme/models/saved_place.dart';
import 'package:mahalaga_app/kyme/utils/place_utils.dart';
import 'package:mahalaga_app/kyme/widgets/filter_sidebar.dart';
import 'package:mahalaga_app/kyme/widgets/place_bottom_sheet.dart';
import 'package:mahalaga_app/kyme/widgets/place_details_bottom_sheet.dart';
import 'package:mahalaga_app/kyme/widgets/saved_places_bottom_sheet.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

final supabase = Supabase.instance.client;

Future<void> initializeSupabase() async {
  await Supabase.initialize(
    url: 'https://hntloshxinkevqumurmm.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhudGxvc2h4aW5rZXZxdW11cm1tIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUzMTIyMDgsImV4cCI6MjA2MDg4ODIwOH0.OqMe0u5YupElH3rY422KvnYTYdje-nuBjv0Ls86glwo',
  );
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

// ito yung main class para sa MapScreen natin.
// here nangyayari lahat ng logic para sa map, search, route, at mga suggestions.
class _MapScreenState extends State<MapScreen> {
  final Logger _logger = Logger(
    'MapScreen',
  ); // nagde-declare ng logger para sa mga errors or info logs

  Marker? _searchedMarker; // marker para sa PLACE NA SINEARCH ng user

  Polyline? _routePolyline; // line na ipapakita sa mapa para sa ROUTE ng travel

  String? _travelDuration; // storage ng travel time

  late final MapController
  _mapController; // controller para sa MAP, ginagamit para galawin yung screen o mag-zoom

  LatLng _defaultLocation = const LatLng(
    0,
    0,
  ); // default location na ipapakita sa mapa if wiz current location (nasa (0,0))

  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> suggestedPlaces = [];

  @override
  void initState() {
    super.initState();
    loadSuggestedPlaces();
    _mapController = MapController();
    _setupLogging();
    _setUserLocationAsDefault();
  }

  // function para tanggalin yung current route at travel duration, and clear yung pin
  void _clearRoute() {
    setState(() {
      _routePolyline = null;
      _travelDuration = null;
      _searchedMarker = null;
    });
  }

  void _handlePlaceTap(Map<String, dynamic> place) {
    // Example: Navigate or zoom sa napiling place
    _showPlaceDetailsModal(place);
  }

  void _deleteSavedPlace(Map<String, dynamic> place) {
    setState(() {
      _savedPlaces.remove(place);
    });
  }

  final List<Map<String, dynamic>> _savedPlaces = [];

  void _savePlace(Map<String, dynamic> place) {
    if (!_savedPlaces.contains(place)) {
      setState(() {
        _savedPlaces.add(place);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Place saved!')));
    }
  }

  // void _goToPlace(Map<String, dynamic> place) {
  //   final latLng = place['latLng'];
  //   if (latLng != null && latLng is LatLng) {
  //     _mapController.move(latLng, 15.0);
  //   } else {
  //     _showSnackbar("Invalid location data for ${place['name']}");
  //   }
  // }

  Future<void> _drawRouteAndShowTime(LatLng destination) async {
    final currentPosition = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
    );

    final start = LatLng(currentPosition.latitude, currentPosition.longitude);

    final directionsUrl =
        'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${destination.longitude},${destination.latitude}?overview=full&geometries=geojson';

    final response = await http.get(Uri.parse(directionsUrl));
    final data = jsonDecode(response.body);

    if (data['routes'] != null && data['routes'].isNotEmpty) {
      final route = data['routes'][0];
      final geometry = route['geometry']['coordinates'] as List;
      final duration = route['duration']; // in seconds

      final points =
          geometry
              .map<LatLng>(
                (coords) => LatLng(coords[1].toDouble(), coords[0].toDouble()),
              )
              .toList();

      setState(() {
        _routePolyline = null; // clear old route
        _travelDuration = null; // reset duration
        _routePolyline = Polyline(
          points: points,
          strokeWidth: 4.0,
          color: Colors.blue,
        );

        // Ensure selectedLatLng and suggestion are defined before using them
        final LatLng selectedLatLng = destination;
        final Map<String, dynamic> suggestion = {};

        _searchedMarker = Marker(
          point: selectedLatLng,
          width: 150,
          height: 50,
          child: GestureDetector(
            onTap: () async {
              if (!mounted) return;

              // Show place details
              _showPlaceDetailsModal({
                'id': suggestion['id'],
                'name': suggestion['name'],
                'address': suggestion['address'],
                'category': suggestion['category'],
                'rating': suggestion['rating'],
                'distance': suggestion['distance'],
                'description': suggestion['description'],
                'latLng': selectedLatLng,
                'placeCoverImage': suggestion['placeCoverImage'],
              });
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 4),
                    ],
                  ),
                  child: Text(
                    suggestion['name'] ?? '',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.location_pin, color: Colors.red, size: 25),
              ],
            ),
          ),
        );
        _travelDuration = (duration / 60).ceil().toString(); // in minutes
      });
      // Optionally center map to route
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(points),
          padding: const EdgeInsets.all(60),
        ),
      );
    }
  }

  Future<List<LatLng>?> fetchRoute(LatLng start, LatLng end) async {
    final url =
        'http://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final coords = data['routes'][0]['geometry']['coordinates'];
      return coords.map<LatLng>((coord) => LatLng(coord[1], coord[0])).toList();
    }
    return null;
  }

  double calculateTravelTime(List<LatLng> route) {
    // Placeholder: you might use average speed instead
    const averageSpeedKmh = 40;
    double totalDistance = 0;

    for (int i = 0; i < route.length - 1; i++) {
      totalDistance += Geolocator.distanceBetween(
        route[i].latitude,
        route[i].longitude,
        route[i + 1].latitude,
        route[i + 1].longitude,
      );
    }

    return (totalDistance / 1000) / averageSpeedKmh * 3600; // in seconds
  }

  Future<Map<String, dynamic>?> fetchPlaceById(String id) async {
    final result =
        await supabase
            .schema('mahalaga_pca_schema')
            .from('places')
            .select('*')
            .eq('id', id)
            .maybeSingle();

    return result;
  }

  Future<List<Map<String, dynamic>>> fetchSimilarPlaces(
    String category,
    String excludeId,
  ) async {
    final result = await supabase //ganito yung supabase query
        .schema('mahalaga_pca_schema')
        .from('places') //ito yung table name
        .select('*')
        .eq('category', category) //ito yung category na gusto mo
        .neq('id', excludeId)
        .order('distance', ascending: true)
        .limit(10);
    return List<Map<String, dynamic>>.from(result);
  }

  void showSearchResultsCarousel(
    Map<String, dynamic> mainPlace,
    List<Map<String, dynamic>> similarPlaces,
  ) {
    final allResults = [mainPlace, ...similarPlaces];
    final scrollController = ScrollController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return PlaceBottomSheet(
          title: "Searched Results",
          suggestedPlaces: allResults,
          scrollController: scrollController,
          onPlaceTap: (place) {
            Navigator.of(context).pop();

            final distance = switch (place['distance']) {
              String d => double.tryParse(d),
              double d => d,
              int d => d.toDouble(),
              _ => null,
            };
            place['distance'] = distance;

            _showPlaceDetailsModal(
              place,
            ); // or use your routing/direction logic here
          },
        );
      },
    );
  }

  Future<void> loadSuggestedPlaces() async {
    final filters = {
      'category': 'All',
      'openNow': false,
      'minRating': null,
      'distance': ['distance'],
      'maxDistanceKm': null,
    };

    final results = await fetchFilteredPlacesWithDistance(filters: filters);
    setState(() {
      _drawRouteAndShowTime(LatLng(16, 0)); // Example destination
      suggestedPlaces = results;
    });
  }

  bool _isExpanded =
      false; // pang track kung nakabukas o nakasara yung dropdown buttons sa ledgi

  bool _isSidebarVisible = false;
  bool _isOpenNow = false;
  String _selectedDistance = "Within 1 km";
  String _selectedRating = "All";
  // ignore: prefer_final_fields
  bool _openNowOnly = false;

  List<String> _selectedCategories = [];

  void _toggleFilterSidebar() {
    setState(() {
      _isSidebarVisible = !_isSidebarVisible;
    });
  }

  void _showPlaceDetailsModal(Map<String, dynamic> place) async {
    try {
      final placeId = place['id']?.toString();

      if (placeId == null) {
        _showSnackbar("Invalid place ID");
        return;
      }

      // Try to get latLng, or construct it from latitude/longitude if missing
      dynamic latLng = place['latLng'];
      if (latLng == null || latLng is! LatLng) {
        final lat = place['latitude'];
        final lng = place['longitude'];
        if (lat != null &&
            lng != null &&
            lat is num &&
            lng is num &&
            lat != 0.0 &&
            lng != 0.0) {
          latLng = LatLng(lat.toDouble(), lng.toDouble());
        } else {
          _showSnackbar("Invalid or missing location data");
          return;
        }
      }

      // fetch schedule if missing
      final schedule = place['schedule'] ?? await fetchPlaceSchedule(placeId);

      // format opening hours
      final openingHours =
          schedule !=
          getFormattedOpeningHours({...place, 'schedule': schedule});

      // Now 'place' has full info
      final completePlace = {
        ...place,
        'id': placeId,
        'latLng': latLng,
        'schedule': schedule,
        'openingHours': openingHours,
      };

      // Then show bottom sheet
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        builder:
            (context) => PlaceDetailsBottomSheet(
              place: completePlace,
              onGetDirections: (LatLng destination) {
                _drawRouteAndShowTime(destination);
                setState(() {
                  _searchedMarker = Marker(
                    point: destination,
                    width: 150,
                    height: 50,
                    child: GestureDetector(
                      onTap: () {
                        _showPlaceDetailsModal(completePlace);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(color: Colors.black26, blurRadius: 4),
                              ],
                            ),
                            child: Text(
                              completePlace['name'] ?? 'Unknown Place',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 25,
                          ),
                        ],
                      ),
                    ),
                  );
                });
                _mapController.move(destination, 15.0);
              },
              onSave: (place) {
                final savedPlace = SavedPlace(
                  id: place.id,
                  category: place.category,
                  imageUrl: place.placeCoverImage,
                  description: place.description ?? '',
                  name: place.name,
                  address: place.address ?? '',
                  latitude: (place.latitude ?? 0.0).toDouble(),
                  longitude: (place.longitude ?? 0.0).toDouble(),
                  rating: (place.rating ?? 0.0).toDouble(),
                );
                _savePlace(savedPlace.toMap());
              },
            ),
      );
    } catch (e) {
      _showSnackbar('Error loading place details: $e');
    }
  }

  void _showSuggestedPlacesModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.2,
          maxChildSize: 0.5,
          builder: (_, scrollController) {
            return PlaceBottomSheet(
              title: "Suggested Places",
              suggestedPlaces: suggestedPlaces,
              scrollController: ScrollController(),
              onPlaceTap: (place) {
                Navigator.pop(context);
                final latLng = place['latLng'];
                if (latLng == null || latLng is! LatLng) {
                  debugPrint(
                    "Error: Place ${place['name']} has no valid latLng.",
                  );
                } else {
                  _mapController.move(latLng, 15);
                }
                _showPlaceDetailsModal(place);
              },
            );
          },
        );
      },
    );
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  void _setupLogging() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      debugPrint('${record.level.name}: ${record.time}: ${record.message}');
    });
  }

  Future<void> _setUserLocationAsDefault() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackbar("Location services are disabled.");
      _mapController.move(_defaultLocation, 15.0);
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      LatLng userLocation = LatLng(position.latitude, position.longitude);
      setState(() {
        _defaultLocation = userLocation;
      });
      _mapController.move(userLocation, 15.0);

      // Automatically fetch suggestions after location is set
      await _applyFilters();
    } catch (e) {
      _showSnackbar("Failed to get location: $e");
      _mapController.move(_defaultLocation, 15.0);
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackbar("Location permission denied.");
        _mapController.move(_defaultLocation, 15.0);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnackbar("Location permission permanently denied.");
      _mapController.move(_defaultLocation, 15.0);
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      LatLng userLocation = LatLng(position.latitude, position.longitude);
      setState(() {
        _defaultLocation = userLocation;
      });
      _mapController.move(userLocation, 15.0);
    } catch (e) {
      _showSnackbar("Failed to get location: $e");
      _mapController.move(_defaultLocation, 15.0);
    }
  }

  Future<void> _searchPlace(String query) async {
    _logger.info("Searching manually for: $query");

    try {
      final supabaseData = await supabase
          .schema('mahalaga_pca_schema')
          .from('places')
          .select('*')
          .ilike('name', '%$query%')
          .limit(1);

      if (supabaseData.isNotEmpty) {
        final item = supabaseData.first;
        final lat = item['latitude'];
        final lng = item['longitude'];

        if (lat != null && lng != null) {
          final latLng = LatLng(lat, lng);

          // Calculate distance
          final userLocation = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.best,
            ),
          );
          debugPrint('GPS Accuracy: ${userLocation.accuracy} meters');

          final distanceInMeters = Geolocator.distanceBetween(
            userLocation.latitude,
            userLocation.longitude,
            lat,
            lng,
          );
          final distanceInKm = (distanceInMeters / 1000).toStringAsFixed(2);

          if (mounted) {
            // Ensure the widget is still mounted
            // Show the PlaceBottomSheet with the searched place
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (_) {
                return PlaceBottomSheet(
                  title: "Searched Results",
                  suggestedPlaces: [
                    {
                      ...item,
                      'distance': distanceInKm, // Add the calculated distance
                    },
                  ], // Pass the searched place as a list
                  scrollController: ScrollController(),
                  onPlaceTap: (place) {
                    Navigator.of(context).pop(); // Close the carousel

                    final distance = switch (item['distance']) {
                      String d => double.tryParse(d),
                      double d => d,
                      int d => d.toDouble(),
                      _ => null,
                    };
                    if (distance != null) {
                      Text("Distance: ${distance.toStringAsFixed(2)} km");
                    }
                    _showPlaceDetailsModal(
                      place,
                    ); // Show the place details modal for the selected place
                  },
                );
              },
            );

            // this add the marker to the map
            setState(() {
              _searchedMarker = Marker(
                point: latLng,
                width: 150,
                height: 50,
                child: GestureDetector(
                  onTap: () {
                    _showPlaceDetailsModal({
                      ...item,
                      'distance': distanceInKm, // Add the calculated distance
                    });
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(color: Colors.black26, blurRadius: 4),
                          ],
                        ),
                        child: Text(
                          item['name'],
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 25,
                      ),
                    ],
                  ),
                ),
              );
              _drawRouteAndShowTime(
                LatLng(lat, lng),
              ); // Draw route to the searched place
              _mapController.move(latLng, 15.0);
            });
          }
        }
      } else {
        if (mounted) {
          _showSnackbar("No results found for '$query'");
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackbar("Error during search: $e");
      }
    }
  }

  Future<double> _calculateDistance(double lat, double lng) async {
    Position userLocation = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
    );

    return Geolocator.distanceBetween(
      userLocation.latitude,
      userLocation.longitude,
      lat,
      lng,
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _applyFilters() async {
    final supabase = Supabase.instance.client;
    Position position = await Geolocator.getCurrentPosition();
    LatLng userLocation = LatLng(position.latitude, position.longitude);

    final response = await supabase
        .schema('mahalaga_pca_schema')
        .from('places')
        .select('*')
        .ilike(
          'category',
          _selectedCategories.isNotEmpty ? _selectedCategories.first : '%',
        )
        .gte(
          'rating',
          _selectedRating == "All"
              ? 0
              : double.parse(_selectedRating.replaceAll('+', '')),
        );

    List<Map<String, dynamic>> places = [];

    for (var item in response) {
      final placeLat = item['latitude'];
      final placeLng = item['longitude'];
      double distanceInMeters = Geolocator.distanceBetween(
        userLocation.latitude,
        userLocation.longitude,
        placeLat,
        placeLng,
      );
      double distanceKm = distanceInMeters / 1000;

      double maxDistanceKm = switch (_selectedDistance) {
        "Within 1 km" => 1,
        "Within 3 km" => 3,
        "Within 5 km" => 5,
        "Within 10 km" => 10,
        "Within 20 km" => 20,
        _ => double.infinity,
      };

      if (distanceKm > maxDistanceKm) continue;

      // Apply openNow filter
      final isOpen = isOpenNow(item);
      if (_openNowOnly && !isOpen) continue;
      places.add({
        'name': item['name'],
        'distance': distanceKm.toStringAsFixed(2),
        'rating': item['rating'],
        'category': item['category'],
        'address': item['address'],
        'description': item['description'],
        'placeCoverImage': item['placeCoverImage'],
        'latLng': LatLng(placeLat, placeLng),
      });
    }

    setState(() {
      suggestedPlaces.addAll(places);
    });
  }

  Future<void> handleSearchResult(String placeId) async {
    try {
      final mainPlace = await fetchPlaceById(placeId);
      if (mainPlace == null) {
        _showSnackbar("Place not found.");
        return;
      }

      final category = mainPlace['category'] ?? 'General';
      final similarPlaces = await fetchSimilarPlaces(category, mainPlace['id']);

      final lat = mainPlace['latitude'];
      final lng = mainPlace['longitude'];
      if (lat != null && lng != null) {
        final latLng = LatLng(lat, lng);
        mainPlace['latLng'] = latLng;
        mainPlace['distance'] = await _calculateDistance(lat, lng);
      }

      showSearchResultsCarousel(mainPlace, similarPlaces);
    } catch (e) {
      _showSnackbar("Error loading search results: $e");
    }
  }

  // Fetches the schedule for a place by its ID from Supabase
  Future<List<Map<String, dynamic>>> fetchPlaceSchedule(String placeId) async {
    final result = await supabase
        .schema('mahalaga_pca_schema')
        .from('places')
        .select('*')
        .eq('id', placeId);
    return List<Map<String, dynamic>>.from(result);
  }

  // Formats the opening hours from the schedule data
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
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Nearby Pet Services'),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 104, 168, 141),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _defaultLocation,
              initialZoom: 13.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
              onTap: (_, __) {
                FocusScope.of(
                  context,
                ).unfocus(); // CLOSE the keyboard + suggestions
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.mahalaga_pcapp_map',
              ),
              CurrentLocationLayer(
                style: const LocationMarkerStyle(
                  marker: DefaultLocationMarker(
                    child: Icon(Icons.location_pin, color: Colors.white),
                  ),
                  markerSize: Size(35, 35),
                  markerDirection: MarkerDirection.heading,
                ),
              ),
              MarkerLayer(
                markers: [if (_searchedMarker != null) _searchedMarker!],
              ),
              if (_routePolyline != null)
                PolylineLayer(polylines: [_routePolyline!]),
            ],
          ),
          // Show travel duration if available
          if (_travelDuration != null)
            Positioned(
              top: 80,
              right: 15,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer, color: Colors.teal, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      'Travel time: $_travelDuration min',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          Positioned(
            top: 10,
            left: 15,
            right: 65,
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 5),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TypeAheadField<Map<String, dynamic>>(
                          // disable suggestions
                          controller: _searchController,
                          builder: (context, controller, focusNode) {
                            return TextField(
                              controller: controller,
                              focusNode: focusNode,
                              decoration: const InputDecoration(
                                hintText: 'Search location...',
                                border: InputBorder.none,
                              ),
                              onSubmitted: (value) async {
                                final response =
                                    await Supabase.instance.client
                                        .schema('mahalaga_pca_schema')
                                        .from('places')
                                        .select('*')
                                        .ilike('name', '%$value%')
                                        .limit(1)
                                        .maybeSingle();

                                if (response != null && context.mounted) {
                                  _showPlaceDetailsModal(response);
                                }
                              },
                            );
                          },
                          suggestionsCallback: (pattern) async {
                            if (pattern.isEmpty) return [];

                            final supabase = Supabase.instance.client;

                            // start: ito yung place details widget kapag pinindot ng user yung mga suggested searches
                            final supabaseData = await supabase
                                .schema('mahalaga_pca_schema')
                                .from('places')
                                .select('*')
                                .ilike('name', '%$pattern%')
                                .limit(5);
                            final supabaseResults =
                                (supabaseData as List<dynamic>)
                                    .map<Map<String, dynamic>>(
                                      (item) => {
                                        'source': 'supabase',
                                        'id': item['id'],
                                        'name': item['name'],
                                        'address': item['address'] ?? '',
                                        'latitude': item['latitude'],
                                        'longitude': item['longitude'],
                                        'rating': item['rating'],
                                        'description': item['description'],
                                        'distance': item['distance'],
                                        'category': item['category'],
                                        'placeCoverImage':
                                            item['placeCoverImage'],
                                      },
                                    )
                                    .toList();
                            // end: ito yung place details widget kapag pinindot ng user yung mga suggested searches

                            // OpenStreetMap query
                            final osmResponse = await http.get(
                              Uri.parse(
                                'https://nominatim.openstreetmap.org/search?q=$pattern&format=json',
                              ),
                              headers: {
                                'User-Agent':
                                    'mahalaga_pcapp_map/1.0 (mahalagapetcareapp@gmail.com)',
                              },
                            );

                            final currentLocation = await _getCurrentLocation();
                            final userLat = currentLocation.latitude;
                            final userLon = currentLocation.longitude;
                            final osmJson = jsonDecode(osmResponse.body);

                            final osmResults = List<Map<String, dynamic>>.from(
                              osmJson.map((item) {
                                final placeLat =
                                    double.tryParse(item['lat'] ?? '') ?? 0.0;
                                final placeLon =
                                    double.tryParse(item['lon'] ?? '') ?? 0.0;

                                final distanceInMeters =
                                    Geolocator.distanceBetween(
                                      userLat,
                                      userLon,
                                      placeLat,
                                      placeLon,
                                    );
                                final distanceInKm = distanceInMeters / 1000;

                                return {
                                  'source': 'supabase',
                                  'id': '${item['id']}',
                                  'name': item['name'] ?? 'Unnamed Place',
                                  'address': item['address'] ?? '',
                                  'latitude': placeLat,
                                  'longitude': placeLon,
                                  'rating': null,
                                  'category': 'General',
                                  'placeCoverImage': item['placeCoverImage'],
                                  'distance': distanceInKm.toStringAsFixed(
                                    2,
                                  ), // Now in km with 2 decimals
                                };
                              }),
                            );

                            return [...supabaseResults, ...osmResults];
                          },
                          itemBuilder: (context, suggestion) {
                            final source =
                                suggestion['source'] == 'supabase'
                                    ? '📍'
                                    : '🌍';
                            return ListTile(
                              leading: Text(source),
                              title: Text(suggestion['name']),
                              subtitle: Text(suggestion['address'] ?? ''),
                            );
                          },
                          onSelected: (suggestion) async {
                            final lat = suggestion['latitude'];
                            final lon = suggestion['longitude'];
                            final selectedLatLng = LatLng(lat, lon);

                            //
                            setState(() {
                              _searchedMarker = Marker(
                                point: selectedLatLng,
                                width: 150,
                                height: 50,
                                child: GestureDetector(
                                  onTap: () async {
                                    if (!mounted) return;

                                    // Show place detais
                                    _showPlaceDetailsModal({
                                      'id': suggestion['id'],
                                      'name': suggestion['name'],
                                      'address': suggestion['address'],
                                      'category': suggestion['category'],
                                      'rating': suggestion['rating'],
                                      'distance': suggestion['distance'],
                                      'description': suggestion['description'],
                                      'latLng': selectedLatLng,
                                      'placeCoverImage':
                                          suggestion['placeCoverImage'],
                                    });
                                  },
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          suggestion['name'],

                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.location_pin,
                                        color: Colors.red,
                                        size: 25,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            });
                            //lalagyan ng route
                            _mapController.move(selectedLatLng, 15.0);

                            // Show carousel bottom sheet directly after selecting
                            if (!mounted) return;

                            _showPlaceDetailsModal({
                              'id': suggestion['id'],
                              'name': suggestion['name'],
                              'address': suggestion['address'],
                              'category': suggestion['category'],
                              'rating': suggestion['rating'],
                              'latLng': selectedLatLng,
                              'description': suggestion['description'],
                              'distance': suggestion['distance'],
                              'placeCoverImage': suggestion['placeCoverImage'],
                            });
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.search, color: Colors.teal),
                        onPressed: () {
                          _searchPlace(_searchController.text);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          //FILTER BUTTON
          Positioned(
            right: 10,
            top: 10,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 2,
                    spreadRadius: 2,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: FloatingActionButton(
                elevation: 2.0,
                backgroundColor: Colors.white,
                onPressed: _toggleFilterSidebar,
                child: const Icon(Icons.tune, color: Colors.teal),
              ),
            ),
          ),

          //END OF FILTER BUTTON
          if (_isSidebarVisible)
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              child: FilterSidebar(
                onClose: () => setState(() => _isSidebarVisible = false),
                isOpenNow: _isOpenNow,
                selectedCategories: _selectedCategories,
                onOpenNowChanged:
                    (value) => setState(() => _isOpenNow = value ?? false),
                onDistanceChanged:
                    (value) =>
                        setState(() => _selectedDistance = value ?? "None"),
                onRatingChanged:
                    (value) => setState(() => _selectedRating = value ?? "All"),
                onCategoryChanged:
                    (updatedCategories) =>
                        setState(() => _selectedCategories = updatedCategories),
                onClear: () {
                  setState(() {
                    _selectedDistance = "None";
                    _selectedRating = "All";
                    _selectedCategories.clear();
                    _isOpenNow = false;
                  });
                },
                onApply: () {
                  _applyFilters();
                  setState(() => _isSidebarVisible = false);
                },
              ),
            ),

          Positioned(
            top: 70,
            left: 15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // pag expanded, ipakita lahat ng buttons
                if (_isExpanded) ...[
                  FloatingActionButton(
                    mini: true,
                    heroTag: "btnLocation",
                    backgroundColor: Colors.white,
                    onPressed: _setUserLocationAsDefault,
                    child: const Icon(Icons.my_location, color: Colors.teal),
                  ),
                  const SizedBox(height: 8), // spacing
                  FloatingActionButton(
                    mini: true,
                    heroTag: "suggestedBtn",
                    backgroundColor: Colors.white,
                    onPressed: _showSuggestedPlacesModal,
                    child: const Icon(
                      FontAwesomeIcons.mapPin,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.white,
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) {
                          return SavedPlacesBottomSheet(
                            savedPlaces: _savedPlaces,
                            scrollController: ScrollController(),
                            onPlaceTap: _handlePlaceTap,
                            onDelete: _deleteSavedPlace,
                          );
                        },
                      );
                    },
                    child: const Icon(Icons.bookmark, color: Colors.teal),
                  ),
                  FloatingActionButton(
                    mini: true,
                    heroTag: "btnClearRoute",
                    backgroundColor:
                        (_routePolyline == null && _searchedMarker == null)
                            ? Colors
                                .grey
                                .shade300 // disabled look pag walang route or pin
                            : Colors.white, // normal color kapag meron
                    onPressed:
                        (_routePolyline == null && _searchedMarker == null)
                            ? null // disabled kapag walang route at pin
                            : _clearRoute, // normal clear kapag meron
                    tooltip: 'Reset Route',
                    child: Icon(
                      Icons.refresh,
                      color:
                          (_routePolyline == null && _searchedMarker == null)
                              ? Colors
                                  .grey // icon color pag disabled
                              : Colors.teal, // normal color
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                // eto yung main dropdown button
                FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.teal,
                  heroTag: "toggleDropdown",
                  onPressed: () {
                    setState(() {
                      _isExpanded =
                          !_isExpanded; // palitan yung state kapag pinindot
                    });
                  },
                  child: Icon(
                    _isExpanded ? Icons.close : Icons.menu,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
