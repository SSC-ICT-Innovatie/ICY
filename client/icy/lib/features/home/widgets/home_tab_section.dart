import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:icy/features/home/bloc/home_bloc.dart';
import 'package:icy/data/models/survey_model.dart';
import 'package:icy/features/authentication/state/bloc/auth_bloc.dart';
import 'package:icy/features/survey/screens/survey_screen.dart';

class HomeTabSection extends StatefulWidget {
  const HomeTabSection({super.key});

  @override
  State<HomeTabSection> createState() => _HomeTabSectionState();
}

class _HomeTabSectionState extends State<HomeTabSection> {
  @override
  Widget build(BuildContext context) {
    // Get user information for department filtering
    final user = (context.read<AuthBloc>().state as AuthSuccess).user;
    final userDepartment = user.department;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: FTabs(
            initialIndex: 1,
            tabs: [
              // For You tab
              FTabEntry(
                label: const Text('For You'),
                content: SingleChildScrollView(
                  child: _buildSurveyList(
                    context,
                    filterByDepartment: true,
                    userDepartment: userDepartment,
                  ),
                ),
              ),

              // All Surveys tab
              FTabEntry(
                label: const Text('All Surveys'),
                content: SingleChildScrollView(
                  child: _buildSurveyList(context, filterByDepartment: false),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSurveyList(
    BuildContext context, {
    bool filterByDepartment = false,
    String? userDepartment,
  }) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is HomeError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${state.message}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<HomeBloc>().add(const LoadHome());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is HomeLoaded) {
          final List<SurveyModel> surveys =
              filterByDepartment
                  ? _filterSurveysByDepartment(
                    state.availableSurveys,
                    userDepartment,
                  )
                  : state.availableSurveys;

          if (surveys.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    filterByDepartment
                        ? 'No surveys available for your department'
                        : 'No surveys available at the moment',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: surveys.length,
            itemBuilder: (context, index) {
              final survey = surveys[index];
              return _buildSurveyCard(context, survey);
            },
          );
        }

        // Default state (initial)
        return const Center(child: Text('No data available'));
      },
    );
  }

  List<SurveyModel> _filterSurveysByDepartment(
    List<SurveyModel> surveys,
    String? department,
  ) {
    if (department == null) return surveys;

    return surveys.where((survey) {
      // Include if survey targets all departments or specifically the user's department
      return survey.targetDepartments.contains('all') ||
          survey.targetDepartments.contains(department);
    }).toList();
  }

  Widget _buildSurveyCard(BuildContext context, SurveyModel survey) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SurveyScreen(survey: survey),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          survey.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          survey.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      survey.estimatedTime,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.help_outline,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${survey.questions.length} questions',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${survey.reward.xp} XP',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.attach_money,
                        size: 16,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${survey.reward.coins} coins',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
