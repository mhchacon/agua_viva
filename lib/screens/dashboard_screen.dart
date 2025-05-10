import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agua_viva/services/auth_service.dart';
import 'package:agua_viva/models/assessment_model.dart';
import 'package:agua_viva/screens/assessment_form_screen.dart';
import 'package:agua_viva/screens/assessment_details_screen.dart';
import 'package:agua_viva/services/assessment_service.dart';
import 'package:agua_viva/theme.dart';

class DashboardScreen extends StatefulWidget {
  final UserRole userRole;

  const DashboardScreen({Key? key, required this.userRole}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _mounted = true;

  @override
  void initState() {
    super.initState();
    int tabCount = _getTabCount();
    _tabController = TabController(length: tabCount, vsync: this);
  }

  @override
  void dispose() {
    _mounted = false;
    _tabController.dispose();
    super.dispose();
  }

  int _getTabCount() {
    switch (widget.userRole) {
      case UserRole.admin:
        return 3;
      case UserRole.evaluator:
        return 2;
      case UserRole.proprietario:
        return 2;
      default:
        return 2;
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final navigator = Navigator.of(context);
    await authService.signOut();
    if (_mounted) {
      navigator.pushReplacementNamed('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.userRole == UserRole.proprietario) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Bem-vindo!'),
          backgroundColor: AppTheme.primaryColor,
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _handleLogout(context),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.water_drop, size: 80, color: AppTheme.primaryColor),
              const SizedBox(height: 24),
              const Text(
                'Olá! Aqui você pode acompanhar suas nascentes.',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: const Icon(Icons.visibility, size: 32),
                label: const Text('Ver Minhas Nascentes', style: TextStyle(fontSize: 20)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  backgroundColor: AppTheme.primaryColor,
                ),
                onPressed: () {
                  _tabController.animateTo(0);
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_circle, size: 32),
                label: const Text('Cadastrar Nova Nascente', style: TextStyle(fontSize: 20)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  backgroundColor: AppTheme.secondaryColor,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AssessmentFormScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.info, size: 32),
                label: const Text('Ver Status', style: TextStyle(fontSize: 20)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  backgroundColor: AppTheme.accentColor,
                ),
                onPressed: () {
                  _tabController.animateTo(1);
                },
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard - ${_getRoleTitle()}'),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _buildTabs(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _buildTabViews(),
      ),
      floatingActionButton: widget.userRole == UserRole.evaluator
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: const Text('Nova Avaliação'),
              backgroundColor: AppTheme.primaryColor,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AssessmentFormScreen(),
                  ),
                );
              },
            )
          : null,
    );
  }

  List<Widget> _buildTabs() {
    switch (widget.userRole) {
      case UserRole.admin:
        return const [
          Tab(text: 'Cadastros', icon: Icon(Icons.dashboard_rounded)),
          Tab(text: 'Mapa', icon: Icon(Icons.map_rounded)),
          Tab(text: 'Relatórios', icon: Icon(Icons.summarize_rounded)),
        ];
      case UserRole.evaluator:
        return const [
          Tab(text: 'Minhas Avaliações', icon: Icon(Icons.assessment_rounded)),
          Tab(text: 'Novo Cadastro', icon: Icon(Icons.add_circle_rounded)),
        ];
      case UserRole.proprietario:
        return const [
          Tab(text: 'Minhas Nascentes', icon: Icon(Icons.water_drop_rounded)),
          Tab(text: 'Status', icon: Icon(Icons.info_rounded)),
        ];
      default:
        return const [
          Tab(text: 'Minhas Nascentes', icon: Icon(Icons.water_drop_rounded)),
          Tab(text: 'Status', icon: Icon(Icons.info_rounded)),
        ];
    }
  }

  List<Widget> _buildTabViews() {
    switch (widget.userRole) {
      case UserRole.admin:
        return [
          _buildAdminDashboard(),
          _buildMapView(),
          _buildReportsView(),
        ];
      case UserRole.evaluator:
        return [
          _buildEvaluatorAssessments(),
          _buildNewAssessmentView(),
        ];
      case UserRole.proprietario:
        return [
          _buildOwnerSprings(),
          _buildOwnerStatusView(),
        ];
      default:
        return [
          _buildOwnerSprings(),
          _buildOwnerStatusView(),
        ];
    }
  }

  Widget _buildAdminDashboard() {
    return const Center(child: Text('Painel do Administrador'));
  }
  Widget _buildMapView() {
    return const Center(child: Text('Mapa de Nascentes'));
  }
  Widget _buildReportsView() {
    return const Center(child: Text('Relatórios'));
  }
  Widget _buildEvaluatorAssessments() {
    return const Center(child: Text('Minhas Avaliações'));
  }
  Widget _buildNewAssessmentView() {
    return const Center(child: Text('Novo Cadastro'));
  }
  Widget _buildOwnerSprings() {
    return Consumer2<AuthService, AssessmentService>(
      builder: (context, authService, assessmentService, _) {
        return FutureBuilder<Map<String, dynamic>?>(
          future: authService.getCurrentUser(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (userSnapshot.hasError || userSnapshot.data == null) {
              return const Center(child: Text('Erro ao carregar dados do usuário'));
            }

            final userCpf = userSnapshot.data!['cpf'] as String;

            return FutureBuilder<List<SpringAssessment>?>(
              future: (() async {
                try {
                  final List<SpringAssessment> assessmentsValue = await assessmentService.getAssessmentsByOwnerCpf(userCpf);
                  return assessmentsValue;
                } catch (e) {
                  // Em caso de erro ao buscar, retorna null, compatível com List<SpringAssessment>?
                  // print('Erro ao buscar avaliações no FutureBuilder: $e'); // Para depuração, se necessário
                  return null;
                }
              })(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Erro ao carregar avaliações: ${snapshot.error}'),
                      ],
                    ),
                  );
                }

                // Se o future retornou null (devido ao nosso catch), snapshot.data será null.
                // snapshot.data ?? <SpringAssessment>[] tratará isso como uma lista vazia.
                final assessments = snapshot.data ?? <SpringAssessment>[];

                if (assessments.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.water_drop_outlined, size: 48, color: Colors.blue),
                        SizedBox(height: 16),
                        Text(
                          'Nenhuma avaliação encontrada',
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'As avaliações das suas nascentes aparecerão aqui',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: assessments.length,
                  itemBuilder: (context, index) {
                    final assessment = assessments[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        leading: Icon(
                          Icons.water_drop,
                          color: _getStatusColor(assessment.status),
                        ),
                        title: Text(assessment.municipality),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Referência: ${assessment.reference}'),
                            Text('Estado: ${assessment.generalState}'),
                            Text('Status: ${_getStatusText(assessment.status)}'),
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AssessmentDetailsScreen(
                                assessmentId: assessment.id,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'approved':
        return 'Aprovado';
      case 'rejected':
        return 'Rejeitado';
      case 'pending':
        return 'Pendente';
      default:
        return 'Desconhecido';
    }
  }

  Widget _buildOwnerStatusView() {
    return const Center(child: Text('Status das Nascentes'));
  }

  String _getRoleTitle() {
    switch (widget.userRole) {
      case UserRole.admin:
        return 'Administrador';
      case UserRole.evaluator:
        return 'Avaliador';
      case UserRole.proprietario:
        return 'Proprietário';
      default:
        return 'Usuário';
    }
  }
}
