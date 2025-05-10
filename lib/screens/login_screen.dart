import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agua_viva/services/auth_service.dart';
import 'package:agua_viva/screens/dashboard_screen.dart';
import 'package:agua_viva/theme.dart';
import 'package:agua_viva/models/user_model.dart';
import 'package:agua_viva/screens/cadastro_proprietario_screen.dart';

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
        _emailController.text = 'admin@agua-viva.com';
        _passwordController.text = 'admin123';
        break;
      case UserRole.evaluator:
        _emailController.text = 'avaliador@agua-viva.com';
        _passwordController.text = 'avaliador123';
        break;
      case UserRole.proprietario:
        _emailController.text = 'proprietario@agua-viva.com';
        _passwordController.text = 'proprietario123';
        break;
      default:
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
        _errorMessage = null;
      });

      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        bool success;
        
        if (widget.selectedRole == UserRole.proprietario) {
          success = await authService.signInProprietario(
            _emailController.text,
            _passwordController.text,
          );
        } else {
          success = await authService.signInWithEmailAndPassword(
            _emailController.text,
            _passwordController.text,
          );
        }

        if (!mounted) return;

        if (success) {
          // Navegar para o dashboard com o perfil do usuário
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => DashboardScreen(
                userRole: authService.currentUserRole ?? UserRole.admin,
              ),
            ),
          );
        } else {
          setState(() {
            _errorMessage = 'Email ou senha incorretos';
          });
        }
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _errorMessage = 'Erro ao fazer login. Tente novamente.';
        });
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
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
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
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'PSA - Programa de Pagamento de Serviços Ambientais',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white.withAlpha(230),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  // Login Form
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Entrar como ${_getRoleName(widget.selectedRole)}',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'E-mail',
                                prefixIcon: Icon(Icons.email_rounded),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, insira seu e-mail';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: 'Senha',
                                prefixIcon: const Icon(Icons.lock_rounded),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureText
                                        ? Icons.visibility_rounded
                                        : Icons.visibility_off_rounded,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureText = !_obscureText;
                                    });
                                  },
                                ),
                              ),
                              obscureText: _obscureText,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, insira sua senha';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Checkbox(
                                  value: _rememberMe,
                                  onChanged: (value) {
                                    setState(() {
                                      _rememberMe = value ?? false;
                                    });
                                  },
                                ),
                                const Text('Lembrar-me'),
                              ],
                            ),
                            if (_errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _isLoading ? null : _signIn,
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Text('Entrar'),
                            ),
                            if (widget.selectedRole == UserRole.proprietario) ...[
                              const SizedBox(height: 16),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const CadastroProprietarioScreen(),
                                    ),
                                  );
                                },
                                child: const Text('Não tem uma conta? Cadastre-se'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getRoleName(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Administrador';
      case UserRole.evaluator:
        return 'Avaliador';
      case UserRole.proprietario:
        return 'Proprietário';
      case UserRole.owner:
        return 'Proprietário';
    }
  }
}
