import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agua_viva/services/assessment_service.dart';
import 'package:agua_viva/models/assessment_model.dart';
import 'package:uuid/uuid.dart';
import 'package:agua_viva/services/auth_service.dart';
import 'package:agua_viva/services/report_service.dart';

class ReviewAndSubmitScreen extends StatefulWidget {
  final Map<String, dynamic> assessmentData;
  final String classification;

  const ReviewAndSubmitScreen({Key? key, required this.assessmentData, required this.classification}) : super(key: key);

  @override
  State<ReviewAndSubmitScreen> createState() => _ReviewAndSubmitScreenState();
}

class _ReviewAndSubmitScreenState extends State<ReviewAndSubmitScreen> {
  bool _expanded1 = false;
  bool _expanded2 = false;
  bool _expanded3 = false;
  bool _expanded4 = false;
  bool _expanded5 = false;
  bool _expanded6 = false;
  bool _expanded7 = false;
  bool _expanded8 = false;
  bool _confirm = false;
  String _recommendations = '';
  final ReportService _reportService = ReportService();

  Future<void> _generatePdf() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUser = await authService.getCurrentUser();

    if (currentUser == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário não autenticado')),
      );
      return;
    }

    try {
      final tempAssessment = SpringAssessment.fromJson({
        ...widget.assessmentData,
        'id': const Uuid().v4(),
        'evaluatorId': currentUser['id'],
        'status': 'pending',
        'recommendations': _recommendations,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      await _reportService.generatePdfReport(tempAssessment);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Relatório PDF gerado com sucesso'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao gerar PDF: $e')),
      );
    }
  }

  Color _getFinalColor(String classificacao) {
    switch (classificacao) {
      case 'Preservada':
        return Colors.green;
      case 'Perturbada':
        return Colors.amber;
      case 'Degradada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getHidroColor(String classificacao) {
    switch (classificacao) {
      case 'Ótimo':
        return const Color(0xFF00E676);
      case 'Bom':
        return Colors.green;
      case 'Razoável':
        return Colors.yellow;
      case 'Ruim':
        return Colors.orange;
      case 'Péssimo':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getRiskColor(String classificacao) {
    switch (classificacao) {
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

  String _getHidroClass() {
    final total = widget.assessmentData['hydroEnvironmentalTotal'] as int? ?? 0;
    if (total >= 30) return 'Ótimo';
    if (total >= 25) return 'Bom';
    if (total >= 20) return 'Razoável';
    if (total >= 15) return 'Ruim';
    return 'Péssimo';
  }

  String _getRiskClass() {
    final total = widget.assessmentData['riskTotal'] as int? ?? 0;
    if (total <= 10) return 'Baixo';
    if (total <= 20) return 'Médio';
    return 'Alto';
  }

  Future<void> _submitAssessment() async {
    if (!mounted) return;
    
    final assessmentService = Provider.of<AssessmentService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    
    final currentUser = await authService.getCurrentUser();
    if (currentUser == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário não autenticado')),
      );
      return;
    }

    final assessment = SpringAssessment.fromJson({
      ...widget.assessmentData,
      'id': const Uuid().v4(),
      'evaluatorId': currentUser['id'],
      'status': 'pending',
      'recommendations': _recommendations,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    });

    await assessmentService.saveAssessment(assessment);
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Avaliação enviada com sucesso!')),
    );
    
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Visualizar Dados e Submissão')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExpansionPanelList(
                expansionCallback: (i, isOpen) {
                  setState(() {
                    if (i == 0) _expanded1 = !_expanded1;
                    if (i == 1) _expanded2 = !_expanded2;
                    if (i == 2) _expanded3 = !_expanded3;
                    if (i == 3) _expanded4 = !_expanded4;
                    if (i == 4) _expanded5 = !_expanded5;
                    if (i == 5) _expanded6 = !_expanded6;
                    if (i == 6) _expanded7 = !_expanded7;
                    if (i == 7) _expanded8 = !_expanded8;
                  });
                },
                children: [
                  ExpansionPanel(
                    headerBuilder: (c, isOpen) => const ListTile(title: Text('Dados do proprietário')),
                    body: ListTile(title: Text(widget.assessmentData['ownerName'] ?? '')),
                    isExpanded: _expanded1,
                  ),
                  ExpansionPanel(
                    headerBuilder: (c, isOpen) => const ListTile(title: Text('Localização e características gerais')),
                    body: ListTile(title: Text(widget.assessmentData['location'] ?? '')),
                    isExpanded: _expanded2,
                  ),
                  ExpansionPanel(
                    headerBuilder: (c, isOpen) => const ListTile(title: Text('Tipo de nascente e regime hídrico')),
                    body: ListTile(title: Text('${widget.assessmentData['springType'] ?? ''} - ${widget.assessmentData['flowRegime'] ?? ''}')),
                    isExpanded: _expanded3,
                  ),
                  ExpansionPanel(
                    headerBuilder: (c, isOpen) => const ListTile(title: Text('Avaliação hidroambiental')),
                    body: ListTile(title: Text('Pontuação: ${widget.assessmentData['hydroEnvironmentalTotal'] ?? ''}')),
                    isExpanded: _expanded4,
                  ),
                  ExpansionPanel(
                    headerBuilder: (c, isOpen) => const ListTile(title: Text('Avaliação de riscos')),
                    body: ListTile(title: Text('Pontuação: ${widget.assessmentData['riskTotal'] ?? ''}')),
                    isExpanded: _expanded5,
                  ),
                  ExpansionPanel(
                    headerBuilder: (c, isOpen) => const ListTile(title: Text('Estado final da nascente')),
                    body: ListTile(title: Text(widget.assessmentData['generalState'] ?? '')),
                    isExpanded: _expanded6,
                  ),
                  ExpansionPanel(
                    headerBuilder: (c, isOpen) => const ListTile(title: Text('Uso prioritário')),
                    body: ListTile(title: Text(widget.assessmentData['primaryUse'] ?? '')),
                    isExpanded: _expanded7,
                  ),
                  ExpansionPanel(
                    headerBuilder: (c, isOpen) => const ListTile(title: Text('Qualidade da água e vazão')),
                    body: ListTile(title: Text('${widget.assessmentData['analysisParameters'] ?? ''} - ${widget.assessmentData['flowRateValue'] ?? ''}')),
                    isExpanded: _expanded8,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Card(
                color: Colors.grey[100],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Classificações Intermediárias', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.water_drop, color: _getHidroColor(_getHidroClass()), size: 20),
                          const SizedBox(width: 8),
                          const Text('Avaliação Hidroambiental: ', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(_getHidroClass(), style: TextStyle(color: _getHidroColor(_getHidroClass()), fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.warning, color: _getRiskColor(_getRiskClass()), size: 20),
                          const SizedBox(width: 8),
                          const Text('Risco Ambiental: ', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(_getRiskClass(), style: TextStyle(color: _getRiskColor(_getRiskClass()), fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Icon(Icons.circle, color: _getFinalColor(widget.classification), size: 18),
                  const SizedBox(width: 8),
                  Text('Classificação Final: ${widget.classification}', style: TextStyle(fontWeight: FontWeight.bold, color: _getFinalColor(widget.classification), fontSize: 18)),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Recomendações Técnicas (opcional):', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Escreva observações ou orientações...'
                ),
                onChanged: (v) => setState(() => _recommendations = v),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                value: _confirm,
                onChanged: (v) => setState(() => _confirm = v ?? false),
                title: const Text('Confirmo que revisei todos os dados.'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _confirm ? _submitAssessment : null,
                      child: const Text('Enviar Avaliação'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _generatePdf,
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('Gerar PDF'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 