import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:icy/abstractions/navigation/widgets/modal_wrapper.dart';
import 'package:icy/core/utils/widget_utils.dart';
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
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      context.read<HomeBloc>().add(LoadHomeData(userId: authState.user.id));
    }
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
          // Extract header to a separate widget
          header: HomeHeader(user: user, primaryColor: primaryColor),

          content: RefreshIndicator(
            onRefresh: () async {
              _loadHomeData();
              return Future.delayed(const Duration(seconds: 1));
            },
            child: BlocBuilder<HomeBloc, HomeState>(
              builder: (context, homeState) {
                return Scrollbar(
                  child: Column(
                    children: [
                      // Extract daily challenge to a separate widget
                      DailyChallengeCard(primaryColor: primaryColor),

                      // Extract tab section to a separate widget
                      const Expanded(child: HomeTabSection()),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
