import 'package:mongo_dart/mongo_dart.dart';
import 'package:agua_viva/models/location.dart';

class SpringAssessment {
  final ObjectId id;
  final ObjectId springId;
  final ObjectId evaluatorId;
  final String status; // 'draft', 'pending', 'approved', 'rejected'
  final List<String> environmentalServices;
  final String ownerName;
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
  String get idString => id.toHexString();
  String get springIdString => springId.toHexString();
  String get evaluatorIdString => evaluatorId.toHexString();

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'springId': springId,
      'evaluatorId': evaluatorId,
      'status': status,
      'environmentalServices': environmentalServices,
      'ownerName': ownerName,
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
      id: map['_id'] is String ? ObjectId.parse(map['_id']) : map['_id'],
      springId: map['springId'] is String ? ObjectId.parse(map['springId']) : map['springId'],
      evaluatorId: map['evaluatorId'] is String ? ObjectId.parse(map['evaluatorId']) : map['evaluatorId'],
      status: map['status'],
      environmentalServices: List<String>.from(map['environmentalServices']),
      ownerName: map['ownerName'],
      hasCAR: map['hasCAR'],
      carNumber: map['carNumber'],
      location: Location(
        latitude: map['location']['latitude'],
        longitude: map['location']['longitude'],
      ),
      altitude: map['altitude'],
      municipality: map['municipality'],
      reference: map['reference'],
      hasAPP: map['hasAPP'],
      appStatus: map['appStatus'],
      hasWaterFlow: map['hasWaterFlow'],
      hasWetlandVegetation: map['hasWetlandVegetation'],
      hasFavorableTopography: map['hasFavorableTopography'],
      hasSoilSaturation: map['hasSoilSaturation'],
      springType: map['springType'],
      springCharacteristic: map['springCharacteristic'],
      diffusePoints: map['diffusePoints'],
      flowRegime: map['flowRegime'],
      ownerResponse: map['ownerResponse'],
      informationSource: map['informationSource'],
      hydroEnvironmentalScores: Map<String, int>.from(map['hydroEnvironmentalScores']),
      hydroEnvironmentalTotal: map['hydroEnvironmentalTotal'],
      surroundingConditions: Map<String, int>.from(map['surroundingConditions']),
      springConditions: Map<String, int>.from(map['springConditions']),
      anthropicImpacts: Map<String, int>.from(map['anthropicImpacts']),
      generalState: map['generalState'],
      primaryUse: map['primaryUse'],
      hasWaterAnalysis: map['hasWaterAnalysis'],
      analysisDate: map['analysisDate'],
      analysisParameters: map['analysisParameters'],
      hasFlowRate: map['hasFlowRate'],
      flowRateValue: map['flowRateValue'],
      flowRateDate: map['flowRateDate'],
      photoReferences: List<String>.from(map['photoReferences']),
      recommendations: map['recommendations'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
      submittedAt: map['submittedAt'],
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
      id: ObjectId.parse(id),
      springId: ObjectId.parse(springId),
      evaluatorId: ObjectId.parse(evaluatorId),
      status: status,
      environmentalServices: environmentalServices,
      ownerName: ownerName,
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
      'id': id.toHexString(),
      'springId': springId.toHexString(),
      'evaluatorId': evaluatorId.toHexString(),
      'status': status,
      'environmentalServices': environmentalServices,
      'ownerName': ownerName,
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
    return SpringAssessment(
      id: ObjectId.parse(json['id']),
      springId: ObjectId.parse(json['springId']),
      evaluatorId: ObjectId.parse(json['evaluatorId']),
      status: json['status'],
      environmentalServices: List<String>.from(json['environmentalServices']),
      ownerName: json['ownerName'],
      hasCAR: json['hasCAR'],
      carNumber: json['carNumber'],
      location: Location(
        latitude: json['location']['latitude'],
        longitude: json['location']['longitude'],
      ),
      altitude: json['altitude'],
      municipality: json['municipality'],
      reference: json['reference'],
      hasAPP: json['hasAPP'],
      appStatus: json['appStatus'],
      hasWaterFlow: json['hasWaterFlow'],
      hasWetlandVegetation: json['hasWetlandVegetation'],
      hasFavorableTopography: json['hasFavorableTopography'],
      hasSoilSaturation: json['hasSoilSaturation'],
      springType: json['springType'],
      springCharacteristic: json['springCharacteristic'],
      diffusePoints: json['diffusePoints'],
      flowRegime: json['flowRegime'],
      ownerResponse: json['ownerResponse'],
      informationSource: json['informationSource'],
      hydroEnvironmentalScores: Map<String, int>.from(json['hydroEnvironmentalScores']),
      hydroEnvironmentalTotal: json['hydroEnvironmentalTotal'],
      surroundingConditions: Map<String, int>.from(json['surroundingConditions']),
      springConditions: Map<String, int>.from(json['springConditions']),
      anthropicImpacts: Map<String, int>.from(json['anthropicImpacts']),
      generalState: json['generalState'],
      primaryUse: json['primaryUse'],
      hasWaterAnalysis: json['hasWaterAnalysis'],
      analysisDate: json['analysisDate'] != null ? DateTime.parse(json['analysisDate']) : null,
      analysisParameters: json['analysisParameters'],
      hasFlowRate: json['hasFlowRate'],
      flowRateValue: json['flowRateValue'],
      flowRateDate: json['flowRateDate'] != null ? DateTime.parse(json['flowRateDate']) : null,
      photoReferences: List<String>.from(json['photoReferences']),
      recommendations: json['recommendations'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      submittedAt: json['submittedAt'] != null ? DateTime.parse(json['submittedAt']) : null,
    );
  }
} 