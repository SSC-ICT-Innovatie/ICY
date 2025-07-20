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
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize all services and resources in parallel
  final futures = await Future.wait([
    AppInitializationService.initialize(),
    AppConstants().initThemeCache(),
    SharedPreferences.getInstance(),
  ]);
  
  // Extract SharedPreferences from futures
  final sharedPreferences = futures[2] as SharedPreferences;
  
  runApp(MyApp(sharedPreferences: sharedPreferences));
}

class MyApp extends StatelessWidget {
  final SharedPreferences sharedPreferences;
  
  const MyApp({required this.sharedPreferences, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsBloc(prefs: sharedPreferences),
      child: const AppWithSettings(),
    );
  }
}

class AppWithSettings extends StatelessWidget {
  const AppWithSettings({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the SettingsBloc
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) {
        // Determine theme mode based on settings
        ThemeMode themeMode = ThemeMode.system;
        if (!settingsState.useSystemTheme) {
          themeMode = settingsState.isDarkMode ? ThemeMode.dark : ThemeMode.light;
        }

        return MaterialApp(
          title: 'ICY App',
          themeMode: themeMode,
          debugShowCheckedModeBanner: false,
          home: DependencyInjectorWidget(),
          builder: (context, child) {
            // Safely wrap in a null check
            if (child == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return FTheme(
              data: AppConstants().isLight(context)
                  ? FThemes.blue.light.copyWith()
                  : FThemes.blue.dark.copyWith(),
              child: child,
            );
          },
        );
      },
    );
  }
}

class DependencyInjectorWidget extends StatelessWidget {
  const DependencyInjectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: DependencyInjector().injectStateIntoApp(
        const AuthStateListener(child: IceNavigation()),
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return  FScaffold(
            content: Center(child: CircularProgressIndicator.adaptive()),
          );
        }

        if (snapshot.hasError) {
          return FScaffold(
            content: Center(
              child: Text('Error initializing app: ${snapshot.error}'),
            ),
          );
        }

        return snapshot.data ??  FScaffold(
            content: Center(child: Text('Failed to load application')),
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
      listenWhen: (previous, current) => previous.runtimeType != current.runtimeType,
      listener: (context, state) {
        // Refresh navigation when auth state changes
        if (state is AuthSuccess || state is AuthInitial) {
          try {
            final navCubit = context.read<NavigationCubit>();
            navCubit.refreshTabs(injectNavigationTabs(context));
          } catch (e) {
            debugPrint('Error updating navigation: $e');
          }
        }
      },
      child: child,
    );
  }
}
