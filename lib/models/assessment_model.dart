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
      id: map['_id'],
      springId: map['springId'],
      evaluatorId: map['evaluatorId'],
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
} 