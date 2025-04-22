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
  void initState() {
    super.initState();
    // Ensure we load fresh data when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeBloc>().add(const LoadHome(forceRefresh: true));
    });
  }

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
            initialIndex: 0, // Start with "For You" tab selected
            tabs: [
              // For You tab
              FTabEntry(
                label: const Text('For You'),
                content: RefreshIndicator(
                  onRefresh: () async {
                    context.read<HomeBloc>().add(const LoadHome(forceRefresh: true));
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: _buildSurveyList(
                      context,
                      filterByDepartment: true,
                      userDepartment: userDepartment,
                    ),
                  ),
                ),
              ),

              // All Surveys tab
              FTabEntry(
                label: const Text('All Surveys'),
                content: RefreshIndicator(
                  onRefresh: () async {
                    context.read<HomeBloc>().add(const LoadHome(forceRefresh: true));
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: _buildSurveyList(context, filterByDepartment: false),
                  ),
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
                FButton(
                  onPress: () {
                    context.read<HomeBloc>().add(const LoadHome());
                  },
                  label: const Text('Retry'),
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

          // Fixed: Use shrinkWrap: true and disable physics to prevent the unbounded height issue
          return FTileGroup.builder(
          
            count: surveys.length,
          
         
            tileBuilder: (context, index) {
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
    return FTile(
      onPress: () {
        // Get the current HomeBloc
        final homeBloc = context.read<HomeBloc>();
        
        // Navigate to survey screen with HomeBloc provided
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider.value(
              value: homeBloc,
              child: SurveyScreen(survey: survey),
            ),
          ),
        );
      },
      suffixIcon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
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
      details: Text(
        survey.description,
        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      title: Text(
        survey.title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),

      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.help_outline, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                '${survey.questions.length} questions',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.star, size: 16, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                '${survey.reward.xp} XP',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.attach_money, size: 16, color: Colors.green),
              const SizedBox(width: 4),
              Text(
                '${survey.reward.coins} coins',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
