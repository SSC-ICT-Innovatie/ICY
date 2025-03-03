import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:icy/abstractions/navigation/screens/navigation.dart';
import 'package:icy/abstractions/utils/constants.dart';
import 'package:icy/dependency_injector.dart';
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
        child: DependencyInjector().injectStateIntoApp(const IceNavigation()),
      ),
    );
  }
}
