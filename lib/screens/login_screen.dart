import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agua_viva/services/auth_service.dart';
import 'package:agua_viva/screens/dashboard_screen.dart';
import 'package:agua_viva/theme.dart';

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
                      color: Colors.white.withOpacity(0.9),
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
                      role: UserRole.owner,
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
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
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
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
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

class LoginScreen extends StatefulWidget {
  final UserRole selectedRole;

  const LoginScreen({super.key, required this.selectedRole});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscureText = true;

  // Pre-fill for demo purposes
  @override
  void initState() {
    super.initState();
    switch (widget.selectedRole) {
      case UserRole.admin:
        _emailController.text = 'admin@psa.com';
        _passwordController.text = '12345678';
        break;
      case UserRole.evaluator:
        _emailController.text = 'avaliador@psa.com';
        _passwordController.text = '12345678';
        break;
      case UserRole.owner:
        _emailController.text = 'proprietario@psa.com';
        _passwordController.text = '12345678';
        break;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Simular autenticação
        await Future.delayed(const Duration(seconds: 1));

        // Determinar o perfil do usuário com base no email
        UserRole userRole;
        if (_emailController.text == 'admin@psa.com') {
          userRole = UserRole.admin;
        } else if (_emailController.text == 'avaliador@psa.com') {
          userRole = UserRole.evaluator;
        } else {
          userRole = UserRole.owner;
        }

        if (!mounted) return;

        // Navegar para o dashboard com o perfil do usuário
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => DashboardScreen(userRole: userRole),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao fazer login. Tente novamente.'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryColor.withOpacity(0.8),
              AppTheme.primaryColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo ou Título
                        const Icon(
                          Icons.water_drop,
                          size: 80,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Água Viva',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Campo de Email
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'E-mail',
                            prefixIcon: const Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, insira seu e-mail';
                            }
                            if (!value.contains('@')) {
                              return 'Por favor, insira um e-mail válido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Campo de Senha
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, insira sua senha';
                            }
                            if (value.length < 8) {
                              return 'A senha deve ter pelo menos 8 caracteres';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        
                        // Botão de Login
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _signIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator()
                                : const Text(
                                    'Entrar',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Link para Cadastro
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/cadastro');
                          },
                          child: const Text(
                            'Não tem uma conta? Cadastre-se',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getRoleTitle(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Login como Administrador';
      case UserRole.evaluator:
        return 'Login como Avaliador';
      case UserRole.owner:
        return 'Login como Proprietário';
      default:
        return 'Login';
    }
  }
}
