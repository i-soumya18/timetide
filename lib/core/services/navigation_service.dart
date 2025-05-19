import 'package:flutter/material.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  NavigatorState? get navigator => navigatorKey.currentState;

  Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    return navigator!.pushNamed(routeName, arguments: arguments);
  }

  Future<dynamic> navigateToReplacement(String routeName, {Object? arguments}) {
    return navigator!.pushReplacementNamed(routeName, arguments: arguments);
  }

  Future<dynamic> navigateToAndClearStack(String routeName,
      {Object? arguments}) {
    return navigator!.pushNamedAndRemoveUntil(
      routeName,
      (Route<dynamic> route) => false,
      arguments: arguments,
    );
  }

  Future<void> navigateBack() {
    navigator!.pop();
    return Future.value();
  }

  Future<void> navigateBackUntil(String routeName) {
    navigator!.popUntil(ModalRoute.withName(routeName));
    return Future.value();
  }

  Future<void> navigateBackWithResult(dynamic result) {
    navigator!.pop(result);
    return Future.value();
  }

  Future<dynamic> navigateToWithResult(String routeName,
      {Object? arguments}) async {
    return await navigator!.pushNamed(routeName, arguments: arguments);
  }
}
