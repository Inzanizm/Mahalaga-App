class Place {
  final String id;
  final String name;
  final double? rating;
  final double? distance;
  final String? address;
  final String? description;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;
  final String placeCoverImage;
  final String category;

  Place({
    required this.id,
    required this.name,
    this.rating,
    this.distance,
    this.address,
    this.description,
    this.imageUrl,
    this.latitude,
    this.longitude,
    required this.placeCoverImage,
    required this.category,
  });

  factory Place.fromMap(Map<String, dynamic> map) {
    return Place(
      id: map['id'],
      name: map['name'],
      rating: map['rating']?.toDouble(),
      distance: map['distance']?.toDouble(),
      address: map['address'],
      description: map['description'],
      placeCoverImage: map['placeCoverImage'],
      category: map['category'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'rating': rating,
      'distance': distance,
      'address': address,
      'description': description,
      'placeCoverImage': placeCoverImage,
      'latitude': latitude,
      'longitude': longitude,
      'category': category,
    };
  }
}
