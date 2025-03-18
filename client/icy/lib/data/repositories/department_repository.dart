import 'package:icy/abstractions/utils/api_constants.dart';
import 'package:icy/data/models/department_model.dart';
import 'package:icy/services/api_service.dart';

class DepartmentRepository {
  final ApiService _apiService;

  DepartmentRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  /// Get all departments from the backend API
  Future<List<Department>> getDepartments() async {
    try {
      final response = await _apiService.get(ApiConstants.departmentsEndpoint);

      if (response['success'] == true && response['data'] != null) {
        return (response['data'] as List)
            .map((json) => Department.fromJson(json))
            .toList();
      }

      // If response wasn't successful but didn't throw an error
      print('Warning: Failed to get departments, response was: $response');
      return _getFallbackDepartments();
    } catch (e) {
      print('Error fetching departments: $e');
      // Return fallback departments only if API fails completely
      return _getFallbackDepartments();
    }
  }

  /// Fallback departments only used when API is completely unavailable
  /// These should match the default seeded departments in the database
  List<Department> _getFallbackDepartments() {
    print('Using fallback departments due to API unavailability');
    return [
      Department(id: 'fallback-1', name: 'ICT'),
      Department(id: 'fallback-2', name: 'HR'),
      Department(id: 'fallback-3', name: 'Finance'),
      // Minimal list - the real data should come from the database
    ];
  }
}
