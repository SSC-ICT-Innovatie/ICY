import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icy/abstractions/navigation/state/navigation_cubit.dart';
import 'package:icy/features/authentication/services/auth_cache_service.dart';
import 'package:icy/features/authentication/state/bloc/auth_bloc.dart';
import 'package:icy/tabs.dart';

class DependencyInjector {
  DependencyInjector();
  Widget injectStateIntoApp(Widget app) {
    return MultiBlocProvider(
      providers: [
        // First create AuthBloc so it's available for NavigationCubit
        BlocProvider<AuthBloc>(
          create: (context) {
            final authBloc = AuthBloc();
            // Initialize the cached auth state right away
            AuthCacheService().updateAuthState(authBloc.state is AuthSuccess);
            return authBloc;
          },
        ),
        // Then create NavigationCubit with access to AuthBloc
        BlocProvider<NavigationCubit>(
          lazy: false, // Create immediately
          create: (context) {
            // Now the AuthBloc is available when accessing tabs
            final tabs = injectNavigationTabs(context);
            final navCubit = NavigationCubit(tabs);

            // Initialize with the correct tab based on auth state
            Future.microtask(() {
              final isLoggedIn = hasLoggedIn(context);
              if (isLoggedIn) {
                navCubit.navigateAfterAuthChange();
              }
            });

            return navCubit;
          },
        ),
      ],
      child: app,
    );
  }
}
