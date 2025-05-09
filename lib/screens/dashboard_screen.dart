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

  @override
  void initState() {
    super.initState();
    int tabCount = _getTabCount();
    _tabController = TabController(length: tabCount, vsync: this);
  }

  int _getTabCount() {
    switch (widget.userRole) {
      case UserRole.admin:
        return 3;
      case UserRole.evaluator:
        return 2;
      case UserRole.owner:
        return 2;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.userRole == UserRole.owner) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Bem-vindo!'),
          backgroundColor: AppTheme.primaryColor,
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.water_drop, size: 80, color: AppTheme.primaryColor),
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
                  // TODO: Navegar para lista de nascentes
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
                  // TODO: Navegar para cadastro
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
                  // TODO: Navegar para status
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
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/');
            },
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
              label: const Text('Novo Cadastro'),
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
      case UserRole.owner:
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
      case UserRole.owner:
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
    return const Center(child: Text('Minhas Nascentes'));
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
      case UserRole.owner:
        return 'Proprietário';
    }
  }
}
