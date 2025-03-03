import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icy/abstractions/navigation/state/navigation_cubit.dart';
import 'package:icy/features/authentication/state/bloc/auth_bloc.dart';
import 'package:icy/tabs.dart';

extension NavigationContextExtensions on BuildContext {
  void refreshNavigationTabs() {
    read<NavigationCubit>().refreshTabs(injectNavigationTabs(this));
  }
  
  void navigateToTab(String tabTitle) {
    final navCubit = read<NavigationCubit>();
    final tabs = navCubit.state.tabs;
    
    for (int i = 0; i < tabs.length; i++) {
      if (tabs[i].title == tabTitle && tabs[i].canAccess()) {
        navCubit.changeVisibleTabByIndex(i);
        break;
      }
    }
  }
  
  void logout() {
    read<AuthBloc>().add(Logout());
    refreshNavigationTabs();
  }
}

// Usage example
// context.refreshNavigationTabs();
// context.navigateToTab("Home");
// context.logout();
