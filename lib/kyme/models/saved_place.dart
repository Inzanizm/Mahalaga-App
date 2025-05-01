class SavedPlace {
  final String id;
  final String name;
  final String address;
  final String category;
  final String imageUrl;
  final String description;
  final double latitude;
  final double longitude;
  final double rating;

  SavedPlace({
    required this.id,
    required this.name,
    required this.address,
    required this.category,
    required this.imageUrl,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.rating,
  });

  factory SavedPlace.fromMap(Map<String, dynamic> map) {
    return SavedPlace(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      category: map['category'] ?? '',
      imageUrl: map['placeCoverImage'] ?? '',
      description: map['description'] ?? '',
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
      rating: (map['rating'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'category': category,
      'placeCoverImage': imageUrl,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'rating': rating,
    };
  }
}