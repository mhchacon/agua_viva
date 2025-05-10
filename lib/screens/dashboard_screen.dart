import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agua_viva/services/auth_service.dart';
import 'package:agua_viva/models/assessment_model.dart';
import 'package:agua_viva/screens/assessment_form_screen.dart';
import 'package:agua_viva/screens/assessment_details_screen.dart';
import 'package:agua_viva/services/assessment_service.dart';
import 'package:agua_viva/theme.dart';
import 'package:agua_viva/services/report_service.dart';

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
    return Consumer<AssessmentService>(
      builder: (context, assessmentService, _) {
        return FutureBuilder<List<SpringAssessment>>(
          future: assessmentService.getAllAssessments(),
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
                    Text('Erro ao carregar dados: ${snapshot.error}'),
                  ],
                ),
              );
            }

            final assessments = snapshot.data ?? [];
            
            if (assessments.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.assessment_outlined, size: 48, color: Colors.blue),
                    SizedBox(height: 16),
                    Text(
                      'Nenhuma avaliação cadastrada',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'As avaliações serão exibidas aqui quando disponíveis',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                )
              );
            }

            // Extrair estatísticas e dados para o dashboard
            final totalAssessments = assessments.length;
            final approvedCount = assessments.where((a) => a.status == 'approved').length;
            final pendingCount = assessments.where((a) => a.status == 'pending').length;
            final rejectedCount = assessments.where((a) => a.status == 'rejected').length;
            
            // Agrupar por município para estatísticas
            final municipalityMap = <String, int>{};
            for (var assessment in assessments) {
              final municipality = assessment.municipality;
              municipalityMap[municipality] = (municipalityMap[municipality] ?? 0) + 1;
            }
            
            // Extrair os municípios com mais avaliações
            final topMunicipalities = municipalityMap.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));
            
            // Calcular porcentagens de classificação
            final preservedCount = assessments.where((a) => a.generalState == 'Preservada').length;
            final disturbedCount = assessments.where((a) => a.generalState == 'Perturbada').length;
            final degradedCount = assessments.where((a) => a.generalState == 'Degradada').length;
            
            final preservedPercent = (preservedCount / totalAssessments * 100).toStringAsFixed(1);
            final disturbedPercent = (disturbedCount / totalAssessments * 100).toStringAsFixed(1);
            final degradedPercent = (degradedCount / totalAssessments * 100).toStringAsFixed(1);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Painel de Controle',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Resumo de avaliações
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Resumo de Avaliações',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatCard(
                                'Total', 
                                totalAssessments.toString(), 
                                Icons.assessment, 
                                AppTheme.primaryColor,
                              ),
                              _buildStatCard(
                                'Aprovadas', 
                                approvedCount.toString(), 
                                Icons.check_circle, 
                                Colors.green,
                              ),
                              _buildStatCard(
                                'Pendentes', 
                                pendingCount.toString(), 
                                Icons.pending, 
                                Colors.orange,
                              ),
                              _buildStatCard(
                                'Rejeitadas', 
                                rejectedCount.toString(), 
                                Icons.cancel, 
                                Colors.red,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => _generateSummaryPdf(assessments),
                            icon: const Icon(Icons.picture_as_pdf),
                            label: const Text('Gerar Relatório PDF'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              minimumSize: const Size(double.infinity, 48),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Distribuição de estados das nascentes
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Estado das Nascentes',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _buildProgressStat(
                                'Preservadas', 
                                preservedCount, 
                                totalAssessments, 
                                Colors.green,
                              ),
                              const SizedBox(width: 8),
                              _buildProgressStat(
                                'Perturbadas', 
                                disturbedCount, 
                                totalAssessments, 
                                Colors.orange,
                              ),
                              const SizedBox(width: 8),
                              _buildProgressStat(
                                'Degradadas', 
                                degradedCount, 
                                totalAssessments, 
                                Colors.red,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Municípios
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Municípios mais Avaliados',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(),
                          const SizedBox(height: 8),
                          ...topMunicipalities.take(5).map((entry) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    entry.key,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    entry.value.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )).toList(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Últimas avaliações
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Últimas Avaliações',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(),
                          const SizedBox(height: 8),
                          ...assessments
                            .take(5)
                            .map((assessment) => ListTile(
                              leading: Icon(
                                Icons.water_drop,
                                color: _getStatusColor(assessment.status),
                              ),
                              title: Text(assessment.ownerName),
                              subtitle: Text('${assessment.municipality} - ${assessment.generalState}'),
                              trailing: Chip(
                                label: Text(_getStatusText(assessment.status)),
                                backgroundColor: _getStatusColor(assessment.status).withOpacity(0.1),
                                labelStyle: TextStyle(
                                  color: _getStatusColor(assessment.status),
                                ),
                              ),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => AssessmentDetailsScreen(
                                      assessmentId: assessment.id,
                                    ),
                                  ),
                                );
                              },
                            )),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.center,
                            child: TextButton.icon(
                              icon: const Icon(Icons.view_list),
                              label: const Text('Ver todas'),
                              onPressed: () {
                                // Aqui poderia navegar para uma tela com a lista completa
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 36),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: color,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressStat(String label, int count, int total, Color color) {
    final percent = total > 0 ? count / total : 0.0;
    
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percent,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 10,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(height: 4),
          Text(
            '${count.toString()} (${(percent * 100).toStringAsFixed(1)}%)',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Future<void> _generateSummaryPdf(List<SpringAssessment> assessments) async {
    final reportService = ReportService();
    
    try {
      await reportService.generateSummaryPdfReport(assessments);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Relatório PDF gerado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao gerar relatório: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildMapView() {
    return const Center(child: Text('Mapa de Nascentes'));
  }
  Widget _buildReportsView() {
    return const Center(child: Text('Relatórios'));
  }
  Widget _buildEvaluatorAssessments() {
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

            final userId = userSnapshot.data!['id'] as String;

            return FutureBuilder<List<SpringAssessment>?>(
              future: (() async {
                try {
                  // Buscar todas as avaliações (para o avaliador ver todas)
                  final List<SpringAssessment> assessmentsValue = await assessmentService.getAllAssessments();
                  return assessmentsValue;
                } catch (e) {
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

                final assessments = snapshot.data ?? <SpringAssessment>[];

                if (assessments.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assessment_outlined, size: 48, color: Colors.blue),
                        SizedBox(height: 16),
                        Text(
                          'Nenhuma avaliação encontrada',
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'As avaliações cadastradas aparecerão aqui',
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
                      elevation: 3,
                      child: ListTile(
                        leading: Icon(
                          Icons.water_drop,
                          color: _getStatusColor(assessment.status),
                          size: 36,
                        ),
                        title: Text(assessment.municipality,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Proprietário: ${assessment.ownerName}'),
                            Text('Referência: ${assessment.reference}'),
                            Text('Estado: ${assessment.generalState}'),
                            Row(
                              children: [
                                Text('Status: '),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(assessment.status).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: _getStatusColor(assessment.status)),
                                  ),
                                  child: Text(
                                    _getStatusText(assessment.status),
                                    style: TextStyle(
                                      color: _getStatusColor(assessment.status),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        isThreeLine: true,
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
