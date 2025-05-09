class Location {
  final double latitude;
  final double longitude;
  final double? altitude;
  final String? address;
  final String? reference;

  Location({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.address,
    this.reference,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      altitude: json['altitude']?.toDouble(),
      address: json['address'] as String?,
      reference: json['reference'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      if (altitude != null) 'altitude': altitude,
      if (address != null) 'address': address,
      if (reference != null) 'reference': reference,
    };
  }

  Location copyWith({
    double? latitude,
    double? longitude,
    double? altitude,
    String? address,
    String? reference,
  }) {
    return Location(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      address: address ?? this.address,
      reference: reference ?? this.reference,
    );
  }
} 