import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:icy/abstractions/navigation/state/navigation_cubit.dart';
import 'package:icy/abstractions/navigation/state/navigation_state.dart';
import 'package:icy/icy_tab_registerar.dart';

class IceNavigation extends StatelessWidget {
  const IceNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, NavigationState>(
      builder: (context, state) {
        final navigationCubit = context.read<NavigationCubit>();
        final currentTab = navigationCubit.currentTab;
        final visibleTabs = navigationCubit.visibleTabs;

        return FScaffold(
          contentPad: false,
          content: currentTab.content,
          footer: _buildNavigationBar(context, visibleTabs, state.currentIndex),
        );
      },
    );
  }

  Widget _buildNavigationBar(
    BuildContext context,
    List<IcyTab> tabs,
    int currentIndex,
  ) {
    if (tabs.isEmpty) return const SizedBox.shrink();

    return FBottomNavigationBar(
      index: currentIndex,
      onChange: (index) => context.read<NavigationCubit>().changeTab(index),
      children:
          tabs
              .map(
                (tab) => FBottomNavigationBarItem(
                  icon: FIcon(tab.icon),
                  label: Text(tab.title),
                ),
              )
              .toList(),
    );
  }
}
