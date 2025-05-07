import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agua_viva/services/auth_service.dart';
import 'package:agua_viva/models/spring_assessment_model.dart';
import 'package:agua_viva/services/assessment_service.dart';
import 'package:agua_viva/theme.dart';
import 'package:agua_viva/utils/image_upload.dart';

class AssessmentFormScreen extends StatefulWidget {
  final String? existingAssessmentId;

  const AssessmentFormScreen({Key? key, this.existingAssessmentId}) : super(key: key);

  @override
  State<AssessmentFormScreen> createState() => _AssessmentFormScreenState();
}

class _AssessmentFormScreenState extends State<AssessmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late AssessmentService _assessmentService;
  late AuthService _authService;
  
  // Stepper steps
  int _currentStep = 0;
  bool _isLoading = false;
  
  // Form data
  // Owner Information
  final TextEditingController _ownerNameController = TextEditingController();
  bool _hasCAR = false;
  
  // Location
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _altitudeController = TextEditingController();
  final TextEditingController _municipalityController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  
  // APP
  bool _hasAPP = false;
  String _appStatus = 'Bom';
  
  // Spring Analysis
  bool _hasWaterFlow = false;
  bool _hasWetlandVegetation = false;
  bool _hasFavorableTopography = false;
  bool _hasSoilSaturation = false;
  
  // Spring Type
  String _springType = 'Encosta / Eluvial';
  String _springCharacteristic = 'Pontual';
  int _diffusePoints = 1;
  String _flowRegime = 'Perene';
  String? _ownerResponse;
  String? _informationSource;
  
  // Environmental Assessment
  Map<String, int> _hydroEnvironmentalScores = {
    'waterColor': 2,
    'waterOdor': 3,
    'solidWaste': 3,
    'floatingMaterials': 3,
    'foam': 3,
    'oils': 3,
    'sewage': 3,
    'vegetation': 2,
    'uses': 3,
    'access': 2,
    'urbanEquipment': 3,
  };
  
  // Risk Assessment
  Map<String, int> _surroundingConditions = {
    'landUse': 2,
    'groundCover': 2,
    'riparianVegetation': 2,
  };
  
  Map<String, int> _springConditions = {
    'physicalState': 2,
    'flowProduced': 2,
    'humanIntervention': 2,
    'emergence': 2,
  };
  
  Map<String, int> _anthropicImpacts = {
    'infrastructure': 1,
    'erosion': 2,
    'silting': 1,
    'animalPresence': 2,
    'animalOrigin': 2,
    'soilCompaction': 2,
    'pollutionSources': 1,
  };
  
  // Final Assessment
  String _generalState = 'Perturbada';
  String _primaryUse = 'Abastecimento humano';
  
  // Water Quality
  bool _hasWaterAnalysis = false;
  DateTime? _analysisDate;
  String? _analysisParameters;
  
  // Flow Rate
  bool _hasFlowRate = false;
  double? _flowRateValue;
  DateTime? _flowRateDate;
  
  // Photos
  List<String> _photoReferences = [];
  String? _recommendations;
  
  // For loading existing data
  bool _dataLoaded = false;

  @override
  void initState() {
    super.initState();
    // Set default values for latitude and longitude
    _latitudeController.text = '-23.5505';
    _longitudeController.text = '-46.6333';
    _altitudeController.text = '760.5';
    
    // Load existing assessment if editing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _assessmentService = Provider.of<AssessmentService>(context, listen: false);
      _authService = Provider.of<AuthService>(context, listen: false);
      
      if (widget.existingAssessmentId != null) {
        _loadExistingAssessment();
      } else {
        setState(() {
          _dataLoaded = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _ownerNameController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _altitudeController.dispose();
    _municipalityController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingAssessment() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final assessment = await _assessmentService.getAssessmentById(widget.existingAssessmentId!);
      
      if (assessment != null) {
        // Set all form fields from assessment data
        _ownerNameController.text = assessment.ownerName;
        _hasCAR = assessment.hasCAR;
        
        _latitudeController.text = assessment.location.latitude.toString();
        _longitudeController.text = assessment.location.longitude.toString();
        _altitudeController.text = assessment.altitude.toString();
        _municipalityController.text = assessment.municipality;
        _referenceController.text = assessment.reference;
        
        _hasAPP = assessment.hasAPP;
        _appStatus = assessment.appStatus;
        
        _hasWaterFlow = assessment.hasWaterFlow;
        _hasWetlandVegetation = assessment.hasWetlandVegetation;
        _hasFavorableTopography = assessment.hasFavorableTopography;
        _hasSoilSaturation = assessment.hasSoilSaturation;
        
        _springType = assessment.springType;
        _springCharacteristic = assessment.springCharacteristic;
        _diffusePoints = assessment.diffusePoints ?? 1;
        _flowRegime = assessment.flowRegime;
        _ownerResponse = assessment.ownerResponse;
        _informationSource = assessment.informationSource;
        
        _hydroEnvironmentalScores = assessment.hydroEnvironmentalScores;
        _surroundingConditions = assessment.surroundingConditions;
        _springConditions = assessment.springConditions;
        _anthropicImpacts = assessment.anthropicImpacts;
        
        _generalState = assessment.generalState;
        _primaryUse = assessment.primaryUse;
        
        _hasWaterAnalysis = assessment.hasWaterAnalysis;
        _analysisDate = assessment.analysisDate;
        _analysisParameters = assessment.analysisParameters;
        
        _hasFlowRate = assessment.hasFlowRate;
        _flowRateValue = assessment.flowRateValue;
        _flowRateDate = assessment.flowRateDate;
        
        _photoReferences = assessment.photoReferences;
        _recommendations = assessment.recommendations;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
        _dataLoaded = true;
      });
    }
  }

  int _calculateHydroEnvironmentalTotal() {
    return _hydroEnvironmentalScores.values.fold(0, (sum, score) => sum + score);
  }

  Future<void> _saveAssessment(bool submit) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }
      
      // Create/update Spring record first
      final spring = Spring(
        id: '', // This will be auto-generated or updated by the service
        ownerId: userId,
        ownerName: _ownerNameController.text,
        location: Location(
          latitude: double.parse(_latitudeController.text),
          longitude: double.parse(_longitudeController.text),
        ),
        altitude: double.parse(_altitudeController.text),
        municipality: _municipalityController.text,
        reference: _referenceController.text,
        hasCAR: _hasCAR,
        hasAPP: _hasAPP,
        appStatus: _appStatus,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final springId = await _assessmentService.saveSpring(spring);

      // Then create/update the Assessment
      final assessment = SpringAssessment(
        id: widget.existingAssessmentId ?? '',
        springId: springId,
        evaluatorId: userId,
        status: submit ? 'pending' : 'draft',
        environmentalServices: [], // Simplified for MVP
        ownerName: _ownerNameController.text,
        hasCAR: _hasCAR,
        location: Location(
          latitude: double.parse(_latitudeController.text),
          longitude: double.parse(_longitudeController.text),
        ),
        altitude: double.parse(_altitudeController.text),
        municipality: _municipalityController.text,
        reference: _referenceController.text,
        hasAPP: _hasAPP,
        appStatus: _appStatus,
        hasWaterFlow: _hasWaterFlow,
        hasWetlandVegetation: _hasWetlandVegetation,
        hasFavorableTopography: _hasFavorableTopography,
        hasSoilSaturation: _hasSoilSaturation,
        springType: _springType,
        springCharacteristic: _springCharacteristic,
        diffusePoints: _springCharacteristic == 'Difusa' ? _diffusePoints : null,
        flowRegime: _flowRegime,
        ownerResponse: _flowRegime == 'Sem vazão no momento da visita' ? _ownerResponse : null,
        informationSource: _flowRegime == 'Sem vazão no momento da visita' ? _informationSource : null,
        hydroEnvironmentalScores: _hydroEnvironmentalScores,
        hydroEnvironmentalTotal: _calculateHydroEnvironmentalTotal(),
        surroundingConditions: _surroundingConditions,
        springConditions: _springConditions,
        anthropicImpacts: _anthropicImpacts,
        generalState: _generalState,
        primaryUse: _primaryUse,
        hasWaterAnalysis: _hasWaterAnalysis,
        analysisDate: _analysisDate,
        analysisParameters: _analysisParameters,
        hasFlowRate: _hasFlowRate,
        flowRateValue: _flowRateValue,
        flowRateDate: _flowRateDate,
        photoReferences: _photoReferences,
        recommendations: _recommendations,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        submittedAt: submit ? DateTime.now() : null,
      );

      await _assessmentService.saveAssessment(assessment);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(submit 
              ? 'Avaliação enviada com sucesso!' 
              : 'Avaliação salva com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_dataLoaded || _isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Avaliação de Nascente')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingAssessmentId != null 
            ? 'Editar Avaliação' 
            : 'Nova Avaliação'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            onPressed: () => _saveAssessment(false),
            tooltip: 'Salvar rascunho',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          type: StepperType.vertical,
          currentStep: _currentStep,
          onStepContinue: () {
            final lastStep = _currentStep >= 7;
            if (lastStep) {
              _saveAssessment(true);
            } else {
              setState(() {
                _currentStep += 1;
              });
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() {
                _currentStep -= 1;
              });
            }
          },
          controlsBuilder: (context, details) {
            final isLastStep = _currentStep == 7;
            return Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: details.onStepContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isLastStep 
                            ? Theme.of(context).colorScheme.secondary 
                            : Theme.of(context).colorScheme.primary,
                      ),
                      child: Text(
                        isLastStep ? 'Enviar' : 'Continuar',
                      ),
                    ),
                  ),
                  if (_currentStep > 0) ...[  
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: details.onStepCancel,
                        child: const Text('Voltar'),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
          steps: [
            _buildIdentificationStep(),
            _buildSpringAnalysisStep(),
            _buildSpringTypeStep(),
            _buildEnvironmentalAssessmentStep(),
            _buildSurroundingConditionsStep(),
            _buildSpringConditionsStep(),
            _buildAnthropicImpactsStep(),
            _buildFinalAssessmentStep(),
          ],
        ),
      ),
    );
  }

  Step _buildIdentificationStep() {
    return Step(
      title: const Text('Identificação do Proprietário'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _ownerNameController,
            decoration: const InputDecoration(
              labelText: 'Nome do proprietário',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, informe o nome do proprietário';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Área com CAR (Cadastro Ambiental Rural)?'),
            value: _hasCAR,
            onChanged: (value) {
              setState(() {
                _hasCAR = value;
              });
            },
            activeColor: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          const Text(
            'Localização Geográfica',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _latitudeController,
                  decoration: const InputDecoration(
                    labelText: 'Latitude',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe a latitude';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _longitudeController,
                  decoration: const InputDecoration(
                    labelText: 'Longitude',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe a longitude';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _altitudeController,
            decoration: const InputDecoration(
              labelText: 'Altitude (m)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Informe a altitude';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _municipalityController,
            decoration: const InputDecoration(
              labelText: 'Município',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Informe o município';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _referenceController,
            decoration: const InputDecoration(
              labelText: 'Referência (sítio, distrito ou outro ponto de apoio)',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Informe uma referência';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Áreas de Preservação Permanente (APP)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Possui área de APP?'),
            value: _hasAPP,
            onChanged: (value) {
              setState(() {
                _hasAPP = value;
              });
            },
            activeColor: Theme.of(context).colorScheme.primary,
          ),
          if (_hasAPP) ...[  
            const SizedBox(height: 8),
            const Text('Estado da APP:'),
            RadioListTile<String>(
              title: const Text('Bom'),
              value: 'Bom',
              groupValue: _appStatus,
              onChanged: (value) {
                setState(() {
                  _appStatus = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('Ruim'),
              value: 'Ruim',
              groupValue: _appStatus,
              onChanged: (value) {
                setState(() {
                  _appStatus = value!;
                });
              },
            ),
          ],
        ],
      ),
      isActive: _currentStep >= 0,
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
    );
  }

  Step _buildSpringAnalysisStep() {
    return Step(
      title: const Text('Análise da Nascente'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Análise Confirmatória da Nascente',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          _buildCriteriaCheckbox(
            'Presença de fluxo hídrico',
            'Identificação de água fluindo (aspecto dinâmico)',
            _hasWaterFlow,
            (value) {
              setState(() {
                _hasWaterFlow = value!;
              });
            },
          ),
          _buildCriteriaCheckbox(
            'Vegetação associada a áreas úmidas',
            'Presença de espécies indicadoras (samambaias, arbustos higrófilos)',
            _hasWetlandVegetation,
            (value) {
              setState(() {
                _hasWetlandVegetation = value!;
              });
            },
          ),
          _buildCriteriaCheckbox(
            'Condições topográficas favoráveis',
            'Presença de depressões ou encostas',
            _hasFavorableTopography,
            (value) {
              setState(() {
                _hasFavorableTopography = value!;
              });
            },
          ),
          _buildCriteriaCheckbox(
            'Indícios de saturação do solo',
            'Solo encharcado ou com empoçamento (aspecto hidrostático)',
            _hasSoilSaturation,
            (value) {
              setState(() {
                _hasSoilSaturation = value!;
              });
            },
          ),
        ],
      ),
      isActive: _currentStep >= 1,
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
    );
  }

  Widget _buildCriteriaCheckbox(
    String title,
    String subtitle,
    bool value,
    Function(bool?) onChanged,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: CheckboxListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).colorScheme.primary,
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  Step _buildSpringTypeStep() {
    return Step(
      title: const Text('Tipo de Nascente'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tipo de Nascente',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          RadioListTile<String>(
            title: const Text('Encosta / Eluvial'),
            value: 'Encosta / Eluvial',
            groupValue: _springType,
            onChanged: (value) {
              setState(() {
                _springType = value!;
              });
            },
          ),
          RadioListTile<String>(
            title: const Text('Depressão'),
            value: 'Depressão',
            groupValue: _springType,
            onChanged: (value) {
              setState(() {
                _springType = value!;
              });
            },
          ),
          RadioListTile<String>(
            title: const Text('Anticlinal'),
            value: 'Anticlinal',
            groupValue: _springType,
            onChanged: (value) {
              setState(() {
                _springType = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Característica Física da Nascente',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          RadioListTile<String>(
            title: const Text('Pontual'),
            value: 'Pontual',
            groupValue: _springCharacteristic,
            onChanged: (value) {
              setState(() {
                _springCharacteristic = value!;
              });
            },
          ),
          RadioListTile<String>(
            title: const Text('Difusa'),
            value: 'Difusa',
            groupValue: _springCharacteristic,
            onChanged: (value) {
              setState(() {
                _springCharacteristic = value!;
              });
            },
          ),
          if (_springCharacteristic == 'Difusa') ...[  
            const SizedBox(height: 8),
            TextFormField(
              initialValue: _diffusePoints.toString(),
              decoration: const InputDecoration(
                labelText: 'Número de pontos',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Informe o número de pontos';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  _diffusePoints = int.tryParse(value) ?? 1;
                });
              },
            ),
          ],
          const SizedBox(height: 16),
          const Text(
            'Regime de Vazão da Nascente',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          RadioListTile<String>(
            title: const Text('Perene'),
            value: 'Perene',
            groupValue: _flowRegime,
            onChanged: (value) {
              setState(() {
                _flowRegime = value!;
              });
            },
          ),
          RadioListTile<String>(
            title: const Text('Intermitente'),
            value: 'Intermitente',
            groupValue: _flowRegime,
            onChanged: (value) {
              setState(() {
                _flowRegime = value!;
              });
            },
          ),
          RadioListTile<String>(
            title: const Text('Efêmera'),
            value: 'Efêmera',
            groupValue: _flowRegime,
            onChanged: (value) {
              setState(() {
                _flowRegime = value!;
              });
            },
          ),
          RadioListTile<String>(
            title: const Text('Sem vazão no momento da visita'),
            value: 'Sem vazão no momento da visita',
            groupValue: _flowRegime,
            onChanged: (value) {
              setState(() {
                _flowRegime = value!;
              });
            },
          ),
          if (_flowRegime == 'Sem vazão no momento da visita') ...[  
            const SizedBox(height: 8),
            TextFormField(
              initialValue: _ownerResponse,
              decoration: const InputDecoration(
                labelText: 'Resposta do proprietário quanto ao regime',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _ownerResponse = value;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('Fonte da informação:'),
            RadioListTile<String>(
              title: const Text('Observação direta do técnico'),
              value: 'Observação direta do técnico',
              groupValue: _informationSource,
              onChanged: (value) {
                setState(() {
                  _informationSource = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('Informação fornecida pelo proprietário'),
              value: 'Informação fornecida pelo proprietário',
              groupValue: _informationSource,
              onChanged: (value) {
                setState(() {
                  _informationSource = value!;
                });
              },
            ),
          ],
        ],
      ),
      isActive: _currentStep >= 2,
      state: _currentStep > 2 ? StepState.complete : StepState.indexed,
    );
  }

  Step _buildEnvironmentalAssessmentStep() {
    final totalScore = _calculateHydroEnvironmentalTotal();
    
    return Step(
      title: const Text('Avaliação Hidroambiental'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Avaliação Hidroambiental Geral',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'Atribua uma pontuação de 1 (ruim) a 3 (bom) para cada parâmetro.',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 16),
          _buildScoreRadioGroup('Cor da água', 'waterColor'),
          _buildScoreRadioGroup('Odor da água', 'waterOdor'),
          _buildScoreRadioGroup('Resíduos Sólidos', 'solidWaste'),
          _buildScoreRadioGroup('Materiais flutuantes', 'floatingMaterials'),
          _buildScoreRadioGroup('Espumas', 'foam'),
          _buildScoreRadioGroup('Óleos', 'oils'),
          _buildScoreRadioGroup('Esgoto na nascente', 'sewage'),
          _buildScoreRadioGroup('Vegetação (degradação)', 'vegetation'),
          _buildScoreRadioGroup('Usos', 'uses'),
          _buildScoreRadioGroup('Acesso', 'access'),
          _buildScoreRadioGroup('Equipamentos urbanos', 'urbanEquipment'),
          const SizedBox(height: 24),
          Text(
            'Pontuação Total: $totalScore/33',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            _getEnvironmentalClassification(totalScore),
            style: TextStyle(
              fontSize: 16,
              color: _getEnvironmentalColor(totalScore),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      isActive: _currentStep >= 3,
      state: _currentStep > 3 ? StepState.complete : StepState.indexed,
    );
  }

  String _getEnvironmentalClassification(int score) {
    if (score <= 11) {
      return 'Severamente Impactada';
    } else if (score <= 22) {
      return 'Moderadamente Impactada';
    } else {
      return 'Preservada';
    }
  }

  Color _getEnvironmentalColor(int score) {
    if (score <= 11) {
      return Colors.red;
    } else if (score <= 22) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  Widget _buildScoreRadioGroup(String title, String scoreKey) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildScoreRadio(scoreKey, 1, 'Ruim'),
                _buildScoreRadio(scoreKey, 2, 'Médio'),
                _buildScoreRadio(scoreKey, 3, 'Bom'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreRadio(String scoreKey, int value, String label) {
    return Row(
      children: [
        Radio<int>(
          value: value,
          groupValue: _hydroEnvironmentalScores[scoreKey],
          onChanged: (newValue) {
            setState(() {
              _hydroEnvironmentalScores[scoreKey] = newValue!;
            });
          },
        ),
        Text(label),
      ],
    );
  }

  Step _buildSurroundingConditionsStep() {
    return Step(
      title: const Text('Condições do Entorno'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Condições do Entorno da Nascente',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          _buildRiskRadioGroup(
            'Uso do Solo',
            {
              1: 'Floresta nativa preservada',
              2: 'Em recuperação',
              3: 'Pastagem manejada',
            },
            'landUse',
            _surroundingConditions,
          ),
          _buildRiskRadioGroup(
            'Cobertura do Solo',
            {
              1: 'Vegetação densa',
              2: 'Vegetação rala',
              3: 'Solo exposto/desmatado',
            },
            'groundCover',
            _surroundingConditions,
          ),
          _buildRiskRadioGroup(
            'Vegetação Ciliar',
            {
              1: 'Preservada >30m',
              2: 'Em recuperação 10–30m',
              3: 'Degradada <10m',
            },
            'riparianVegetation',
            _surroundingConditions,
          ),
        ],
      ),
      isActive: _currentStep >= 4,
      state: _currentStep > 4 ? StepState.complete : StepState.indexed,
    );
  }

  Step _buildSpringConditionsStep() {
    return Step(
      title: const Text('Condição da Nascente'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Condição Física da Nascente',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          _buildRiskRadioGroup(
            'Estado Físico',
            {
              1: 'Preservada',
              2: 'Parcialmente alterada',
              3: 'Artificial',
            },
            'physicalState',
            _springConditions,
          ),
          _buildRiskRadioGroup(
            'Vazão Produzida',
            {
              1: 'Estável',
              2: 'Variação sazonal leve',
              3: 'Intermitente/seca',
            },
            'flowProduced',
            _springConditions,
          ),
          _buildRiskRadioGroup(
            'Intervenção Humana',
            {
              1: 'Nenhuma',
              2: 'Captação moderada',
              3: 'Captação intensa/represamento',
            },
            'humanIntervention',
            _springConditions,
          ),
          _buildRiskRadioGroup(
            'Afloramento',
            {
              1: 'Natural e bem definido',
              2: 'Alterado, funcional',
              3: 'Modificado/canalizado',
            },
            'emergence',
            _springConditions,
          ),
        ],
      ),
      isActive: _currentStep >= 5,
      state: _currentStep > 5 ? StepState.complete : StepState.indexed,
    );
  }

  Step _buildAnthropicImpactsStep() {
    return Step(
      title: const Text('Impactos Antrópicos e Ambientais'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Impactos Antrópicos e Ambientais',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          _buildRiskRadioGroup(
            'Presença de Infraestrutura',
            {
              1: 'Nenhuma',
              2: 'Moderada',
              3: 'Próxima',
            },
            'infrastructure',
            _anthropicImpacts,
          ),
          _buildRiskRadioGroup(
            'Erosão',
            {
              1: 'Ausente',
              2: 'Erosão laminar',
              3: 'Ravinas/voçorocas',
            },
            'erosion',
            _anthropicImpacts,
          ),
          _buildRiskRadioGroup(
            'Assoreamento',
            {
              1: 'Ausente',
              2: 'Moderado',
              3: 'Significativo',
            },
            'silting',
            _anthropicImpacts,
          ),
          _buildRiskRadioGroup(
            'Presença de Animais',
            {
              1: 'Nenhuma',
              2: 'Acesso esporádico',
              3: 'Frequente',
            },
            'animalPresence',
            _anthropicImpacts,
          ),
          _buildRiskRadioGroup(
            'Origem dos Animais',
            {
              1: 'Não há influência',
              2: 'Entrada ocasional',
              3: 'Entrada constante',
            },
            'animalOrigin',
            _anthropicImpacts,
          ),
          _buildRiskRadioGroup(
            'Compactação do Solo',
            {
              1: 'Ausente',
              2: 'Moderada',
              3: 'Severa',
            },
            'soilCompaction',
            _anthropicImpacts,
          ),
          _buildRiskRadioGroup(
            'Fontes de Poluição',
            {
              1: 'Ausentes',
              2: 'Distantes',
              3: 'Próximas',
            },
            'pollutionSources',
            _anthropicImpacts,
          ),
        ],
      ),
      isActive: _currentStep >= 6,
      state: _currentStep > 6 ? StepState.complete : StepState.indexed,
    );
  }

  Widget _buildRiskRadioGroup(
    String title,
    Map<int, String> options,
    String riskKey,
    Map<String, int> riskMap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            ...options.entries.map((entry) {
              return RadioListTile<int>(
                title: Text(entry.value),
                value: entry.key,
                groupValue: riskMap[riskKey],
                onChanged: (value) {
                  setState(() {
                    riskMap[riskKey] = value!;
                  });
                },
                dense: true,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Step _buildFinalAssessmentStep() {
    return Step(
      title: const Text('Avaliação Final'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estado Geral da Nascente',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          RadioListTile<String>(
            title: const Text('Preservada'),
            value: 'Preservada',
            groupValue: _generalState,
            onChanged: (value) {
              setState(() {
                _generalState = value!;
              });
            },
          ),
          RadioListTile<String>(
            title: const Text('Perturbada'),
            value: 'Perturbada',
            groupValue: _generalState,
            onChanged: (value) {
              setState(() {
                _generalState = value!;
              });
            },
          ),
          RadioListTile<String>(
            title: const Text('Degradada'),
            value: 'Degradada',
            groupValue: _generalState,
            onChanged: (value) {
              setState(() {
                _generalState = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Uso Prioritário',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          DropdownButtonFormField<String>(
            value: _primaryUse,
            decoration: const InputDecoration(
              labelText: 'Uso principal da água',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: 'Abastecimento humano',
                child: Text('Abastecimento humano'),
              ),
              DropdownMenuItem(
                value: 'Agricultura',
                child: Text('Agricultura'),
              ),
              DropdownMenuItem(
                value: 'Criação de animais',
                child: Text('Criação de animais'),
              ),
              DropdownMenuItem(
                value: 'Recreação',
                child: Text('Recreação'),
              ),
              DropdownMenuItem(
                value: 'Conservação',
                child: Text('Conservação'),
              ),
              DropdownMenuItem(
                value: 'Outro',
                child: Text('Outro'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _primaryUse = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Análise da Água',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SwitchListTile(
            title: const Text('Possui análise da água?'),
            value: _hasWaterAnalysis,
            onChanged: (value) {
              setState(() {
                _hasWaterAnalysis = value;
              });
            },
            activeColor: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          const Text(
            'Medição de Vazão',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SwitchListTile(
            title: const Text('Possui medição de vazão?'),
            value: _hasFlowRate,
            onChanged: (value) {
              setState(() {
                _hasFlowRate = value;
              });
            },
            activeColor: Theme.of(context).colorScheme.primary,
          ),
          if (_hasFlowRate) ...[
            const SizedBox(height: 8),
            TextFormField(
              initialValue: _flowRateValue?.toString(),
              decoration: const InputDecoration(
                labelText: 'Vazão (L/s)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _flowRateValue = double.tryParse(value);
                });
              },
            ),
          ],
          const SizedBox(height: 16),
          const Text(
            'Recomendações Técnicas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: _recommendations,
            decoration: const InputDecoration(
              labelText: 'Recomendações para o proprietário',
              border: OutlineInputBorder(),
              hintText: 'Descreva as recomendações técnicas para preservação ou recuperação da nascente...',
            ),
            maxLines: 4,
            onChanged: (value) {
              setState(() {
                _recommendations = value;
              });
            },
          ),
        ],
      ),
      isActive: _currentStep >= 7,
      state: _currentStep > 7 ? StepState.complete : StepState.indexed,
    );
  }
}
