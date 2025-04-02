import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:icy/abstractions/navigation/screens/navigation.dart';
import 'package:icy/abstractions/navigation/state/navigation_cubit.dart';
import 'package:icy/abstractions/utils/constants.dart';
import 'package:icy/dependency_injector.dart';
import 'package:icy/features/authentication/state/bloc/auth_bloc.dart';
import 'package:icy/features/settings/bloc/settings_bloc.dart';
import 'package:icy/services/app_initialization_service.dart';
import 'package:icy/tabs.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // Initialize all services
  await AppInitializationService.initialize();

  // Initialize AppConstants theme cache
  await AppConstants().initThemeCache();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(child: CircularProgressIndicator.adaptive()),
            ),
          );
        }

        if (snapshot.hasError) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: Text('Error initializing app: ${snapshot.error}'),
              ),
            ),
          );
        }

        // Create SettingsBloc first
        return BlocProvider(
          create: (context) => SettingsBloc(prefs: snapshot.data!),
          child: const AppWithSettings(),
        );
      },
    );
  }
}

class AppWithSettings extends StatelessWidget {
  const AppWithSettings({super.key});

  @override
  Widget build(BuildContext context) {
    // Now we can safely access the SettingsBloc
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) {
        return FutureBuilder<Widget>(
          future: DependencyInjector().injectStateIntoApp(
            const AuthStateListener(child: IceNavigation()),
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const MaterialApp(
                debugShowCheckedModeBanner: false,
                home: Scaffold(
                  body: Center(child: CircularProgressIndicator.adaptive()),
                ),
              );
            }

            if (snapshot.hasError) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                home: Scaffold(
                  body: Center(
                    child: Text('Error initializing app: ${snapshot.error}'),
                  ),
                ),
              );
            }

            // Determine theme mode based on settings
            ThemeMode themeMode = ThemeMode.system;
            if (!settingsState.useSystemTheme) {
              themeMode =
                  settingsState.isDarkMode ? ThemeMode.dark : ThemeMode.light;
            }

            return MaterialApp(
              title: 'ICY App',
              themeMode: themeMode,
              debugShowCheckedModeBanner: false,
              home: snapshot.data,
              builder: (context, child) {
                // Safely wrap in a null check
                if (child == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                return FTheme(
                  data:
                      AppConstants().isLight(context)
                          ? FThemes.orange.light.copyWith()
                          : FThemes.orange.dark.copyWith(),
                  child: child,
                );
              },
            );
          },
        );
      },
    );
  }
}

class AuthStateListener extends StatelessWidget {
  final Widget child;

  const AuthStateListener({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen:
          (previous, current) => previous.runtimeType != current.runtimeType,
      listener: (context, state) {
        // Refresh navigation when auth state changes
        if (state is AuthSuccess || state is AuthInitial) {
          try {
            final navCubit = context.read<NavigationCubit>();
            navCubit.refreshTabs(injectNavigationTabs(context));
          } catch (e) {
            print('Error updating navigation: $e');
          }
        }
      },
      child: child,
    );
  }
}
