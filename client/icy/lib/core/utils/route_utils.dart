import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/single_child_widget.dart';

class RouteUtils {
  /// Creates a route that maintains the BlocProviders from the parent context
  static Route<T> createRouteWithBloc<T>({
    required BuildContext parentContext,
    required Widget child,
    List<SingleChildWidget> extraProviders = const [],
  }) {
    return MaterialPageRoute<T>(
      builder: (context) {
        // Gather all needed providers from parent context
        final providers = <SingleChildWidget>[...extraProviders];

        return MultiBlocProvider(providers: providers, child: child);
      },
    );
  }
}
