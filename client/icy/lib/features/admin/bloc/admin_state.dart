part of 'admin_bloc.dart';

abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object> get props => [];
}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminStatsLoaded extends AdminState {
  final AdminStats stats;

  const AdminStatsLoaded(this.stats);

  @override
  List<Object> get props => [stats];
}

class DepartmentsLoaded extends AdminState {
  final List<Department> departments;

  const DepartmentsLoaded(this.departments);

  @override
  List<Object> get props => [departments];
}

class SurveysLoaded extends AdminState {
  final List<SurveyModel> surveys;

  const SurveysLoaded(this.surveys);

  @override
  List<Object> get props => [surveys];
}

class UsersLoaded extends AdminState {
  final List<UserModel> users;

  const UsersLoaded(this.users);

  @override
  List<Object> get props => [users];
}

class AdminActionSuccess extends AdminState {
  final String message;

  const AdminActionSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class AdminError extends AdminState {
  final String message;

  const AdminError(this.message);

  @override
  List<Object> get props => [message];
}
