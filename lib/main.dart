import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agua_viva/services/auth_service.dart';
import 'package:agua_viva/screens/login_screen.dart';
import 'package:agua_viva/screens/dashboard_screen.dart';
import 'package:agua_viva/services/assessment_service.dart';
import 'package:agua_viva/theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/cadastro_proprietario_screen.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(
          create: (_) => AuthService(),
        ),
        Provider<AssessmentService>(
          create: (_) => AssessmentService(ApiService()),
          dispose: (_, service) => service.dispose(),
        ),
      ],
      child: MaterialApp(
        title: 'Água Viva PSA',
        theme: ThemeData(
          primaryColor: AppTheme.primaryColor,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppTheme.primaryColor,
            primary: AppTheme.primaryColor,
            secondary: AppTheme.secondaryColor,
          ),
          useMaterial3: true,
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.primaryColor,
                width: 2,
              ),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ),
        darkTheme: darkTheme,
        themeMode: ThemeMode.system,
        home: const RoleSelectionScreen(),
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('pt', 'BR'),
        ],
        routes: {
          '/cadastro': (context) => const CadastroProprietarioScreen(),
        },
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return StreamBuilder<bool>(
      stream: authService.authStateChanges,
      initialData: authService.isAuthenticated,
      builder: (context, snapshot) {
        // If the snapshot has user data, user is logged in
        if (snapshot.data == true) {
          // In a real app, we would check user role and route accordingly
          return DashboardScreen(userRole: authService.currentUserRole ?? UserRole.admin);
        }
        
        // If the snapshot doesn't have data, user is not logged in
        return const RoleSelectionScreen();
      },
    );
  }
}
