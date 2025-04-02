import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icy/data/models/survey_model.dart';
import 'package:icy/features/admin/bloc/admin_bloc.dart';
import 'package:icy/features/admin/screens/create_survey_screen.dart';
import 'package:intl/intl.dart';

class SurveysScreen extends StatefulWidget {
  const SurveysScreen({super.key});

  @override
  State<SurveysScreen> createState() => _SurveysScreenState();
}

class _SurveysScreenState extends State<SurveysScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(LoadSurveys());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Surveys'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder:
                      (context) => BlocProvider.value(
                        value: context.read<AdminBloc>(),
                        child: const CreateSurveyScreen(),
                      ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SurveysLoaded) {
            return _buildSurveysList(context, state.surveys);
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assignment_late_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                const Text('No surveys found'),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<AdminBloc>().add(LoadSurveys());
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (context) => BlocProvider.value(
                    value: context.read<AdminBloc>(),
                    child: const CreateSurveyScreen(),
                  ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSurveysList(BuildContext context, List<SurveyModel> surveys) {
    if (surveys.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_late_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            const Text('No surveys found'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<AdminBloc>().add(LoadSurveys());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
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
        DateTime expiryDate;

        try {
          if (survey.expiresAt is DateTime) {
            expiryDate = survey.expiresAt as DateTime;
          } else {
            expiryDate = DateTime.parse(survey.expiresAt);
          }
        } catch (e) {
          // If parsing fails, use default
          expiryDate = DateTime.now().add(const Duration(days: 7));
          print('Error parsing date: $e');
        }

        final isExpired = expiryDate.isBefore(DateTime.now());

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outline,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.description,
                      color:
                          isExpired
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        survey.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (isExpired)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Expired',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(survey.description),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Questions: ${survey.questions.length}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          'Time: ${survey.estimatedTime}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.diamond, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              '${survey.reward.xp} XP',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.monetization_on, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              '${survey.reward.coins} Coins',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Expires: ${DateFormat('MMM d, yyyy').format(expiryDate)}',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        isExpired
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
