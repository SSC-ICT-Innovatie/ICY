import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// IcyTab - Define a navigation tab in the application
class IcyTab {
  /// Icon for the tab
  final SvgAsset icon;

  /// Title of the tab
  final String title;

  /// Widget to display when tab is selected
  final Widget content;

  /// Whether to show this tab in the navigation bar
  final bool showInTabBar;

  /// Custom rules for when this tab should be accessible
  /// Return true to allow access, false to deny
  /// Examples:
  /// - () => isUserLoggedIn()
  /// - () => userHasPermission('admin')
  final bool Function()? accessRule;

  /// Fallback widget to display when access is denied
  /// If not provided, the tab will be hidden when access is denied
  final Widget? fallbackContent;

  IcyTab({
    required this.icon,
    required this.title,
    required this.content,
    this.showInTabBar = true,
    this.accessRule,
    this.fallbackContent,
  });

  bool canAccess() {
    return accessRule == null || accessRule!();
  }

  /// Get the content to display based on access permissions
  Widget getContent() {
    if (canAccess()) {
      return content;
    } else if (fallbackContent != null) {
      return fallbackContent!;
    } else {
      // Default fallback if none specified
      return Center(child: Text("Access denied to '$title'"));
    }
  }
}

/// Register all navigation tabs here
/// This is the only function developers need to modify to add new tabs
Future<List<IcyTab>> injectNavigationTabs() async {
  return [
    // Example:
    IcyTab(
      icon: FAssets.icons.house,
      title: "Home",
      content: Container(color: Colors.pink),
      // Optional auth rule example:
      // accessRule: () => AuthService.isLoggedIn,
      // fallbackContent: LoginPage(),
    ),

    IcyTab(
      icon: FAssets.icons.search,
      title: "Home",
      content: Container(color: Colors.blue),
      // Optional auth rule example:
      // accessRule: () => AuthService.isLoggedIn,
      // fallbackContent: LoginPage(),
    ),
    // Add more tabs as needed
  ];
}
