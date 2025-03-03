import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icy/abstractions/navigation/state/navigation_cubit.dart';
import 'package:icy/features/authentication/state/bloc/auth_bloc.dart';
import 'package:icy/tabs.dart';

class AuthNavigationService {
  static Widget wrapWithAuthListener(Widget child) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => previous.runtimeType != current.runtimeType,
      listener: (context, state) {
        // Refresh navigation when auth state changes
        final navCubit = context.read<NavigationCubit>();
        navCubit.refreshTabs(injectNavigationTabs(context));
      },
      child: child,
    );
  }
  
  // Other auth navigation related methods could be added here
  static void logoutAndNavigate(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    authBloc.add(Logout());
    //? Navigation will be handled by the listener
  }
}


