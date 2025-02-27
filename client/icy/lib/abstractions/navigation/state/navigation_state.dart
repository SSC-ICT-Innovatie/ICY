import 'package:equatable/equatable.dart';
import 'package:icy/icy_tab_registerar.dart';

class NavigationState extends Equatable {
  final List<IcyTab> tabs;
  final int currentIndex;

  const NavigationState({
    required this.tabs,
    this.currentIndex = 0,
  });

  NavigationState copyWith({
    List<IcyTab>? tabs,
    int? currentIndex,
  }) {
    return NavigationState(
      tabs: tabs ?? this.tabs,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }

  @override
  List<Object> get props => [tabs, currentIndex];
}
