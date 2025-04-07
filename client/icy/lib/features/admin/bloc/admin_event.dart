part of 'admin_bloc.dart';

abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object?> get props => [];
}

class LoadAdminStats extends AdminEvent {}

class LoadDepartments extends AdminEvent {}

class LoadSurveys extends AdminEvent {}

class LoadUsers extends AdminEvent {}

class CreateDepartment extends AdminEvent {
  final String name;
  final String description;

  const CreateDepartment({required this.name, required this.description});

  @override
  List<Object?> get props => [name, description];
}

class UpdateDepartment extends AdminEvent {
  final String id;
  final String name;
  final String description;

  const UpdateDepartment({
    required this.id,
    required this.name,
    required this.description,
  });

  @override
  List<Object?> get props => [id, name, description];
}

class DeleteDepartment extends AdminEvent {
  final String id;

  const DeleteDepartment({required this.id});

  @override
  List<Object?> get props => [id];
}

class CreateSurvey extends AdminEvent {
  final SurveyCreationModel survey;

  const CreateSurvey(this.survey);

  @override
  List<Object?> get props => [survey];
}
