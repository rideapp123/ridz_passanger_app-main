import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';

class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Pop current route from Global NavigatorState
  void pop([value]) {
    return navigatorKey.currentState!.pop(value);
  }

  /// Pop navigation stack excluding the given [routeName]
  /// This will navigate us back to the [routeName]
  void popUntil(String routeNamed) {
    return navigatorKey.currentState!.popUntil(
      ModalRoute.withName(routeNamed),
    );
  }

  void pushNameAndRemoveUntil(String routeNamed) {
    navigatorKey.currentState!.pushNamedAndRemoveUntil(
      routeNamed,
      (route) => false,
    );
  }

  Future<dynamic> navigateTo(
    String routeName, {
    Map<String, dynamic>? arguments,
  }) {
    return navigatorKey.currentState!.pushNamed(
      routeName,
      arguments: arguments,
    );
  }

  Future<dynamic> transitionPushTo(
      {required Widget page, required PageTransitionType transitionType}) {
    return navigatorKey.currentState!.push(
      PageTransition(
        type: transitionType,
        settings: RouteSettings(name: page.toString()),
        duration: const Duration(milliseconds: 600),
        curve: Curves.ease,
        child: page,
      ),
    );
  }

  Future<dynamic> transitionPushOnboarding(
      {required Widget page, required PageTransitionType transitionType}) {
    return navigatorKey.currentState!.push(
      PageTransition(
        type: transitionType,
        settings: RouteSettings(name: page.toString()),
        duration: const Duration(milliseconds: 300),
        child: page,
      ),
    );
  }

  Future<dynamic> transitionPushAndRemoveUntil(
      {required Widget page, required PageTransitionType transitionType}) {
    return navigatorKey.currentState!.pushAndRemoveUntil(
      PageTransition(
        type: transitionType,
        duration: const Duration(milliseconds: 500),
        child: page,
      ),
      (route) => false,
    );
  }

  void transitionPopUntil(
      {required Widget page, required PageTransitionType transitionType}) {
    return navigatorKey.currentState!
        .popUntil(ModalRoute.withName(page.toString()));
  }

  /// Navigate to a specific tab on the main page.
  /// TODO: Implement when MainPage route is available.
  void navigateToMainPageTab(int tabIndex) {}

  /// Replaces current active route in navigation stack with new route
  Future<dynamic> replaceWith(
    String routeName, {
    Map<String, dynamic>? arguments,
  }) {
    return navigatorKey.currentState!.pushReplacementNamed(
      routeName,
      arguments: arguments,
    );
  }

  /// Refreshes the given route by clearing out the navigation stack and pushing
  /// a new route.
  ///
  /// If provided [arguments] will be sent as well.
  ///
  /// The typical use case for this is for navigating to a route and providing
  /// the initial state for Widgets or controllers such as ExpandedTileList,
  /// PageView, DefaultTabController and etc.
  ///
  /// Any previous information or opened routes are cleared and disposed of before
  /// pushing a new route.
  void refreshWith(
    String routeName, {
    Map<String, dynamic>? arguments,
  }) {
    navigatorKey.currentState!.popUntil((route) => false);
    navigateTo(routeName, arguments: arguments);
  }
}

/// An observer class that hides the keyboard everytime a page is changed.
class KeyboardStateNavigatorObserver extends NavigatorObserver {
  void _hideKeyboard() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    _hideKeyboard();
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    _hideKeyboard();
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    _hideKeyboard();
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    _hideKeyboard();
  }
}
