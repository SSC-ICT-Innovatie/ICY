import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icy/abstractions/navigation/state/navigation_cubit.dart';
import 'package:icy/features/authentication/state/bloc/auth_bloc.dart';
import 'package:icy/tabs.dart';

class DependencyInjector {
  DependencyInjector();
  Widget injectStateIntoApp(Widget app) {
    final tabs = injectNavigationTabs();

    return MultiBlocProvider(
      providers: [
        BlocProvider<NavigationCubit>(
          create: (context) => NavigationCubit(tabs),
        ),

        BlocProvider<AuthBloc>(create: (context) => AuthBloc()),
      ],

      child: app,
    );
  }
}
