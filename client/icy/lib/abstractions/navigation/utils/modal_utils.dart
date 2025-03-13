import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icy/abstractions/navigation/state/navigation_cubit.dart';
import 'package:icy/features/authentication/state/bloc/auth_bloc.dart';

/// Shows a platform-appropriate modal while preserving navigation state
void showStatePreservingModal({
  required BuildContext context,
  required Widget content,
  bool isDialog = false,
}) {
  // Capture the current navigation state
  final NavigationCubit navigationCubit = context.read<NavigationCubit>();
  final navigationState = navigationCubit.state;
  final currentTabIndex = navigationState.currentIndex;

  // Capture the current auth state
  final AuthBloc authBloc = context.read<AuthBloc>();
  final authState = authBloc.state;

  // Function to restore state if needed
  void restoreState() {
    // Check if the tab has changed incorrectly
    if (navigationCubit.state.currentIndex != currentTabIndex) {
      // Force the navigation back to the correct tab
      navigationCubit.emit(navigationState);
      print("Navigation state restored to tab $currentTabIndex");
    }

    // Ensure auth state remains consistent
    if (authBloc.state != authState) {
      // This should not happen under normal circumstances
      print("Warning: Auth state changed during modal display");
    }
  }

  // Use appropriate modal presentation based on platform
  if (isDialog || !Platform.isIOS) {
    showDialog(
      context: context,
      builder: (context) => content,
    ).then((_) => restoreState());
  } else {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => content,
    ).then((_) => restoreState());
  }
}
