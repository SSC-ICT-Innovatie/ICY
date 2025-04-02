import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:icy/data/models/department_model.dart';
import 'package:icy/features/admin/bloc/admin_bloc.dart';
import 'package:icy/features/admin/models/admin_model.dart';
import 'package:intl/intl.dart';

class CreateSurveyScreen extends StatefulWidget {
  const CreateSurveyScreen({super.key});

  @override
  State<CreateSurveyScreen> createState() => _CreateSurveyScreenState();
}

class _CreateSurveyScreenState extends State<CreateSurveyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _estimatedTimeController = TextEditingController(text: '5 mins');
  final _xpRewardController = TextEditingController(text: '100');
  final _coinsRewardController = TextEditingController(text: '50');

  DateTime _expiryDate = DateTime.now().add(const Duration(days: 7));
  List<Department> _departments = [];
  List<String> _selectedDepartments = [];
  List<Map<String, dynamic>> _questions = [];
  bool _isSubmitting = false;
  bool _isLoadingDepartments = true;

  @override
  void initState() {
    super.initState();
    // Add initial question
    _addNewQuestion();

    // Load departments
    context.read<AdminBloc>().add(LoadDepartments());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _estimatedTimeController.dispose();
    _xpRewardController.dispose();
    _coinsRewardController.dispose();
    super.dispose();
  }

  void _addNewQuestion() {
    setState(() {
      _questions.add({
        'id': 'q${_questions.length + 1}',
        'text': '',
        'type': 'yes_no',
        'options': <String>[],
        'optional': false,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminBloc, AdminState>(
      listener: (context, state) {
        if (state is DepartmentsLoaded) {
          setState(() {
            _departments = state.departments;
            _isLoadingDepartments = false;
          });
        } else if (state is AdminActionSuccess) {
          setState(() {
            _isSubmitting = false;
          });

          // Show success message and navigate back
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));

          Navigator.of(context).pop();
        } else if (state is AdminError) {
          setState(() {
            _isSubmitting = false;
          });

          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        } else if (state is AdminLoading) {
          setState(() {
            _isSubmitting = true;
          });
        }
      },
      builder: (context, state) {
        return FScaffold(
          header: FHeader(
            title: const Text('Create Survey'),
            actions: [
              FButton.icon(
                onPress: () => Navigator.of(context).pop(),
                child: FIcon(FAssets.icons.chevronLeft),
              ),
            ],
          ),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBasicInfo(),
                  const SizedBox(height: 32),

                  _buildSectionTitle('Questions'),
                  _buildQuestionsList(),

                  FButton(
                    style: FButtonStyle.secondary,
                    onPress: _addNewQuestion,
                    label: const Text('Add Question'),
                    prefix: FIcon(FAssets.icons.plus),
                  ),
                  const SizedBox(height: 32),

                  _buildSectionTitle('Target Departments'),
                  _buildDepartmentSelection(),
                  const SizedBox(height: 32),

                  _buildSectionTitle('Rewards & Duration'),
                  _buildRewardsAndDuration(),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: FButton(
                      onPress: _isSubmitting ? null : _submitForm,
                      label:
                          _isSubmitting
                              ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text('Create Survey'),
                    ),
                  ),
                  const SizedBox(height: 64),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FTile(
          title: const Text('Survey Title'),
          subtitle: FTextField(
            controller: _titleController,
            description: Text('Enter survey title'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter survey title';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 16),
        FTile(
          title: const Text('Survey Description'),
          subtitle: FTextField(
            controller: _descriptionController,
            description: Text('Enter survey description'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter survey description';
              }
              return null;
            },
            maxLines: 3,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _questions.length,
      itemBuilder: (context, index) {
        final question = _questions[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: context.theme.colorScheme.border, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Question ${index + 1}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: () {
                        setState(() {
                          _questions.removeAt(index);
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                FTextField(
                  description: Text('Enter question text'),
                  initialValue: question['text'] ?? '',
                  onChange: (value) {
                    setState(() {
                      _questions[index]['text'] = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter question text';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Question Type:'),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: question['type'],
                      items: const [
                        DropdownMenuItem(
                          value: 'yes_no',
                          child: Text('Yes/No'),
                        ),
                        DropdownMenuItem(
                          value: 'rating',
                          child: Text('Rating'),
                        ),
                        DropdownMenuItem(
                          value: 'multiple_choice',
                          child: Text('Multiple Choice'),
                        ),
                        DropdownMenuItem(
                          value: 'single_choice',
                          child: Text('Single Choice'),
                        ),
                        DropdownMenuItem(value: 'text', child: Text('Text')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _questions[index]['type'] = value;
                          // Initialize options for choice types
                          if (value == 'multiple_choice' ||
                              value == 'single_choice') {
                            if (_questions[index]['options'].isEmpty) {
                              _questions[index]['options'] = [
                                'Option 1',
                                'Option 2',
                              ];
                            }
                          }
                        });
                      },
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Text('Optional'),
                        Checkbox(
                          value: question['optional'] ?? false,
                          onChanged: (value) {
                            setState(() {
                              _questions[index]['optional'] = value ?? false;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),

                // Show options if question type is choice-based
                if (question['type'] == 'multiple_choice' ||
                    question['type'] == 'single_choice')
                  _buildOptionsEditor(question, index),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionsEditor(Map<String, dynamic> question, int questionIndex) {
    final options = question['options'] as List;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Options:'),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: options.length,
          itemBuilder: (context, optionIndex) {
            return Row(
              children: [
                Expanded(
                  child: FTextField(
                    initialValue: options[optionIndex],
                    onChange: (value) {
                      setState(() {
                        options[optionIndex] = value;
                      });
                    },
                    description: Text('Option ${optionIndex + 1}'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, size: 20),
                  onPressed: () {
                    if (options.length > 2) {
                      setState(() {
                        options.removeAt(optionIndex);
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Minimum 2 options required'),
                        ),
                      );
                    }
                  },
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 8),
        FButton(
          style: FButtonStyle.secondary,
          onPress: () {
            setState(() {
              options.add('New Option');
            });
          },
          label: const Text('Add Option'),
          prefix: FIcon(FAssets.icons.plus),
        ),
      ],
    );
  }

  Widget _buildDepartmentSelection() {
    if (_isLoadingDepartments) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator.adaptive(),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildCustomChip(
              label: 'All Departments',
              selected: _selectedDepartments.contains('all'),
              onTap: () {
                setState(() {
                  if (_selectedDepartments.contains('all')) {
                    _selectedDepartments.remove('all');
                  } else {
                    _selectedDepartments = ['all'];
                  }
                });
              },
            ),
            ..._departments.map((department) {
              return _buildCustomChip(
                label: department.name,
                selected:
                    _selectedDepartments.contains(department.name) ||
                    _selectedDepartments.contains('all'),
                onTap: () {
                  setState(() {
                    if (_selectedDepartments.contains('all')) {
                      _selectedDepartments = [];
                    }

                    if (_selectedDepartments.contains(department.name)) {
                      _selectedDepartments.remove(department.name);
                    } else {
                      _selectedDepartments.add(department.name);
                    }
                  });
                },
              );
            }).toList(),
          ],
        ),
        if (_selectedDepartments.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              'Please select at least one department',
              style: TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }

  Widget _buildCustomChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              selected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                selected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              Icon(
                Icons.check,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color:
                    selected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardsAndDuration() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: FTile(
                title: const Text('XP Reward'),
                subtitle: FTextField(
                  controller: _xpRewardController,
                  description: Text('XP'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FTile(
                title: const Text('Coins Reward'),
                subtitle: FTextField(
                  controller: _coinsRewardController,
                  description: Text('Coins'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FTile(
                title: const Text('Estimated Time'),
                subtitle: FTextField(
                  controller: _estimatedTimeController,
                  description: Text('e.g., 5 mins'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FTile(
                title: const Text('Expiry Date'),
                subtitle: FTextField(
                  readOnly: true,
                  initialValue: DateFormat('yyyy-MM-dd').format(_expiryDate),
                  suffixBuilder: (_, _, _) => const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _expiryDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );

                    if (date != null) {
                      setState(() {
                        _expiryDate = date;
                      });
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const Divider(),
        const SizedBox(height: 16),
      ],
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      // Validate questions
      for (var question in _questions) {
        if (question['text'].isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please fill in all question texts')),
          );
          return;
        }

        // Validate options for choice questions
        if ((question['type'] == 'multiple_choice' ||
                question['type'] == 'single_choice') &&
            (question['options'] as List).any((option) => option.isEmpty)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please fill in all options for choice questions'),
            ),
          );
          return;
        }
      }

      // Validate departments selection
      if (_selectedDepartments.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one department'),
          ),
        );
        return;
      }

      // Create survey model
      final surveyModel = SurveyCreationModel(
        title: _titleController.text,
        description: _descriptionController.text,
        questions: _questions,
        estimatedTime: _estimatedTimeController.text,
        reward: {
          'xp': int.parse(_xpRewardController.text),
          'coins': int.parse(_coinsRewardController.text),
        },
        expiresAt: _expiryDate,
        tags: ['created_by_admin'],
        targetDepartments: _selectedDepartments,
      );

      // Submit survey
      context.read<AdminBloc>().add(CreateSurvey(surveyModel));
    }
  }
}
