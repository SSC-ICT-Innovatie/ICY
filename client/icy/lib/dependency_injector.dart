import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icy/abstractions/navigation/state/navigation_cubit.dart';
import 'package:icy/data/repositories/achievement_repository.dart';
import 'package:icy/data/repositories/auth_repository.dart';
import 'package:icy/features/authentication/services/auth_cache_service.dart';
import 'package:icy/features/authentication/state/bloc/auth_bloc.dart';
import 'package:icy/features/home/bloc/home_bloc.dart';
import 'package:icy/features/home/repositories/home_repository.dart';
import 'package:icy/features/marketplace/bloc/marketplace_bloc.dart';
import 'package:icy/features/notifications/bloc/notifications_bloc.dart';
import 'package:icy/features/notifications/repository/notifications_repository.dart';
import 'package:icy/features/marketplace/repository/marketplace_repository_impl.dart';
import 'package:icy/services/api_service.dart';
import 'package:icy/tabs.dart';

class DependencyInjector {
  // Create repositories
  final AuthRepository authRepository = AuthRepository();
  final NotificationsRepository notificationsRepository =
      NotificationsRepository();
  final HomeRepository homeRepository = HomeRepository();
  final AchievementRepository achievementRepository = AchievementRepository();

  DependencyInjector();

  Widget injectStateIntoApp(Widget app) {
    return MultiRepositoryProvider(
      providers: [
        // Provide repositories
        RepositoryProvider<AuthRepository>(create: (context) => authRepository),
        RepositoryProvider<NotificationsRepository>(
          create: (context) => notificationsRepository,
        ),
        RepositoryProvider<HomeRepository>(create: (context) => homeRepository),
        RepositoryProvider<AchievementRepository>(
          create: (context) => achievementRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          // First create AuthBloc so it's available for NavigationCubit
          BlocProvider<AuthBloc>(
            create: (context) {
              // Use repository from provider
              final authRepo = RepositoryProvider.of<AuthRepository>(context);
              final authBloc = AuthBloc(authRepository: authRepo);

              // Check auth status on startup
              authBloc.add(AuthCheckRequested());

              // Initialize the cached auth state right away
              AuthCacheService().updateAuthState(authBloc.state is AuthSuccess);
              return authBloc;
            },
          ),

          // Create MarketplaceBloc
          BlocProvider<MarketplaceBloc>(
            create:
                (context) => MarketplaceBloc(
                  marketplaceRepository: MarketplaceRepositoryImpl(
                    apiService: ApiService(),
                  ),
                ),
          ),

          // Create NotificationsBloc
          BlocProvider<NotificationsBloc>(
            create: (context) {
              return NotificationsBloc(
                notificationsRepository:
                    context.read<NotificationsRepository>(),
              );
            },
          ),

          // Create HomeBloc
          BlocProvider<HomeBloc>(
            create: (context) {
              return HomeBloc(
                homeRepository: context.read<HomeRepository>(),
                achievementRepository: context.read<AchievementRepository>(),
              );
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
              final isLoggedIn = hasLoggedIn(context);
              if (isLoggedIn) {
                navCubit.navigateAfterAuthChange();
              }

              return navCubit;
            },
          ),
        ],
        child: app,
      ),
    );
  }
}

// Helper function to check login status
bool hasLoggedIn(BuildContext context) {
  final authState = context.read<AuthBloc>().state;
  return authState is AuthSuccess;
}
