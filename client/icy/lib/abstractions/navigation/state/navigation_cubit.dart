import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:icy/abstractions/navigation/state/navigation_state.dart';
import 'package:icy/abstractions/navigation/services/icy_tab_registerar.dart';

// Cubit for managing the current navigation state
// ! Please don't modify this file
// ! Critical changes can break the app
// ! If you need to modify navigation, do so in tabs.dart
// ! Or submit an issue to the Icy repository cause there are loads of logics here although documented can be confusing also dont use AI here.
class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit(List<IcyTab> tabs)
    : super(
        NavigationState(
          tabs: tabs.isNotEmpty ? tabs : [],
          currentIndex: 0, // Always start at 0 for consistency
        ),
      );

  // Change to visible tab by its position in the tab bar
  void changeVisibleTabByIndex(int visibleIndex) {
    final visibleTabs = getVisibleTabs();
    if (visibleIndex >= 0 && visibleIndex < visibleTabs.length) {
      // Find the actual index of this tab in the full tabs list
      final actualTabIndex = state.tabs.indexOf(visibleTabs[visibleIndex]);
      if (actualTabIndex != -1) {
        emit(state.copyWith(currentIndex: actualTabIndex));
        print(
          "Changed to tab index $actualTabIndex: ${state.tabs[actualTabIndex].title}",
        );
      }
    }
  }

  // Get the index of the current tab within visible tabs
  int getCurrentVisibleIndex() {
    final visibleTabs = getVisibleTabs();
    if (visibleTabs.isEmpty) return 0;

    if (state.currentIndex >= state.tabs.length) {
      return 0;
    }

    final currentTab = state.tabs[state.currentIndex];
    return visibleTabs.indexOf(currentTab);
  }

  // Get the list of tabs that should be shown in the tab bar
  List<IcyTab> getVisibleTabs() {
    return state.tabs
        .where((tab) => tab.showInTabBar && tab.canAccess())
        .toList();
  }

  // Finds the first appropriate tab to show after login
  // Returns the actual tab index, not the visible index
  int findFirstVisibleTabAfterLogin() {
    // Special rule: Look for Home tab first
    for (int i = 0; i < state.tabs.length; i++) {
      final tab = state.tabs[i];
      if (tab.title == "Home" && tab.showInTabBar && tab.canAccess()) {
        return i;
      }
    }

    // Next, find any visible tab that's not login/signup
    for (int i = 0; i < state.tabs.length; i++) {
      final tab = state.tabs[i];
      if (tab.showInTabBar &&
          tab.canAccess() &&
          tab.title != "Login" &&
          tab.title != "Signup") {
        return i;
      }
    }

    // Last resort: any visible tab
    for (int i = 0; i < state.tabs.length; i++) {
      if (state.tabs[i].showInTabBar && state.tabs[i].canAccess()) {
        return i;
      }
    }

    return 0;
  }

  // Complete tab refresh after auth state change - with forced rebuild
  void refreshTabs(List<IcyTab> tabs) {
    // First update the tab list with a clear index
    emit(NavigationState(tabs: tabs, currentIndex: 0));

    // Then find and set the appropriate tab after auth change
    final newIndex = findFirstVisibleTabAfterLogin();

    // Force a rebuild by using a temporary index and then the real one
    emit(NavigationState(tabs: tabs, currentIndex: newIndex));

    print(
      "Refreshed tabs with ${tabs.length} tabs, navigated to tab: ${tabs[newIndex].title}",
    );
  }

  // Navigate to appropriate tab after login/logout - with forced rebuild
  void navigateAfterAuthChange() {
    final newIndex = findFirstVisibleTabAfterLogin();

    // Force a rebuild by emitting a new state object
    emit(
      NavigationState(
        tabs: List.from(state.tabs), // Create a new list to force rebuild
        currentIndex: newIndex,
      ),
    );

    print("Navigated to tab: ${state.tabs[newIndex].title} (index $newIndex)");
  }

  IcyTab get currentTab {
    if (state.tabs.isEmpty || state.currentIndex >= state.tabs.length) {
      // Return a default/fallback tab if no tabs are available
      return IcyTab(
        icon: FAssets.icons.house,
        title: "Default",
        content: const Center(child: Text("No content available")),
      );
    }
    return state.tabs[state.currentIndex];
  }
}
