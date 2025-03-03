import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:icy/abstractions/navigation/services/icy_tab_registerar.dart';
import 'package:icy/features/authentication/screens/login.dart';
import 'package:icy/features/authentication/screens/signup.dart';

import 'features/authentication/state/bloc/auth_bloc.dart';
// rules//regels als boolean warden

bool hasLoggedIn(BuildContext context) {
  final stateValue = Bloc;
  print(
    "Authentication receipt ${stateValue is AuthSuccess ? stateValue : null}",
  );
  return stateValue is AuthSuccess;
}

/// Register all navigation tabs here
/// This is the only function developers need to modify to add new tabs
List<IcyTab> injectNavigationTabs() {
  return [
    IcyTab(icon: FAssets.icons.lock, title: "Login", content: LoginScreen()),
    IcyTab(icon: FAssets.icons.user, title: "Signup", content: SignupScreen()),
    IcyTab(
      showInTabBar: false,
      icon: FAssets.icons.house,
      title: "Home",
      content: Container(color: Colors.pink),
    ),

    IcyTab(
      showInTabBar: hasLoggedIn(context),
      icon: FAssets.icons.search,
      title: "Search",
      content: Container(color: Colors.blue),
    ),
    IcyTab(
      showInTabBar: hasLoggedIn(context),
      icon: FAssets.icons.testTube,
      title: "Test",
      content: Container(color: Colors.orange),
    ),
  ];
}
