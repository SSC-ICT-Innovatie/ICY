import 'package:equatable/equatable.dart';
import 'package:icy/abstractions/navigation/services/icy_tab_registerar.dart';

class NavigationState extends Equatable {
  final List<IcyTab> tabs;
  final int currentIndex;

  const NavigationState({required this.tabs, required this.currentIndex});

  NavigationState copyWith({List<IcyTab>? tabs, int? currentIndex}) {
    return NavigationState(
      tabs: tabs ?? this.tabs,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }

  @override
  List<Object> get props => [tabs, currentIndex];
}
