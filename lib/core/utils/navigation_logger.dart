import 'package:flutter/material.dart';
import 'package:balaji_points/core/utils/app_logger.dart';

/// Navigation Observer that automatically logs all route changes
/// 
/// This observer tracks:
/// - Route pushes (navigation to new screen)
/// - Route pops (back navigation)
/// - Route replacements
/// 
/// Usage in MaterialApp:
/// ```dart
/// MaterialApp(
///   navigatorObservers: [NavigationLogger()],
///   ...
/// )
/// ```
class NavigationLogger extends RouteObserver<PageRoute<dynamic>> {
  
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    
    final routeName = _getRouteName(route);
    final previousRouteName = previousRoute != null ? _getRouteName(previousRoute) : 'None';
    
    AppLogger.navigation(
      routeName,
      action: 'pushed',
      extra: 'from: $previousRouteName',
    );
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    
    final routeName = _getRouteName(route);
    final previousRouteName = previousRoute != null ? _getRouteName(previousRoute) : 'None';
    
    AppLogger.navigation(
      routeName,
      action: 'popped',
      extra: 'back to: $previousRouteName',
    );
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    
    final newRouteName = newRoute != null ? _getRouteName(newRoute) : 'Unknown';
    final oldRouteName = oldRoute != null ? _getRouteName(oldRoute) : 'Unknown';
    
    AppLogger.navigation(
      newRouteName,
      action: 'replaced',
      extra: 'from: $oldRouteName',
    );
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    
    final routeName = _getRouteName(route);
    
    AppLogger.navigation(
      routeName,
      action: 'removed',
    );
  }

  /// Extract route name from route settings
  String _getRouteName(Route<dynamic> route) {
    if (route.settings.name != null) {
      return route.settings.name!;
    }
    
    // Try to extract from route type
    final routeType = route.runtimeType.toString();
    return routeType.replaceAll('PageRoute', '').replaceAll('Route', '');
  }
}
