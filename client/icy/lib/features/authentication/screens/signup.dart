import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      resizeToAvoidBottomInset: false,
      header: FHeader(title: Text("Signup")),
      content: FTileGroup(
        label: Text("Start by creating an account"),
        children: [
          FTile(
            title: Text("Email"),
            subtitle: FTextField.email(autocorrect: false, label: SizedBox()),
          ),

          FTile(
            title: Text("Password"),
            subtitle: FTextField.password(
              autocorrect: false,
              label: SizedBox(),
            ),
          ),
          FTile(
            title: FButton(onPress: () {}, label: Text("Create an account")),
          ),
        ],
      ),
    );
  }
}
