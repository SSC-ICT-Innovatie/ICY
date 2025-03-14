import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:forui/widgets/scaffold.dart';
import 'package:icy/features/authentication/state/bloc/auth_bloc.dart';
import 'package:icy/features/home/bloc/home_bloc.dart';
import 'package:icy/features/home/widgets/daily_challenge_card.dart';
import 'package:icy/features/home/widgets/home_header.dart';
import 'package:icy/features/home/widgets/home_tab_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load home data when screen initializes
    _loadHomeData();
  }

  void _loadHomeData() {
    // Use LoadHome event instead of LoadHomeData for API compatibility
    context.read<HomeBloc>().add(const LoadHome());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthSuccess) {
          return const Center(child: Text('Please log in'));
        }

        final user = authState.user;
        // Use amber as the primary accent color
        final Color primaryColor = Colors.amber.shade700;

        return FScaffold(
          contentPad: false,
          content: RefreshIndicator(
            onRefresh: () async {
              _loadHomeData();
              return Future.delayed(const Duration(seconds: 1));
            },
            child: BlocBuilder<HomeBloc, HomeState>(
              builder: (context, homeState) {
                return CustomScrollView(
                  slivers: [
                    // SliverAppBar with HomeHeader
                    SliverAppBar(
                      backgroundColor: context.theme.colorScheme.primary,
                      expandedHeight: 200.0,
                      pinned: true,
                      flexibleSpace: FlexibleSpaceBar(
                        background: HomeHeader(
                          user: user,
                          primaryColor: primaryColor,
                        ),
                      ),

                      title: Padding(
                        padding: context.theme.scaffoldStyle.contentPadding,
                        child: Text(
                          'Icy',
                          style: context
                              .theme
                              .headerStyle
                              .rootStyle
                              .titleTextStyle
                              .copyWith(color: Colors.white),
                        ),
                      ),
                      titleSpacing: 0,
                      centerTitle: false,
                    ),

                    SliverToBoxAdapter(
                      child: DailyChallengeCard(
                        primaryColor: primaryColor,
                        onTap: () {},
                      ),
                    ),

                    // SliverFillRemaining for the tab section content
                    SliverFillRemaining(
                      hasScrollBody: true,
                      child: HomeTabSection(),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
