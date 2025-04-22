part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class LoadHome extends HomeEvent {
  final bool forceRefresh;
  
  const LoadHome({this.forceRefresh = false});
  
  @override
  List<Object> get props => [forceRefresh];
}

// For backwards compatibility
class LoadHomeData extends LoadHome {
  final String? userId;

  const LoadHomeData({this.userId, bool forceRefresh = false}) 
      : super(forceRefresh: forceRefresh);

  @override
  List<Object> get props => [userId ?? '', forceRefresh];
}
