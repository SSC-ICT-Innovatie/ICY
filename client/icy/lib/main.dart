import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:icy/abstractions/navigation/screens/navigation.dart';
import 'package:icy/abstractions/navigation/state/navigation_cubit.dart';
import 'package:icy/abstractions/utils/constants.dart';
import 'package:icy/dependency_injector.dart';
import 'package:icy/features/authentication/state/bloc/auth_bloc.dart';
import 'package:icy/services/app_initialization_service.dart';
import 'package:icy/tabs.dart';

void main() async {
  // Initialize all services
  await AppInitializationService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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

        return MaterialApp(
          title: 'ICY App',
          themeMode: ThemeMode.system,
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
