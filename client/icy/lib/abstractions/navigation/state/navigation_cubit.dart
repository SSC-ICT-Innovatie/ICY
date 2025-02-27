import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:icy/abstractions/navigation/state/navigation_state.dart';
import 'package:icy/icy_tab_registerar.dart';
import 'package:icy/abstractions/utils/constants.dart';

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit(List<IcyTab> tabs)
      : super(NavigationState(
          tabs: tabs.isNotEmpty ? tabs : [],
          currentIndex: tabs.isNotEmpty ? AppConstants.defaultNavigationIndex : 0,
        ));

  void changeTab(int index) {
    if (index >= 0 && index < state.tabs.length) {
      final tab = state.tabs[index];
      if (tab.canAccess()) {
        emit(state.copyWith(currentIndex: index));
      }
    }
  }

  IcyTab get currentTab {
    if (state.tabs.isEmpty) {
      // Return a default/fallback tab if no tabs are available
      return IcyTab(
        icon: FAssets.icons.house,
        title: "Default",
        content: const Center(child: Text("No content available")),
      );
    }
    return state.tabs[state.currentIndex];
  }

  List<IcyTab> get visibleTabs => 
      state.tabs.where((tab) => tab.showInTabBar && tab.canAccess()).toList();
      
  bool get requiresAuthentication => 
      state.tabs.any((tab) => tab.accessRule != null);
}
