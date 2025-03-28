import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:icy/data/models/user_model.dart';
import 'package:icy/features/authentication/services/auth_navigation_service.dart';
import 'package:icy/features/authentication/state/bloc/auth_bloc.dart';
import 'package:icy/features/profile/bloc/user_preferences_bloc.dart';
import 'package:icy/features/profile/widgets/level_progress.dart';
import 'package:icy/features/profile/widgets/stats_card.dart';
import 'package:icy/features/settings/screens/settings_screen.dart';
import 'package:icy/services/notification_service.dart'; // Import the system notification service

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
          return const Center(child: Text("Not logged in"));
        }
      },
    );
  }

  Widget _buildProfileContent(BuildContext context, UserModel user) {
    return FScaffold(
      header: FHeader(
        title: const Text("My Profile"),
        actions: [
          FButton(
            style: FButtonStyle.ghost,
            onPress: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            label: const Text("Settings"),
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
            _buildUserPreferences(context, user),
            const SizedBox(height: 16),
            FTileGroup(
              children: [
                FTile(
                  title: FButton(
                    onPress: () {
                      AuthNavigationService.logoutAndNavigate(context);
                    },
                    label: const Text("Logout"),
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
      description: const Text("Profile Information"),
      children: [
        FTile(
          prefixIcon: _buildAvatarWithErrorHandling(user.avatar),
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

  // New method to safely load user avatar with error handling
  Widget _buildAvatarWithErrorHandling(String avatarUrl) {
    return CircleAvatar(
      radius: 30,
      backgroundColor: Colors.grey.shade200,
      child: ClipOval(
        child: SizedBox(
          width: 60,
          height: 60,
          child: Image.network(
            avatarUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Show fallback icon on error
              return const Icon(Icons.person, size: 40, color: Colors.grey);
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value:
                      loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Updated to use UserPreferencesBloc
  Widget _buildUserPreferences(BuildContext context, UserModel user) {
    return BlocBuilder<UserPreferencesBloc, UserPreferencesState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return FTileGroup(
          description: const Text("Preferences"),
          children: [
            FTile(
              title: const Text("Notifications"),
              subtitle: const Text("Enable app notifications"),
              suffixIcon: _buildCustomSwitch(
                context,
                value: state.notificationsEnabled,
                onChanged: (value) {
                  context.read<UserPreferencesBloc>().add(
                    ToggleNotificationsEvent(enabled: value),
                  );

                  // Test notification when enabled
                  if (value) {
                    _sendTestNotification(context);
                  }
                },
              ),
            ),
            FTile(
              title: const Text("Daily Reminder"),
              subtitle: Text("Time: ${state.dailyReminderTime}"),
              suffixIcon: const Icon(Icons.access_time),
              onPress:
                  () => _showTimePickerDialog(context, state.dailyReminderTime),
            ),
            // Remove unused language picker dialog call
            FTile(
              title: const Text("Language"),
              subtitle: Text(state.language),
              suffixIcon: const Icon(Icons.language),
            ),
            // Remove unused theme picker dialog call
            FTile(
              title: const Text("Theme"),
              subtitle: Text(state.theme),
              suffixIcon: const Icon(Icons.brightness_4),
            ),
            // Add a test notification button
            if (state.notificationsEnabled)
              FTile(
                title: const Text("Test Notification"),
                subtitle: const Text("Send a test notification"),
                suffixIcon: const Icon(Icons.notifications_active),
                onPress: () => _sendTestNotification(context),
              ),
          ],
        );
      },
    );
  }

  // Add a helper method to test notifications, with clear commenting about which service is used
  void _sendTestNotification(BuildContext context) async {
    // Using SystemNotificationService for device-level notifications
    final notificationService = SystemNotificationService();
    await notificationService.showNotification(
      id: 999,
      title: 'Test Notification',
      body: 'This is a test notification from ICY!',
    );

    // Show feedback to user
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Test notification sent!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Keep only the time picker dialog since it's being used
  void _showTimePickerDialog(BuildContext context, String currentTime) async {
    // Parse the current time string (format: "HH:mm")
    final parts = currentTime.split(':');
    int hour = 9;
    int minute = 0;

    if (parts.length == 2) {
      hour = int.tryParse(parts[0]) ?? 9;
      minute = int.tryParse(parts[1]) ?? 0;
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: minute),
    );

    if (picked != null) {
      // Format as "HH:mm"
      final formattedTime =
          '${picked.hour.toString().padLeft(2, '0')}:'
          '${picked.minute.toString().padLeft(2, '0')}';

      context.read<UserPreferencesBloc>().add(
        SetDailyReminderTimeEvent(time: formattedTime),
      );
    }
  }

  Widget _buildCustomSwitch(
    BuildContext context, {
    required bool value,
    required Function(bool) onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 50,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color:
              value
                  ? context.theme.colorScheme.primary
                  : Colors.grey.withOpacity(0.3),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              left: value ? 20 : 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
