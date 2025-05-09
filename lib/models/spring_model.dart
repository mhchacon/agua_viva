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

  // Getters para IDs como String
  String get idString => id.toHexString();
  String get ownerIdString => ownerId.toHexString();

  Map<String, dynamic> toJson() {
    return {
      '_id': id.toHexString(),
      'ownerId': ownerId.toHexString(),
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
      id: json['_id'] is String ? ObjectId.parse(json['_id']) : json['_id'],
      ownerId: json['ownerId'] is String ? ObjectId.parse(json['ownerId']) : json['ownerId'],
      ownerName: json['ownerName'],
      location: Location.fromJson(json['location']),
      altitude: json['altitude'].toDouble(),
      municipality: json['municipality'],
      reference: json['reference'],
      hasCAR: json['hasCAR'],
      carNumber: json['carNumber'],
      hasAPP: json['hasAPP'],
      appStatus: json['appStatus'],
      createdAt: json['createdAt'] is String ? DateTime.parse(json['createdAt']) : json['createdAt'],
      updatedAt: json['updatedAt'] is String ? DateTime.parse(json['updatedAt']) : json['updatedAt'],
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
      id: ObjectId.parse(id),
      ownerId: ObjectId.parse(ownerId),
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