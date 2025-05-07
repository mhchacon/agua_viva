import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agua_viva/models/spring_assessment_model.dart';
import 'package:agua_viva/services/assessment_service.dart';
import 'package:agua_viva/services/report_service.dart';
import 'package:agua_viva/services/auth_service.dart';

class AssessmentDetailsScreen extends StatefulWidget {
  final String assessmentId;

  const AssessmentDetailsScreen({Key? key, required this.assessmentId}) : super(key: key);

  @override
  _AssessmentDetailsScreenState createState() => _AssessmentDetailsScreenState();
}

class _AssessmentDetailsScreenState extends State<AssessmentDetailsScreen> {
  late AssessmentService _assessmentService;
  final ReportService _reportService = ReportService();
  bool _isLoading = true;
  SpringAssessment? _assessment;
  
  // For admin actions
  String _selectedStatus = 'pending';
  final TextEditingController _justificationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _assessmentService = Provider.of<AssessmentService>(context, listen: false);
      _loadAssessment();
    });
  }

  @override
  void dispose() {
    _justificationController.dispose();
    super.dispose();
  }

  Future<void> _loadAssessment() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final assessment = await _assessmentService.getAssessmentById(widget.assessmentId);
      
      if (assessment != null) {
        setState(() {
          _assessment = assessment;
          _selectedStatus = assessment.status;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar avaliação: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _assessmentService.updateAssessmentStatus(
        widget.assessmentId,
        _selectedStatus,
        _justificationController.text.isEmpty ? null : _justificationController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Status atualizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      // Reload the assessment
      await _loadAssessment();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar status: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _generateReport() async {
    if (_assessment == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _reportService.generatePdfReport(_assessment!);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Relatório gerado! Esta função será implementada completa em versões futuras.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao gerar relatório: $e')),
      );
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Avaliação'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _generateReport,
            tooltip: 'Gerar PDF',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _assessment == null
              ? const Center(child: Text('Avaliação não encontrada'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatusBadge(_assessment!.status),
                      const SizedBox(height: 16),
                      _buildSectionHeader('Informações do Proprietário'),
                      _buildDetailCard(
                        title: _assessment!.ownerName,
                        subtitle: 'Proprietário',
                        icon: Icons.person,
                      ),
                      _buildDetailCard(
                        title: _assessment!.municipality,
                        subtitle: 'Município',
                        icon: Icons.location_city,
                      ),
                      _buildDetailCard(
                        title: _assessment!.reference,
                        subtitle: 'Referência',
                        icon: Icons.pin_drop,
                      ),
                      _buildDetailCard(
                        title: '${_assessment!.location.latitude}, ${_assessment!.location.longitude}',
                        subtitle: 'Coordenadas',
                        icon: Icons.my_location,
                      ),
                      _buildDetailCard(
                        title: '${_assessment!.altitude.toStringAsFixed(1)} metros',
                        subtitle: 'Altitude',
                        icon: Icons.height,
                      ),
                      _buildDetailCard(
                        title: _assessment!.hasCAR ? 'Sim' : 'Não',
                        subtitle: 'Área com CAR',
                        icon: Icons.assignment,
                        iconColor: _assessment!.hasCAR ? Colors.green : Colors.red,
                      ),
                      _buildDetailCard(
                        title: _assessment!.hasAPP ? _assessment!.appStatus : 'Não possui',
                        subtitle: 'Área de APP',
                        icon: Icons.park,
                        iconColor: _assessment!.hasAPP 
                            ? (_assessment!.appStatus == 'Bom' ? Colors.green : Colors.orange) 
                            : Colors.red,
                      ),

                      const SizedBox(height: 16),
                      _buildSectionHeader('Características da Nascente'),
                      _buildDetailCard(
                        title: _assessment!.springType,
                        subtitle: 'Tipo de Nascente',
                        icon: Icons.category,
                      ),
                      _buildDetailCard(
                        title: _assessment!.springCharacteristic + (_assessment!.diffusePoints != null 
                            ? ' (${_assessment!.diffusePoints} pontos)' 
                            : ''),
                        subtitle: 'Característica Física',
                        icon: Icons.water_drop,
                      ),
                      _buildDetailCard(
                        title: _assessment!.flowRegime,
                        subtitle: 'Regime de Vazão',
                        icon: Icons.waves,
                      ),
                      if (_assessment!.ownerResponse != null) _buildDetailCard(
                        title: _assessment!.ownerResponse!,
                        subtitle: 'Resposta do Proprietário',
                        icon: Icons.comment,
                      ),

                      const SizedBox(height: 16),
                      _buildSectionHeader('Análise Confirmatória'),
                      _buildCriteriaCard(
                        'Presença de fluxo hídrico',
                        _assessment!.hasWaterFlow,
                      ),
                      _buildCriteriaCard(
                        'Vegetação associada a áreas úmidas',
                        _assessment!.hasWetlandVegetation,
                      ),
                      _buildCriteriaCard(
                        'Condições topográficas favoráveis',
                        _assessment!.hasFavorableTopography,
                      ),
                      _buildCriteriaCard(
                        'Indícios de saturação do solo',
                        _assessment!.hasSoilSaturation,
                      ),

                      const SizedBox(height: 16),
                      _buildSectionHeader('Avaliação Hidroambiental'),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _getEnvironmentalColor(_assessment!.hydroEnvironmentalTotal).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getEnvironmentalColor(_assessment!.hydroEnvironmentalTotal).withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Pontuação Total: ${_assessment!.hydroEnvironmentalTotal}/33',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _getEnvironmentalClassification(_assessment!.hydroEnvironmentalTotal),
                              style: TextStyle(
                                fontSize: 16,
                                color: _getEnvironmentalColor(_assessment!.hydroEnvironmentalTotal),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),
                      _buildSectionHeader('Avaliação Final'),
                      _buildDetailCard(
                        title: _assessment!.generalState,
                        subtitle: 'Estado Geral',
                        icon: Icons.assessment,
                        iconColor: _getStateColor(_assessment!.generalState),
                      ),
                      _buildDetailCard(
                        title: _assessment!.primaryUse,
                        subtitle: 'Uso Prioritário',
                        icon: Icons.water,
                      ),
                      if (_assessment!.recommendations != null && _assessment!.recommendations!.isNotEmpty) _buildDetailCard(
                        title: _assessment!.recommendations!,
                        subtitle: 'Recomendações Técnicas',
                        icon: Icons.recommend,
                        maxLines: 5,
                      ),

                      // Display photos if any
                      if (_assessment!.photoReferences.isNotEmpty) ...[  
                        const SizedBox(height: 16),
                        _buildSectionHeader('Fotos da Nascente'),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _assessment!.photoReferences.map((ref) {
                            return Chip(
                              label: Text(ref),
                              avatar: const Icon(Icons.image),
                            );
                          }).toList(),
                        ),
                      ],

                      // Admin-only section for updating status
                      Consumer<AuthService>(
                        builder: (context, authService, _) {
                          final userRole = authService.currentUserRole;
                          
                          if (userRole == UserRole.admin) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 24),
                                const Divider(),
                                const SizedBox(height: 16),
                                _buildSectionHeader('Ações Administrativas'),
                                const SizedBox(height: 8),
                                Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Atualizar status da avaliação',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        const SizedBox(height: 16),
                                        DropdownButtonFormField<String>(
                                          value: _selectedStatus,
                                          decoration: const InputDecoration(
                                            labelText: 'Status',
                                            border: OutlineInputBorder(),
                                          ),
                                          items: const [
                                            DropdownMenuItem(
                                              value: 'pending',
                                              child: Text('Pendente'),
                                            ),
                                            DropdownMenuItem(
                                              value: 'approved',
                                              child: Text('Aprovado'),
                                            ),
                                            DropdownMenuItem(
                                              value: 'rejected',
                                              child: Text('Indeferido'),
                                            ),
                                          ],
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedStatus = value!;
                                            });
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                        TextFormField(
                                          controller: _justificationController,
                                          decoration: const InputDecoration(
                                            labelText: 'Justificativa (opcional)',
                                            border: OutlineInputBorder(),
                                            hintText: 'Motivo da atualização de status...',
                                          ),
                                          maxLines: 3,
                                        ),
                                        const SizedBox(height: 16),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: _updateStatus,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Theme.of(context).colorScheme.primary,
                                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                            ),
                                            child: const Text('Salvar Alterações'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                          
                          return const SizedBox();
                        },
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    IconData icon;
    Color color;
    String label;

    switch (status) {
      case 'approved':
        icon = Icons.check_circle;
        color = Colors.green;
        label = 'Aprovado';
        break;
      case 'rejected':
        icon = Icons.cancel;
        color = Colors.red;
        label = 'Indeferido';
        break;
      default: // pending
        icon = Icons.hourglass_empty;
        color = Colors.orange;
        label = 'Pendente';
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(
            'Status: $label',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard({
    required String title,
    required String subtitle,
    required IconData icon,
    Color? iconColor,
    int maxLines = 2,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: iconColor ?? Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: maxLines,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCriteriaCard(String title, bool value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          children: [
            Icon(
              value ? Icons.check_circle : Icons.cancel,
              color: value ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title),
            ),
          ],
        ),
      ),
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

  Color _getStateColor(String state) {
    switch (state) {
      case 'Preservada':
        return Colors.green;
      case 'Perturbada':
        return Colors.orange;
      case 'Degradada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
