import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icy/data/repositories/department_repository.dart';
import 'package:icy/data/repositories/survey_repository.dart';
import 'package:icy/features/admin/bloc/admin_bloc.dart';
import 'package:icy/features/admin/repositories/admin_repository.dart';
import 'package:icy/services/api_service.dart';

/// Wrapper widget that ensures AdminBloc is available to child widgets
class AdminProvider extends StatelessWidget {
  final Widget child;

  const AdminProvider({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Try to get existing AdminBloc from context
    AdminBloc? existingBloc;
    try {
      existingBloc = context.read<AdminBloc>();
    } catch (e) {
      // AdminBloc not found in context, we'll create a new one
    }

    // If existing AdminBloc is found, use it
    if (existingBloc != null) {
      return child;
    }

    // Otherwise create a new AdminBloc
    return BlocProvider<AdminBloc>(
      create:
          (context) => AdminBloc(
            adminRepository: AdminRepository(apiService: ApiService()),
            departmentRepository: DepartmentRepository(
              apiService: ApiService(),
            ),
            surveyRepository: SurveyRepository(apiService: ApiService()),
          ),
      child: child,
    );
  }
}
