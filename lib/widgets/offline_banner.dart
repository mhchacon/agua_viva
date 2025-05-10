import 'package:flutter/material.dart';
import 'package:agua_viva/config/api_config.dart';
import 'package:agua_viva/theme.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ApiConfig.offlineModeNotifier,
      builder: (context, isOffline, child) {
        if (!isOffline) return const SizedBox.shrink();
        
        return Container(
          width: double.infinity,
          color: Colors.red.shade800,
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  const Icon(
                    Icons.cloud_off,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Você está offline',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Os dados serão sincronizados quando a conexão for restaurada',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    tooltip: 'Tentar novamente',
                    onPressed: () async {
                      // Mostrar indicador de carregamento
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Verificando conexão...'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                      
                      // Atualizar ApiService para verificar conexão
                      if (context.mounted) {
                        final result = await context.findAncestorWidgetOfExactType<RetryConnectionCallback>()?.onRetry();
                        
                        if (context.mounted && result == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Conexão restaurada!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Não foi possível conectar ao servidor. Tentando novamente mais tarde.'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class RetryConnectionCallback extends InheritedWidget {
  final Future<bool> Function() onRetry;

  const RetryConnectionCallback({
    Key? key,
    required this.onRetry,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(RetryConnectionCallback oldWidget) {
    return onRetry != oldWidget.onRetry;
  }
} 