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
            final navCubit = context.read<NavigationCubit>();
            // Refresh tabs with new auth state
            navCubit.refreshTabs(injectNavigationTabs(context));
          } else if (state is AuthFailure) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return state is AuthLoading
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
                          if (_formKey.currentState?.validate() ?? false) {
                            // Use the new updated auth event with email and password
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
              );
        },
      ),
    );
  }
}
