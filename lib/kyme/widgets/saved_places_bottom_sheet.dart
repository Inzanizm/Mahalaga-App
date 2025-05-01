import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:mahalaga_app/kyme/widgets/place_details_bottom_sheet.dart';

class SavedPlacesBottomSheet extends StatelessWidget {
  final List<Map<String, dynamic>> savedPlaces;
  final ScrollController scrollController;
  final Function(Map<String, dynamic>) onPlaceTap;
  final Function(Map<String, dynamic>) onDelete;

  const SavedPlacesBottomSheet({
    super.key,
    required this.savedPlaces,
    required this.scrollController,
    required this.onPlaceTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.5,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag Handle
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
          const Padding(
            padding: EdgeInsets.all(12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Saved Places",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          // Saved Places List or Empty State
          savedPlaces.isEmpty
              ? const Expanded(
                child: Center(child: Text("No saved places yet.")),
              )
              : Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: savedPlaces.length,
                  itemBuilder: (context, index) {
                    final place = savedPlaces[index];
                    return ListTile(
                      title: Text(place['name'] ?? 'Unknown'),
                      subtitle: Text(place['category'] ?? ''),
                      onTap:
                          () => showModalBottomSheet(
                            context: context,
                            builder:
                                (context) => PlaceDetailsBottomSheet(
                                  place: place,
                                  onGetDirections: (LatLng destination) {
                                    onPlaceTap(place);
                                  },

                                  onSave: (place) {},
                                ),
                          ),
                      leading: CircleAvatar(
                        backgroundImage:
                            (place['placeCoverImage'] != null &&
                                    place['placeCoverImage']
                                        .toString()
                                        .isNotEmpty)
                                ? NetworkImage(place['placeCoverImage'])
                                : null,
                        child:
                            (place['placeCoverImage'] == null ||
                                    place['placeCoverImage'].toString().isEmpty)
                                ? const Icon(Icons.place)
                                : null,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.directions,
                              color: Colors.blue,
                            ),
                            tooltip: 'Show Route & Pin',
                            onPressed: () => onPlaceTap(place),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDelete(context, place),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
        ],
      ),
    );
  }

  // Show confirmation dialog before deleting
  void _confirmDelete(BuildContext context, Map<String, dynamic> place) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Saved Place'),
          content: const Text(
            'Are you sure you want to delete this saved place?',
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close dialog
                onDelete(place); // Trigger deletion
              },
            ),
          ],
        );
      },
    );
  }
}
