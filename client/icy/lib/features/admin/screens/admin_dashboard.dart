import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:icy/features/admin/bloc/admin_bloc.dart';
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
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    try {
      context.read<AdminBloc>().add(LoadAdminStats());
    } catch (e) {
      print("Error loading admin stats: $e");
      setState(() {
        _errorMessage = "Failed to load admin stats: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: FHeader(title: const Text('Admin Dashboard')),
      content: Stack(
        children: [
          BlocConsumer<AdminBloc, AdminState>(
            listener: (context, state) {
              if (state is AdminError) {
                setState(() {
                  _errorMessage = state.message;
                });
              } else if (state is AdminActionSuccess) {
                setState(() {
                  _successMessage = state.message;
                });
              } else if (state is AdminLoading) {
                setState(() {
                });
              } else {
                setState(() {
                });
              }
            },
            builder: (context, state) {
              // Conditionally render based on state
              return Stack(
                children: [
                  _buildContent(context, state),

                  // Error message
                  if (_errorMessage != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      right: 8,
                      child: FAlert(
                        icon: FIcon(FAssets.icons.badgeAlert),
                        title: const Text('Error'),
                        subtitle: Text(_errorMessage!),
                        style: FAlertStyle.destructive,
                      ),
                    ),

                  // Success message
                  if (_successMessage != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      right: 8,
                      child: FAlert(
                        icon: FIcon(FAssets.icons.badgeCheck),
                        title: const Text('Success'),
                        subtitle: Text(_successMessage!),
                        style: FAlertStyle.primary,
                      ),
                    ),
                ],
              );
            },
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: _buildFloatingActionButton(context),
          ),
        ],
      ),
    );
  }

  void _showAlert({required String message, bool isError = false}) {
    setState(() {
      if (isError) {
        _errorMessage = message;
      } else {
        _successMessage = message;
      }
    });

    // Auto-dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          if (isError) {
            _errorMessage = null;
          } else {
            _successMessage = null;
          }
        });
      }
    });
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
    return FTileGroup(
      children: [
        FTile(
          prefixIcon: Icon(
            Icons.poll,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: const Text('Manage Surveys'),
          subtitle: const Text('Create, edit and view all surveys'),
          suffixIcon: const Icon(Icons.chevron_right),
          onPress: () => _navigateTo(context, const SurveysScreen()),
        ),

        FTile(
          prefixIcon: Icon(
            Icons.business,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: const Text('Manage Departments'),
          subtitle: const Text('Create and manage departments'),
          suffixIcon: const Icon(Icons.chevron_right),
          onPress: () => _navigateTo(context, const DepartmentsScreen()),
        ),

        FTile(
          prefixIcon: Icon(
            Icons.people,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: const Text('Manage Users'),
          subtitle: const Text('View and manage user accounts'),
          suffixIcon: const Icon(Icons.chevron_right),
          onPress: () => _navigateTo(context, const UsersScreen()),
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
    return FButton(onPress: onPress, prefix: Icon(icon), label: Text(label));
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return FTile(
      title: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FButton(
          label: const Icon(Icons.add),
          onPress: () {
            _showFloatingActionMenu(context);
          },
        ),
      ],
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
    try {
      final adminBloc = context.read<AdminBloc>();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (context) => BlocProvider.value(value: adminBloc, child: screen),
        ),
      );
    } catch (e) {
      print("AdminBloc not found in context: $e");
      _showAlert(message: "Navigation error: $e", isError: true);
    }
  }
}
