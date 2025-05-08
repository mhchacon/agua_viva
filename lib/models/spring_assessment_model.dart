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
  final String status; // pending, approved, rejected
  final List<String> environmentalServices;
  
  // Owner information
  final String ownerName;
  final bool hasCAR; // Cadastro Ambiental Rural
  final String? carNumber;
  
  // Location
  final Location location;
  final double altitude;
  final String municipality;
  final String reference;
  
  // APP (Área de Preservação Permanente)
  final bool hasAPP;
  final String appStatus; // Bom, Ruim, Não tem
  
  // Spring Analysis
  final bool hasWaterFlow;
  final bool hasWetlandVegetation;
  final bool hasFavorableTopography;
  final bool hasSoilSaturation;
  
  // Spring Type
  final String springType; // Encosta/Eluvial, Depressão, Anticlinal
  final String springCharacteristic; // Pontual, Difusa
  final int? diffusePoints; // Number of points if diffuse
  final String flowRegime; // Perene, Intermitente, Efêmera, Sem vazão
  final String? ownerResponse; // If no flow at visit time
  final String? informationSource; // Direct observation or owner info
  
  // Environmental Assessment
  final Map<String, int> hydroEnvironmentalScores; // Parameters with scores
  final int hydroEnvironmentalTotal; // Sum of scores
  
  // Risk Assessment
  final Map<String, int> surroundingConditions;
  final Map<String, int> springConditions;
  final Map<String, int> anthropicImpacts;
  
  // Final Assessment
  final String generalState; // Preservada, Perturbada, Degradada
  final String primaryUse; // Abastecimento humano, Agricultura, etc.
  
  // Water Quality
  final bool hasWaterAnalysis;
  final DateTime? analysisDate;
  final String? analysisParameters;
  
  // Flow Rate
  final bool hasFlowRate;
  final double? flowRateValue;
  final DateTime? flowRateDate;
  
  // Photos and Recommendations
  final List<String> photoReferences;
  final String? recommendations;
  
  // Timestamps
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

  // Create a SpringAssessment from JSON
  factory SpringAssessment.fromJson(Map<String, dynamic> json) {
    return SpringAssessment(
      id: json['id'] ?? '',
      springId: json['springId'] ?? '',
      evaluatorId: json['evaluatorId'] ?? '',
      status: json['status'] ?? 'pending',
      environmentalServices: List<String>.from(json['environmentalServices'] ?? []),
      ownerName: json['ownerName'] ?? '',
      hasCAR: json['hasCAR'] ?? false,
      carNumber: json['carNumber'],
      location: json['location'] != null 
        ? Location.fromJson(json['location']) 
        : Location(latitude: 0, longitude: 0),
      altitude: (json['altitude'] ?? 0).toDouble(),
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
      hydroEnvironmentalScores: Map<String, int>.from(json['hydroEnvironmentalScores'] ?? {}),
      hydroEnvironmentalTotal: json['hydroEnvironmentalTotal'] ?? 0,
      surroundingConditions: Map<String, int>.from(json['surroundingConditions'] ?? {}),
      springConditions: Map<String, int>.from(json['springConditions'] ?? {}),
      anthropicImpacts: Map<String, int>.from(json['anthropicImpacts'] ?? {}),
      generalState: json['generalState'] ?? '',
      primaryUse: json['primaryUse'] ?? '',
      hasWaterAnalysis: json['hasWaterAnalysis'] ?? false,
      analysisDate: json['analysisDate'] != null ? DateTime.parse(json['analysisDate']) : null,
      analysisParameters: json['analysisParameters'],
      hasFlowRate: json['hasFlowRate'] ?? false,
      flowRateValue: json['flowRateValue']?.toDouble(),
      flowRateDate: json['flowRateDate'] != null ? DateTime.parse(json['flowRateDate']) : null,
      photoReferences: List<String>.from(json['photoReferences'] ?? []),
      recommendations: json['recommendations'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
      submittedAt: json['submittedAt'] != null ? DateTime.parse(json['submittedAt']) : null,
    );
  }

  // Convert SpringAssessment to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'springId': springId,
      'evaluatorId': evaluatorId,
      'status': status,
      'environmentalServices': environmentalServices,
      'ownerName': ownerName,
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
