import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icy/features/settings/bloc/settings_bloc.dart';
import 'package:icy/features/authentication/services/auth_navigation_service.dart';
import 'package:icy/core/utils/color_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Try to get the existing SettingsBloc if available
    SettingsBloc? existingBloc;
    try {
      existingBloc = context.read<SettingsBloc>();
    } catch (e) {
      print('No SettingsBloc available in context, will create a new one');
    }

    // If we can't get the existing bloc, wrap with a new provider
    if (existingBloc == null) {
      return FutureBuilder<SharedPreferences>(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return BlocProvider(
            create: (context) => SettingsBloc(prefs: snapshot.data!),
            child: _SettingsScreenContent(),
          );
        },
      );
    }

    // Use existing bloc if available
    return _SettingsScreenContent();
  }
}

// Extract the content into a separate widget to avoid duplication
class _SettingsScreenContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return FScaffold(
          header: FHeader(
            title: const Text('Settings'),
            actions: [
              FButton(
                style: FButtonStyle.ghost,
                onPress: () {
                  Navigator.of(context).pop();
                },
                label: const Text('Done'),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildAppearanceSection(context, state),
                const SizedBox(height: 16),
                _buildNotificationsSection(context, state),
                const SizedBox(height: 16),
                _buildAboutSection(context),
                const SizedBox(height: 16),
                _buildLogoutSection(context),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppearanceSection(BuildContext context, SettingsState state) {
    return FTileGroup(
      description: const Text("Appearance"),
      children: [
        FTile(
          title: const Text("Dark Mode"),
          subtitle: const Text("Change app theme"),
          suffixIcon: _buildCustomSwitch(
            context,
            value: state.isDarkMode,
            onChanged: (value) {
              context.read<SettingsBloc>().add(
                ToggleThemeEvent(isDarkMode: value),
              );
            },
          ),
        ),
        FTile(
          title: const Text("System Theme"),
          subtitle: const Text("Match device theme settings"),
          suffixIcon: _buildCustomSwitch(
            context,
            value: state.useSystemTheme,
            onChanged: (value) {
              context.read<SettingsBloc>().add(
                ToggleUseSystemThemeEvent(useSystemTheme: value),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationsSection(BuildContext context, SettingsState state) {
    return FTileGroup(
      description: const Text("Notifications"),
      children: [
        FTile(
          title: const Text("Push Notifications"),
          subtitle: const Text("Receive all app notifications"),
          suffixIcon: _buildCustomSwitch(
            context,
            value: state.notificationsEnabled,
            onChanged: (value) {
              context.read<SettingsBloc>().add(
                ToggleNotificationsEvent(enabled: value),
              );
            },
          ),
        ),
        FTile(
          title: const Text("Survey Reminders"),
          subtitle: const Text("Get reminded about daily surveys"),
          suffixIcon: _buildCustomSwitch(
            context,
            value: state.surveyRemindersEnabled,
            onChanged: (value) {
              context.read<SettingsBloc>().add(
                ToggleSurveyRemindersEvent(enabled: value),
              );
            },
          ),
        ),
        FTile(
          title: const Text("Reminder Time"),
          subtitle: Text("Current time: ${state.reminderTime}"),
          onPress: () {
            _showTimePickerDialog(context);
          },
          suffixIcon: Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return FTileGroup(
      description: const Text("About"),
      children: [
        FTile(
          title: const Text("Version"),
          subtitle: const Text("1.0.0 (Build 100)"),
        ),
        FTile(
          title: const Text("Terms of Service"),
          onPress: () {
            _showTermsDialog(context);
          },
          suffixIcon: Icon(Icons.chevron_right),
        ),
        FTile(
          title: const Text("Privacy Policy"),
          onPress: () {
            _showPrivacyPolicyDialog(context);
          },
          suffixIcon: Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  Widget _buildLogoutSection(BuildContext context) {
    return FTileGroup(
      children: [
        FTile(
          title: FButton(
            style: FButtonStyle.destructive,
            onPress: () {
              AuthNavigationService.logoutAndNavigate(context);
            },
            label: const Text("Log Out"),
            prefix: FIcon(FAssets.icons.logOut),
          ),
        ),
      ],
    );
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
                  : ColorUtils.applyOpacity(Colors.grey, 0.3),
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
                      color: ColorUtils.applyOpacity(Colors.black, 0.1),
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

  void _showTimePickerDialog(BuildContext context) {
    // Get the current reminder time from state
    final currentTime = context.read<SettingsBloc>().state.reminderTime;

    // Parse the current time string (format: "HH:mm")
    final parts = currentTime.split(':');
    int hour = 9;
    int minute = 0;

    if (parts.length == 2) {
      hour = int.tryParse(parts[0]) ?? 9;
      minute = int.tryParse(parts[1]) ?? 0;
    }

    showAdaptiveDialog(
      context: context,
      builder:
          (dialogContext) => FDialog(
            direction: Axis.horizontal,
            title: const Text('Set Reminder Time'),
            body: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Choose when you want to receive daily reminders"),
                const SizedBox(height: 16),
                FTextField(
                  label: const Text('Time'),
                  readOnly: true,
                  initialValue: currentTime, // Use the current time from state
                  suffixBuilder:
                      (context, value, child) => const Icon(Icons.access_time),
                  onTap: () async {
                    // Use the parsed current time for initial value
                    final TimeOfDay? time = await showTimePicker(
                      context: dialogContext,
                      initialTime: TimeOfDay(hour: hour, minute: minute),
                    );

                    if (time != null) {
                      // Format as "HH:mm"
                      final formattedTime =
                          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

                      // Dispatch the event to update the time
                      context.read<SettingsBloc>().add(
                        SetReminderTimeEvent(time: formattedTime),
                      );

                      // Close the dialog after setting the time
                      Navigator.of(dialogContext).pop();
                    }
                  },
                ),
              ],
            ),
            actions: [
              FButton(
                style: FButtonStyle.outline,
                label: const Text('Cancel'),
                onPress: () => Navigator.of(dialogContext).pop(),
              ),
              FButton(
                label: const Text('Save'),
                onPress: () => Navigator.of(dialogContext).pop(),
              ),
            ],
          ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showAdaptiveDialog(
      context: context,
      builder:
          (context) => FDialog(
            direction: Axis.horizontal,
            title: const Text('Terms of Service'),
            body: const SingleChildScrollView(
              child: Text(
                'These are the Terms of Service for the ICY application. By using this application, you agree to these terms.\n\n'
                'The application is provided "as is" without warranty of any kind, either express or implied, including but not limited to the implied warranties of merchantability and fitness for a particular purpose.\n\n'
                'The company reserves the right to modify these terms at any time, and such modifications shall be effective immediately upon posting of the modified terms.',
              ),
            ),
            actions: [
              FButton(
                label: const Text('Close'),
                onPress: () => Navigator.of(context).pop(),
              ),
            ],
          ),
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
    showAdaptiveDialog(
      context: context,
      builder:
          (context) => FDialog(
            direction: Axis.horizontal,
            title: const Text('Privacy Policy'),
            body: const SingleChildScrollView(
              child: Text(
                'This Privacy Policy describes how your personal information is collected, used, and shared when you use the ICY application.\n\n'
                'We collect information that you provide directly to us, such as your name, email address, and other information you choose to provide.\n\n'
                'We use the information we collect to provide, maintain, and improve our services, to develop new ones, and to protect our company and users.',
              ),
            ),
            actions: [
              FButton(
                label: const Text('Close'),
                onPress: () => Navigator.of(context).pop(),
              ),
            ],
          ),
    );
  }
}
