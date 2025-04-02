import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icy/data/repositories/department_repository.dart';
import 'package:icy/data/repositories/survey_repository.dart';
import 'package:icy/features/admin/bloc/admin_bloc.dart';
import 'package:icy/features/admin/repositories/admin_repository.dart';
import 'package:icy/features/admin/screens/create_department_screen.dart';
import 'package:icy/features/admin/screens/create_survey_screen.dart';
import 'package:icy/features/admin/screens/departments_screen.dart';
import 'package:icy/features/admin/screens/surveys_screen.dart';
import 'package:icy/features/admin/screens/users_screen.dart';
import 'package:icy/features/admin/widgets/admin_stat_card.dart';
import 'package:icy/features/admin/models/admin_model.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    // Try to safely load admin stats
    try {
      context.read<AdminBloc>().add(LoadAdminStats());
    } catch (e) {
      print("Error loading admin stats: $e");
      // We'll try again in the build method
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: BlocConsumer<AdminBloc, AdminState>(
        listener: (context, state) {
          if (state is AdminError) {
            _showSnackBar(context, state.message, isError: true);
          } else if (state is AdminActionSuccess) {
            _showSnackBar(context, state.message, isError: false);
          }
        },
        builder: (context, state) {
          return _buildContent(context, state);
        },
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  void _showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Widget _buildContent(BuildContext context, AdminState state) {
    if (state is AdminLoading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    AdminStats stats = AdminStats.empty();
    if (state is AdminStatsLoaded) {
      stats = state.stats;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to Admin Dashboard',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),

          _buildStatCards(context, stats),
          const SizedBox(height: 32),

          _buildQuickActions(context),
          const SizedBox(height: 32),

          _buildSectionTitle(context, 'Manage Content'),
          const SizedBox(height: 16),

          _buildManageContent(context),
          const SizedBox(height: 100), // Extra space for FAB
        ],
      ),
    );
  }

  Widget _buildStatCards(BuildContext context, AdminStats stats) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          AdminStatCard(
            title: 'Total Users',
            value: stats.totalUsers.toString(),
            icon: Icons.person,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          AdminStatCard(
            title: 'Total Surveys',
            value: stats.totalSurveys.toString(),
            icon: Icons.description,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(width: 12),
          AdminStatCard(
            title: 'Departments',
            value: stats.totalDepartments.toString(),
            icon: Icons.business,
            color: Colors.teal,
          ),
          const SizedBox(width: 12),
          AdminStatCard(
            title: 'Active Users',
            value: stats.activeUsers.toString(),
            icon: Icons.people,
            color: Colors.purple,
          ),
          const SizedBox(width: 12),
          AdminStatCard(
            title: 'Participation',
            value: '${stats.participationRate}%',
            icon: Icons.bar_chart,
            color: Colors.amber,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Quick Actions'),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildActionButton(
              context,
              'Create Survey',
              Icons.note_add,
              () => _navigateTo(context, const CreateSurveyScreen()),
            ),
            _buildActionButton(
              context,
              'Add Department',
              Icons.create_new_folder,
              () => _navigateTo(context, const CreateDepartmentScreen()),
            ),
            _buildActionButton(
              context,
              'View Users',
              Icons.supervised_user_circle,
              () => _navigateTo(context, const UsersScreen()),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildManageContent(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(
            Icons.poll,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: const Text('Manage Surveys'),
          subtitle: const Text('Create, edit and view all surveys'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _navigateTo(context, const SurveysScreen()),
        ),
        const Divider(),
        ListTile(
          leading: Icon(
            Icons.business,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: const Text('Manage Departments'),
          subtitle: const Text('Create and manage departments'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _navigateTo(context, const DepartmentsScreen()),
        ),
        const Divider(),
        ListTile(
          leading: Icon(
            Icons.people,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: const Text('Manage Users'),
          subtitle: const Text('View and manage user accounts'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _navigateTo(context, const UsersScreen()),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPress,
  ) {
    return ElevatedButton.icon(
      onPressed: onPress,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(title, style: Theme.of(context).textTheme.titleLarge);
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      child: const Icon(Icons.add),
      onPressed: () {
        _showFloatingActionMenu(context);
      },
    );
  }

  void _showFloatingActionMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Create New',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildFloatingActionOption(
                        context,
                        'Survey',
                        Icons.description,
                        () => _navigateTo(context, const CreateSurveyScreen()),
                      ),
                      _buildFloatingActionOption(
                        context,
                        'Department',
                        Icons.business,
                        () => _navigateTo(
                          context,
                          const CreateDepartmentScreen(),
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

  Widget _buildFloatingActionOption(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop(); // Close bottom sheet
        onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    // Create a provider that preserves the existing AdminBloc instance
    try {
      final adminBloc = context.read<AdminBloc>();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (context) => BlocProvider.value(value: adminBloc, child: screen),
        ),
      );
    } catch (e) {
      // Fallback if AdminBloc is not available
      print("AdminBloc not found in context: $e");
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => screen));
    }
  }
}
