import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:icy/abstractions/navigation/state/navigation_cubit.dart';
import 'package:icy/abstractions/utils/validation_constants.dart';
import 'package:icy/features/authentication/state/bloc/auth_bloc.dart';
import 'package:icy/tabs.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Keep track of error message state
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _showErrorDialog(String message) {
    showAdaptiveDialog(
      context: context,
      builder:
          (context) => FDialog(
            direction: Axis.horizontal,
            title: const Text('Login Error'),
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

  void _showAdminLoginInfo() {
    showAdaptiveDialog(
      context: context,
      builder:
          (context) => FDialog(
            direction: Axis.horizontal,
            title: const Text('Admin Login'),
            body: const Text(
              'Administrator accounts have elevated privileges. '
              'Please enter your admin email and password to continue.',
            ),
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

  void _login() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      context.read<AuthBloc>().add(
        AuthLogin(email: _email.text, password: _password.text),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      resizeToAvoidBottomInset: true,
      header: FHeader(
        title: Text("Login"),
        actions: [
          FButton(
            style: FButtonStyle.ghost,
            onPress: () {
              launchUrl(Uri.parse("https://www.ssc-ict.nl/"));
            },
            label: Text("Forgot Password?"),
          ),
        ],
      ),
      content: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            // Clear error message and loading state
            setState(() {
              _errorMessage = null;
              _isLoading = false;
            });

            final navCubit = context.read<NavigationCubit>();
            // Refresh tabs with new auth state
            navCubit.refreshTabs(injectNavigationTabs(context));
          } else if (state is AuthFailure) {
            // Show error dialog instead of inline message
            _showErrorDialog(state.message);
            setState(() {
              _isLoading = false;
            });
          } else if (state is AuthLoading) {
            setState(() {
              _isLoading = true;
            });
          } else {
            setState(() {
              _isLoading = false;
            });
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  // App logo or branding
                  Center(
                    child: Icon(
                      Icons.eco_outlined,
                      size: 80,
                      color: context.theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      "ICY Application",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Error message display (optional backup)
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade300),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(color: Colors.red.shade900),
                            ),
                          ),
                        ],
                      ),
                    ),

                  Form(
                    key: _formKey,
                    child: FTileGroup(
                      children: [
                        FTile(
                          title: const Text("Email"),
                          subtitle: FTextField.email(
                            controller: _email,
                            autocorrect: false,
                            label: const SizedBox(),
                            hint: "Enter your email",
                            validator: ValidationConstants.validateEmail,
                          ),
                        ),
                        FTile(
                          title: const Text("Password"),
                          subtitle: FTextField.password(
                            controller: _password,
                            autocorrect: false,
                            label: const SizedBox(),
                            hint: "Enter your password",
                            validator: ValidationConstants.validatePassword,
                          ),
                        ),
                        FTile(
                          title: FButton(
                            onPress: _isLoading ? null : _login,
                            label:
                                _isLoading
                                    ? const CircularProgressIndicator.adaptive()
                                    : const Text("Login"),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  FButton(
                    style: FButtonStyle.ghost,
                    onPress: () {
                      // Navigate to signup screen
                      context.read<NavigationCubit>().changeVisibleTabByIndex(
                        1,
                      );
                    },
                    label: const Text("Don't have an account? Register now"),
                  ),

                  // Add Admin Login Info Button
                  const SizedBox(height: 8),
                  FButton(
                    style: FButtonStyle.ghost,
                    onPress: _showAdminLoginInfo,
                    label: const Text("Administrator Login"),
                    prefix: FIcon(FAssets.icons.shield),
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
