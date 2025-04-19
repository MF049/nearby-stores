class Store {
  final int? id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  bool isFavorite;
  double? distance;
  String? direction;

  Store({
    this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.isFavorite = false,
    this.distance,
    this.direction,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'isFavorite': isFavorite ? 1 : 0,
      'distance': distance,
      'direction': direction,
    };
  }

  factory Store.fromMap(Map<String, dynamic> map) {
    return Store(
      id: map['id'],
      name: map['name'],
      address: map['address'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      isFavorite: map['isFavorite'] == 1,
      distance: map['distance'],
      direction: map['direction'],
    );
  }

  Store copyWith({
    int? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    bool? isFavorite,
    double? distance,
    String? direction,
  }) {
    return Store(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isFavorite: isFavorite ?? this.isFavorite,
      distance: distance ?? this.distance,
      direction: direction ?? this.direction,
    );
  }
} 