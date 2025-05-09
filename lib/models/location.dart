class Location {
  final double latitude;
  final double longitude;

  Location({required this.latitude, required this.longitude});

  Map<String, dynamic> toMap() => {
    'latitude': latitude,
    'longitude': longitude,
  };

  factory Location.fromMap(Map<String, dynamic> map) => Location(
    latitude: map['latitude'],
    longitude: map['longitude'],
  );
} 