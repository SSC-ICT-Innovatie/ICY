import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
      content: FTileGroup(
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
          FTile(title: FButton(onPress: () {}, label: Text("Login"))),
        ],
      ),
    );
  }
}
