import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:icy/abstractions/navigation/state/navigation_cubit.dart';
import 'package:icy/abstractions/utils/validation_constants.dart';
import 'package:icy/features/authentication/models/user.dart';
import 'package:icy/features/authentication/state/bloc/auth_bloc.dart';
import 'package:icy/features/authentication/widgets/random_avatar.dart';
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
  late final RandomAvatarPick _avatar;
  
  @override
  void initState() {
    super.initState();
    _avatar = RandomAvatarPick();
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("Avatar id: ${_avatar.count}");

    return FScaffold(
      resizeToAvoidBottomInset: false,
      header: FHeader(title: Text("Signup")),
      content: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            final navCubit = context.read<NavigationCubit>();
            // Refresh tabs with new auth state
            navCubit.refreshTabs(injectNavigationTabs(context));
          }
        },
        builder: (context, state) {
          return state is AuthLoading
              ? Center(child: CircularProgressIndicator.adaptive())
              : Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _avatar,
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FTileGroup(
                          description: Text("Start by creating an account"),
                          children: [
                            FTile(
                              title: Text("Name"),
                              subtitle: FTextField(
                                autocorrect: false,
                                controller: _name,
                                label: SizedBox(),
                                validator: ValidationConstants.validateName,
                              ),
                            ),
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
                                autocorrect: false,
                                controller: _password,
                                label: SizedBox(),
                                validator: ValidationConstants.validatePassword,
                              ),
                            ),
                            FTile(
                              title: FButton(
                                onPress: () {
                                  if (_formKey.currentState?.validate() ?? false) {
                                    print("Name: ${_name.text}");
                                    print("Email: ${_email.text}");
                                    print("Password: ${_password.text}");

                                    // Use read instead of watch for event handlers
                                    context.read<AuthBloc>().add(
                                      SignUp(
                                        user: User(
                                          id: UniqueKey().toString(),
                                          email: _email.text,
                                          name: _name.text,
                                          photoUrl: _avatar.count.toString(),
                                        ),
                                      ),
                                    );
                                  }
                                },
                                label: Text("Create an account"),
                              ),
                            ),
                          ],
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
