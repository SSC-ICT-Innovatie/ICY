import 'package:icy/abstractions/utils/api_constants.dart';
import 'package:icy/data/models/department_model.dart';
import 'package:icy/data/models/survey_model.dart';
import 'package:icy/data/models/user_model.dart';
import 'package:icy/features/admin/models/admin_model.dart';
import 'package:icy/services/api_service.dart';

class AdminRepository {
  final ApiService _apiService;

  AdminRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  /// Get admin dashboard statistics
  Future<AdminStats> getAdminStats() async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.adminEndpoint}/stats',
      );
      return AdminStats.fromJson(response['data']);
    } catch (e) {
      print('Error getting admin stats: $e');
      return AdminStats.empty();
    }
  }

  /// Create a new department
  Future<Department?> createDepartment(String name, String description) async {
    try {
      final response = await _apiService.post(
        ApiConstants.departmentsEndpoint,
        {'name': name, 'description': description},
      );

      if (response['success'] == true && response['data'] != null) {
        return Department.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      print('Error creating department: $e');
      return null;
    }
  }

  /// Update a department
  Future<Department?> updateDepartment(
    String id,
    String name,
    String description,
  ) async {
    try {
      final response = await _apiService.put(
        '${ApiConstants.departmentsEndpoint}/$id',
        {'name': name, 'description': description},
      );

      if (response['success'] == true && response['data'] != null) {
        return Department.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      print('Error updating department: $e');
      return null;
    }
  }

  /// Delete a department
  Future<bool> deleteDepartment(String id) async {
    try {
      final response = await _apiService.delete(
        '${ApiConstants.departmentsEndpoint}/$id',
      );

      return response['success'] == true;
    } catch (e) {
      print('Error deleting department: $e');
      return false;
    }
  }

  /// Create a new survey
  Future<SurveyModel?> createSurvey(SurveyCreationModel survey) async {
    try {
      final response = await _apiService.post(
        ApiConstants.surveysEndpoint,
        survey.toJson(),
      );

      if (response['success'] == true && response['data'] != null) {
        return SurveyModel.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      print('Error creating survey: $e');
      return null;
    }
  }

  /// Get all users (admin only)
  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await _apiService.get(ApiConstants.usersEndpoint);

      if (response['success'] == true && response['data'] != null) {
        return (response['data'] as List)
            .map((user) => UserModel.fromJson(user))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error getting users: $e');
      return [];
    }
  }
}
