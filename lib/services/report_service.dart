import 'dart:convert';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/assessment_model.dart';

class ReportService {
  // Generate a CSV string from assessment data
  String generateCsvReport(List<SpringAssessment> assessments) {
    // Create CSV header row
    String csvData = 'ID,Proprietário,Município,Status,Estado Geral,Pontuação Ambiental\n';
    
    // Add data rows
    for (var assessment in assessments) {
      final formattedDate = DateFormat('dd/MM/yyyy').format(assessment.updatedAt);
      csvData += '${assessment.idString},${_escapeCsvField(assessment.ownerName)},' 
               '${_escapeCsvField(assessment.municipality)},${_escapeCsvField(assessment.status)},' 
               '${_escapeCsvField(assessment.generalState)},${assessment.hydroEnvironmentalTotal},' 
               '$formattedDate\n';
    }
    
    return csvData;
  }
  
  // Helper to escape special characters in CSV fields
  String _escapeCsvField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      // Escape quotes by doubling them and wrap in quotes
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  // Generate a detailed PDF report for an assessment
  Future<void> generatePdfReport(SpringAssessment assessment) async {
    // Criar um documento PDF
    final pdf = pw.Document();

    // Definir estilos
    final titleStyle = pw.TextStyle(
      fontSize: 20,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.blue900,
    );
    
    final sectionStyle = pw.TextStyle(
      fontSize: 14,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.blue600,
    );
    
    final labelStyle = pw.TextStyle(
      fontSize: 12,
      fontWeight: pw.FontWeight.bold,
    );

    final valueStyle = pw.TextStyle(
      fontSize: 12,
    );

    // Função para criar uma seção no relatório
    pw.Widget buildSection(String title, List<Map<String, dynamic>> fields) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: sectionStyle),
          pw.SizedBox(height: 8),
          ...fields.map((field) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Text("${field['label']}: ", style: labelStyle),
                    pw.Text("${field['value']}", style: valueStyle),
                  ],
                ),
                pw.Divider(height: 1)
              ],
            ),
          )).toList(),
          pw.SizedBox(height: 12),
        ],
      );
    }

    // Formatar datas
    final dateFormat = DateFormat('dd/MM/yyyy');
    String formatDate(DateTime? date) {
      if (date == null) return 'Não informado';
      return dateFormat.format(date);
    }

    // Adicionar páginas ao PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text('RELATÓRIO DE AVALIAÇÃO DE NASCENTE', style: titleStyle),
            pw.SizedBox(height: 8),
            pw.Divider(thickness: 2, color: PdfColors.blue700),
            pw.SizedBox(height: 8),
          ],
        ),
        footer: (context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Água Viva - Sistema de Avaliação de Nascentes'),
            pw.Text('Página ${context.pageNumber} de ${context.pagesCount}'),
          ],
        ),
        build: (context) => [
          // Informações de identificação
          buildSection('Informações de Identificação', [
            {'label': 'ID', 'value': assessment.idString},
            {'label': 'Status', 'value': _getStatusText(assessment.status)},
            {'label': 'Data de Criação', 'value': formatDate(assessment.createdAt)},
            {'label': 'Última Atualização', 'value': formatDate(assessment.updatedAt)},
            {'label': 'Data de Submissão', 'value': formatDate(assessment.submittedAt)},
          ]),

          // Informações do proprietário
          buildSection('Dados do Proprietário', [
            {'label': 'Nome', 'value': assessment.ownerName},
            {'label': 'CPF', 'value': assessment.ownerCpf},
            {'label': 'Possui CAR', 'value': assessment.hasCAR ? 'Sim' : 'Não'},
            {'label': 'Número do CAR', 'value': assessment.carNumber ?? 'Não informado'},
          ]),

          // Localização
          buildSection('Localização', [
            {'label': 'Município', 'value': assessment.municipality},
            {'label': 'Referência', 'value': assessment.reference},
            {'label': 'Coordenadas', 'value': '${assessment.location.latitude}, ${assessment.location.longitude}'},
            {'label': 'Altitude', 'value': '${assessment.altitude} metros'},
          ]),

          // Características da APP
          buildSection('Área de Preservação Permanente', [
            {'label': 'Possui APP', 'value': assessment.hasAPP ? 'Sim' : 'Não'},
            {'label': 'Estado da APP', 'value': assessment.appStatus},
          ]),

          // Características da nascente
          buildSection('Características da Nascente', [
            {'label': 'Tipo de Nascente', 'value': assessment.springType},
            {'label': 'Característica', 'value': assessment.springCharacteristic},
            {'label': 'Regime de Fluxo', 'value': assessment.flowRegime},
            {'label': 'Pontos Difusos', 'value': assessment.diffusePoints?.toString() ?? 'Não aplicável'},
            {'label': 'Possui Fluxo de Água', 'value': assessment.hasWaterFlow ? 'Sim' : 'Não'},
            {'label': 'Possui Vegetação de Áreas Úmidas', 'value': assessment.hasWetlandVegetation ? 'Sim' : 'Não'},
            {'label': 'Topografia Favorável', 'value': assessment.hasFavorableTopography ? 'Sim' : 'Não'},
            {'label': 'Solo Saturado', 'value': assessment.hasSoilSaturation ? 'Sim' : 'Não'},
          ]),

          // Avaliação Hidroambiental
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Avaliação Hidroambiental', style: sectionStyle),
              pw.SizedBox(height: 8),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('Critério', style: labelStyle),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('Pontuação', style: labelStyle),
                      ),
                    ],
                  ),
                  ...assessment.hydroEnvironmentalScores.entries.map((entry) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(entry.key),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(entry.value.toString()),
                      ),
                    ],
                  )).toList(),
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.blue100),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('TOTAL', style: labelStyle),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('${assessment.hydroEnvironmentalTotal}/33', style: labelStyle),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
            ],
          ),

          // Condições do Entorno
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Condições do Entorno', style: sectionStyle),
              pw.SizedBox(height: 8),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('Condição', style: labelStyle),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('Valor', style: labelStyle),
                      ),
                    ],
                  ),
                  ...assessment.surroundingConditions.entries.map((entry) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(entry.key),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(entry.value.toString()),
                      ),
                    ],
                  )).toList(),
                ],
              ),
              pw.SizedBox(height: 12),
            ],
          ),

          // Condições da Nascente
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Condições da Nascente', style: sectionStyle),
              pw.SizedBox(height: 8),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('Condição', style: labelStyle),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('Valor', style: labelStyle),
                      ),
                    ],
                  ),
                  ...assessment.springConditions.entries.map((entry) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(entry.key),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(entry.value.toString()),
                      ),
                    ],
                  )).toList(),
                ],
              ),
              pw.SizedBox(height: 12),
            ],
          ),

          // Impactos Antrópicos
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Impactos Antrópicos', style: sectionStyle),
              pw.SizedBox(height: 8),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('Impacto', style: labelStyle),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('Valor', style: labelStyle),
                      ),
                    ],
                  ),
                  ...assessment.anthropicImpacts.entries.map((entry) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(entry.key),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(entry.value.toString()),
                      ),
                    ],
                  )).toList(),
                ],
              ),
              pw.SizedBox(height: 12),
            ],
          ),

          // Classificação Final
          buildSection('Classificação Final', [
            {'label': 'Estado Geral', 'value': assessment.generalState},
            {'label': 'Uso Prioritário', 'value': assessment.primaryUse},
          ]),

          // Análise de Água e Vazão
          buildSection('Análise de Água e Vazão', [
            {'label': 'Possui Análise de Água', 'value': assessment.hasWaterAnalysis ? 'Sim' : 'Não'},
            {'label': 'Data da Análise', 'value': formatDate(assessment.analysisDate)},
            {'label': 'Parâmetros Analisados', 'value': assessment.analysisParameters ?? 'Não informado'},
            {'label': 'Possui Medição de Vazão', 'value': assessment.hasFlowRate ? 'Sim' : 'Não'},
            {'label': 'Vazão Medida', 'value': assessment.flowRateValue != null ? '${assessment.flowRateValue} L/s' : 'Não informado'},
            {'label': 'Data da Medição', 'value': formatDate(assessment.flowRateDate)},
          ]),

          // Serviços Ambientais
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Serviços Ambientais', style: sectionStyle),
              pw.SizedBox(height: 8),
              ...assessment.environmentalServices.map((service) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 4),
                child: pw.Row(
                  children: [
                    pw.Text('• ', style: labelStyle),
                    pw.Text(service, style: valueStyle),
                  ],
                ),
              )).toList(),
              pw.SizedBox(height: 12),
            ],
          ),

          // Recomendações
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Recomendações Técnicas', style: sectionStyle),
              pw.SizedBox(height: 8),
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(assessment.recommendations ?? 'Nenhuma recomendação fornecida.'),
              ),
              pw.SizedBox(height: 20),
            ],
          ),

          // Assinaturas
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  pw.Column(
                    children: [
                      pw.Container(
                        width: 200,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(top: pw.BorderSide())
                        ),
                        padding: const pw.EdgeInsets.only(top: 8),
                        child: pw.Text('Avaliador', textAlign: pw.TextAlign.center),
                      ),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Container(
                        width: 200,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(top: pw.BorderSide())
                        ),
                        padding: const pw.EdgeInsets.only(top: 8),
                        child: pw.Text('Proprietário', textAlign: pw.TextAlign.center),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    // Mostrar o PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) => pdf.save(),
    );
  }

  // Função auxiliar para formatar o status em português
  String _getStatusText(String status) {
    switch (status) {
      case 'approved':
        return 'Aprovado';
      case 'rejected':
        return 'Rejeitado';
      case 'pending':
        return 'Pendente';
      default:
        return status;
    }
  }

  // Export data in KMZ format (for Google Earth)
  // Note: This is a simplified placeholder for the UI to work with
  Future<Uint8List> generateKmzExport(List<SpringAssessment> assessments) async {
    // In a real app, this would generate actual KMZ data
    // For now, we'll just return a placeholder
    String kmlContent = """<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
  <Document>
    <n>Nascentes PSA</n>
""";
    
    for (var assessment in assessments) {
      kmlContent += """    <Placemark>
      <n>${_escapeXml(assessment.ownerName)}</n>
      <description>Estado: ${_escapeXml(assessment.generalState)}</description>
      <Point>
        <coordinates>${assessment.location.longitude},${assessment.location.latitude}</coordinates>
      </Point>
    </Placemark>
""";
    }
    
    kmlContent += """  </Document>
</kml>""";
    
    // Convert KML to Uint8List (in a real app, this would be zipped with images as KMZ)
    return Uint8List.fromList(utf8.encode(kmlContent));
  }
  
  // Helper to escape XML content
  String _escapeXml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll('\'', '&apos;');
  }

  // Gerar um PDF com resumo de múltiplas avaliações (para administradores)
  Future<void> generateSummaryPdfReport(List<SpringAssessment> assessments) async {
    // Criar um documento PDF
    final pdf = pw.Document();

    // Definir estilos
    final titleStyle = pw.TextStyle(
      fontSize: 20,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.blue900,
    );
    
    final sectionStyle = pw.TextStyle(
      fontSize: 14,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.blue600,
    );
    
    final labelStyle = pw.TextStyle(
      fontSize: 12,
      fontWeight: pw.FontWeight.bold,
    );

    final valueStyle = pw.TextStyle(
      fontSize: 12,
    );

    // Formatar datas
    final dateFormat = DateFormat('dd/MM/yyyy');
    String formatDate(DateTime? date) {
      if (date == null) return 'Não informado';
      return dateFormat.format(date);
    }

    // Cores para status
    PdfColor getStatusColor(String status) {
      switch (status) {
        case 'approved':
          return PdfColors.green;
        case 'rejected':
          return PdfColors.red;
        case 'pending':
          return PdfColors.orange;
        default:
          return PdfColors.grey;
      }
    }

    // Adicionar páginas ao PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text('RESUMO DE AVALIAÇÕES DE NASCENTES', style: titleStyle),
            pw.SizedBox(height: 8),
            pw.Divider(thickness: 2, color: PdfColors.blue700),
            pw.SizedBox(height: 8),
          ],
        ),
        footer: (context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Água Viva - Sistema de Avaliação de Nascentes'),
            pw.Text('Página ${context.pageNumber} de ${context.pagesCount}'),
          ],
        ),
        build: (context) => [
          // Resumo geral
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 8),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Resumo Geral', style: sectionStyle),
                pw.SizedBox(height: 8),
                pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 2,
                      child: pw.Container(
                        padding: const pw.EdgeInsets.all(8),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.grey200,
                          border: pw.Border.all(),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.Text('Total de Avaliações', style: labelStyle),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              '${assessments.length}',
                              style: pw.TextStyle(
                                fontSize: 18,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Container(
                        padding: const pw.EdgeInsets.all(8),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.grey200,
                          border: pw.Border.all(),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.Text('Aprovadas', style: labelStyle),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              '${assessments.where((a) => a.status == 'approved').length}',
                              style: pw.TextStyle(
                                fontSize: 18,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Container(
                        padding: const pw.EdgeInsets.all(8),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.grey200,
                          border: pw.Border.all(),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.Text('Pendentes', style: labelStyle),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              '${assessments.where((a) => a.status == 'pending').length}',
                              style: pw.TextStyle(
                                fontSize: 18,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Container(
                        padding: const pw.EdgeInsets.all(8),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.grey200,
                          border: pw.Border.all(),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.Text('Rejeitadas', style: labelStyle),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              '${assessments.where((a) => a.status == 'rejected').length}',
                              style: pw.TextStyle(
                                fontSize: 18,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tabela de avaliações
          pw.SizedBox(height: 16),
          pw.Text('Lista de Avaliações', style: sectionStyle),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(),
            columnWidths: {
              0: const pw.FlexColumnWidth(1), // ID
              1: const pw.FlexColumnWidth(3), // Proprietário
              2: const pw.FlexColumnWidth(2), // Município
              3: const pw.FlexColumnWidth(1.5), // Estado Geral
              4: const pw.FlexColumnWidth(1.5), // Pontuação
              5: const pw.FlexColumnWidth(1.5), // Status
              6: const pw.FlexColumnWidth(1.5), // Data
            },
            children: [
              // Cabeçalho
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('ID', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('Proprietário', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('Município', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('Estado', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('Pontuação', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('Status', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('Data', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                ],
              ),
              // Linhas de dados
              ...assessments.map((assessment) => pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(assessment.idString.substring(0, 8) + '...', style: valueStyle),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(assessment.ownerName, style: valueStyle),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(assessment.municipality, style: valueStyle),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(assessment.generalState, style: valueStyle),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('${assessment.hydroEnvironmentalTotal}/33', style: valueStyle),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('#33${getStatusColor(assessment.status).toHex().substring(1)}'),
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(
                        _getStatusText(assessment.status),
                        style: pw.TextStyle(
                          color: getStatusColor(assessment.status),
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(formatDate(assessment.updatedAt), style: valueStyle),
                  ),
                ],
              )).toList(),
            ],
          ),

          // Informações por município
          pw.SizedBox(height: 24),
          pw.Text('Avaliações por Município', style: sectionStyle),
          pw.SizedBox(height: 8),
          
          // Agrupar avaliações por município
          ...(() {
            final Map<String, List<SpringAssessment>> byMunicipality = {};
            for (var assessment in assessments) {
              if (!byMunicipality.containsKey(assessment.municipality)) {
                byMunicipality[assessment.municipality] = [];
              }
              byMunicipality[assessment.municipality]!.add(assessment);
            }
            
            return byMunicipality.entries.map((entry) {
              final municipality = entry.key;
              final municipalityAssessments = entry.value;
              
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    color: PdfColors.blue100,
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          municipality,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(
                          'Total: ${municipalityAssessments.length}',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Table(
                    border: pw.TableBorder.all(),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(3), // Proprietário
                      1: const pw.FlexColumnWidth(2), // Estado
                      2: const pw.FlexColumnWidth(1.5), // Status
                    },
                    children: [
                      // Cabeçalho da tabela por município
                      pw.TableRow(
                        decoration: pw.BoxDecoration(color: PdfColors.grey200),
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text('Proprietário', style: valueStyle),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text('Estado', style: valueStyle),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text('Status', style: valueStyle),
                          ),
                        ],
                      ),
                      // Linhas de dados por município
                      ...municipalityAssessments.map((assessment) => pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(assessment.ownerName, style: valueStyle),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(assessment.generalState, style: valueStyle),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(_getStatusText(assessment.status), style: valueStyle),
                          ),
                        ],
                      )).toList(),
                    ],
                  ),
                  pw.SizedBox(height: 8),
                ]
              );
            }).toList();
          })(),
        ],
      ),
    );

    // Mostrar o PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) => pdf.save(),
    );
  }
}
