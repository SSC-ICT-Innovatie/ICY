import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:icy/features/authentication/models/user.dart';
import 'package:icy/features/authentication/state/bloc/auth_bloc.dart';
import 'package:icy/features/authentication/widgets/random_avatar.dart';

class SignupScreen extends StatelessWidget {
  SignupScreen({super.key});

  final RandomAvatarPick _avatar = RandomAvatarPick();

  @override
  Widget build(BuildContext context) {
    TextEditingController name = TextEditingController();
    TextEditingController email = TextEditingController();
    TextEditingController password = TextEditingController();

    print("Avatar id: ${_avatar.count}");

    return FScaffold(
      resizeToAvoidBottomInset: false,
      header: FHeader(title: Text("Signup")),
      content:
          context.watch<AuthBloc>().state is AuthLoading
              ? Center(child: CircularProgressIndicator.adaptive())
              : Column(
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
                            controller: name,
                            label: SizedBox(),
                          ),
                        ),
                        FTile(
                          title: Text("Email"),
                          subtitle: FTextField.email(
                            controller: email,
                            autocorrect: false,
                            label: SizedBox(),
                          ),
                        ),
                        FTile(
                          title: Text("Password"),
                          subtitle: FTextField.password(
                            autocorrect: false,
                            controller: password,
                            label: SizedBox(),
                          ),
                        ),
                        FTile(
                          title: FButton(
                            onPress: () {
                              print("Name: ${name.text}");
                              print("Email: ${email.text}");
                              print("Password: ${password.text}");

                              // In het echt zou ik deze methode koppelen aan een backend API.
                              context.watch<AuthBloc>().add(
                                SignUp(
                                  user: User(
                                    id: UniqueKey().toString(),
                                    email: email.text,
                                    name: name.text,
                                    photoUrl: _avatar.count.toString(),
                                  ),
                                ),
                              );
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
  }
}
