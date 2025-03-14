part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class LoadHome extends HomeEvent {
  const LoadHome();
}

// For backwards compatibility
class LoadHomeData extends LoadHome {
  final String? userId;

  const LoadHomeData({this.userId});

  @override
  List<Object> get props => [userId ?? ''];
}
