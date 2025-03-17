import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:icy/abstractions/navigation/screens/navigation.dart';
import 'package:icy/abstractions/navigation/state/navigation_cubit.dart';
import 'package:icy/abstractions/utils/constants.dart';
import 'package:icy/abstractions/utils/db_migration_util.dart';
import 'package:icy/dependency_injector.dart';
import 'package:icy/features/authentication/state/bloc/auth_bloc.dart';
import 'package:icy/services/api_service.dart';
import 'package:icy/tabs.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize HydratedBloc for state persistence
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(
      (await getTemporaryDirectory()).path,
    ),
  );

  // Initialize API service
  final apiService = ApiService();
  await apiService.init();

  // Check if we need to migrate data
  final dbMigrationUtil = DbMigrationUtil(apiService: apiService);
  await dbMigrationUtil.migrateIfNeeded();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: DependencyInjector().injectStateIntoApp(
        const AuthStateListener(child: IceNavigation()),
      ),
      builder:
          (context, child) => FTheme(
            data:
                AppConstants().isLight(context)
                    ? FThemes.orange.light.copyWith(
                      // scaffoldStyle: context.theme.scaffoldStyle.copyWith(
                      //   // backgroundColor: Colors.white,
                      // ),
                      // cardStyle: context.theme.cardStyle.copyWith(
                      //   // contentStyle: context.theme.cardStyle.contentStyle
                      //   //     .copyWith(padding: EdgeInsets.zero),
                      // ),
                    )
                    : FThemes.orange.dark.copyWith(
                      // scaffoldStyle: context.theme.scaffoldStyle.copyWith(
                      //   // backgroundColor: Colors.grey.shade900,
                      // ),
                      // cardStyle: context.theme.cardStyle.copyWith(
                      //   decoration: context.theme.cardStyle.decoration.copyWith(
                      //     // color: Colors.grey.shade800,
                      //     // border: Border.all(color: Colors.grey.shade900),
                      //   ),
                      //   contentStyle: context.theme.cardStyle.contentStyle
                      //       .copyWith(padding: EdgeInsets.zero),
                      // ),
                    ),
            child: child!,
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
      listenWhen:
          (previous, current) => previous.runtimeType != current.runtimeType,
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
