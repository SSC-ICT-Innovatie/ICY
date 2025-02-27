import 'package:icy/abstractions/navigation/services/icy_tab_registerar.dart';

/// Register all navigation tabs here
/// This is the only function developers need to modify to add new tabs
Future<List<IcyTab>> injectNavigationTabs() async {
  return [
    // Example:
    // IcyTab(
    //   icon: FAssets.icons.house,
    //   title: "Home",
    //   content: Container(color: Colors.pink),
    //   // Optional auth rule example:
    //   // accessRule: () => AuthService.isLoggedIn,
    //   // fallbackContent: LoginPage(),
    // ),

    // IcyTab(
    //   icon: FAssets.icons.search,
    //   title: "Home",
    //   content: Container(color: Colors.blue),
    //   // Optional auth rule example:
    //   // accessRule: () => AuthService.isLoggedIn,
    //   // fallbackContent: LoginPage(),
    // ),
    // Add more tabs as needed
  ];
}
