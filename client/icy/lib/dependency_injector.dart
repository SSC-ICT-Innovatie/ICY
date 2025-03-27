import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icy/abstractions/navigation/state/navigation_cubit.dart';
import 'package:icy/data/repositories/achievement_repository.dart';
import 'package:icy/features/achievements/bloc/achievements_bloc.dart';
import 'package:icy/features/authentication/state/bloc/auth_bloc.dart';
import 'package:icy/features/home/bloc/home_bloc.dart';
import 'package:icy/features/home/repositories/home_repository.dart';
import 'package:icy/features/marketplace/bloc/marketplace_bloc.dart';
import 'package:icy/features/marketplace/repository/marketplace_repository_impl.dart';
import 'package:icy/features/notifications/bloc/notifications_bloc.dart';
import 'package:icy/features/notifications/repository/notifications_repository.dart';
import 'package:icy/features/settings/bloc/settings_bloc.dart';
import 'package:icy/services/api_service.dart';
import 'package:icy/tabs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DependencyInjector {
  Future<Widget> injectStateIntoApp(Widget app) async {
    final prefs = await SharedPreferences.getInstance();


    

    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingsBloc>(
          create: (context) => SettingsBloc(prefs: prefs),
        ),
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
        BlocProvider<AuthBloc>(create: (context) => AuthBloc()),

        BlocProvider<HomeBloc>(
          create:
              (context) => HomeBloc(
                context.read<SettingsBloc>(),
                homeRepository: HomeRepository(),
                achievementRepository: AchievementRepository(),
              ),
        ),

        BlocProvider<AchievementsBloc>(
          create:
              (context) => AchievementsBloc(
                achievementRepository: AchievementRepository(),
              ),
        ),

        BlocProvider<NotificationsBloc>(
          create:
              (context) => NotificationsBloc(
                notificationsRepository: NotificationsRepository(),
              ),
        ),

        BlocProvider<MarketplaceBloc>(
          create:
              (context) => MarketplaceBloc(
                marketplaceRepository: MarketplaceRepositoryImpl(
                  apiService: ApiService(),
                ),
              ),
        ),
      ],
      child: app,
    );
  }

  static Future<Widget> injectStateIntoAppStatic(Widget app) async {
    final injector = DependencyInjector();
    return injector.injectStateIntoApp(app);
  }
}




