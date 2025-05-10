import 'package:agua_viva/models/location.dart';

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

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'springId': springId,
      'evaluatorId': evaluatorId,
      'status': status,
      'environmentalServices': environmentalServices,
      'ownerName': ownerName,
      'ownerCpf': ownerCpf,
      'hasCAR': hasCAR,
      'carNumber': carNumber,
      'location': {
        'latitude': location.latitude,
        'longitude': location.longitude,
      },
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
      'analysisDate': analysisDate,
      'analysisParameters': analysisParameters,
      'hasFlowRate': hasFlowRate,
      'flowRateValue': flowRateValue,
      'flowRateDate': flowRateDate,
      'photoReferences': photoReferences,
      'recommendations': recommendations,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'submittedAt': submittedAt,
    };
  }

  factory SpringAssessment.fromMap(Map<String, dynamic> map) {
    return SpringAssessment(
      id: map['_id'] as String,
      springId: map['springId'] as String,
      evaluatorId: map['evaluatorId'] as String,
      status: map['status'] as String,
      environmentalServices: List<String>.from(map['environmentalServices']),
      ownerName: map['ownerName'] as String,
      ownerCpf: map['ownerCpf'] as String,
      hasCAR: map['hasCAR'] as bool,
      carNumber: map['carNumber'] as String?,
      location: Location(
        latitude: map['location']['latitude'],
        longitude: map['location']['longitude'],
      ),
      altitude: map['altitude'],
      municipality: map['municipality'] as String,
      reference: map['reference'] as String,
      hasAPP: map['hasAPP'] as bool,
      appStatus: map['appStatus'] as String,
      hasWaterFlow: map['hasWaterFlow'] as bool,
      hasWetlandVegetation: map['hasWetlandVegetation'] as bool,
      hasFavorableTopography: map['hasFavorableTopography'] as bool,
      hasSoilSaturation: map['hasSoilSaturation'] as bool,
      springType: map['springType'] as String,
      springCharacteristic: map['springCharacteristic'] as String,
      diffusePoints: map['diffusePoints'] as int?,
      flowRegime: map['flowRegime'] as String,
      ownerResponse: map['ownerResponse'] as String?,
      informationSource: map['informationSource'] as String?,
      hydroEnvironmentalScores: Map<String, int>.from(map['hydroEnvironmentalScores']),
      hydroEnvironmentalTotal: map['hydroEnvironmentalTotal'] as int,
      surroundingConditions: Map<String, int>.from(map['surroundingConditions']),
      springConditions: Map<String, int>.from(map['springConditions']),
      anthropicImpacts: Map<String, int>.from(map['anthropicImpacts']),
      generalState: map['generalState'] as String,
      primaryUse: map['primaryUse'] as String,
      hasWaterAnalysis: map['hasWaterAnalysis'] as bool,
      analysisDate: map['analysisDate'] as DateTime?,
      analysisParameters: map['analysisParameters'] as String?,
      hasFlowRate: map['hasFlowRate'] as bool,
      flowRateValue: map['flowRateValue'] as double?,
      flowRateDate: map['flowRateDate'] as DateTime?,
      photoReferences: List<String>.from(map['photoReferences']),
      recommendations: map['recommendations'] as String?,
      createdAt: map['createdAt'] as DateTime,
      updatedAt: map['updatedAt'] as DateTime,
      submittedAt: map['submittedAt'] as DateTime?,
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

  // Método para converter para JSON
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
      'location': {
        'latitude': location.latitude,
        'longitude': location.longitude,
      },
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

  // Método para criar a partir de JSON
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
      status: json['status'] as String? ?? 'pending',
      environmentalServices: json['environmentalServices'] != null 
          ? List<String>.from(json['environmentalServices'] as List)
          : [],
      ownerName: json['ownerName'] ?? '',
      ownerCpf: json['ownerCpf'] ?? '',
      hasCAR: json['hasCAR'] ?? false,
      carNumber: json['carNumber'],
      location: json['location'] != null 
          ? Location.fromJson(json['location'] as Map<String, dynamic>)
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
          ? Map<String, int>.from(json['hydroEnvironmentalScores'] as Map)
          : {},
      hydroEnvironmentalTotal: json['hydroEnvironmentalTotal'] ?? 0,
      surroundingConditions: json['surroundingConditions'] != null 
          ? Map<String, int>.from(json['surroundingConditions'] as Map)
          : {},
      springConditions: json['springConditions'] != null 
          ? Map<String, int>.from(json['springConditions'] as Map)
          : {},
      anthropicImpacts: json['anthropicImpacts'] != null 
          ? Map<String, int>.from(json['anthropicImpacts'] as Map)
          : {},
      generalState: json['generalState'] ?? '',
      primaryUse: json['primaryUse'] ?? '',
      hasWaterAnalysis: json['hasWaterAnalysis'] ?? false,
      analysisDate: json['analysisDate'] != null ? DateTime.parse(json['analysisDate'] as String) : null,
      analysisParameters: json['analysisParameters'],
      hasFlowRate: json['hasFlowRate'] ?? false,
      flowRateValue: parseDouble(json['flowRateValue']),
      flowRateDate: json['flowRateDate'] != null ? DateTime.parse(json['flowRateDate'] as String) : null,
      photoReferences: json['photoReferences'] != null 
          ? List<String>.from(json['photoReferences'] as List)
          : [],
      recommendations: json['recommendations'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : DateTime.now(),
      submittedAt: json['submittedAt'] != null ? DateTime.parse(json['submittedAt'] as String) : null,
    );
  }

  SpringAssessment copyWith({
    String? id,
    String? springId,
    String? evaluatorId,
    String? status,
    List<String>? environmentalServices,
    String? ownerName,
    String? ownerCpf,
    bool? hasCAR,
    String? carNumber,
    Location? location,
    double? altitude,
    String? municipality,
    String? reference,
    bool? hasAPP,
    String? appStatus,
    bool? hasWaterFlow,
    bool? hasWetlandVegetation,
    bool? hasFavorableTopography,
    bool? hasSoilSaturation,
    String? springType,
    String? springCharacteristic,
    int? diffusePoints,
    String? flowRegime,
    String? ownerResponse,
    String? informationSource,
    Map<String, int>? hydroEnvironmentalScores,
    int? hydroEnvironmentalTotal,
    Map<String, int>? surroundingConditions,
    Map<String, int>? springConditions,
    Map<String, int>? anthropicImpacts,
    String? generalState,
    String? primaryUse,
    bool? hasWaterAnalysis,
    DateTime? analysisDate,
    String? analysisParameters,
    bool? hasFlowRate,
    double? flowRateValue,
    DateTime? flowRateDate,
    List<String>? photoReferences,
    String? recommendations,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? submittedAt,
  }) {
    return SpringAssessment(
      id: id != null ? id : this.id,
      springId: springId != null ? springId : this.springId,
      evaluatorId: evaluatorId != null ? evaluatorId : this.evaluatorId,
      status: status ?? this.status,
      environmentalServices: environmentalServices ?? this.environmentalServices,
      ownerName: ownerName ?? this.ownerName,
      ownerCpf: ownerCpf ?? this.ownerCpf,
      hasCAR: hasCAR ?? this.hasCAR,
      carNumber: carNumber ?? this.carNumber,
      location: location ?? this.location,
      altitude: altitude ?? this.altitude,
      municipality: municipality ?? this.municipality,
      reference: reference ?? this.reference,
      hasAPP: hasAPP ?? this.hasAPP,
      appStatus: appStatus ?? this.appStatus,
      hasWaterFlow: hasWaterFlow ?? this.hasWaterFlow,
      hasWetlandVegetation: hasWetlandVegetation ?? this.hasWetlandVegetation,
      hasFavorableTopography: hasFavorableTopography ?? this.hasFavorableTopography,
      hasSoilSaturation: hasSoilSaturation ?? this.hasSoilSaturation,
      springType: springType ?? this.springType,
      springCharacteristic: springCharacteristic ?? this.springCharacteristic,
      diffusePoints: diffusePoints ?? this.diffusePoints,
      flowRegime: flowRegime ?? this.flowRegime,
      ownerResponse: ownerResponse ?? this.ownerResponse,
      informationSource: informationSource ?? this.informationSource,
      hydroEnvironmentalScores: hydroEnvironmentalScores ?? this.hydroEnvironmentalScores,
      hydroEnvironmentalTotal: hydroEnvironmentalTotal ?? this.hydroEnvironmentalTotal,
      surroundingConditions: surroundingConditions ?? this.surroundingConditions,
      springConditions: springConditions ?? this.springConditions,
      anthropicImpacts: anthropicImpacts ?? this.anthropicImpacts,
      generalState: generalState ?? this.generalState,
      primaryUse: primaryUse ?? this.primaryUse,
      hasWaterAnalysis: hasWaterAnalysis ?? this.hasWaterAnalysis,
      analysisDate: analysisDate ?? this.analysisDate,
      analysisParameters: analysisParameters ?? this.analysisParameters,
      hasFlowRate: hasFlowRate ?? this.hasFlowRate,
      flowRateValue: flowRateValue ?? this.flowRateValue,
      flowRateDate: flowRateDate ?? this.flowRateDate,
      photoReferences: photoReferences ?? this.photoReferences,
      recommendations: recommendations ?? this.recommendations,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      submittedAt: submittedAt ?? this.submittedAt,
    );
  }
} 