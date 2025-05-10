import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agua_viva/screens/login_screen.dart';
import 'package:agua_viva/screens/dashboard_screen.dart';
import 'package:agua_viva/screens/role_selection_screen.dart';
import 'package:agua_viva/services/auth_service.dart';
import 'package:agua_viva/services/api_service.dart';
import 'package:agua_viva/services/assessment_service.dart';
import 'package:agua_viva/services/location_service.dart';
import 'package:agua_viva/theme.dart';
import 'package:agua_viva/widgets/offline_banner.dart';
import 'package:agua_viva/utils/logger.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ApiService _apiService;
  late AuthService _authService;
  late AssessmentService _assessmentService;
  final logger = AppLogger();
  
  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _authService = AuthService();
    _assessmentService = AssessmentService(_apiService);
    
    // Verificar conexão com o servidor ao iniciar
    _checkConnection();
  }
  
  Future<bool> _checkConnection() async {
    try {
      final isConnected = await _apiService.checkServerConnection();
      if (isConnected) {
        // Tentar sincronizar dados offline
        await _assessmentService.syncOfflineData();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>.value(value: _apiService),
        ChangeNotifierProvider<AuthService>.value(value: _authService),
        Provider<AssessmentService>.value(value: _assessmentService),
        Provider<LocationService>(create: (_) => LocationService()),
      ],
      child: RetryConnectionCallback(
        onRetry: _checkConnection,
        child: MaterialApp(
          title: 'Água Viva',
          theme: AppTheme.lightTheme,
          darkTheme: darkTheme,
          themeMode: ThemeMode.light,
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Column(
                  children: [
                    const OfflineBanner(),
                    Expanded(
                      child: FutureBuilder<Map<String, dynamic>?>(
                        future: _authService.getCurrentUser(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          
                          if (snapshot.hasData && snapshot.data != null) {
                            final userRole = _getUserRole(snapshot.data!['role'] as String?);
                            return DashboardScreen(userRole: userRole);
                          }
                          
                          return const RoleSelectionScreen();
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
  
  UserRole _getUserRole(String? roleString) {
    switch (roleString) {
      case 'admin':
        return UserRole.admin;
      case 'evaluator':
        return UserRole.evaluator;
      case 'proprietario':
        return UserRole.proprietario;
      default:
        return UserRole.proprietario;
    }
  }
}
