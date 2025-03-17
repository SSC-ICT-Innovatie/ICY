import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:icy/data/models/user_model.dart';
import 'package:icy/features/authentication/services/auth_navigation_service.dart';
import 'package:icy/features/authentication/state/bloc/auth_bloc.dart';
import 'package:icy/features/profile/widgets/level_progress.dart';
import 'package:icy/features/profile/widgets/stats_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthSuccess) {
          final user = state.user;
          return _buildProfileContent(context, user);
        } else {
          // This shouldn't happen since this screen should only be accessible when logged in
          return Center(child: Text("Not logged in"));
        }
      },
    );
  }

  Widget _buildProfileContent(BuildContext context, UserModel user) {
    return FScaffold(
      header: FHeader(
        title: Text("My Profile"),
        actions: [
          FButton(
            style: FButtonStyle.ghost,
            onPress: () {
              // Show settings dialog or navigate to settings
            },
            label: Text("Settings"),
            prefix: FIcon(FAssets.icons.settings),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildUserHeader(context, user),
            const SizedBox(height: 16),
            if (user.level != null) LevelProgressCard(level: user.level!),
            const SizedBox(height: 16),
            if (user.stats != null) StatsCard(stats: user.stats!),
            const SizedBox(height: 16),
            _buildPreferences(context, user),
            const SizedBox(height: 16),
            FTileGroup(
              children: [
                FTile(
                  title: FButton(
                    onPress: () {
                      AuthNavigationService.logoutAndNavigate(context);
                    },
                    label: Text("Logout"),
                    prefix: FIcon(FAssets.icons.logOut),
                    style: FButtonStyle.destructive,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context, UserModel user) {
    return FTileGroup(
      description: Text("Profile Information"),
      children: [
        FTile(
          prefixIcon: CircleAvatar(
            backgroundImage: NetworkImage(user.avatar),
            radius: 30,
          ),
          title: Text(user.fullName),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.email),
              Text(user.department),
              if (user.level != null) Text(user.level!.title),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreferences(BuildContext context, UserModel user) {
    if (user.preferences == null) return SizedBox();

    return FTileGroup(
      description: Text("Preferences"),
      children: [
        FTile(
          title: Text("Notifications"),
          suffixIcon: Switch(
            value: user.preferences!.notifications,
            onChanged: (value) {
              // Update preferences (would be handled by a BLoC in a full implementation)
            },
          ),
        ),
        FTile(
          title: Text("Daily Reminder"),
          subtitle: Text(user.preferences!.dailyReminderTime),
        ),
        FTile(
          title: Text("Language"),
          subtitle: Text(user.preferences!.language),
        ),
        FTile(title: Text("Theme"), subtitle: Text(user.preferences!.theme)),
      ],
    );
  }
}
