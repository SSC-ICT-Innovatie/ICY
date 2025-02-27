import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icy/abstractions/navigation/state/navigation_cubit.dart';
import 'package:icy/abstractions/navigation/services/icy_tab_registerar.dart';

class DependencyInjector {
  static Future<List<BlocProvider>> getProviders() async {
    final tabs = await injectNavigationTabs();

    return [
      BlocProvider<NavigationCubit>(create: (context) => NavigationCubit(tabs)),
      // other providers can come here
    ];
  }
}
