part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class LoadHomeData extends HomeEvent {
  final String userId;

  const LoadHomeData({required this.userId});

  @override
  List<Object> get props => [userId];
}
