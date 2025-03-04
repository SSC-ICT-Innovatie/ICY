import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:icy/abstractions/navigation/screens/navigation.dart';
import 'package:icy/abstractions/navigation/state/navigation_cubit.dart';
import 'package:icy/abstractions/utils/constants.dart';
import 'package:icy/dependency_injector.dart';
import 'package:icy/features/authentication/state/bloc/auth_bloc.dart';
import 'package:icy/tabs.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(
      (await getTemporaryDirectory()).path,
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FTheme(
        data:
            AppConstants().isLight(context)
                ? FThemes.orange.light
                : FThemes.orange.dark,
        child: DependencyInjector().injectStateIntoApp(
          const AuthStateListener(child: IceNavigation()),
        ),
      ),
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
          final navCubit = context.read<NavigationCubit>();
          navCubit.refreshTabs(injectNavigationTabs(context));
        }
      },
      child: child,
    );
  }
}
