import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:icy/abstractions/navigation/services/icy_tab_registerar.dart';
import 'package:icy/features/authentication/screens/login.dart';
import 'package:icy/features/authentication/screens/signup.dart';
import 'package:icy/features/authentication/services/auth_cache_service.dart';
import 'package:icy/features/home/screens/home_screen.dart';

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
      content: HomeScreen(),
      // Use the cached value for access rules
      accessRule: () => AuthCacheService().isLoggedIn,
    ),
    IcyTab(
      showInTabBar: isLoggedIn,
      icon: FAssets.icons.trophy,
      title: "Achievements",
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
      icon: FAssets.icons.store,
      title: "Marketplace",
      content: Container(
        color: Colors.orange,
        child: Center(
          child: Text(
            "Marketplace",
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
        ),
      ),
      // Use the cached value for access rules
      accessRule: () => AuthCacheService().isLoggedIn,
    ),
    IcyTab(
      showInTabBar: isLoggedIn,
      icon: FAssets.icons.user,
      title: "Profile",
      content: Container(
        color: Colors.orange,
        child: Center(
          child: Text(
            "Profile",
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
        ),
      ),
      // Use the cached value for access rules
      accessRule: () => AuthCacheService().isLoggedIn,
    ),
  ];
}
