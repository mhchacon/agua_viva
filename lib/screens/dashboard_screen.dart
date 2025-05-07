import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agua_viva/services/auth_service.dart';
import 'package:agua_viva/models/spring_assessment_model.dart';
import 'package:agua_viva/screens/assessment_form_screen.dart';
import 'package:agua_viva/screens/assessment_details_screen.dart';
import 'package:agua_viva/services/assessment_service.dart';
import 'package:agua_viva/services/report_service.dart';
import 'package:agua_viva/theme.dart';

class DashboardScreen extends StatefulWidget {
  final UserRole userRole;

  const DashboardScreen({Key? key, required this.userRole}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ReportService _reportService = ReportService();
  String _filterStatus = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Initialize tabs based on user role
    int tabCount = _getTabCount();
    _tabController = TabController(length: tabCount, vsync: this);
  }

  int _getTabCount() {
    switch (widget.userRole) {
      case UserRole.admin:
        return 3; // Dashboard, Map, Reports
      case UserRole.evaluator:
        return 2; // My Assessments, Create New
      case UserRole.owner:
        return 2; // My Springs, Status
      default:
        return 1;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Água Viva PSA'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await Provider.of<AuthService>(context, listen: false).signOut();
              if (!mounted) return;
              Navigator.of(context).pushReplacementNamed('/');
            },
            tooltip: 'Sair',
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
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  List<Widget> _buildTabs() {
    switch (widget.userRole) {
      case UserRole.admin:
        return [
          const Tab(text: 'Cadastros', icon: Icon(Icons.dashboard_rounded)),
          const Tab(text: 'Mapa', icon: Icon(Icons.map_rounded)),
          const Tab(text: 'Relatórios', icon: Icon(Icons.summarize_rounded)),
        ];
      case UserRole.evaluator:
        return [
          const Tab(text: 'Minhas Avaliações', icon: Icon(Icons.assessment_rounded)),
          const Tab(text: 'Novo Cadastro', icon: Icon(Icons.add_circle_rounded)),
        ];
      case UserRole.owner:
        return [
          const Tab(text: 'Minhas Nascentes', icon: Icon(Icons.water_drop_rounded)),
          const Tab(text: 'Status', icon: Icon(Icons.info_rounded)),
        ];
      default:
        return [const Tab(text: 'Dashboard')];
    }
  }

  List<Widget> _buildTabViews() {
    final userId = Provider.of<AuthService>(context).currentUserId ?? '';
    
    switch (widget.userRole) {
      case UserRole.admin:
        return [
          _buildAdminDashboard(),
          _buildMapView(),
          _buildReportsView(),
        ];
      case UserRole.evaluator:
        return [
          _buildEvaluatorAssessments(userId),
          _buildNewAssessmentView(),
        ];
      case UserRole.owner:
        return [
          _buildOwnerSprings(userId),
          _buildOwnerStatusView(userId),
        ];
      default:
        return [Container()];
    }
  }

  Widget? _buildFloatingActionButton() {
    if (widget.userRole == UserRole.evaluator && _tabController.index == 0) {
      return FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AssessmentFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      );
    }
    return null;
  }

  // Admin Views
  Widget _buildAdminDashboard() {
    final assessmentService = Provider.of<AssessmentService>(context);
    
    return Column(
      children: [
        _buildStatusFilter(),
        _buildSearchBar(),
        Expanded(
          child: StreamBuilder<List<SpringAssessment>>(
            stream: _filterStatus == 'all'
                ? assessmentService.getAllAssessments()
                : assessmentService.getAssessmentsByStatus(_filterStatus),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Erro: ${snapshot.error}'),
                );
              }

              List<SpringAssessment> assessments = snapshot.data ?? [];

              // Apply search filter
              if (_searchQuery.isNotEmpty) {
                assessments = assessments.where((assessment) {
                  return assessment.ownerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                     assessment.municipality.toLowerCase().contains(_searchQuery.toLowerCase());
                }).toList();
              }

              if (assessments.isEmpty) {
                return const Center(
                  child: Text('Nenhuma avaliação encontrada.'),
                );
              }

              return ListView.builder(
                itemCount: assessments.length,
                itemBuilder: (context, index) {
                  return _buildAssessmentCard(assessments[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMapView() {
    // Placeholder for map view
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.map_rounded,
            size: 100,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'Mapa de Nascentes',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'O mapa não está disponível nesta versão do MVP.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReportsView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Geração de Relatórios',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          _buildReportCard(
            title: 'Relatório Completo em PDF',
            description: 'Gera um relatório com todos os dados dos formulários',
            icon: Icons.picture_as_pdf_rounded,
            onTap: () {
              _showReportGenerationDialog('pdf');
            },
          ),
          const SizedBox(height: 16),
          _buildReportCard(
            title: 'Exportar para Excel (CSV)',
            description: 'Exporta os dados para planilha',
            icon: Icons.table_chart_rounded,
            onTap: () {
              _showReportGenerationDialog('csv');
            },
          ),
          const SizedBox(height: 16),
          _buildReportCard(
            title: 'Exportar para KMZ',
            description: 'Para visualização em Google Earth',
            icon: Icons.public_rounded,
            onTap: () {
              _showReportGenerationDialog('kmz');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: Theme.of(context).colorScheme.secondary,
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
                    const SizedBox(height: 4),
                    Text(
                      description,
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

  // Evaluator Views
  Widget _buildEvaluatorAssessments(String evaluatorId) {
    final assessmentService = Provider.of<AssessmentService>(context);
    
    return StreamBuilder<List<SpringAssessment>>(
      stream: assessmentService.getEvaluatorAssessments(evaluatorId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Erro: ${snapshot.error}'),
          );
        }

        List<SpringAssessment> assessments = snapshot.data ?? [];

        if (assessments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assessment_outlined,
                  size: 80,
                  color: Colors.grey.withOpacity(0.7),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Nenhuma avaliação encontrada.',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Comece criando uma nova avaliação.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AssessmentFormScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Nova Avaliação'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: assessments.length,
          itemBuilder: (context, index) {
            return _buildAssessmentCard(assessments[index]);
          },
        );
      },
    );
  }

  Widget _buildNewAssessmentView() {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add_circle_outline_rounded,
                    size: 100,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Cadastrar Nova Avaliação',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 48.0),
                  child: Text(
                    'Inicie o cadastro de uma nova avaliação preenchendo o formulário completo.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  height: 50,
                  width: 200,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AssessmentFormScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Iniciar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Owner Views
  Widget _buildOwnerSprings(String ownerId) {
    final assessmentService = Provider.of<AssessmentService>(context);
    
    return StreamBuilder<List<Spring>>(
      stream: assessmentService.getOwnerSprings(ownerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Erro: ${snapshot.error}'),
          );
        }

        List<Spring> springs = snapshot.data ?? [];

        if (springs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.water_drop_outlined,
                  size: 80,
                  color: Colors.grey.withOpacity(0.7),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Nenhuma nascente cadastrada.',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Entre em contato com um avaliador para cadastrar suas nascentes.',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: springs.length,
          itemBuilder: (context, index) {
            return _buildSpringCard(springs[index]);
          },
        );
      },
    );
  }

  Widget _buildOwnerStatusView(String ownerId) {
    final assessmentService = Provider.of<AssessmentService>(context);
    
    return StreamBuilder<List<Spring>>(
      stream: assessmentService.getOwnerSprings(ownerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Erro: ${snapshot.error}'),
          );
        }

        List<Spring> springs = snapshot.data ?? [];
        int activeCount = springs.where((s) => s.hasAPP && s.appStatus == 'Bom').length;
        int inactiveCount = springs.length - activeCount;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Status das Nascentes',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  _buildStatusCard(
                    title: 'Ativas',
                    count: activeCount,
                    icon: Icons.check_circle_rounded,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 16),
                  _buildStatusCard(
                    title: 'Inativas',
                    count: inactiveCount,
                    icon: Icons.cancel_rounded,
                    color: Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'Histórico de Atualizações',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              // Placeholder for history
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('03/04/2023', style: TextStyle(color: Colors.grey)),
                          Icon(Icons.info_outline, color: Colors.blue, size: 18),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text('Avaliação inicial realizada', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('Nascente classificada como "Perturbada". Recomendado o cercamento.'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('15/07/2023', style: TextStyle(color: Colors.grey)),
                          Icon(Icons.check_circle, color: Colors.green, size: 18),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text('Cercamento realizado', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('Verificação do cercamento aprovada. PSA iniciado.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(icon, color: color),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                count.toString(),
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Shared Components
  Widget _buildStatusFilter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('Todos', 'all'),
            const SizedBox(width: 8),
            _buildFilterChip('Pendentes', 'pending'),
            const SizedBox(width: 8),
            _buildFilterChip('Aprovados', 'approved'),
            const SizedBox(width: 8),
            _buildFilterChip('Indeferidos', 'rejected'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String status) {
    final isSelected = _filterStatus == status;
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      checkmarkColor: Theme.of(context).colorScheme.primary,
      onSelected: (selected) {
        setState(() {
          _filterStatus = selected ? status : 'all';
        });
      },
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Buscar por nome ou município',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildAssessmentCard(SpringAssessment assessment) {
    IconData statusIcon;
    Color statusColor;

    switch (assessment.status) {
      case 'approved':
        statusIcon = Icons.check_circle;
        statusColor = Colors.green;
        break;
      case 'rejected':
        statusIcon = Icons.cancel;
        statusColor = Colors.red;
        break;
      default: // pending
        statusIcon = Icons.hourglass_empty;
        statusColor = Colors.orange;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AssessmentDetailsScreen(assessmentId: assessment.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      assessment.ownerName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(statusIcon, color: statusColor, size: 20),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(assessment.municipality),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.water_drop_outlined,
                    size: 16,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: 4),
                  Text(assessment.generalState),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Tipo: ${assessment.springType} | Regime: ${assessment.flowRegime}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pontuação: ${assessment.hydroEnvironmentalTotal}/33',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    _formatDate(assessment.updatedAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpringCard(Spring spring) {
    IconData statusIcon;
    Color statusColor;

    if (spring.hasAPP && spring.appStatus == 'Bom') {
      statusIcon = Icons.check_circle;
      statusColor = Colors.green;
    } else {
      statusIcon = spring.hasAPP ? Icons.warning_amber_rounded : Icons.cancel;
      statusColor = spring.hasAPP ? Colors.orange : Colors.red;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Nascente: ${spring.reference}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(statusIcon, color: statusColor, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(spring.municipality),
                const SizedBox(width: 16),
                Icon(
                  Icons.terrain_outlined,
                  size: 16,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 4),
                Text('Alt. ${spring.altitude.toStringAsFixed(0)}m'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.forest_outlined,
                  size: 16,
                  color: spring.hasAPP ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  spring.hasAPP 
                      ? 'APP: ${spring.appStatus}' 
                      : 'Sem APP',
                  style: TextStyle(
                    color: spring.hasAPP 
                        ? (spring.appStatus == 'Bom' ? Colors.green : Colors.orange) 
                        : Colors.grey,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.description_outlined,
                  size: 16,
                  color: spring.hasCAR ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  spring.hasCAR ? 'CAR: Sim' : 'CAR: Não',
                  style: TextStyle(
                    color: spring.hasCAR ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  _formatDate(spring.updatedAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _showReportGenerationDialog(String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Gerar ${_getReportTypeName(type)}'),
        content: const Text('Esta funcionalidade será implementada em uma versão futura do aplicativo.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _getReportTypeName(String type) {
    switch (type) {
      case 'pdf':
        return 'PDF';
      case 'csv':
        return 'CSV (Excel)';
      case 'kmz':
        return 'KMZ (Google Earth)';
      default:
        return 'Relatório';
    }
  }
}
