import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:icy/abstractions/navigation/screens/navigation.dart';
import 'package:icy/dependency_injector.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final providers = await DependencyInjector.getProviders();
  
  runApp(
    MultiBlocProvider(
      providers: providers,
      child: FTheme(
        data: FThemes.zinc.light, 
        child: const IceNavigation()
      ),
    )
  );
}

