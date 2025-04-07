// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:icy/data/models/survey_model.dart';
import 'package:icy/features/home/pages/survey.dart';

class SurveyScreen extends StatefulWidget {
  final SurveyModel survey;

  const SurveyScreen({super.key, required this.survey});

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  int _currentQuestion = 0;
  final Map<String, dynamic> _answers = {};

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: FHeader(
        title: Text(widget.survey.title),
        actions: [
          FButton.icon(
            onPress: () => Navigator.of(context).pop(),
            child: FIcon(FAssets.icons.x),
          ),
        ],
      ),
      content: Column(
        children: [
          // Survey progress indicator
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                Text(
                  'Question ${_currentQuestion + 1} of ${widget.survey.questions.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(_currentQuestion + 1) * 100 ~/ widget.survey.questions.length}%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Progress bar
          LinearProgressIndicator(
            value: (_currentQuestion + 1) / widget.survey.questions.length,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),

          // Survey content
          Expanded(child: _buildSurveyContent()),

          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentQuestion > 0)
                  FButton(
                    style: FButtonStyle.outline,
                    onPress: _previousQuestion,
                    label: const Text('Previous'),
                  )
                else
                  const SizedBox.shrink(),

                FButton(
                  onPress: _isLastQuestion ? _submitSurvey : _nextQuestion,
                  label: Text(_isLastQuestion ? 'Submit' : 'Next'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool get _isLastQuestion =>
      _currentQuestion == widget.survey.questions.length - 1;

  Widget _buildSurveyContent() {
    if (_currentQuestion >= widget.survey.questions.length) {
      return const Center(child: Text('Survey completed!'));
    }

    final question = widget.survey.questions[_currentQuestion];
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question title
          Text(
            question.text,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // Question content based on type
          _buildQuestionContent(question),
        ],
      ),
    );
  }

  Widget _buildQuestionContent(dynamic question) {
    final questionType = question.type;
    final questionId = question.id;

    switch (questionType) {
      case 'yes_no':
        return _buildYesNoQuestion(questionId);
      case 'rating':
        return _buildRatingQuestion(questionId);
      case 'multiple_choice':
        return _buildMultipleChoiceQuestion(question);
      case 'single_choice':
        return _buildSingleChoiceQuestion(question);
      case 'text':
        return _buildTextQuestion(questionId);
      default:
        return const Text('Unsupported question type');
    }
  }

  Widget _buildYesNoQuestion(String questionId) {
    return Column(
      children: [
        FTile(
          title: const Text('Yes'),
          onPress: () => _setAnswer(questionId, true),
          suffixIcon:
              _answers[questionId] == true
                  ? Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                  )
                  : null,
        ),
        FTile(
          title: const Text('No'),
          onPress: () => _setAnswer(questionId, false),
          suffixIcon:
              _answers[questionId] == false
                  ? Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                  )
                  : null,
        ),
      ],
    );
  }

  Widget _buildRatingQuestion(String questionId) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(5, (index) {
        final rating = index + 1;
        return GestureDetector(
          onTap: () => _setAnswer(questionId, rating),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  _answers[questionId] == rating
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[200],
            ),
            child: Center(
              child: Text(
                '$rating',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color:
                      _answers[questionId] == rating
                          ? Colors.white
                          : Colors.black,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMultipleChoiceQuestion(dynamic question) {
    final questionId = question.id;
    final options = question.options as List;

    if (!_answers.containsKey(questionId)) {
      _answers[questionId] = <String>[];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          options.map<Widget>((option) {
            final isSelected = (_answers[questionId] as List).contains(option);
            return FTile(
              title: Text(option),
              onPress: () {
                setState(() {
                  if (isSelected) {
                    (_answers[questionId] as List).remove(option);
                  } else {
                    (_answers[questionId] as List).add(option);
                  }
                });
              },
              prefixIcon:
                  isSelected
                      ? Icon(
                        Icons.check_box,
                        color: Theme.of(context).colorScheme.primary,
                      )
                      : const Icon(Icons.check_box_outline_blank),
            );
          }).toList(),
    );
  }

  Widget _buildSingleChoiceQuestion(dynamic question) {
    final questionId = question.id;
    final options = question.options as List;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          options.map<Widget>((option) {
            final isSelected = _answers[questionId] == option;
            return FTile(
              title: Text(option),
              onPress: () => _setAnswer(questionId, option),
              prefixIcon:
                  isSelected
                      ? Icon(
                        Icons.radio_button_checked,
                        color: Theme.of(context).colorScheme.primary,
                      )
                      : const Icon(Icons.radio_button_unchecked),
            );
          }).toList(),
    );
  }

  Widget _buildTextQuestion(String questionId) {
    return FTextField(
      canRequestFocus: true,
      description: Text('Enter your answer here'),
      initialValue: _answers[questionId] ?? '',
      onChange: (value) => _setAnswer(questionId, value),
      maxLines: 3,
    );
  }

  void _setAnswer(String questionId, dynamic value) {
    setState(() {
      _answers[questionId] = value;
    });
  }

  void _nextQuestion() {
    final currentQuestion = widget.survey.questions[_currentQuestion];

    // Check if answer is required
    if (!currentQuestion.optional &&
        !_answers.containsKey(currentQuestion.id)) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please answer this question')),
      );
      return;
    }

    setState(() {
      _currentQuestion++;
    });
  }

  void _previousQuestion() {
    if (_currentQuestion > 0) {
      setState(() {
        _currentQuestion--;
      });
    }
  }

  void _submitSurvey() {
    final currentQuestion = widget.survey.questions[_currentQuestion];

    // Check if last answer is required
    if (!currentQuestion.optional &&
        !_answers.containsKey(currentQuestion.id)) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please answer this question')),
      );
      return;
    }

    setState(() {
    });

    // Convert answers to the format expected by the API
    final formattedAnswers =
        _answers.entries.map((entry) {
          return {'questionId': entry.key, 'answer': entry.value};
        }).toList();

    // TODO: Submit the survey responses to the server
    // This would typically be done via a BLoC event

    // For now, simulate a network delay and show success
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Survey submitted! You earned ${widget.survey.reward.xp} XP',
          ),
          backgroundColor: Colors.green,
        ),
      );
    });
  }
}
