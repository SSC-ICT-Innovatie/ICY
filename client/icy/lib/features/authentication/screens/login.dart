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

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      resizeToAvoidBottomInset: false,
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
            // Clear any error message
            setState(() {
              _errorMessage = null;
            });

            final navCubit = context.read<NavigationCubit>();
            // Refresh tabs with new auth state
            navCubit.refreshTabs(injectNavigationTabs(context));
          } else if (state is AuthFailure) {
            // Update error message state instead of showing SnackBar
            setState(() {
              _errorMessage = state.message;
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
                  // Error message display
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
                          Icon(Icons.error_outline, color: Colors.red),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(color: Colors.red.shade900),
                            ),
                          ),
                        ],
                      ),
                    ),

                  state is AuthLoading
                      ? Center(child: CircularProgressIndicator.adaptive())
                      : Form(
                        key: _formKey,
                        child: FTileGroup(
                          children: [
                            FTile(
                              title: Text("Email"),
                              subtitle: FTextField.email(
                                controller: _email,
                                autocorrect: false,
                                label: SizedBox(),
                                validator: ValidationConstants.validateEmail,
                              ),
                            ),
                            FTile(
                              title: Text("Password"),
                              subtitle: FTextField.password(
                                controller: _password,
                                autocorrect: false,
                                label: SizedBox(),
                                validator: ValidationConstants.validatePassword,
                              ),
                            ),
                            FTile(
                              title: FButton(
                                onPress: () {
                                  if (_formKey.currentState?.validate() ??
                                      false) {
                                    context.read<AuthBloc>().add(
                                      AuthLogin(
                                        email: _email.text,
                                        password: _password.text,
                                      ),
                                    );
                                  }
                                },
                                label: Text("Login"),
                              ),
                            ),
                          ],
                        ),
                      ),

                  FButton(
                    style: FButtonStyle.ghost,
                    onPress: () {
                      // Navigate to login screen
                      context.read<NavigationCubit>().changeVisibleTabByIndex(
                        1,
                      );
                    },
                    label: const Text("Already have an account? Login"),
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
