import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:icy/abstractions/navigation/services/icy_tab_registerar.dart';
import 'package:icy/features/authentication/screens/login.dart';
import 'package:icy/features/authentication/screens/signup.dart';
import 'package:icy/features/authentication/services/auth_cache_service.dart';


// Function that dynamically checks login status using the current context
bool hasLoggedIn(BuildContext context) {
  return AuthCacheService().checkLoggedIn(context);
}

/// Register all navigation tabs here
List<IcyTab> injectNavigationTabs(BuildContext context) {
  final isLoggedIn = hasLoggedIn(context);

  // Clear debug info
  print("Building tabs, user logged in: $isLoggedIn");

  return [
    // Authentication tabs (only visible when logged out)
    IcyTab(
      showInTabBar: !isLoggedIn,
      icon: FAssets.icons.lock,
      title: "Login",
      content: LoginScreen(),
      // Use the cached value for access rules
      accessRule: () => !AuthCacheService().isLoggedIn,
    ),
    IcyTab(
      showInTabBar: !isLoggedIn,
      icon: FAssets.icons.user,
      title: "Signup",
      content: SignupScreen(),
      // Use the cached value for access rules
      accessRule: () => !AuthCacheService().isLoggedIn,
    ),

    // App content tabs (only visible when logged in)
    IcyTab(
      showInTabBar: isLoggedIn,
      icon: FAssets.icons.house,
      title: "Home",
      content: Container(
        color: Colors.pink,
        child: Center(
          child: Text(
            "HOME SCREEN",
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
        ),
      ),
      // Use the cached value for access rules
      accessRule: () => AuthCacheService().isLoggedIn,
    ),
    IcyTab(
      showInTabBar: isLoggedIn,
      icon: FAssets.icons.search,
      title: "Search",
      content: Container(
        color: Colors.blue,
        child: Center(
          child: Text(
            "SEARCH SCREEN",
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
        ),
      ),
      // Use the cached value for access rules
      accessRule: () => AuthCacheService().isLoggedIn,
    ),
    IcyTab(
      showInTabBar: isLoggedIn,
      icon: FAssets.icons.testTube,
      title: "Test",
      content: Container(
        color: Colors.orange,
        child: Center(
          child: Text(
            "TEST SCREEN",
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
        ),
      ),
      // Use the cached value for access rules
      accessRule: () => AuthCacheService().isLoggedIn,
    ),
  ];
}
