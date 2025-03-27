import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:icy/features/settings/bloc/settings_bloc.dart';

class ThemeProvider extends StatelessWidget {
  final Widget child;

  const ThemeProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      buildWhen:
          (previous, current) =>
              previous.isDarkMode != current.isDarkMode ||
              previous.useSystemTheme != current.useSystemTheme,
      builder: (context, state) {
        final platformBrightness = MediaQuery.platformBrightnessOf(context);

        // Determine if we should use dark mode based on settings
        final useDarkMode =
            state.useSystemTheme
                ? platformBrightness == Brightness.dark
                : state.isDarkMode;

        return Builder(
          builder:
              (context) => FTheme(
                data:
                    !useDarkMode
                        ? FThemes.orange.light.copyWith()
                        : FThemes.orange.dark.copyWith(),
                child: child,
              ),
        );
      },
    );
  }
}
