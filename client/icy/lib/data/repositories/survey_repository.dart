import 'package:icy/abstractions/utils/api_constants.dart';
import 'package:icy/data/models/survey_model.dart';
import 'package:icy/features/admin/models/admin_model.dart';
import 'package:icy/services/api_service.dart';

class SurveyRepository {
  final ApiService _apiService;
  
  // Cache survey data
  List<SurveyModel>? _cachedSurveys;
  DateTime _lastFetchTime = DateTime.now().subtract(const Duration(days: 1));

  SurveyRepository({ApiService? apiService}) 
      : _apiService = apiService ?? ApiService();

  /// Get all available surveys
  Future<List<SurveyModel>> getSurveys({bool forceRefresh = false}) async {
    // Return cached surveys if available and not forcing refresh
    if (!forceRefresh && 
        _cachedSurveys != null && 
        DateTime.now().difference(_lastFetchTime) < const Duration(minutes: 5)) {
      return _cachedSurveys!;
    }
    
    try {
      final response = await _apiService.get(ApiConstants.surveysEndpoint);
      final List<dynamic> surveysJson = response['data'] ?? [];
      _cachedSurveys = surveysJson.map((json) => SurveyModel.fromJson(json)).toList();
      _lastFetchTime = DateTime.now();
      return _cachedSurveys!;
    } catch (e) {
      print('Error fetching surveys: $e');
      if (_cachedSurveys != null) {
        return _cachedSurveys!;
      }
      throw Exception('Failed to load surveys: $e');
    }
  }

  /// Submit survey responses
  Future<Map<String, dynamic>> submitSurveyResponses(String surveyId, List<Map<String, dynamic>> answers) async {
    try {
      // Use the correct endpoint pattern with the survey ID
      final response = await _apiService.post(
        '${ApiConstants.surveysEndpoint}/$surveyId/submit', 
        {
          'answers': answers,
        }
      );
      
      // Clear cache to force refresh of surveys
      _cachedSurveys = null;
      
      return response;
    } catch (e) {
      print('Error submitting survey: $e');
      throw Exception('Failed to submit survey: $e');
    }
  }
  
  /// Create a new survey (admin only)
  Future<SurveyModel?> createSurvey(SurveyCreationModel survey) async {
    try {
      final response = await _apiService.post(
        ApiConstants.surveysEndpoint, 
        survey.toJson(),
      );
      
      // Clear cached surveys to ensure fresh data
      _cachedSurveys = null;
      
      if (response['success'] == true && response['data'] != null) {
        return SurveyModel.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      print('Error creating survey: $e');
      throw Exception('Failed to create survey: $e');
    }
  }
  
  /// Clear survey cache
  void clearCache() {
    _cachedSurveys = null;
    _lastFetchTime = DateTime.now().subtract(const Duration(days: 1));
  }

  // Get daily surveys with graceful error handling
  Future<List<Survey>> getDailySurveys() async {
    try {
      final response = await _apiService.get(ApiConstants.dailySurveysEndpoint);

      if (response['success'] == true && response['data'] != null) {
        return (response['data'] as List)
            .map((surveyJson) => Survey.fromJson(surveyJson))
            .toList();
      }

      // If we got a non-success response but it has data, still try to use it
      if (response['data'] != null && response['data'] is List) {
        return (response['data'] as List)
            .map((surveyJson) => Survey.fromJson(surveyJson))
            .toList();
      }

      // Log the error but return an empty list
      print('Error fetching daily surveys: ${response['message']}');
      return [];
    } catch (e) {
      print('Exception fetching daily surveys: $e');
      return [];
    }
  }

  // Get details for a specific survey
  Future<SurveyDetail?> getSurveyById(String id) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.surveysEndpoint}/$id',
      );

      if (response['success'] == true && response['data'] != null) {
        final surveyData = response['data'];

        return SurveyDetail(
          survey: Survey.fromJson(surveyData['survey']),
          progress:
              surveyData['progress'] != null
                  ? SurveyProgress.fromJson(surveyData['progress'])
                  : null,
        );
      }

      return null;
    } catch (e) {
      print('Error fetching survey details: $e');
      return null;
    }
  }

  // Submit a survey response
  Future<SurveySubmitResult?> submitSurveyResponse(
    String surveyId,
    List<SurveyAnswer> answers,
  ) async {
    try {
      // Convert answers to JSON format expected by API
      final answersJson =
          answers
              .map(
                (answer) => {
                  'questionId': answer.questionId,
                  'answer': answer.answer,
                },
              )
              .toList();

      final response = await _apiService.post(
        '${ApiConstants.surveysEndpoint}/$surveyId/submit',
        {'answers': answersJson},
      );

      if (response['success'] == true) {
        return SurveySubmitResult(
          success: true,
          xpEarned: response['rewards']['xp'],
          coinsEarned: response['rewards']['coins'],
        );
      }

      return SurveySubmitResult(success: false, xpEarned: 0, coinsEarned: 0);
    } catch (e) {
      print('Error submitting survey: $e');
      return SurveySubmitResult(
        success: false,
        xpEarned: 0,
        coinsEarned: 0,
        errorMessage: e.toString(),
      );
    }
  }

  // Save survey progress
  Future<bool> saveSurveyProgress(
    String surveyId,
    List<SurveyAnswer> answers,
    int completedQuestions,
  ) async {
    try {
      // Convert answers to JSON format expected by API
      final answersJson =
          answers
              .map(
                (answer) => {
                  'questionId': answer.questionId,
                  'answer': answer.answer,
                },
              )
              .toList();

      final response = await _apiService.post(
        '${ApiConstants.surveysEndpoint}/$surveyId/progress',
        {'answers': answersJson, 'completed': completedQuestions},
      );

      return response['success'] == true;
    } catch (e) {
      print('Error saving survey progress: $e');
      return false;
    }
  }
}

class SurveySubmitResult {
  final bool success;
  final int xpEarned;
  final int coinsEarned;
  final String? errorMessage;

  SurveySubmitResult({
    required this.success,
    required this.xpEarned,
    required this.coinsEarned,
    this.errorMessage,
  });
}
