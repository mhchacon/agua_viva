import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:agua_viva/services/assessment_service.dart';
import 'package:agua_viva/models/spring_assessment_model.dart';

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

  Future<void> _generatePdf() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text('Relatório de Avaliação de Nascente', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 16),
          pw.Text('Classificação Final: ${widget.classification}', style: pw.TextStyle(fontSize: 16)),
          pw.SizedBox(height: 12),
          pw.Text('Dados do proprietário: ${widget.assessmentData['ownerName'] ?? ''}'),
          pw.Text('Localização: ${widget.assessmentData['location'] ?? ''}'),
          pw.Text('Tipo de nascente: ${widget.assessmentData['springType'] ?? ''}'),
          pw.Text('Regime hídrico: ${widget.assessmentData['flowRegime'] ?? ''}'),
          pw.Text('Avaliação hidroambiental: ${widget.assessmentData['hydroEnvironmentalTotal'] ?? ''}'),
          pw.Text('Avaliação de riscos: ${widget.assessmentData['riskTotal'] ?? ''}'),
          pw.Text('Estado final: ${widget.assessmentData['generalState'] ?? ''}'),
          pw.Text('Uso prioritário: ${widget.assessmentData['primaryUse'] ?? ''}'),
          pw.Text('Qualidade da água: ${widget.assessmentData['analysisParameters'] ?? ''}'),
          pw.Text('Vazão: ${widget.assessmentData['flowRateValue'] ?? ''}'),
          pw.SizedBox(height: 12),
          pw.Text('Recomendações Técnicas:'),
          pw.Text(_recommendations),
        ],
      ),
    );
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
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
              Row(
                children: [
                  const Icon(Icons.circle, color: Colors.green, size: 18),
                  const SizedBox(width: 8),
                  Text('Classificação: ${widget.classification}', style: const TextStyle(fontWeight: FontWeight.bold)),
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
                      onPressed: _confirm ? () async {
                        final assessmentService = Provider.of<AssessmentService>(context, listen: false);
                        final assessment = SpringAssessment(
                          id: '',
                          springId: '',
                          evaluatorId: '',
                          status: 'pending',
                          environmentalServices: [],
                          ownerName: widget.assessmentData['ownerName'] ?? '',
                          hasCAR: widget.assessmentData['hasCAR'] ?? false,
                          carNumber: widget.assessmentData['carNumber'],
                          location: Location(
                            latitude: double.tryParse(widget.assessmentData['latitude'] ?? '0') ?? 0,
                            longitude: double.tryParse(widget.assessmentData['longitude'] ?? '0') ?? 0,
                          ),
                          altitude: double.tryParse(widget.assessmentData['altitude'] ?? '0') ?? 0,
                          municipality: widget.assessmentData['municipality'] ?? '',
                          reference: widget.assessmentData['reference'] ?? '',
                          hasAPP: widget.assessmentData['hasAPP'] ?? false,
                          appStatus: widget.assessmentData['appStatus'] ?? '',
                          hasWaterFlow: widget.assessmentData['hasWaterFlow'] ?? false,
                          hasWetlandVegetation: widget.assessmentData['hasWetlandVegetation'] ?? false,
                          hasFavorableTopography: widget.assessmentData['hasFavorableTopography'] ?? false,
                          hasSoilSaturation: widget.assessmentData['hasSoilSaturation'] ?? false,
                          springType: widget.assessmentData['springType'] ?? '',
                          springCharacteristic: widget.assessmentData['springCharacteristic'] ?? '',
                          diffusePoints: widget.assessmentData['diffusePoints'],
                          flowRegime: widget.assessmentData['flowRegime'] ?? '',
                          ownerResponse: widget.assessmentData['ownerResponse'],
                          informationSource: widget.assessmentData['informationSource'],
                          hydroEnvironmentalScores: Map<String, int>.from(widget.assessmentData['hydroEnvironmentalScores'] ?? {}),
                          hydroEnvironmentalTotal: widget.assessmentData['hydroEnvironmentalTotal'] ?? 0,
                          surroundingConditions: Map<String, int>.from(widget.assessmentData['surroundingConditions'] ?? {}),
                          springConditions: Map<String, int>.from(widget.assessmentData['springConditions'] ?? {}),
                          anthropicImpacts: Map<String, int>.from(widget.assessmentData['anthropicImpacts'] ?? {}),
                          generalState: widget.assessmentData['generalState'] ?? '',
                          primaryUse: widget.assessmentData['primaryUse'] ?? '',
                          hasWaterAnalysis: widget.assessmentData['hasWaterAnalysis'] ?? false,
                          analysisDate: widget.assessmentData['analysisDate'],
                          analysisParameters: widget.assessmentData['analysisParameters'],
                          hasFlowRate: widget.assessmentData['hasFlowRate'] ?? false,
                          flowRateValue: widget.assessmentData['flowRateValue'],
                          flowRateDate: widget.assessmentData['flowRateDate'],
                          photoReferences: List<String>.from(widget.assessmentData['photoReferences'] ?? []),
                          recommendations: _recommendations.isNotEmpty ? _recommendations : (widget.assessmentData['recommendations'] ?? ''),
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                          submittedAt: DateTime.now(),
                        );
                        await assessmentService.saveAssessment(assessment);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Formulário enviado com sucesso!'), backgroundColor: Colors.green),
                        );
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      } : null,
                      child: const Text('Submeter formulário'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('Gerar PDF'),
                      onPressed: _generatePdf,
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