import 'package:mongo_dart/mongo_dart.dart';
import 'package:agua_viva/models/location.dart';

class Spring {
  final ObjectId id;
  final ObjectId ownerId;
  final String ownerName;
  final Location location;
  final double altitude;
  final String municipality;
  final String reference;
  final bool hasCAR;
  final String? carNumber;
  final bool hasAPP;
  final String appStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  Spring({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.location,
    required this.altitude,
    required this.municipality,
    required this.reference,
    required this.hasCAR,
    this.carNumber,
    required this.hasAPP,
    required this.appStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'location': {
        'latitude': location.latitude,
        'longitude': location.longitude,
      },
      'altitude': altitude,
      'municipality': municipality,
      'reference': reference,
      'hasCAR': hasCAR,
      'carNumber': carNumber,
      'hasAPP': hasAPP,
      'appStatus': appStatus,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory Spring.fromMap(Map<String, dynamic> map) {
    return Spring(
      id: map['_id'],
      ownerId: map['ownerId'],
      ownerName: map['ownerName'],
      location: Location(
        latitude: map['location']['latitude'],
        longitude: map['location']['longitude'],
      ),
      altitude: map['altitude'],
      municipality: map['municipality'],
      reference: map['reference'],
      hasCAR: map['hasCAR'],
      carNumber: map['carNumber'],
      hasAPP: map['hasAPP'],
      appStatus: map['appStatus'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }
}

class Location {
  final double latitude;
  final double longitude;

  Location({
    required this.latitude,
    required this.longitude,
  });
} 