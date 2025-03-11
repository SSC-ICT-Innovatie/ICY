import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:icy/abstractions/navigation/widgets/modal_wrapper.dart';
import 'package:icy/features/home/bloc/home_bloc.dart';
import 'package:icy/features/home/pages/tabs/today.dart';
import 'package:icy/features/home/pages/tabs/ongoing_survey.dart';
import 'package:icy/features/home/pages/tabs/results.dart';

class HomeTabSection extends StatefulWidget {
  const HomeTabSection({Key? key}) : super(key: key);

  @override
  State<HomeTabSection> createState() => _HomeTabSectionState();
}

class _HomeTabSectionState extends State<HomeTabSection> {
  int _currentTabIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, homeState) {
        return Column(
          children: [
            // Tab header with buttons
            SizedBox(
              height: 50,
              child: Row(
                children: [
                  Expanded(
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      children: [
                        _buildTabButton(0, "Today", _currentTabIndex == 0),
                        const SizedBox(width: 8),
                        _buildTabButton(1, "Ongoing", _currentTabIndex == 1),
                        const SizedBox(width: 8),
                        _buildTabButton(2, "Results", _currentTabIndex == 2),
                        const SizedBox(width: 16),
                        FButton(
                          onPress: () => _showAllContent(context, homeState),
                          label: const Text("See All"),
                          style: FButtonStyle.ghost,
                          prefix: FIcon(FAssets.icons.layoutDashboard),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // PageView for swiping between tabs
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentTabIndex = index;
                  });
                },
                children: [
                  // Today tab - use SliverList compatible widget
                  NewSurvey(
                    surveys:
                        homeState is HomeLoaded ? homeState.dailySurveys : [],
                  ),

                  // Ongoing tab
                  const OngoingSurvey(),

                  // Results tab
                  const SurveyResults(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // Function to build tab buttons
  Widget _buildTabButton(int index, String label, bool isSelected) {
    return FButton(
      onPress: () {
        setState(() {
          _currentTabIndex = index;
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        });
      },
      style: isSelected ? FButtonStyle.primary : FButtonStyle.secondary,
      label: Text(label),
    );
  }

  // Function to show all content in a modal sheet
  void _showAllContent(BuildContext context, HomeState homeState) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      _showIOSAllContent(context, homeState);
    } else {
      _showAndroidAllContent(context, homeState);
    }
  }

  // Show content in iOS style modal
  void _showIOSAllContent(BuildContext context, HomeState homeState) {
    showCupertinoModalPopup(
      context: context,
      builder:
          (context) => ModalWrapper(
            body: Column(
              children: [
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader("Today"),
                          NewSurvey(
                            surveys:
                                homeState is HomeLoaded
                                    ? homeState.dailySurveys
                                    : [],
                          ),

                          _buildSectionHeader("Ongoing"),
                          const OngoingSurvey(),

                          _buildSectionHeader("Results"),
                          const SurveyResults(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  // Show content in Android style bottom sheet
  void _showAndroidAllContent(BuildContext context, HomeState homeState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.8,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder:
                (context, scrollController) => Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      // Handle
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),

                      // Content
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionHeader("Today"),
                                NewSurvey(
                                  surveys:
                                      homeState is HomeLoaded
                                          ? homeState.dailySurveys
                                          : [],
                                ),

                                _buildSectionHeader("Ongoing"),
                                const OngoingSurvey(),

                                _buildSectionHeader("Results"),
                                const SurveyResults(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  // Helper to build section headers in the all content view
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Divider(),
        ],
      ),
    );
  }
}
