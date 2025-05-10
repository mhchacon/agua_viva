import 'package:agua_viva/models/location.dart';

class Spring {
  final String id;
  final String ownerId;
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

  String get idString => id;
  String get ownerIdString => ownerId;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'location': location.toJson(),
      'altitude': altitude,
      'municipality': municipality,
      'reference': reference,
      'hasCAR': hasCAR,
      'carNumber': carNumber,
      'hasAPP': hasAPP,
      'appStatus': appStatus,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Spring.fromJson(Map<String, dynamic> json) {
    return Spring(
      id: json['id'] ?? json['_id'] ?? '',
      ownerId: json['ownerId'] ?? '',
      ownerName: json['ownerName'] ?? '',
      location: json['location'] != null 
        ? Location.fromJson(json['location']) 
        : Location(latitude: 0, longitude: 0),
      altitude: (json['altitude'] ?? 0).toDouble(),
      municipality: json['municipality'] ?? '',
      reference: json['reference'] ?? '',
      hasCAR: json['hasCAR'] ?? false,
      carNumber: json['carNumber'],
      hasAPP: json['hasAPP'] ?? false,
      appStatus: json['appStatus'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
    );
  }

  // Método para criar uma nova nascente com IDs como String
  factory Spring.fromStringIds({
    required String id,
    required String ownerId,
    required String ownerName,
    required Location location,
    required double altitude,
    required String municipality,
    required String reference,
    required bool hasCAR,
    String? carNumber,
    required bool hasAPP,
    required String appStatus,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) {
    return Spring(
      id: id,
      ownerId: ownerId,
      ownerName: ownerName,
      location: location,
      altitude: altitude,
      municipality: municipality,
      reference: reference,
      hasCAR: hasCAR,
      carNumber: carNumber,
      hasAPP: hasAPP,
      appStatus: appStatus,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
} 