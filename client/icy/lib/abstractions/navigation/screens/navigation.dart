import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:icy/abstractions/navigation/state/navigation_cubit.dart';
import 'package:icy/abstractions/navigation/state/navigation_state.dart';
import 'package:icy/abstractions/navigation/services/icy_tab_registerar.dart';

class IceNavigation extends StatelessWidget {
  const IceNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NavigationCubit, NavigationState>(
      listenWhen:
          (previous, current) =>
              previous.tabs != current.tabs ||
              previous.currentIndex != current.currentIndex,
      listener: (context, state) {
        // This ensures tab changes are properly recognized
        print("Navigation state changed: current tab ${state.currentIndex}");
      },
      buildWhen:
          (previous, current) =>
              previous.tabs != current.tabs ||
              previous.currentIndex != current.currentIndex,
      builder: (context, state) {
        final navigationCubit = context.read<NavigationCubit>();
        final currentTab = navigationCubit.currentTab;
        final visibleTabs = navigationCubit.getVisibleTabs();
        final currentVisibleIndex = navigationCubit.getCurrentVisibleIndex();

        // Debug output
        print("Visible tabs: ${visibleTabs.map((t) => t.title).join(', ')}");
        print(
          "Current tab: ${currentTab.title}, visible index: $currentVisibleIndex",
        );

        return FScaffold(
          contentPad: false,
          content: currentTab.content,
          footer: _buildNavigationBar(
            context,
            visibleTabs,
            currentVisibleIndex >= 0 ? currentVisibleIndex : 0,
          ),
        );
      },
    );
  }

  Widget _buildNavigationBar(
    BuildContext context,
    List<IcyTab> visibleTabs,
    int currentVisibleIndex,
  ) {
    if (visibleTabs.isEmpty) return const SizedBox.shrink();

    return FBottomNavigationBar(
      index:
          currentVisibleIndex >= 0 && currentVisibleIndex < visibleTabs.length
              ? currentVisibleIndex
              : 0,
      onChange: (index) {
        final navCubit = context.read<NavigationCubit>();
        print("Tab pressed: $index (of ${visibleTabs.length})");
        navCubit.changeVisibleTabByIndex(index);
      },
      children:
          visibleTabs
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
