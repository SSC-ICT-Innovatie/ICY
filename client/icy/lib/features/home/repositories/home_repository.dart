import 'package:icy/abstractions/utils/api_constants.dart';
import 'package:icy/data/models/survey_model.dart';
import 'package:icy/services/api_service.dart';

class HomeRepository {
  final ApiService _apiService;

  HomeRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  Future<List<SurveyModel>> getDailySurveys() async {
    try {
      final response = await _apiService.get(ApiConstants.dailySurveysEndpoint);

      if (response['success'] == true && response['data'] != null) {
        return (response['data'] as List)
            .map((surveyJson) => SurveyModel.fromJson(surveyJson))
            .toList();
      }

      return [];
    } catch (e) {
      print('Error fetching daily surveys: $e');
      return [];
    }
  }

  Future<List<SurveyModel>> getAllSurveys() async {
    try {
      final response = await _apiService.get(ApiConstants.surveysEndpoint);

      if (response['success'] == true && response['data'] != null) {
        return (response['data'] as List)
            .map((surveyJson) => SurveyModel.fromJson(surveyJson))
            .toList();
      }

      return [];
    } catch (e) {
      print('Error fetching all surveys: $e');
      return [];
    }
  }
}
