import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:icy/abstractions/navigation/state/navigation_cubit.dart';
import 'package:icy/abstractions/utils/validation_constants.dart';
import 'package:icy/features/authentication/state/bloc/auth_bloc.dart';
import 'package:icy/tabs.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Add listener to update UI when name changes
    _name.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _name.removeListener(_onNameChanged);
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    // This will trigger a rebuild whenever the name changes
    setState(() {});
  }

  // Function to get user initials from their name
  String _getInitials() {
    final name = _name.text.trim();
    if (name.isEmpty) return '';

    final parts = name.split(' ');
    if (parts.length == 1) {
      // Only one name, take the first character
      return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '';
    } else {
      // Multiple names, take first character of first and last name
      String firstInitial =
          parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '';
      String lastInitial =
          parts.last.isNotEmpty ? parts.last[0].toUpperCase() : '';
      return '$firstInitial$lastInitial';
    }
  }

  void _showErrorDialog(String message) {
    showAdaptiveDialog(
      context: context,
      builder:
          (context) => FDialog(
            direction: Axis.horizontal,
            title: const Text('Registration Error'),
            body: Text(message),
            actions: [
              FButton(
                style: FButtonStyle.outline,
                label: const Text('OK'),
                onPress: () => Navigator.of(context).pop(),
              ),
            ],
          ),
    );
  }

  void _signup() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Default avatar ID (can be customized later)
        final avatarId = '1';

        // Dispatch signup event to auth bloc
        context.read<AuthBloc>().add(
          AuthSignUpRequested(
            name: _name.text,
            email: _email.text,
            password: _password.text,
            avatarId: avatarId,
            department: 'ICT', // Default department
          ),
        );
      } catch (e) {
        print('Signup error: $e');

        // Show error dialog
        if (mounted) {
          _showErrorDialog('Registration failed: ${e.toString()}');
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get initials for avatar
    final initials = _getInitials();

    return FScaffold(
      resizeToAvoidBottomInset: true,
      header: FHeader(title: Text("Create Account")),
      content: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            final navCubit = context.read<NavigationCubit>();
            // Refresh tabs with new auth state
            navCubit.refreshTabs(injectNavigationTabs(context));
          } else if (state is AuthFailure) {
            // Show error dialog
            _showErrorDialog(state.message);
          }
        },
        builder: (context, state) {
          return state is AuthLoading || _isLoading
              ? const Center(child: CircularProgressIndicator.adaptive())
              : SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // New avatar implementation
                      const SizedBox(height: 24),
                      FAvatar(
                        image: null,
                      size: 64,
                        fallback: Text(
                          initials,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FTileGroup(
                          description: const Text(
                            "Enter your information to create an account",
                          ),
                          children: [
                            FTile(
                              title: const Text("Full Name"),
                              subtitle: FTextField(
                                autocorrect: false,
                                controller: _name,
                                label: const SizedBox(),
                                hint: 'Enter your full name',
                                validator: ValidationConstants.validateName,
                              ),
                            ),
                            FTile(
                              title: const Text("Email"),
                              subtitle: FTextField.email(
                                controller: _email,
                                autocorrect: false,
                                label: const SizedBox(),
                                hint: 'Enter your work email',
                                validator: ValidationConstants.validateEmail,
                              ),
                            ),
                            FTile(
                              title: const Text("Password"),
                              subtitle: FTextField.password(
                                autocorrect: false,
                                controller: _password,
                                label: const SizedBox(),
                                hint: 'Create a secure password',
                                validator: ValidationConstants.validatePassword,
                              ),
                            ),
                            FTile(
                              title: FButton(
                                onPress: _signup,
                                label: const Text("Create Account"),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          // Navigate to login screen
                          context
                              .read<NavigationCubit>()
                              .changeVisibleTabByIndex(0);
                        },
                        child: const Text("Already have an account? Login"),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              );
        },
      ),
    );
  }
}
