import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agua_viva/services/auth_service.dart';
import 'package:agua_viva/screens/login_screen.dart';
import 'package:agua_viva/screens/dashboard_screen.dart';
import 'package:agua_viva/services/assessment_service.dart';
import 'package:agua_viva/theme.dart';

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
          create: (_) => AssessmentService(),
          dispose: (_, service) => service.dispose(),
        ),
      ],
      child: MaterialApp(
        title: 'Água Viva PSA',
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.system,
        home: const AuthGate(),
        debugShowCheckedModeBanner: false,
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
