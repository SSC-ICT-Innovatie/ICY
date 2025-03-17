import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icy/abstractions/navigation/state/navigation_cubit.dart';
import 'package:icy/features/authentication/state/bloc/auth_bloc.dart';
import 'package:icy/tabs.dart';

class AuthNavigationService {
  static Widget wrapWithAuthListener(Widget child) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen:
          (previous, current) => previous.runtimeType != current.runtimeType,
      listener: (context, state) {
        // Refresh navigation when auth state changes
        final navCubit = context.read<NavigationCubit>();
        navCubit.refreshTabs(injectNavigationTabs(context));
      },
      child: child,
    );
  }

  // Static method to handle logout and navigation
  static void logoutAndNavigate(BuildContext context) {
    // Show confirmation dialog
    showAdaptiveDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Logout Confirmation'),
            content: const Text('Are you sure you want to log out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Logout'),
              ),
            ],
          ),
    ).then((confirmed) {
      if (confirmed == true) {
        // Dispatch logout event
        context.read<AuthBloc>().add(Logout());

        // Navigate to login tab
        context.read<NavigationCubit>().changeVisibleTabByIndex(0);

        // Refresh tabs for auth state change
        context.read<NavigationCubit>().refreshTabs(
          injectNavigationTabs(context),
        );
      }
    });
  }

  // Navigate to profile screen
  static void navigateToProfile(BuildContext context) {
    // Assuming profile is at index 5
    context.read<NavigationCubit>().changeVisibleTabByIndex(5);
  }

  // Navigate to home screen
  static void navigateToHome(BuildContext context) {
    // Assuming home is at index 2
    context.read<NavigationCubit>().changeVisibleTabByIndex(2);
  }
}
