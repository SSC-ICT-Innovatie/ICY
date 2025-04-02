import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:icy/abstractions/navigation/services/icy_tab_registerar.dart';
import 'package:icy/features/achievements/screens/achievement_page.dart';
import 'package:icy/features/admin/screens/admin_dashboard.dart';
import 'package:icy/features/authentication/screens/login.dart';
import 'package:icy/features/authentication/screens/signup.dart';
import 'package:icy/features/authentication/services/auth_cache_service.dart';
import 'package:icy/features/home/screens/home_screen.dart';
import 'package:icy/features/marketplace/screens/marketplace_screen.dart';
import 'package:icy/features/profile/screens/profile_screen.dart';

bool hasLoggedIn(BuildContext context) {
  return AuthCacheService().checkLoggedIn(context);
}

/// Check if the current user is an admin
bool isAdmin(BuildContext context) {
  try {
    final authService = AuthCacheService();
    if (!authService.isLoggedIn) return false;

    // Get user role from auth state
    final userRole = authService.getUserRole(context);
    return userRole == 'admin';
  } catch (e) {
    print('Error checking admin status: $e');
    return false;
  }
}

/// Register all navigation tabs here
List<IcyTab> injectNavigationTabs(BuildContext context) {
  final isLoggedIn = hasLoggedIn(context);
  final isAdminUser = isAdmin(context);

  // Clear debug info
  print("Building tabs, user logged in: $isLoggedIn, isAdmin: $isAdminUser");

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

    // Admin tab (only visible for admins)
    IcyTab(
      showInTabBar: isLoggedIn && isAdminUser,
      icon: FAssets.icons.settings,
      title: "Admin",
      content: AdminDashboard(),
      accessRule: () => AuthCacheService().isLoggedIn && isAdmin(context),
    ),

    // App content tabs (only visible when the person has logged in)
    IcyTab(
      showInTabBar: isLoggedIn,
      icon: FAssets.icons.house,
      title: "Home",
      content: HomeScreen(),
      accessRule: () => AuthCacheService().isLoggedIn,
    ),
    IcyTab(
      showInTabBar: isLoggedIn,
      icon: FAssets.icons.trophy,
      title: "Achievements",
      content: isAdminUser ? Container() : AchievementPage(),
      accessRule: () => AuthCacheService().isLoggedIn,
    ),
    IcyTab(
      showInTabBar: isLoggedIn,
      icon: FAssets.icons.store,
      title: "Marketplace",
      content: MarketplaceScreen(),
      accessRule: () => AuthCacheService().isLoggedIn,
    ),
    IcyTab(
      showInTabBar: isLoggedIn,
      icon: FAssets.icons.user,
      title: "Profile",
      content: ProfileScreen(),
      accessRule: () => AuthCacheService().isLoggedIn,
    ),
  ];
}
