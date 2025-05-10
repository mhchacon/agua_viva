import 'package:uuid/uuid.dart';
import 'location.dart';

class Location {
  final double latitude;
  final double longitude;

  Location({required this.latitude, required this.longitude});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: json['latitude'] ?? 0.0,
      longitude: json['longitude'] ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class SpringAssessment {
  final String id;
  final String springId;
  final String evaluatorId;
  final String status; // 'draft', 'pending', 'approved', 'rejected'
  final List<String> environmentalServices;
  final String ownerName;
  final String ownerCpf;
  final bool hasCAR;
  final String? carNumber;
  final Location location;
  final double altitude;
  final String municipality;
  final String reference;
  final bool hasAPP;
  final String appStatus;
  final bool hasWaterFlow;
  final bool hasWetlandVegetation;
  final bool hasFavorableTopography;
  final bool hasSoilSaturation;
  final String springType;
  final String springCharacteristic;
  final int? diffusePoints;
  final String flowRegime;
  final String? ownerResponse;
  final String? informationSource;
  final Map<String, int> hydroEnvironmentalScores;
  final int hydroEnvironmentalTotal;
  final Map<String, int> surroundingConditions;
  final Map<String, int> springConditions;
  final Map<String, int> anthropicImpacts;
  final String generalState;
  final String primaryUse;
  final bool hasWaterAnalysis;
  final DateTime? analysisDate;
  final String? analysisParameters;
  final bool hasFlowRate;
  final double? flowRateValue;
  final DateTime? flowRateDate;
  final List<String> photoReferences;
  final String? recommendations;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? submittedAt;

  SpringAssessment({
    required this.id,
    required this.springId,
    required this.evaluatorId,
    required this.status,
    required this.environmentalServices,
    required this.ownerName,
    required this.ownerCpf,
    required this.hasCAR,
    this.carNumber,
    required this.location,
    required this.altitude,
    required this.municipality,
    required this.reference,
    required this.hasAPP,
    required this.appStatus,
    required this.hasWaterFlow,
    required this.hasWetlandVegetation,
    required this.hasFavorableTopography,
    required this.hasSoilSaturation,
    required this.springType,
    required this.springCharacteristic,
    this.diffusePoints,
    required this.flowRegime,
    this.ownerResponse,
    this.informationSource,
    required this.hydroEnvironmentalScores,
    required this.hydroEnvironmentalTotal,
    required this.surroundingConditions,
    required this.springConditions,
    required this.anthropicImpacts,
    required this.generalState,
    required this.primaryUse,
    required this.hasWaterAnalysis,
    this.analysisDate,
    this.analysisParameters,
    required this.hasFlowRate,
    this.flowRateValue,
    this.flowRateDate,
    required this.photoReferences,
    this.recommendations,
    required this.createdAt,
    required this.updatedAt,
    this.submittedAt,
  });

  // Getters para IDs como String
  String get idString => id;
  String get springIdString => springId;
  String get evaluatorIdString => evaluatorId;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'springId': springId,
      'evaluatorId': evaluatorId,
      'status': status,
      'environmentalServices': environmentalServices,
      'ownerName': ownerName,
      'ownerCpf': ownerCpf,
      'hasCAR': hasCAR,
      'carNumber': carNumber,
      'location': location.toJson(),
      'altitude': altitude,
      'municipality': municipality,
      'reference': reference,
      'hasAPP': hasAPP,
      'appStatus': appStatus,
      'hasWaterFlow': hasWaterFlow,
      'hasWetlandVegetation': hasWetlandVegetation,
      'hasFavorableTopography': hasFavorableTopography,
      'hasSoilSaturation': hasSoilSaturation,
      'springType': springType,
      'springCharacteristic': springCharacteristic,
      'diffusePoints': diffusePoints,
      'flowRegime': flowRegime,
      'ownerResponse': ownerResponse,
      'informationSource': informationSource,
      'hydroEnvironmentalScores': hydroEnvironmentalScores,
      'hydroEnvironmentalTotal': hydroEnvironmentalTotal,
      'surroundingConditions': surroundingConditions,
      'springConditions': springConditions,
      'anthropicImpacts': anthropicImpacts,
      'generalState': generalState,
      'primaryUse': primaryUse,
      'hasWaterAnalysis': hasWaterAnalysis,
      'analysisDate': analysisDate?.toIso8601String(),
      'analysisParameters': analysisParameters,
      'hasFlowRate': hasFlowRate,
      'flowRateValue': flowRateValue,
      'flowRateDate': flowRateDate?.toIso8601String(),
      'photoReferences': photoReferences,
      'recommendations': recommendations,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'submittedAt': submittedAt?.toIso8601String(),
    };
  }

  factory SpringAssessment.fromJson(Map<String, dynamic> json) {
    // Função auxiliar para converter para double
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return SpringAssessment(
      id: json['_id'] ?? json['id'] ?? '',
      springId: json['springId'] ?? '',
      evaluatorId: json['evaluatorId'] ?? '',
      status: json['status'] ?? '',
      environmentalServices: json['environmentalServices'] != null 
          ? List<String>.from(json['environmentalServices'])
          : [],
      ownerName: json['ownerName'] ?? '',
      ownerCpf: json['ownerCpf'] ?? '',
      hasCAR: json['hasCAR'] ?? false,
      carNumber: json['carNumber'],
      location: json['location'] != null 
          ? Location.fromJson(json['location'])
          : Location(latitude: 0, longitude: 0),
      altitude: parseDouble(json['altitude']) ?? 0.0,
      municipality: json['municipality'] ?? '',
      reference: json['reference'] ?? '',
      hasAPP: json['hasAPP'] ?? false,
      appStatus: json['appStatus'] ?? '',
      hasWaterFlow: json['hasWaterFlow'] ?? false,
      hasWetlandVegetation: json['hasWetlandVegetation'] ?? false,
      hasFavorableTopography: json['hasFavorableTopography'] ?? false,
      hasSoilSaturation: json['hasSoilSaturation'] ?? false,
      springType: json['springType'] ?? '',
      springCharacteristic: json['springCharacteristic'] ?? '',
      diffusePoints: json['diffusePoints'],
      flowRegime: json['flowRegime'] ?? '',
      ownerResponse: json['ownerResponse'],
      informationSource: json['informationSource'],
      hydroEnvironmentalScores: json['hydroEnvironmentalScores'] != null
          ? Map<String, int>.from(json['hydroEnvironmentalScores'])
          : {},
      hydroEnvironmentalTotal: json['hydroEnvironmentalTotal'] ?? 0,
      surroundingConditions: json['surroundingConditions'] != null
          ? Map<String, int>.from(json['surroundingConditions'])
          : {},
      springConditions: json['springConditions'] != null
          ? Map<String, int>.from(json['springConditions'])
          : {},
      anthropicImpacts: json['anthropicImpacts'] != null
          ? Map<String, int>.from(json['anthropicImpacts'])
          : {},
      generalState: json['generalState'] ?? '',
      primaryUse: json['primaryUse'] ?? '',
      hasWaterAnalysis: json['hasWaterAnalysis'] ?? false,
      analysisDate: json['analysisDate'] != null
          ? DateTime.parse(json['analysisDate'])
          : null,
      analysisParameters: json['analysisParameters'],
      hasFlowRate: json['hasFlowRate'] ?? false,
      flowRateValue: parseDouble(json['flowRateValue']),
      flowRateDate: json['flowRateDate'] != null
          ? DateTime.parse(json['flowRateDate'])
          : null,
      photoReferences: json['photoReferences'] != null
          ? List<String>.from(json['photoReferences'])
          : [],
      recommendations: json['recommendations'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
      submittedAt: json['submittedAt'] != null ? DateTime.parse(json['submittedAt']) : null,
    );
  }

  // Método para criar uma nova avaliação com IDs como String
  factory SpringAssessment.fromStringIds({
    required String id,
    required String springId,
    required String evaluatorId,
    required String status,
    required List<String> environmentalServices,
    required String ownerName,
    required String ownerCpf,
    required bool hasCAR,
    String? carNumber,
    required Location location,
    required double altitude,
    required String municipality,
    required String reference,
    required bool hasAPP,
    required String appStatus,
    required bool hasWaterFlow,
    required bool hasWetlandVegetation,
    required bool hasFavorableTopography,
    required bool hasSoilSaturation,
    required String springType,
    required String springCharacteristic,
    int? diffusePoints,
    required String flowRegime,
    String? ownerResponse,
    String? informationSource,
    required Map<String, int> hydroEnvironmentalScores,
    required int hydroEnvironmentalTotal,
    required Map<String, int> surroundingConditions,
    required Map<String, int> springConditions,
    required Map<String, int> anthropicImpacts,
    required String generalState,
    required String primaryUse,
    required bool hasWaterAnalysis,
    DateTime? analysisDate,
    String? analysisParameters,
    required bool hasFlowRate,
    double? flowRateValue,
    DateTime? flowRateDate,
    required List<String> photoReferences,
    String? recommendations,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? submittedAt,
  }) {
    return SpringAssessment(
      id: id,
      springId: springId,
      evaluatorId: evaluatorId,
      status: status,
      environmentalServices: environmentalServices,
      ownerName: ownerName,
      ownerCpf: ownerCpf,
      hasCAR: hasCAR,
      carNumber: carNumber,
      location: location,
      altitude: altitude,
      municipality: municipality,
      reference: reference,
      hasAPP: hasAPP,
      appStatus: appStatus,
      hasWaterFlow: hasWaterFlow,
      hasWetlandVegetation: hasWetlandVegetation,
      hasFavorableTopography: hasFavorableTopography,
      hasSoilSaturation: hasSoilSaturation,
      springType: springType,
      springCharacteristic: springCharacteristic,
      diffusePoints: diffusePoints,
      flowRegime: flowRegime,
      ownerResponse: ownerResponse,
      informationSource: informationSource,
      hydroEnvironmentalScores: hydroEnvironmentalScores,
      hydroEnvironmentalTotal: hydroEnvironmentalTotal,
      surroundingConditions: surroundingConditions,
      springConditions: springConditions,
      anthropicImpacts: anthropicImpacts,
      generalState: generalState,
      primaryUse: primaryUse,
      hasWaterAnalysis: hasWaterAnalysis,
      analysisDate: analysisDate,
      analysisParameters: analysisParameters,
      hasFlowRate: hasFlowRate,
      flowRateValue: flowRateValue,
      flowRateDate: flowRateDate,
      photoReferences: photoReferences,
      recommendations: recommendations,
      createdAt: createdAt,
      updatedAt: updatedAt,
      submittedAt: submittedAt,
    );
  }
}

// Spring model for managing spring data separately from assessments
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

  // Create a Spring from JSON
  factory Spring.fromJson(Map<String, dynamic> json) {
    return Spring(
      id: json['id'] ?? '',
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

  // Convert Spring to JSON for storage
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
}
