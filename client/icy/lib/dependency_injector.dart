import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icy/abstractions/navigation/state/navigation_cubit.dart';
import 'package:icy/data/repositories/achievement_repository.dart';
import 'package:icy/data/repositories/department_repository.dart';
import 'package:icy/data/repositories/survey_repository.dart';
import 'package:icy/features/achievements/bloc/achievements_bloc.dart';
import 'package:icy/features/admin/bloc/admin_bloc.dart';
import 'package:icy/features/admin/repositories/admin_repository.dart';
import 'package:icy/features/authentication/state/bloc/auth_bloc.dart';
import 'package:icy/features/home/bloc/home_bloc.dart';
import 'package:icy/features/home/repositories/home_repository.dart';
import 'package:icy/features/marketplace/bloc/marketplace_bloc.dart';
import 'package:icy/features/marketplace/repository/marketplace_repository_impl.dart';
import 'package:icy/features/notifications/bloc/notifications_bloc.dart';
import 'package:icy/features/notifications/repository/notifications_repository.dart';
import 'package:icy/features/profile/bloc/user_preferences_bloc.dart';
import 'package:icy/features/settings/bloc/settings_bloc.dart';
import 'package:icy/services/api_service.dart';
import 'package:icy/services/notification_service.dart';
import 'package:icy/tabs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DependencyInjector {
  Future<Widget> injectStateIntoApp(Widget app) async {
    final prefs = await SharedPreferences.getInstance();

    // Initialize notification service with the updated class name
    final notificationService = SystemNotificationService();
    await notificationService.initialize();

    // Create shared repositories
    final apiService = ApiService();
    final departmentRepository = DepartmentRepository(apiService: apiService);
    final surveyRepository = SurveyRepository(apiService: apiService);
    final adminRepository = AdminRepository(apiService: apiService);

    // Create the admin bloc with its dependencies
    final adminBloc = AdminBloc(
      adminRepository: adminRepository,
      departmentRepository: departmentRepository,
      surveyRepository: surveyRepository,
    );

    return MultiBlocProvider(
      providers: [
        // Create AuthBloc first as it's needed by NavigationCubit
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(),
          lazy: false, // Ensure it's created immediately
        ),

        // We no longer create SettingsBloc here since it's created at the root level
        // Instead, we'll reuse the existing one

        // Add UserPreferencesBloc for profile settings with the updated class reference
        BlocProvider<UserPreferencesBloc>(
          create:
              (context) => UserPreferencesBloc(
                prefs: prefs,
                notificationService: notificationService,
              ),
          lazy: false,
        ),

        // Admin Bloc - Set lazy to false to initialize immediately
        BlocProvider<AdminBloc>(
          create: (context) => adminBloc,
          lazy:
              false, // Important: Create immediately to avoid initialization issues
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

        BlocProvider<HomeBloc>(
          create:
              (context) => HomeBloc(
                // Get the SettingsBloc from the context because it's defined at the root
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
