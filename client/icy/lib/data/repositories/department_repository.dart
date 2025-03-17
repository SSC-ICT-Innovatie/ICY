import 'package:icy/abstractions/utils/api_constants.dart';
import 'package:icy/data/models/department_model.dart';
import 'package:icy/services/api_service.dart';

class DepartmentRepository {
  final ApiService _apiService;

  DepartmentRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  /// Get all departments
  Future<List<Department>> getDepartments() async {
    try {
      final response = await _apiService.get(ApiConstants.departmentsEndpoint);

      if (response['success'] == true && response['data'] != null) {
        return (response['data'] as List)
            .map((json) => Department.fromJson(json))
            .toList();
      }

      // If we can't get departments from the API, return default ones
      return _getDefaultDepartments();
    } catch (e) {
      print('Error fetching departments: $e');
      // Return default departments if API fails
      return _getDefaultDepartments();
    }
  }

  /// Default departments used when API is not available
  List<Department> _getDefaultDepartments() {
    return [
      Department(id: 'ict', name: 'ICT'),
      Department(id: 'hr', name: 'HR'),
      Department(id: 'finance', name: 'Finance'),
      Department(id: 'marketing', name: 'Marketing'),
      Department(id: 'operations', name: 'Operations'),
      Department(id: 'sales', name: 'Sales'),
      Department(id: 'customer-service', name: 'Customer Service'),
      Department(id: 'research', name: 'Research & Development'),
    ];
  }
}
