import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:agua_viva/utils/logger.dart';

class ImageCompression {
  static final AppLogger _logger = AppLogger();
  
  /// Comprime uma imagem antes do upload
  /// Retorna o caminho do arquivo comprimido
  static Future<String?> compressImage(String imagePath, {int quality = 80}) async {
    try {
      _logger.info('Comprimindo imagem: $imagePath');
      
      // Verificar se o arquivo existe
      final file = File(imagePath);
      if (!await file.exists()) {
        _logger.error('Arquivo não encontrado: $imagePath');
        return null;
      }
      
      // Caminho de saída para a imagem comprimida
      final dir = await getTemporaryDirectory();
      final baseName = path.basenameWithoutExtension(imagePath);
      final targetPath = '${dir.path}/compressed_$baseName.jpg';
      
      // Obter tamanho original
      final originalSize = await file.length();
      _logger.info('Tamanho original: ${_formatFileSize(originalSize)}');
      
      // Comprimir a imagem
      final result = await FlutterImageCompress.compressAndGetFile(
        imagePath,
        targetPath,
        quality: quality,
        minWidth: 1080,  // Largura máxima
        minHeight: 1080, // Altura máxima (mantém proporção)
        format: CompressFormat.jpeg,
      );
      
      if (result == null) {
        _logger.error('Falha ao comprimir imagem');
        return null;
      }
      
      // Verificar o tamanho após a compressão
      final compressedSize = await result.length();
      final reductionPercent = 100 - ((compressedSize / originalSize) * 100);
      
      _logger.info(
        'Compressão concluída: ${_formatFileSize(compressedSize)} '
        '(redução de ${reductionPercent.toStringAsFixed(1)}%)'
      );
      
      return result.path;
    } catch (e) {
      _logger.error('Erro ao comprimir imagem: $e');
      return null;
    }
  }
  
  /// Formata o tamanho do arquivo para exibição
  static String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
} 