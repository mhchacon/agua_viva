import 'package:flutter/material.dart';
import 'package:agua_viva/screens/login_screen.dart';
import 'package:agua_viva/services/auth_service.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo and App Title
              const Icon(
                Icons.water_drop_rounded,
                size: 80,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              Text(
                'Água Viva',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                'PSA - Programa de Pagamento de Serviços Ambientais',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white.withAlpha(230),
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              // Role Selection Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _roleButton(
                      context,
                      title: 'Administrador',
                      subtitle: 'Equipe Técnica',
                      icon: Icons.admin_panel_settings_rounded,
                      role: UserRole.admin,
                    ),
                    const SizedBox(height: 16),
                    _roleButton(
                      context,
                      title: 'Avaliador',
                      subtitle: 'Realizar avaliações em campo',
                      icon: Icons.analytics_rounded,
                      role: UserRole.evaluator,
                    ),
                    const SizedBox(height: 16),
                    _roleButton(
                      context,
                      title: 'Proprietário',
                      subtitle: 'Acompanhar nascentes',
                      icon: Icons.person_rounded,
                      role: UserRole.proprietario,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleButton(BuildContext context,
      {required String title,
      required String subtitle,
      required IconData icon,
      required UserRole role}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => LoginScreen(selectedRole: role),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              )
            ],
          ),
        ),
      ),
    );
  }
} 