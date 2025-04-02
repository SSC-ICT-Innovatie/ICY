import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:icy/data/models/department_model.dart';
import 'package:icy/data/models/survey_model.dart';
import 'package:icy/data/models/user_model.dart';
import 'package:icy/data/repositories/department_repository.dart';
import 'package:icy/data/repositories/survey_repository.dart';
import 'package:icy/features/admin/models/admin_model.dart';
import 'package:icy/features/admin/repositories/admin_repository.dart';
import 'package:flutter/foundation.dart';

part 'admin_event.dart';
part 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminRepository _adminRepository;
  final DepartmentRepository _departmentRepository;
  final SurveyRepository _surveyRepository;

  AdminBloc({
    required AdminRepository adminRepository,
    required DepartmentRepository departmentRepository,
    required SurveyRepository surveyRepository,
  }) : _adminRepository = adminRepository,
       _departmentRepository = departmentRepository,
       _surveyRepository = surveyRepository,
       super(AdminInitial()) {
    on<LoadAdminStats>(_onLoadAdminStats);
    on<LoadDepartments>(_onLoadDepartments);
    on<LoadSurveys>(_onLoadSurveys);
    on<LoadUsers>(_onLoadUsers);
    on<CreateDepartment>(_onCreateDepartment);
    on<CreateSurvey>(_onCreateSurvey);
  }

  Future<void> _onLoadAdminStats(
    LoadAdminStats event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    try {
      final stats = await _adminRepository.getAdminStats();
      emit(AdminStatsLoaded(stats));
    } catch (e) {
      emit(AdminError('Failed to load admin stats: $e'));
    }
  }

  Future<void> _onLoadDepartments(
    LoadDepartments event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    try {
      final departments = await _departmentRepository.getDepartments();
      emit(DepartmentsLoaded(departments));
    } catch (e) {
      emit(AdminError('Failed to load departments: $e'));
    }
  }

  Future<void> _onLoadSurveys(
    LoadSurveys event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    try {
      final surveys = await _surveyRepository.getSurveys();
      emit(SurveysLoaded(surveys));
    } catch (e) {
      emit(AdminError('Failed to load surveys: $e'));
    }
  }

  Future<void> _onLoadUsers(LoadUsers event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      final users = await _adminRepository.getAllUsers();
      emit(UsersLoaded(users));
    } catch (e) {
      emit(AdminError('Failed to load users: $e'));
    }
  }

  Future<void> _onCreateDepartment(
    CreateDepartment event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    try {
      final department = await _adminRepository.createDepartment(
        event.name,
        event.description,
      );

      if (department != null) {
        emit(
          AdminActionSuccess('Department "${event.name}" created successfully'),
        );
        add(LoadDepartments()); // Reload departments
      } else {
        emit(AdminError('Failed to create department'));
      }
    } catch (e) {
      emit(AdminError('Failed to create department: $e'));
    }
  }

  Future<void> _onCreateSurvey(
    CreateSurvey event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    try {
      final survey = await _adminRepository.createSurvey(event.survey);

      if (survey != null) {
        emit(
          AdminActionSuccess(
            'Survey "${event.survey.title}" created successfully',
          ),
        );
        add(LoadSurveys()); // Reload surveys
      } else {
        emit(AdminError('Failed to create survey'));
      }
    } catch (e) {
      emit(AdminError('Failed to create survey: $e'));
    }
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    debugPrint('AdminBloc error: $error');
    super.onError(error, stackTrace);
  }
}
