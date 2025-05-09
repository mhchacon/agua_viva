import 'dart:convert';
import 'dart:typed_data';
import 'package:intl/intl.dart';
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

  // Generate a simple PDF report for an assessment
  // Note: In a real app, this would use a PDF generation library
  // For now, we'll just return dummy data for the UI to display
  Future<Uint8List> generatePdfReport(SpringAssessment assessment) async {
    // This is just a placeholder - in a real app, we would use
    // a PDF generation library to create an actual PDF
    
    // For now, we'll just create a text representation of what would be in the PDF
    String reportText = "RELATÓRIO DE AVALIAÇÃO DE NASCENTE\n\n";
    reportText += "ID: ${assessment.idString}\n";
    reportText += "Proprietário: ${assessment.ownerName}\n";
    reportText += "Município: ${assessment.municipality}\n";
    reportText += "Referência: ${assessment.reference}\n";
    reportText += "Status: ${assessment.status}\n";
    reportText += "Estado Geral: ${assessment.generalState}\n";
    reportText += "Pontuação Ambiental: ${assessment.hydroEnvironmentalTotal}/33\n";
    reportText += "\nAvaliador: ${assessment.evaluatorIdString}\n";
    reportText += "Data da Avaliação: ${DateFormat('dd/MM/yyyy').format(assessment.createdAt)}\n";
    
    // Convert text to Uint8List (in a real app, this would be PDF data)
    return Uint8List.fromList(utf8.encode(reportText));
  }

  // Export data in KMZ format (for Google Earth)
  // Note: This is a simplified placeholder for the UI to work with
  Future<Uint8List> generateKmzExport(List<SpringAssessment> assessments) async {
    // In a real app, this would generate actual KMZ data
    // For now, we'll just return a placeholder
    String kmlContent = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
    kmlContent += "<kml xmlns=\"http://www.opengis.net/kml/2.2\">\n";
    kmlContent += "  <Document>\n";
    kmlContent += "    <name>Nascentes PSA</name>\n";
    
    for (var assessment in assessments) {
      kmlContent += "    <Placemark>\n";
      kmlContent += "      <name>${_escapeXml(assessment.ownerName)}</name>\n";
      kmlContent += "      <description>Estado: ${_escapeXml(assessment.generalState)}</description>\n";
      kmlContent += "      <Point>\n";
      kmlContent += "        <coordinates>${assessment.location.longitude},${assessment.location.latitude}</coordinates>\n";
      kmlContent += "      </Point>\n";
      kmlContent += "    </Placemark>\n";
    }
    
    kmlContent += "  </Document>\n";
    kmlContent += "</kml>";
    
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
}
