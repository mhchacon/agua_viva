import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agua_viva/models/assessment_model.dart';
import 'package:agua_viva/services/assessment_service.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:agua_viva/screens/review_and_submit_screen.dart';
import 'package:agua_viva/utils/logger.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'package:agua_viva/services/location_service.dart';

class AssessmentFormScreen extends StatefulWidget {
  final String? existingAssessmentId;

  const AssessmentFormScreen({Key? key, this.existingAssessmentId}) : super(key: key);

  @override
  State<AssessmentFormScreen> createState() => _AssessmentFormScreenState();
}

class _AssessmentFormScreenState extends State<AssessmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late AssessmentService _assessmentService;
  
  // Stepper steps
  int _currentStep = 0;
  bool _isLoading = false;
  
  // Form data
  // Owner Information
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _ownerCpfController = TextEditingController();
  bool _hasCAR = false;
  final TextEditingController _carNumberController = TextEditingController();
  
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

  // Adicionar controladores para datas
  DateTime? _selectedAnalysisDate;
  DateTime? _selectedFlowRateDate;
  DateTime? _selectedPhotoDate;

  final _logger = AppLogger();

  // Função utilitária para exibir o DatePicker
  Future<void> _selectDate(BuildContext context, DateTime? initialDate, Function(DateTime) onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null) {
      onDateSelected(picked);
    }
  }

  @override
  void initState() {
    super.initState();
    // Set default values for latitude and longitude
    _latitudeController.text = '-23.5505';
    _longitudeController.text = '-46.6333';
    _altitudeController.text = '760.5';

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        _logger.info('Iniciando AssessmentFormScreen...');
        _assessmentService = Provider.of<AssessmentService>(context, listen: false);
        _logger.info('AssessmentService obtido com sucesso.');
        if (widget.existingAssessmentId != null) {
          _logger.info('Carregando avaliação existente: ${widget.existingAssessmentId}');
          await _loadExistingAssessment();
        } else {
          setState(() {
            _dataLoaded = true;
          });
          _logger.info('Formulário novo, dados carregados.');
        }
      } catch (e, stack) {
        _logger.error('Erro ao inicializar formulário: $e');
        print(stack);
        if (mounted) {
          setState(() {
            _dataLoaded = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao inicializar formulário: $e')),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _ownerNameController.dispose();
    _ownerCpfController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _altitudeController.dispose();
    _municipalityController.dispose();
    _referenceController.dispose();
    _carNumberController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingAssessment() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _logger.info('Buscando avaliação no banco...');
      final assessment = await _assessmentService.getAssessmentById(widget.existingAssessmentId!);
      _logger.info('Avaliação recebida: $assessment');
      if (assessment != null) {
        // Set all form fields from assessment data
        _ownerNameController.text = assessment.ownerName;
        _ownerCpfController.text = assessment.ownerCpf;
        _hasCAR = assessment.hasCAR;
        _carNumberController.text = assessment.carNumber ?? '';
        
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
        _logger.info('Campos do formulário preenchidos com dados da avaliação.');
      }
    } catch (e, stack) {
      _logger.error('Erro ao carregar dados da avaliação: $e');
      print(stack);
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
      _logger.info('Finalizado carregamento dos dados. _dataLoaded=$_dataLoaded');
    }
  }

  int _calculateHydroEnvironmentalTotal() {
    return _hydroEnvironmentalScores.values.fold(0, (sum, score) => sum + score);
  }

  // Função para calcular o total de pontos de risco ambiental
  int _calculateTotalRiskScore() {
    final entorno = _surroundingConditions.values.fold(0, (a, b) => a + b);
    final nascente = _springConditions.values.fold(0, (a, b) => a + b);
    final impactos = _anthropicImpacts.values.fold(0, (a, b) => a + b);
    return entorno + nascente + impactos;
  }

  // Função para classificar o risco ambiental
  String _getRiskLevel(int score) {
    if (score >= 14 && score <= 21) return 'Baixo';
    if (score >= 22 && score <= 31) return 'Médio';
    if (score >= 32 && score <= 42) return 'Alto';
    return 'Indefinido';
  }

  Color _getRiskColor(String level) {
    switch (level) {
      case 'Baixo':
        return Colors.green;
      case 'Médio':
        return Colors.amber;
      case 'Alto':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _saveAssessment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final assessment = SpringAssessment.fromJson({
        'id': const Uuid().v4(),
        'ownerName': _ownerNameController.text,
        'ownerCpf': _ownerCpfController.text,
        'hasCAR': _hasCAR,
        'carNumber': _carNumberController.text,
        'location': {
          'latitude': double.parse(_latitudeController.text),
          'longitude': double.parse(_longitudeController.text),
        },
        'altitude': double.parse(_altitudeController.text),
        'municipality': _municipalityController.text,
        'reference': _referenceController.text,
        'hasAPP': _hasAPP,
        'appStatus': _appStatus,
        'hasWaterFlow': _hasWaterFlow,
        'hasWetlandVegetation': _hasWetlandVegetation,
        'hasFavorableTopography': _hasFavorableTopography,
        'hasSoilSaturation': _hasSoilSaturation,
        'springType': _springType,
        'springCharacteristic': _springCharacteristic,
        'diffusePoints': _diffusePoints,
        'flowRegime': _flowRegime,
        'ownerResponse': _ownerResponse,
        'informationSource': _informationSource,
        'hydroEnvironmentalScores': _hydroEnvironmentalScores,
        'hydroEnvironmentalTotal': _calculateHydroEnvironmentalTotal(),
        'surroundingConditions': _surroundingConditions,
        'springConditions': _springConditions,
        'anthropicImpacts': _anthropicImpacts,
        'riskTotal': _calculateTotalRiskScore(),
        'generalState': _generalState,
        'primaryUse': _primaryUse,
        'hasWaterAnalysis': _hasWaterAnalysis,
        'analysisDate': _analysisDate?.toIso8601String(),
        'analysisParameters': _analysisParameters,
        'hasFlowRate': _hasFlowRate,
        'flowRateValue': _flowRateValue,
        'flowRateDate': _flowRateDate?.toIso8601String(),
        'photoReferences': _photoReferences,
        'recommendations': _recommendations,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      await _assessmentService.saveAssessment(assessment);
      
      if (mounted) {
        _logger.info('Avaliação salva com sucesso!');
        Navigator.pop(context);
      }
    } catch (e) {
      _logger.error('Erro ao salvar avaliação: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar avaliação: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1024,
      );
      
      if (image != null) {
        setState(() {
          _isLoading = true;
        });

        try {
          final String photoId = const Uuid().v4();
          final String photoPath = 'photos/$photoId.jpg';
          
          await _assessmentService.uploadPhoto(image.path, photoPath);
          
          setState(() {
            _photoReferences.add(photoPath);
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Foto enviada com sucesso!')),
            );
          }
        } catch (e) {
          _logger.error('Erro ao fazer upload da foto: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erro ao enviar foto: $e')),
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
    } catch (e) {
      _logger.error('Erro ao capturar foto: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao capturar foto: $e')),
        );
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
            onPressed: _saveAssessment,
            tooltip: 'Salvar rascunho',
          ),
        ],
      ),
      body: _buildForm(),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: () {
          final lastStep = _currentStep >= 7;
          if (lastStep) {
            // Montar dados para revisão
            final assessmentData = {
              'ownerName': _ownerNameController.text,
              'ownerCpf': _ownerCpfController.text,
              'hasCAR': _hasCAR,
              'carNumber': _carNumberController.text,
              'latitude': _latitudeController.text,
              'longitude': _longitudeController.text,
              'altitude': _altitudeController.text,
              'municipality': _municipalityController.text,
              'reference': _referenceController.text,
              'hasAPP': _hasAPP,
              'appStatus': _appStatus,
              'hasWaterFlow': _hasWaterFlow,
              'hasWetlandVegetation': _hasWetlandVegetation,
              'hasFavorableTopography': _hasFavorableTopography,
              'hasSoilSaturation': _hasSoilSaturation,
              'springType': _springType,
              'springCharacteristic': _springCharacteristic,
              'diffusePoints': _diffusePoints,
              'flowRegime': _flowRegime,
              'ownerResponse': _ownerResponse,
              'informationSource': _informationSource,
              'hydroEnvironmentalScores': _hydroEnvironmentalScores,
              'hydroEnvironmentalTotal': _calculateHydroEnvironmentalTotal(),
              'surroundingConditions': _surroundingConditions,
              'springConditions': _springConditions,
              'anthropicImpacts': _anthropicImpacts,
              'riskTotal': _calculateTotalRiskScore(),
              'generalState': _generalState,
              'primaryUse': _primaryUse,
              'hasWaterAnalysis': _hasWaterAnalysis,
              'analysisDate': _analysisDate,
              'analysisParameters': _analysisParameters,
              'hasFlowRate': _hasFlowRate,
              'flowRateValue': _flowRateValue,
              'flowRateDate': _flowRateDate,
              'photoReferences': _photoReferences,
              'recommendations': _recommendations,
            };
            final hidroClass = _getEnvironmentalClassification(_calculateHydroEnvironmentalTotal());
            final riscoClass = _getRiskLevel(_calculateTotalRiskScore());
            final classificacaoFinal = _getFinalClassification(hidroClass, riscoClass);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ReviewAndSubmitScreen(
                  assessmentData: assessmentData,
                  classification: classificacaoFinal,
                ),
              ),
            );
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
                      isLastStep ? 'Enviar' : 'Próximo',
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
          TextFormField(
            controller: _ownerCpfController,
            decoration: const InputDecoration(
              labelText: 'CPF do proprietário',
              border: OutlineInputBorder(),
              hintText: 'Digite apenas os números',
            ),
            keyboardType: TextInputType.number,
            maxLength: 11,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, informe o CPF do proprietário';
              }
              if (value.length != 11) {
                return 'O CPF deve ter 11 dígitos';
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
          if (_hasCAR) ...[
            const SizedBox(height: 8),
            TextFormField(
              controller: _carNumberController,
              decoration: const InputDecoration(
                labelText: 'Número do CAR',
                border: OutlineInputBorder(),
                hintText: 'Digite o número do CAR (41 caracteres)',
              ),
              maxLength: 41,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, informe o número do CAR';
                }
                if (value.length != 41) {
                  return 'O número do CAR deve ter 41 caracteres';
                }
                return null;
              },
            ),
          ],
          const SizedBox(height: 16),
          const Text(
            'Localização Geográfica',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _getCurrentLocation,
            icon: const Icon(Icons.my_location),
            label: const Text('Obter Localização Atual'),
          ),
          const SizedBox(height: 16),
          TextFormField(
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
          const SizedBox(height: 8),
          TextFormField(
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
          const SizedBox(height: 8),
          TextFormField(
            controller: _altitudeController,
            decoration: const InputDecoration(
              labelText: 'Altitude (metros)',
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
          const SizedBox(height: 8),
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
          const SizedBox(height: 8),
          TextFormField(
            controller: _referenceController,
            decoration: const InputDecoration(
              labelText: 'Referência',
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
    if (score >= 31) {
      return 'Ótimo';
    } else if (score >= 28) {
      return 'Bom';
    } else if (score >= 25) {
      return 'Razoável';
    } else if (score >= 22) {
      return 'Ruim';
    } else {
      return 'Péssimo';
    }
  }

  Color _getEnvironmentalColor(int score) {
    if (score >= 31) {
      return const Color(0xFF00E676); // Ótimo - verde vivo
    } else if (score >= 28) {
      return Colors.green; // Bom - verde
    } else if (score >= 25) {
      return Colors.yellow[700]!; // Razoável - amarelo
    } else if (score >= 22) {
      return Colors.orange; // Ruim - laranja
    } else {
      return Colors.red; // Péssimo - vermelho
    }
  }

  Widget _buildScoreRadioGroup(String title, String scoreKey) {
    // Opções específicas para cada parâmetro
    final Map<String, List<Map<String, dynamic>>> options = {
      'waterColor': [
        {'label': 'Escura', 'value': 1},
        {'label': 'Clara', 'value': 2},
        {'label': 'Transparente', 'value': 3},
      ],
      'waterOdor': [
        {'label': 'Forte', 'value': 1},
        {'label': 'Com odor', 'value': 2},
        {'label': 'Ausente', 'value': 3},
      ],
      'solidWaste': [
        {'label': 'Presente', 'value': 1},
        {'label': 'Com odor', 'value': 2},
        {'label': 'Ausente', 'value': 3},
      ],
      'floatingMaterials': [
        {'label': 'Muito', 'value': 1},
        {'label': 'Pouco', 'value': 2},
        {'label': 'Ausente', 'value': 3},
      ],
      'foam': [
        {'label': 'Muito', 'value': 1},
        {'label': 'Pouco', 'value': 2},
        {'label': 'Ausente', 'value': 3},
      ],
      'oils': [
        {'label': 'Muito', 'value': 1},
        {'label': 'Pouco', 'value': 2},
        {'label': 'Ausente', 'value': 3},
      ],
      'sewage': [
        {'label': 'Visível', 'value': 1},
        {'label': 'Provável', 'value': 2},
        {'label': 'Ausente', 'value': 3},
      ],
      'vegetation': [
        {'label': 'Ausente', 'value': 1},
        {'label': 'Alterada', 'value': 2},
        {'label': 'Bom estado', 'value': 3},
      ],
      'uses': [
        {'label': 'Presente', 'value': 1},
        {'label': 'Moderada', 'value': 2},
        {'label': 'Ausente', 'value': 3},
      ],
      'access': [
        {'label': 'Acentuada', 'value': 1},
        {'label': 'Moderada', 'value': 2},
        {'label': 'Ausente', 'value': 3},
      ],
      'urbanEquipment': [
        {'label': '< 50 metros', 'value': 1},
        {'label': '50 a 100 metros', 'value': 2},
        {'label': '> 100 metros', 'value': 3},
      ],
    };

    final paramOptions = options[scoreKey] ?? [
      {'label': 'Ruim', 'value': 1},
      {'label': 'Médio', 'value': 2},
      {'label': 'Bom', 'value': 3},
    ];

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
              children: paramOptions.map((opt) => _buildScoreRadio(scoreKey, opt['value'], opt['label'])).toList(),
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
    final totalScore = _calculateTotalRiskScore();
    final riskClass = _getRiskLevel(totalScore);
    final riskColor = _getRiskColor(riskClass);
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
              1: 'Solo solto',
              2: 'Levemente compactado',
              3: 'Altamente compactado',
            },
            'soilCompaction',
            _anthropicImpacts,
          ),
          _buildRiskRadioGroup(
            'Fontes de Poluição',
            {
              1: 'Nenhuma',
              2: 'Resíduos/agroquímicos moderados',
              3: 'Contaminação visível',
            },
            'pollutionSources',
            _anthropicImpacts,
          ),
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                Text(
                  'Pontuação Total do Risco Ambiental:',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  '$totalScore',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: riskColor),
                ),
                const SizedBox(height: 8),
                Text(
                  'Classificação: $riskClass',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: riskColor),
                ),
              ],
            ),
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
    // Garante valor inicial válido
    if (riskMap[riskKey] == null || !options.keys.contains(riskMap[riskKey])) {
      riskMap[riskKey] = options.keys.first;
    }
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
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

  // Função para classificação final da nascente
  String _getFinalClassification(String hidroambiental, String riscoAmbiental) {
    final isHidroBom = hidroambiental == 'Ótimo' || hidroambiental == 'Bom';
    final isRiscoBom = riscoAmbiental == 'Baixo';
    if (isHidroBom && isRiscoBom) {
      return 'Preservada';
    } else if (isHidroBom || isRiscoBom) {
      return 'Perturbada';
    } else {
      return 'Degradada';
    }
  }

  Step _buildFinalAssessmentStep() {
    final hidroClass = _getEnvironmentalClassification(_calculateHydroEnvironmentalTotal());
    final riscoClass = _getRiskLevel(_calculateTotalRiskScore());
    final classificacaoFinal = _getFinalClassification(hidroClass, riscoClass);
    Color finalColor;
    switch (classificacaoFinal) {
      case 'Preservada':
        finalColor = Colors.green;
        break;
      case 'Perturbada':
        finalColor = Colors.amber;
        break;
      case 'Degradada':
        finalColor = Colors.red;
        break;
      default:
        finalColor = Colors.grey;
    }
    return Step(
      title: const Text('Avaliação Final'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Classificação Final da Nascente',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Center(
            child: Column(
              children: [
                Text(
                  classificacaoFinal,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: finalColor),
                ),
                const SizedBox(height: 8),
                Text(
                  'Hidroambiental: $hidroClass | Risco Ambiental: $riscoClass',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
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
          if (_primaryUse == 'Outro') ...[
            const SizedBox(height: 8),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Descreva o uso principal',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _recommendations = value;
                });
              },
            ),
          ],
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
          if (_hasWaterAnalysis) ...[
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _selectDate(context, _selectedAnalysisDate, (date) {
                setState(() {
                  _selectedAnalysisDate = date;
                  _analysisDate = date;
                });
              }),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Data da análise',
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  _selectedAnalysisDate != null
                      ? '${_selectedAnalysisDate!.day.toString().padLeft(2, '0')}/${_selectedAnalysisDate!.month.toString().padLeft(2, '0')}/${_selectedAnalysisDate!.year}'
                      : 'Selecione a data',
                  style: TextStyle(
                    color: _selectedAnalysisDate != null ? Colors.black : Colors.grey[600],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Parâmetros analisados',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _analysisParameters = value;
                });
              },
            ),
          ],
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
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _selectDate(context, _selectedFlowRateDate, (date) {
                setState(() {
                  _selectedFlowRateDate = date;
                  _flowRateDate = date;
                });
              }),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Data da medição',
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  _selectedFlowRateDate != null
                      ? '${_selectedFlowRateDate!.day.toString().padLeft(2, '0')}/${_selectedFlowRateDate!.month.toString().padLeft(2, '0')}/${_selectedFlowRateDate!.year}'
                      : 'Selecione a data',
                  style: TextStyle(
                    color: _selectedFlowRateDate != null ? Colors.black : Colors.grey[600],
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          const Text(
            'Foto da nascente',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.camera_alt),
            label: const Text('Adicionar foto'),
            onPressed: _pickImage,
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _selectDate(context, _selectedPhotoDate, (date) {
              setState(() {
                _selectedPhotoDate = date;
                // Salvar data da foto
                if (_photoReferences.isNotEmpty) {
                  _photoReferences = _photoReferences.map((ref) {
                    if (ref.contains('_date:')) {
                      return ref.split('_date:')[0] + '_date:${date.toIso8601String()}';
                    }
                    return ref + '_date:${date.toIso8601String()}';
                  }).toList();
                }
              });
            }),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Data da foto',
                border: OutlineInputBorder(),
              ),
              child: Text(
                _selectedPhotoDate != null
                    ? '${_selectedPhotoDate!.day.toString().padLeft(2, '0')}/${_selectedPhotoDate!.month.toString().padLeft(2, '0')}/${_selectedPhotoDate!.year}'
                    : 'Selecione a data',
                style: TextStyle(
                  color: _selectedPhotoDate != null ? Colors.black : Colors.grey[600],
                ),
              ),
            ),
          ),
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

  // Adicionar função para obter localização
  Future<void> _getCurrentLocation() async {
    final position = await LocationService.getCurrentLocation(context);
    if (position != null) {
      setState(() {
        _latitudeController.text = position.latitude.toString();
        _longitudeController.text = position.longitude.toString();
        // A altitude vem em metros
        _altitudeController.text = position.altitude.toString();
      });
    }
  }

  // Modificar o widget que mostra os campos de localização
  Widget _buildLocationFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Localização',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: _getCurrentLocation,
          icon: const Icon(Icons.my_location),
          label: const Text('Obter Localização Atual'),
        ),
        const SizedBox(height: 16),
        TextFormField(
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
        const SizedBox(height: 8),
        TextFormField(
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
        const SizedBox(height: 8),
        TextFormField(
          controller: _altitudeController,
          decoration: const InputDecoration(
            labelText: 'Altitude (metros)',
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
        const SizedBox(height: 8),
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
        const SizedBox(height: 8),
        TextFormField(
          controller: _referenceController,
          decoration: const InputDecoration(
            labelText: 'Referência',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Informe uma referência';
            }
            return null;
          },
        ),
      ],
    );
  }

  // Modificar o Step de localização para usar o novo widget
  Step _buildLocationStep() {
    return Step(
      title: const Text('Localização'),
      content: _buildLocationFields(),
      isActive: _currentStep >= 1,
    );
  }
}
